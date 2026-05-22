// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// fileserver.zig -- Zig FFI implementation of proven-fileserver.
//
// Implements the network file server session state machine with:
//   - 64-slot mutex-protected session pool
//   - File operation tracking per session
//   - Lock management (shared/exclusive/advisory/mandatory)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching FileserverABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching FileserverABI.Types.idr tag assignments)
// =========================================================================

/// File operations (ABI tags 0-9).
pub const Operation = enum(u8) {
    read = 0,
    write = 1,
    create = 2,
    delete = 3,
    rename = 4,
    list = 5,
    stat = 6,
    lock = 7,
    unlock = 8,
    watch = 9,
};

/// File types (ABI tags 0-6).
pub const FileType = enum(u8) {
    regular = 0,
    directory = 1,
    symlink = 2,
    block_device = 3,
    char_device = 4,
    fifo = 5,
    socket = 6,
};

/// POSIX permission bits (ABI tags 0-8).
pub const Permission = enum(u8) {
    owner_read = 0,
    owner_write = 1,
    owner_execute = 2,
    group_read = 3,
    group_write = 4,
    group_execute = 5,
    other_read = 6,
    other_write = 7,
    other_execute = 8,
};

/// Lock types (ABI tags 0-3).
pub const LockType = enum(u8) {
    shared = 0,
    exclusive = 1,
    advisory = 2,
    mandatory = 3,
};

/// Error codes (ABI tags 0-9).
pub const ErrorCode = enum(u8) {
    not_found = 0,
    permission_denied = 1,
    already_exists = 2,
    not_empty = 3,
    is_directory = 4,
    not_directory = 5,
    no_space = 6,
    read_only = 7,
    locked = 8,
    io_error = 9,
};

/// Session lifecycle states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    idle = 0,
    connected = 1,
    operating = 2,
    locked = 3,
    disconnecting = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

const MAX_SESSIONS: usize = 64;
const MAX_NAME_LEN: usize = 256;
const MAX_PATH_LEN: usize = 4096;

/// A file server session.
const Session = struct {
    state: SessionState,
    root_path: [MAX_PATH_LEN]u8,
    root_len: u32,
    op_count: u32,
    is_locked: bool,
    current_lock_type: LockType,
    /// Whether operating returns to Locked or Connected.
    op_return_to_locked: bool,
    active: bool,
};

const empty_session: Session = .{
    .state = .idle,
    .root_path = [_]u8{0} ** MAX_PATH_LEN,
    .root_len = 0,
    .op_count = 0,
    .is_locked = false,
    .current_lock_type = .shared,
    .op_return_to_locked = false,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn fs_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new file server session. Returns slot (>=0) or -1.
/// Starts in Connected state.
pub export fn fs_create(
    root_ptr: [*]const u8,
    root_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (root_len == 0 or root_len > MAX_PATH_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.root_path[0..root_len], root_ptr[0..root_len]);
            s.root_len = root_len;
            s.state = .connected;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn fs_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

pub export fn fs_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

pub export fn fs_op_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].op_count;
}

/// Execute a file operation. Returns 0 on success, 1 on rejection.
/// Transitions Connected -> Operating -> Connected (or Locked -> Operating -> Locked).
pub export fn fs_execute_op(
    slot: c_int,
    operation: u8,
    path_ptr: [*]const u8,
    path_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = path_ptr;
    _ = path_len;

    const idx = validSlot(slot) orelse return 1;
    if (operation > 9) return 1;

    const state = sessions[idx].state;
    if (state != .connected and state != .locked) return 1;

    sessions[idx].op_return_to_locked = (state == .locked);
    sessions[idx].state = .operating;
    sessions[idx].op_count += 1;

    // Immediately complete (simulated)
    if (sessions[idx].op_return_to_locked) {
        sessions[idx].state = .locked;
    } else {
        sessions[idx].state = .connected;
    }

    return 0;
}

// -- Lock management ------------------------------------------------------

/// Acquire a lock. Transitions Connected -> Locked.
pub export fn fs_acquire_lock(
    slot: c_int,
    lock_type: u8,
    path_ptr: [*]const u8,
    path_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = path_ptr;
    _ = path_len;

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected) return 1;
    if (lock_type > 3) return 1;

    sessions[idx].state = .locked;
    sessions[idx].is_locked = true;
    sessions[idx].current_lock_type = @enumFromInt(lock_type);
    return 0;
}

/// Release a lock. Transitions Locked -> Connected.
pub export fn fs_release_lock(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .locked) return 1;

    sessions[idx].state = .connected;
    sessions[idx].is_locked = false;
    return 0;
}

/// Returns 1 if a lock is held, 0 otherwise.
pub export fn fs_is_locked(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].is_locked) 1 else 0;
}

/// Returns the current lock type (only meaningful if locked).
pub export fn fs_lock_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].current_lock_type);
}

// -- Disconnect / Cleanup -------------------------------------------------

pub export fn fs_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .connected or state == .locked or state == .operating) {
        sessions[idx].state = .disconnecting;
        return 0;
    }
    return 1;
}

pub export fn fs_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnecting) return 1;

    sessions[idx].state = .idle;
    sessions[idx].op_count = 0;
    sessions[idx].is_locked = false;

    return 0;
}

// -- Stateless transition table -------------------------------------------

pub export fn fs_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Connected
    if (from == 1 and to == 2) return 1; // Connected -> Operating
    if (from == 2 and to == 1) return 1; // Operating -> Connected
    if (from == 1 and to == 3) return 1; // Connected -> Locked
    if (from == 3 and to == 2) return 1; // Locked -> Operating
    if (from == 2 and to == 3) return 1; // Operating -> Locked
    if (from == 3 and to == 1) return 1; // Locked -> Connected
    if (from == 1 and to == 4) return 1; // Connected -> Disconnecting
    if (from == 3 and to == 4) return 1; // Locked -> Disconnecting
    if (from == 2 and to == 4) return 1; // Operating -> Disconnecting
    if (from == 4 and to == 0) return 1; // Disconnecting -> Idle
    return 0;
}
