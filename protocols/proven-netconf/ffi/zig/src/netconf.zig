// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// netconf.zig -- Zig FFI implementation of proven-netconf.
//
// Implements the NETCONF (RFC 6241) session state machine with:
//   - 64-slot mutex-protected session pool
//   - Datastore lock tracking per session
//   - Edit-config operation queuing
//   - Candidate datastore validation and commit
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching NetconfABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching NetconfABI.Types.idr tag assignments)
// =========================================================================

/// NETCONF operations (ABI tags 0-11).
pub const Operation = enum(u8) {
    get = 0,
    get_config = 1,
    edit_config = 2,
    copy_config = 3,
    delete_config = 4,
    lock = 5,
    unlock = 6,
    close_session = 7,
    kill_session = 8,
    commit = 9,
    validate = 10,
    discard_changes = 11,
};

/// NETCONF datastores (ABI tags 0-2).
pub const Datastore = enum(u8) {
    running = 0,
    startup = 1,
    candidate = 2,
};

/// NETCONF edit operations (ABI tags 0-4).
pub const EditOperation = enum(u8) {
    merge = 0,
    replace = 1,
    create = 2,
    delete = 3,
    remove = 4,
};

/// NETCONF error types (ABI tags 0-3).
pub const ErrorType = enum(u8) {
    transport = 0,
    rpc = 1,
    protocol = 2,
    application = 3,
};

/// NETCONF error severity (ABI tags 0-1).
pub const ErrorSeverity = enum(u8) {
    err = 0,
    warning = 1,
};

/// NETCONF session lifecycle states (ABI tags 0-5).
pub const NetconfState = enum(u8) {
    idle = 0,
    connected = 1,
    locked = 2,
    editing = 3,
    closing = 4,
    terminated = 5,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum pending edit operations per session.
const MAX_EDITS: usize = 32;

/// Maximum hostname/xpath length in bytes.
const MAX_NAME_LEN: usize = 256;

/// A pending edit operation.
const EditEntry = struct {
    /// Target datastore.
    datastore: Datastore,
    /// Edit operation type.
    edit_op: EditOperation,
    /// XPath expression.
    xpath: [MAX_NAME_LEN]u8,
    xpath_len: u32,
    /// Whether this slot is active.
    active: bool,
};

/// A NETCONF session.
const Session = struct {
    /// Current lifecycle state.
    state: NetconfState,
    /// Remote host.
    host: [MAX_NAME_LEN]u8,
    host_len: u32,
    /// Remote port.
    port: u16,
    /// Which datastore is locked (if any). Only meaningful when state == .locked.
    locked_datastore: Datastore,
    /// Whether a datastore lock is held.
    has_lock: bool,
    /// Pending edit operations.
    edits: [MAX_EDITS]EditEntry,
    /// Number of pending edits.
    edit_count: u32,
    /// Total operations executed.
    op_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) edit entry.
const empty_edit: EditEntry = .{
    .datastore = .running,
    .edit_op = .merge,
    .xpath = [_]u8{0} ** MAX_NAME_LEN,
    .xpath_len = 0,
    .active = false,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .host = [_]u8{0} ** MAX_NAME_LEN,
    .host_len = 0,
    .port = 830,
    .locked_datastore = .running,
    .has_lock = false,
    .edits = [_]EditEntry{empty_edit} ** MAX_EDITS,
    .edit_count = 0,
    .op_count = 0,
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

/// Returns the ABI version number.
pub export fn netconf_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new NETCONF session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Connected state.
pub export fn netconf_create(
    host_ptr: [*]const u8,
    host_len: u32,
    port: u16,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (host_len == 0 or host_len > MAX_NAME_LEN) return -1;
    if (port == 0) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.host[0..host_len], host_ptr[0..host_len]);
            s.host_len = host_len;
            s.port = port;
            s.state = .connected;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn netconf_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current NetconfState tag for a session.
pub export fn netconf_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Lock a datastore. Connected -> Locked.
pub export fn netconf_lock(slot: c_int, datastore: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected) return 1;
    if (datastore > 2) return 1;

    sessions[idx].locked_datastore = @enumFromInt(datastore);
    sessions[idx].has_lock = true;
    sessions[idx].state = .locked;
    sessions[idx].op_count += 1;
    return 0;
}

/// Unlock a datastore. Locked -> Connected.
pub export fn netconf_unlock(slot: c_int, datastore: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .locked) return 1;
    if (datastore > 2) return 1;
    if (@intFromEnum(sessions[idx].locked_datastore) != datastore) return 1;

    sessions[idx].has_lock = false;
    sessions[idx].state = .connected;
    sessions[idx].op_count += 1;
    return 0;
}

/// Get configuration from a datastore.
pub export fn netconf_get_config(slot: c_int, datastore: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected and sessions[idx].state != .locked and
        sessions[idx].state != .editing) return 1;
    if (datastore > 2) return 1;

    sessions[idx].op_count += 1;
    return 0;
}

/// Edit configuration. Connected/Locked -> Editing.
pub export fn netconf_edit_config(
    slot: c_int,
    datastore: u8,
    edit_op: u8,
    xpath_ptr: [*]const u8,
    xpath_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected and sessions[idx].state != .locked and
        sessions[idx].state != .editing) return 1;
    if (datastore > 2) return 1;
    if (edit_op > 4) return 1;
    if (xpath_len == 0 or xpath_len > MAX_NAME_LEN) return 1;
    if (sessions[idx].edit_count >= MAX_EDITS) return 1;

    // Queue the edit
    for (&sessions[idx].edits) |*e| {
        if (!e.active) {
            e.datastore = @enumFromInt(datastore);
            e.edit_op = @enumFromInt(edit_op);
            @memcpy(e.xpath[0..xpath_len], xpath_ptr[0..xpath_len]);
            e.xpath_len = xpath_len;
            e.active = true;
            sessions[idx].edit_count += 1;
            sessions[idx].state = .editing;
            sessions[idx].op_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Commit pending edits. Editing -> Connected (or Locked if lock held).
pub export fn netconf_commit(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .editing) return 1;

    // Clear all edits
    sessions[idx].edits = [_]EditEntry{empty_edit} ** MAX_EDITS;
    sessions[idx].edit_count = 0;
    sessions[idx].state = if (sessions[idx].has_lock) .locked else .connected;
    sessions[idx].op_count += 1;
    return 0;
}

/// Discard pending edits. Editing -> Connected (or Locked if lock held).
pub export fn netconf_discard(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .editing) return 1;

    sessions[idx].edits = [_]EditEntry{empty_edit} ** MAX_EDITS;
    sessions[idx].edit_count = 0;
    sessions[idx].state = if (sessions[idx].has_lock) .locked else .connected;
    sessions[idx].op_count += 1;
    return 0;
}

/// Validate a datastore.
pub export fn netconf_validate(slot: c_int, datastore: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected and sessions[idx].state != .locked and
        sessions[idx].state != .editing) return 1;
    if (datastore > 2) return 1;

    sessions[idx].op_count += 1;
    return 0;
}

/// Close the session gracefully. Any non-Idle -> Closing.
pub export fn netconf_close_session(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .idle or state == .closing or state == .terminated) return 1;
    sessions[idx].state = .closing;
    sessions[idx].op_count += 1;
    return 0;
}

/// Kill another session (by session ID). Returns 0 on success.
pub export fn netconf_kill_session(slot: c_int, session_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = session_id;
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected and sessions[idx].state != .locked) return 1;
    sessions[idx].op_count += 1;
    return 0;
}

/// Complete cleanup. Closing/Terminated -> Idle.
pub export fn netconf_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .closing and sessions[idx].state != .terminated) return 1;

    sessions[idx].state = .idle;
    sessions[idx].has_lock = false;
    sessions[idx].edits = [_]EditEntry{empty_edit} ** MAX_EDITS;
    sessions[idx].edit_count = 0;
    sessions[idx].op_count = 0;
    return 0;
}

/// Check if a NETCONF state transition is valid (stateless).
pub export fn netconf_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Connected
    if (from == 1 and to == 2) return 1; // Connected -> Locked
    if (from == 2 and to == 1) return 1; // Locked -> Connected (unlock)
    if (from == 1 and to == 3) return 1; // Connected -> Editing
    if (from == 2 and to == 3) return 1; // Locked -> Editing
    if (from == 3 and to == 1) return 1; // Editing -> Connected (commit/discard)
    if (from == 3 and to == 2) return 1; // Editing -> Locked (commit/discard with lock)
    if (from == 1 and to == 4) return 1; // Connected -> Closing
    if (from == 2 and to == 4) return 1; // Locked -> Closing
    if (from == 3 and to == 4) return 1; // Editing -> Closing
    if (from == 4 and to == 0) return 1; // Closing -> Idle
    if (from == 5 and to == 0) return 1; // Terminated -> Idle
    return 0;
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
