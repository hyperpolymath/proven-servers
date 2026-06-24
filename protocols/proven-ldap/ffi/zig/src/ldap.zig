// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// ldap.zig -- Zig FFI implementation of proven-ldap.
//
// Implements verified LDAP session state machine with:
//   - Slot-based session management (up to 64 concurrent)
//   - State machine enforcement matching Idris2 Transitions.idr
//   - Thread-safe via per-slot mutex pool (64 mutexes)
//   - DN tracking for bind identity
//   - Message ID counter
//   - Result code tracking

const std = @import("std");

// Generated from the proven Idris ABI encoders by tools/gen-abi.sh; the
// comptime guard below pins every enum tag to these, so drift is a build error.
const gen = @import("ldap_abi_gen.zig");

/// ABI version (guarded against gen.ABI_VERSION below).
const ABI_VERSION: u32 = 1;

// -- Enums (matching LDAPABI.Layout.idr tag assignments) ---------------------

/// LDAP session states (4 constructors, tags 0-3).
pub const SessionState = enum(u8) {
    anonymous = 0,
    bound = 1,
    closed = 2,
    binding = 3,
};

/// LDAP operations (10 constructors, tags 0-9).
pub const Operation = enum(u8) {
    bind = 0,
    unbind = 1,
    search = 2,
    modify = 3,
    add = 4,
    delete = 5,
    mod_dn = 6,
    compare = 7,
    abandon = 8,
    extended = 9,
};

/// LDAP search scopes (3 constructors, tags 0-2).
pub const SearchScope = enum(u8) {
    base_object = 0,
    single_level = 1,
    whole_subtree = 2,
};

/// LDAP result codes (11 constructors, tags 0-10).
pub const ResultCode = enum(u8) {
    success = 0,
    operations_error = 1,
    protocol_error = 2,
    time_limit_exceeded = 3,
    size_limit_exceeded = 4,
    auth_method_not_supported = 5,
    no_such_object = 6,
    invalid_credentials = 7,
    insufficient_access_rights = 8,
    busy = 9,
    unavailable = 10,
};

// -- ABI conformance guard ---------------------------------------------------
// Every enum tag MUST equal the generated (= proven Idris) value; a mismatch
// fails `zig build` with the named symbol. Regenerate: bash tools/gen-abi.sh.
comptime {
    if (ABI_VERSION != gen.ABI_VERSION) @compileError("ABI drift: abi_version");

    if (@intFromEnum(SessionState.anonymous) != gen.SESSION_ANONYMOUS) @compileError("ABI drift: SessionState.anonymous");
    if (@intFromEnum(SessionState.bound) != gen.SESSION_BOUND) @compileError("ABI drift: SessionState.bound");
    if (@intFromEnum(SessionState.closed) != gen.SESSION_CLOSED) @compileError("ABI drift: SessionState.closed");
    if (@intFromEnum(SessionState.binding) != gen.SESSION_BINDING) @compileError("ABI drift: SessionState.binding");

    if (@intFromEnum(Operation.bind) != gen.OP_BIND) @compileError("ABI drift: Operation.bind");
    if (@intFromEnum(Operation.unbind) != gen.OP_UNBIND) @compileError("ABI drift: Operation.unbind");
    if (@intFromEnum(Operation.search) != gen.OP_SEARCH) @compileError("ABI drift: Operation.search");
    if (@intFromEnum(Operation.modify) != gen.OP_MODIFY) @compileError("ABI drift: Operation.modify");
    if (@intFromEnum(Operation.add) != gen.OP_ADD) @compileError("ABI drift: Operation.add");
    if (@intFromEnum(Operation.delete) != gen.OP_DELETE) @compileError("ABI drift: Operation.delete");
    if (@intFromEnum(Operation.mod_dn) != gen.OP_MOD_DN) @compileError("ABI drift: Operation.mod_dn");
    if (@intFromEnum(Operation.compare) != gen.OP_COMPARE) @compileError("ABI drift: Operation.compare");
    if (@intFromEnum(Operation.abandon) != gen.OP_ABANDON) @compileError("ABI drift: Operation.abandon");
    if (@intFromEnum(Operation.extended) != gen.OP_EXTENDED) @compileError("ABI drift: Operation.extended");

    if (@intFromEnum(SearchScope.base_object) != gen.SCOPE_BASE_OBJECT) @compileError("ABI drift: SearchScope.base_object");
    if (@intFromEnum(SearchScope.single_level) != gen.SCOPE_SINGLE_LEVEL) @compileError("ABI drift: SearchScope.single_level");
    if (@intFromEnum(SearchScope.whole_subtree) != gen.SCOPE_WHOLE_SUBTREE) @compileError("ABI drift: SearchScope.whole_subtree");

    if (@intFromEnum(ResultCode.success) != gen.RESULT_SUCCESS) @compileError("ABI drift: ResultCode.success");
    if (@intFromEnum(ResultCode.operations_error) != gen.RESULT_OPERATIONS_ERROR) @compileError("ABI drift: ResultCode.operations_error");
    if (@intFromEnum(ResultCode.protocol_error) != gen.RESULT_PROTOCOL_ERROR) @compileError("ABI drift: ResultCode.protocol_error");
    if (@intFromEnum(ResultCode.time_limit_exceeded) != gen.RESULT_TIME_LIMIT_EXCEEDED) @compileError("ABI drift: ResultCode.time_limit_exceeded");
    if (@intFromEnum(ResultCode.size_limit_exceeded) != gen.RESULT_SIZE_LIMIT_EXCEEDED) @compileError("ABI drift: ResultCode.size_limit_exceeded");
    if (@intFromEnum(ResultCode.auth_method_not_supported) != gen.RESULT_AUTH_METHOD_NOT_SUPPORTED) @compileError("ABI drift: ResultCode.auth_method_not_supported");
    if (@intFromEnum(ResultCode.no_such_object) != gen.RESULT_NO_SUCH_OBJECT) @compileError("ABI drift: ResultCode.no_such_object");
    if (@intFromEnum(ResultCode.invalid_credentials) != gen.RESULT_INVALID_CREDENTIALS) @compileError("ABI drift: ResultCode.invalid_credentials");
    if (@intFromEnum(ResultCode.insufficient_access_rights) != gen.RESULT_INSUFFICIENT_ACCESS_RIGHTS) @compileError("ABI drift: ResultCode.insufficient_access_rights");
    if (@intFromEnum(ResultCode.busy) != gen.RESULT_BUSY) @compileError("ABI drift: ResultCode.busy");
    if (@intFromEnum(ResultCode.unavailable) != gen.RESULT_UNAVAILABLE) @compileError("ABI drift: ResultCode.unavailable");
}

// -- LDAP session ------------------------------------------------------------

/// Maximum length for the bind DN.
const MAX_DN_LEN: usize = 2048;

/// An LDAP session slot with all state.
const Session = struct {
    state: SessionState,
    last_result: u8, // ResultCode tag, 255 = none
    message_id: u32, // monotonic counter
    dn_len: u32,
    dn: [MAX_DN_LEN]u8,
    active: bool,
};

const MAX_SESSIONS: usize = 64;

/// Default (inactive) session value.
const DEFAULT_SESSION: Session = .{
    .state = .anonymous,
    .last_result = 255,
    .message_id = 0,
    .dn_len = 0,
    .dn = [_]u8{0} ** MAX_DN_LEN,
    .active = false,
};

var sessions: [MAX_SESSIONS]Session = [_]Session{DEFAULT_SESSION} ** MAX_SESSIONS;

/// Per-slot mutex pool -- avoids global lock contention.
var mutexes: [MAX_SESSIONS]std.Thread.Mutex = [_]std.Thread.Mutex{.{}} ** MAX_SESSIONS;

/// Global mutex for slot allocation only.
var alloc_mutex: std.Thread.Mutex = .{};

/// Lock a per-slot mutex. Returns the index if valid, null otherwise.
fn lockSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    if (!sessions[idx].active) {
        mutexes[idx].unlock();
        return null;
    }
    return idx;
}

/// Unlock a per-slot mutex.
fn unlockSlot(idx: usize) void {
    mutexes[idx].unlock();
}

// -- ABI version ------------------------------------------------------------

pub export fn ldap_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

// -- Lifecycle --------------------------------------------------------------

pub export fn ldap_create() callconv(.c) c_int {
    alloc_mutex.lock();
    defer alloc_mutex.unlock();
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = DEFAULT_SESSION;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

pub export fn ldap_destroy(slot: c_int) callconv(.c) void {
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    sessions[idx].active = false;
}

// -- State queries ----------------------------------------------------------

pub export fn ldap_state(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 2; // closed as fallback
    defer unlockSlot(idx);
    return @intFromEnum(sessions[idx].state);
}

pub export fn ldap_last_result(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 255;
    defer unlockSlot(idx);
    return sessions[idx].last_result;
}

pub export fn ldap_message_id(slot: c_int) callconv(.c) u32 {
    const idx = lockSlot(slot) orelse return 0;
    defer unlockSlot(idx);
    return sessions[idx].message_id;
}

pub export fn ldap_bind_dn(slot: c_int, buf: [*]u8, buf_len: u32) callconv(.c) u32 {
    const idx = lockSlot(slot) orelse return 0;
    defer unlockSlot(idx);
    const copy_len = @min(sessions[idx].dn_len, buf_len);
    @memcpy(buf[0..copy_len], sessions[idx].dn[0..copy_len]);
    return copy_len;
}

// -- Commands: Authentication -----------------------------------------------

pub export fn ldap_bind(slot: c_int, dn: [*]const u8, dn_len: u32, _: [*]const u8, _: u32) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    switch (s.state) {
        .anonymous, .bound => {
            // Store the DN
            const copy_len = @min(dn_len, @as(u32, MAX_DN_LEN));
            @memcpy(s.dn[0..copy_len], dn[0..copy_len]);
            s.dn_len = copy_len;
            s.state = .binding;
            s.message_id +|= 1;
            return 0;
        },
        else => {
            s.last_result = @intFromEnum(ResultCode.protocol_error);
            return 1;
        },
    }
}

pub export fn ldap_bind_complete(slot: c_int, result_tag: u8) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .binding) {
        s.last_result = @intFromEnum(ResultCode.protocol_error);
        return 1;
    }
    s.last_result = result_tag;
    if (result_tag == @intFromEnum(ResultCode.success)) {
        s.state = .bound;
    } else {
        // Bind failed, revert to anonymous
        s.state = .anonymous;
        s.dn_len = 0;
    }
    return 0;
}

pub export fn ldap_unbind(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state == .closed) {
        return 1;
    }
    s.state = .closed;
    s.message_id +|= 1;
    return 0;
}

// -- Commands: Directory operations -----------------------------------------

pub export fn ldap_search(slot: c_int, _: [*]const u8, _: u32, scope: u8) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    // Search allowed from Anonymous or Bound
    switch (s.state) {
        .anonymous, .bound => {},
        else => {
            s.last_result = @intFromEnum(ResultCode.protocol_error);
            return 1;
        },
    }
    // Validate scope tag
    if (scope > 2) {
        s.last_result = @intFromEnum(ResultCode.protocol_error);
        return 2; // bad scope
    }
    s.message_id +|= 1;
    s.last_result = @intFromEnum(ResultCode.success);
    return 0;
}

pub export fn ldap_modify(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .bound) {
        s.last_result = if (s.state == .anonymous)
            @intFromEnum(ResultCode.insufficient_access_rights)
        else
            @intFromEnum(ResultCode.protocol_error);
        return 1;
    }
    s.message_id +|= 1;
    s.last_result = @intFromEnum(ResultCode.success);
    return 0;
}

pub export fn ldap_add(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .bound) {
        s.last_result = if (s.state == .anonymous)
            @intFromEnum(ResultCode.insufficient_access_rights)
        else
            @intFromEnum(ResultCode.protocol_error);
        return 1;
    }
    s.message_id +|= 1;
    s.last_result = @intFromEnum(ResultCode.success);
    return 0;
}

pub export fn ldap_delete(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .bound) {
        s.last_result = if (s.state == .anonymous)
            @intFromEnum(ResultCode.insufficient_access_rights)
        else
            @intFromEnum(ResultCode.protocol_error);
        return 1;
    }
    s.message_id +|= 1;
    s.last_result = @intFromEnum(ResultCode.success);
    return 0;
}

pub export fn ldap_compare(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .bound) {
        s.last_result = if (s.state == .anonymous)
            @intFromEnum(ResultCode.insufficient_access_rights)
        else
            @intFromEnum(ResultCode.protocol_error);
        return 1;
    }
    s.message_id +|= 1;
    s.last_result = @intFromEnum(ResultCode.success);
    return 0;
}

pub export fn ldap_abandon(slot: c_int, _: u32) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    // Abandon allowed from Anonymous or Bound (no state change)
    switch (s.state) {
        .anonymous, .bound => {
            // Abandon has no response and no state change
            return 0;
        },
        else => {
            return 1;
        },
    }
}

// -- Stateless queries ------------------------------------------------------

pub export fn ldap_can_modify(state_tag: u8) callconv(.c) u8 {
    // Only Bound (tag 1) can modify
    return if (state_tag == 1) 1 else 0;
}

pub export fn ldap_can_search(state_tag: u8) callconv(.c) u8 {
    // Anonymous (tag 0) or Bound (tag 1) can search
    return if (state_tag == 0 or state_tag == 1) 1 else 0;
}

pub export fn ldap_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Matches Transitions.idr validateSessionTransition exactly
    if (from == 0 and to == 3) return 1; // Anonymous -> Binding (BeginBind)
    if (from == 0 and to == 0) return 1; // Anonymous -> Anonymous (AnonymousOp)
    if (from == 0 and to == 2) return 1; // Anonymous -> Closed (UnbindAnonymous)
    if (from == 3 and to == 1) return 1; // Binding -> Bound (BindSuccess)
    if (from == 3 and to == 0) return 1; // Binding -> Anonymous (BindFail)
    if (from == 3 and to == 2) return 1; // Binding -> Closed (UnbindBinding)
    if (from == 1 and to == 3) return 1; // Bound -> Binding (ReBind)
    if (from == 1 and to == 1) return 1; // Bound -> Bound (DirectoryOp)
    if (from == 1 and to == 2) return 1; // Bound -> Closed (UnbindBound)
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(mutexes)) > 16 * 1024 * 1024)
        @compileError("pool 'mutexes' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
