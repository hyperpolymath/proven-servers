// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// tacacs.zig -- Zig FFI implementation of proven-tacacs.
//
// Implements the TACACS+ (RFC 8907) AAA session state machine with:
//   - 64-slot mutex-protected session pool
//   - Authentication start/continue/reply tracking
//   - Authorization request/reply tracking
//   - Accounting record tracking (start/stop/watchdog)
//   - Session state machine (Idle -> Authenticating -> Authorizing -> Active -> Closing)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching TACACSABI.Types exactly.

const std = @import("std");

// =========================================================================
// Enums (matching TACACSABI.Types tag assignments)
// =========================================================================

/// TACACS+ packet types (ABI tags 0-2).
pub const PacketType = enum(u8) {
    authentication = 0,
    authorization = 1,
    accounting = 2,
};

/// Authentication method types (ABI tags 0-4).
pub const AuthenType = enum(u8) {
    ascii = 0,
    pap = 1,
    chap = 2,
    mschapv1 = 3,
    mschapv2 = 4,
};

/// Authentication actions (ABI tags 0-2).
pub const AuthenAction = enum(u8) {
    login = 0,
    change_pass = 1,
    send_auth = 2,
};

/// Authentication reply status values (ABI tags 0-7).
pub const AuthenStatus = enum(u8) {
    pass = 0,
    fail = 1,
    get_data = 2,
    get_user = 3,
    get_pass = 4,
    restart = 5,
    authen_error = 6,
    follow = 7,
};

/// Authorization reply status values (ABI tags 0-4).
pub const AuthorStatus = enum(u8) {
    pass_add = 0,
    pass_repl = 1,
    author_fail = 2,
    author_error = 3,
    author_follow = 4,
};

/// Accounting reply status values (ABI tags 0-2).
pub const AcctStatus = enum(u8) {
    acct_success = 0,
    acct_error = 1,
    acct_follow = 2,
};

/// Accounting flags (ABI tags 0-2).
pub const AcctFlag = enum(u8) {
    start = 0,
    stop = 1,
    watchdog = 2,
};

/// Session lifecycle states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    idle = 0,
    authenticating = 1,
    authorizing = 2,
    active = 3,
    closing = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum shared secret length.
const MAX_SECRET_LEN: usize = 128;

/// Maximum username length.
const MAX_USER_LEN: usize = 256;

/// Maximum port/service name length.
const MAX_NAME_LEN: usize = 256;

/// Maximum authentication data length.
const MAX_DATA_LEN: usize = 1024;

/// A TACACS+ session.
const Session = struct {
    /// Current session lifecycle state.
    state: SessionState,
    /// Shared secret for packet obfuscation.
    secret: [MAX_SECRET_LEN]u8,
    secret_len: u32,
    /// Username for the current operation.
    username: [MAX_USER_LEN]u8,
    username_len: u32,
    /// Port identifier.
    port: [MAX_NAME_LEN]u8,
    port_len: u32,
    /// Current authentication type.
    authen_type: AuthenType,
    /// Current authentication action.
    authen_action: AuthenAction,
    /// Last authentication status.
    last_authen_status: AuthenStatus,
    /// Last authorization status.
    last_author_status: AuthorStatus,
    /// Last accounting status.
    last_acct_status: AcctStatus,
    /// Number of authentication rounds completed.
    authen_rounds: u32,
    /// Number of accounting records sent.
    acct_records: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .secret = [_]u8{0} ** MAX_SECRET_LEN,
    .secret_len = 0,
    .username = [_]u8{0} ** MAX_USER_LEN,
    .username_len = 0,
    .port = [_]u8{0} ** MAX_NAME_LEN,
    .port_len = 0,
    .authen_type = .ascii,
    .authen_action = .login,
    .last_authen_status = .fail,
    .last_author_status = .author_fail,
    .last_acct_status = .acct_error,
    .authen_rounds = 0,
    .acct_records = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn tacacs_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new TACACS+ session. Returns slot index (>=0) or -1 on failure.
pub export fn tacacs_create(
    secret_ptr: [*]const u8,
    secret_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (secret_len == 0 or secret_len > MAX_SECRET_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.secret[0..secret_len], secret_ptr[0..secret_len]);
            s.secret_len = secret_len;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn tacacs_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current SessionState tag for a session.
pub export fn tacacs_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle fallback
    return @intFromEnum(sessions[idx].state);
}

/// Start authentication. Returns 0 on success, 1 on rejection.
/// Transitions Idle -> Authenticating.
pub export fn tacacs_authen_start(
    slot: c_int,
    action: u8,
    authen_type: u8,
    user_ptr: [*]const u8,
    user_len: u32,
    port_ptr: [*]const u8,
    port_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .idle) return 1;
    if (action > 2) return 1;
    if (authen_type > 4) return 1;
    if (user_len == 0 or user_len > MAX_USER_LEN) return 1;
    if (port_len > MAX_NAME_LEN) return 1;

    @memcpy(sessions[idx].username[0..user_len], user_ptr[0..user_len]);
    sessions[idx].username_len = user_len;
    if (port_len > 0) {
        @memcpy(sessions[idx].port[0..port_len], port_ptr[0..port_len]);
    }
    sessions[idx].port_len = port_len;
    sessions[idx].authen_action = @enumFromInt(action);
    sessions[idx].authen_type = @enumFromInt(authen_type);
    sessions[idx].last_authen_status = .pass; // Default to pass for simple auth
    sessions[idx].authen_rounds = 1;
    sessions[idx].state = .authenticating;
    return 0;
}

/// Continue multi-step authentication. Returns AuthenStatus tag.
pub export fn tacacs_authen_continue(
    slot: c_int,
    data_ptr: [*]const u8,
    data_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = data_ptr;

    const idx = validSlot(slot) orelse return @intFromEnum(AuthenStatus.authen_error);
    if (sessions[idx].state != .authenticating) return @intFromEnum(AuthenStatus.authen_error);
    if (data_len > MAX_DATA_LEN) return @intFromEnum(AuthenStatus.authen_error);

    sessions[idx].authen_rounds += 1;
    // Simulate: after continue, authentication passes
    sessions[idx].last_authen_status = .pass;
    return @intFromEnum(sessions[idx].last_authen_status);
}

/// Returns last authentication status.
pub export fn tacacs_authen_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return @intFromEnum(AuthenStatus.authen_error);
    return @intFromEnum(sessions[idx].last_authen_status);
}

/// Request authorization. Returns AuthorStatus tag.
/// Transitions Authenticating -> Authorizing.
pub export fn tacacs_author_request(
    slot: c_int,
    user_ptr: [*]const u8,
    user_len: u32,
    service_ptr: [*]const u8,
    service_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = user_ptr;
    _ = service_ptr;

    const idx = validSlot(slot) orelse return @intFromEnum(AuthorStatus.author_error);
    if (sessions[idx].state != .authenticating) return @intFromEnum(AuthorStatus.author_error);
    if (user_len == 0 or user_len > MAX_USER_LEN) return @intFromEnum(AuthorStatus.author_error);
    if (service_len == 0 or service_len > MAX_NAME_LEN) return @intFromEnum(AuthorStatus.author_error);

    sessions[idx].last_author_status = .pass_add;
    sessions[idx].state = .authorizing;
    return @intFromEnum(sessions[idx].last_author_status);
}

/// Returns last authorization status.
pub export fn tacacs_author_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return @intFromEnum(AuthorStatus.author_error);
    return @intFromEnum(sessions[idx].last_author_status);
}

/// Send an accounting record. Returns AcctStatus tag.
/// Transitions Authorizing -> Active on first record.
pub export fn tacacs_acct_record(
    slot: c_int,
    flag: u8,
    user_ptr: [*]const u8,
    user_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = user_ptr;

    const idx = validSlot(slot) orelse return @intFromEnum(AcctStatus.acct_error);
    if (sessions[idx].state != .authorizing and sessions[idx].state != .active)
        return @intFromEnum(AcctStatus.acct_error);
    if (flag > 2) return @intFromEnum(AcctStatus.acct_error);
    if (user_len == 0 or user_len > MAX_USER_LEN) return @intFromEnum(AcctStatus.acct_error);

    sessions[idx].acct_records += 1;
    sessions[idx].last_acct_status = .acct_success;
    if (sessions[idx].state == .authorizing) {
        sessions[idx].state = .active;
    }
    return @intFromEnum(sessions[idx].last_acct_status);
}

/// Returns last accounting status.
pub export fn tacacs_acct_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return @intFromEnum(AcctStatus.acct_error);
    return @intFromEnum(sessions[idx].last_acct_status);
}

/// Disconnect the session. Returns 0 on success, 1 on rejection.
pub export fn tacacs_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .authenticating or state == .authorizing or state == .active) {
        sessions[idx].state = .closing;
        return 0;
    }
    return 1;
}

/// Complete cleanup after disconnect. Returns 0 on success, 1 on rejection.
pub export fn tacacs_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .closing) return 1;

    sessions[idx].state = .idle;
    sessions[idx].username_len = 0;
    sessions[idx].port_len = 0;
    sessions[idx].authen_rounds = 0;
    sessions[idx].acct_records = 0;
    sessions[idx].last_authen_status = .fail;
    sessions[idx].last_author_status = .author_fail;
    sessions[idx].last_acct_status = .acct_error;
    return 0;
}

/// Check if a session state transition is valid.
pub export fn tacacs_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Authenticating
    if (from == 1 and to == 2) return 1; // Authenticating -> Authorizing
    if (from == 2 and to == 3) return 1; // Authorizing -> Active
    if (from == 1 and to == 4) return 1; // Authenticating -> Closing
    if (from == 2 and to == 4) return 1; // Authorizing -> Closing
    if (from == 3 and to == 4) return 1; // Active -> Closing
    if (from == 4 and to == 0) return 1; // Closing -> Idle
    return 0;
}

/// Returns number of active sessions.
pub export fn tacacs_session_count() callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    var count: u32 = 0;
    for (&sessions) |*s| {
        if (s.active) count += 1;
    }
    return count;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
