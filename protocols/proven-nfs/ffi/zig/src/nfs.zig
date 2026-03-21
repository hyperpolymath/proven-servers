// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// nfs.zig -- Zig FFI implementation of proven-nfs.
//
// Implements the NFSv4 (RFC 7530) session state machine with:
//   - 64-slot mutex-protected session pool
//   - File handle tracking (max 32 open files per session)
//   - Byte-range lock tracking
//   - Read/write operation dispatch
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching NFSABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching NFSABI.Types.idr tag assignments)
// =========================================================================

/// NFSv4 operations (ABI tags 0-14).
pub const Operation = enum(u8) {
    access = 0,
    close = 1,
    commit = 2,
    create = 3,
    getattr = 4,
    link = 5,
    lock = 6,
    lookup = 7,
    open = 8,
    read = 9,
    readdir = 10,
    remove = 11,
    rename = 12,
    setattr = 13,
    write = 14,
};

/// NFSv4 file types (ABI tags 0-6).
pub const FileType = enum(u8) {
    regular = 0,
    directory = 1,
    block_device = 2,
    char_device = 3,
    sym_link = 4,
    socket = 5,
    fifo = 6,
};

/// NFSv4 status codes (ABI tags 0-13).
pub const Status = enum(u8) {
    ok = 0,
    perm = 1,
    noent = 2,
    io = 3,
    nxio = 4,
    access = 5,
    exist = 6,
    notdir = 7,
    isdir = 8,
    fbig = 9,
    nospc = 10,
    rofs = 11,
    notempty = 12,
    stale = 13,
};

/// NFS server lifecycle states (ABI tags 0-5).
pub const NFSState = enum(u8) {
    idle = 0,
    mounted = 1,
    file_open = 2,
    locked = 3,
    busy = 4,
    unmounting = 5,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum open files per session.
const MAX_FILES: usize = 32;

/// Maximum path/name length in bytes.
const MAX_PATH_LEN: usize = 1024;

/// Maximum server name length.
const MAX_NAME_LEN: usize = 256;

/// An open file handle.
const FileHandle = struct {
    /// File path.
    path: [MAX_PATH_LEN]u8,
    path_len: u32,
    /// File type.
    file_type: FileType,
    /// Whether a byte-range lock is held.
    has_lock: bool,
    /// Lock offset (if locked).
    lock_offset: u64,
    /// Lock length (if locked).
    lock_length: u64,
    /// Whether this handle slot is active.
    active: bool,
};

/// An NFS session.
const Session = struct {
    /// Current lifecycle state.
    state: NFSState,
    /// Server hostname/IP.
    server: [MAX_NAME_LEN]u8,
    server_len: u32,
    /// Export path.
    export_path: [MAX_PATH_LEN]u8,
    export_len: u32,
    /// Open file handles.
    files: [MAX_FILES]FileHandle,
    /// Number of open files.
    file_count: u32,
    /// Total operations executed.
    op_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) file handle.
const empty_file: FileHandle = .{
    .path = [_]u8{0} ** MAX_PATH_LEN,
    .path_len = 0,
    .file_type = .regular,
    .has_lock = false,
    .lock_offset = 0,
    .lock_length = 0,
    .active = false,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .server = [_]u8{0} ** MAX_NAME_LEN,
    .server_len = 0,
    .export_path = [_]u8{0} ** MAX_PATH_LEN,
    .export_len = 0,
    .files = [_]FileHandle{empty_file} ** MAX_FILES,
    .file_count = 0,
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
pub export fn nfs_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new NFS session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Mounted state.
pub export fn nfs_create(
    server_ptr: [*]const u8,
    server_len: u32,
    export_ptr: [*]const u8,
    export_len: u32,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (server_len == 0 or server_len > MAX_NAME_LEN) return -1;
    if (export_len == 0 or export_len > MAX_PATH_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.server[0..server_len], server_ptr[0..server_len]);
            s.server_len = server_len;
            @memcpy(s.export_path[0..export_len], export_ptr[0..export_len]);
            s.export_len = export_len;
            s.state = .mounted;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn nfs_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current NFSState tag for a session.
pub export fn nfs_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Open a file. Mounted/FileOpen -> FileOpen. Returns 0 on success, 1 on rejection.
pub export fn nfs_open(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    file_type: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .mounted and sessions[idx].state != .file_open) return 1;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 1;
    if (file_type > 6) return 1;
    if (sessions[idx].file_count >= MAX_FILES) return 1;

    for (&sessions[idx].files) |*f| {
        if (!f.active) {
            f.* = empty_file;
            @memcpy(f.path[0..path_len], path_ptr[0..path_len]);
            f.path_len = path_len;
            f.file_type = @enumFromInt(file_type);
            f.active = true;
            sessions[idx].file_count += 1;
            sessions[idx].state = .file_open;
            sessions[idx].op_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Close a file handle. Returns 0 on success, 1 on rejection.
/// FileOpen -> Mounted if last handle.
pub export fn nfs_close(slot: c_int, handle: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (handle >= MAX_FILES) return 1;
    if (!sessions[idx].files[handle].active) return 1;

    sessions[idx].files[handle] = empty_file;
    sessions[idx].file_count -= 1;
    sessions[idx].op_count += 1;

    if (sessions[idx].file_count == 0) {
        sessions[idx].state = .mounted;
    }
    return 0;
}

/// Read from an open file. Returns Status tag.
pub export fn nfs_read(slot: c_int, handle: u32, offset: u64, length: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = offset;
    _ = length;

    const idx = validSlot(slot) orelse return @intFromEnum(Status.io);
    if (sessions[idx].state != .file_open and sessions[idx].state != .locked) {
        return @intFromEnum(Status.io);
    }
    if (handle >= MAX_FILES) return @intFromEnum(Status.io);
    if (!sessions[idx].files[handle].active) return @intFromEnum(Status.stale);

    sessions[idx].op_count += 1;
    return @intFromEnum(Status.ok);
}

/// Write to an open file. Returns Status tag.
pub export fn nfs_write(slot: c_int, handle: u32, offset: u64, length: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = offset;
    _ = length;

    const idx = validSlot(slot) orelse return @intFromEnum(Status.io);
    if (sessions[idx].state != .file_open and sessions[idx].state != .locked) {
        return @intFromEnum(Status.io);
    }
    if (handle >= MAX_FILES) return @intFromEnum(Status.io);
    if (!sessions[idx].files[handle].active) return @intFromEnum(Status.stale);

    sessions[idx].op_count += 1;
    return @intFromEnum(Status.ok);
}

/// Lock a byte range on a file. FileOpen -> Locked.
pub export fn nfs_lock(slot: c_int, handle: u32, offset: u64, length: u64) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .file_open) return 1;
    if (handle >= MAX_FILES) return 1;
    if (!sessions[idx].files[handle].active) return 1;
    if (sessions[idx].files[handle].has_lock) return 1;

    sessions[idx].files[handle].has_lock = true;
    sessions[idx].files[handle].lock_offset = offset;
    sessions[idx].files[handle].lock_length = length;
    sessions[idx].state = .locked;
    sessions[idx].op_count += 1;
    return 0;
}

/// Unlock a file. Locked -> FileOpen (if no other locks).
pub export fn nfs_unlock(slot: c_int, handle: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .locked) return 1;
    if (handle >= MAX_FILES) return 1;
    if (!sessions[idx].files[handle].active) return 1;
    if (!sessions[idx].files[handle].has_lock) return 1;

    sessions[idx].files[handle].has_lock = false;
    sessions[idx].files[handle].lock_offset = 0;
    sessions[idx].files[handle].lock_length = 0;
    sessions[idx].op_count += 1;

    // Check if any other files still have locks
    var any_locked = false;
    for (&sessions[idx].files) |*f| {
        if (f.active and f.has_lock) {
            any_locked = true;
            break;
        }
    }
    if (!any_locked) {
        sessions[idx].state = .file_open;
    }
    return 0;
}

/// Lookup a path. Returns Status tag.
pub export fn nfs_lookup(slot: c_int, path_ptr: [*]const u8, path_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = path_ptr;

    const idx = validSlot(slot) orelse return @intFromEnum(Status.io);
    if (sessions[idx].state == .idle or sessions[idx].state == .unmounting) {
        return @intFromEnum(Status.io);
    }
    if (path_len == 0 or path_len > MAX_PATH_LEN) return @intFromEnum(Status.io);

    sessions[idx].op_count += 1;
    return @intFromEnum(Status.ok);
}

/// Get file attributes. Returns FileType tag on success, 255 on error.
pub export fn nfs_getattr(slot: c_int, handle: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 255;
    if (handle >= MAX_FILES) return 255;
    if (!sessions[idx].files[handle].active) return 255;

    sessions[idx].op_count += 1;
    return @intFromEnum(sessions[idx].files[handle].file_type);
}

/// Returns the number of open file handles.
pub export fn nfs_open_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].file_count;
}

/// Unmount. Any non-Idle/Unmounting -> Unmounting.
pub export fn nfs_unmount(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .idle or state == .unmounting) return 1;
    sessions[idx].state = .unmounting;
    return 0;
}

/// Complete cleanup. Unmounting -> Idle.
pub export fn nfs_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .unmounting) return 1;

    sessions[idx].state = .idle;
    sessions[idx].files = [_]FileHandle{empty_file} ** MAX_FILES;
    sessions[idx].file_count = 0;
    sessions[idx].op_count = 0;
    return 0;
}

/// Check if an NFS state transition is valid (stateless).
pub export fn nfs_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Mounted
    if (from == 1 and to == 2) return 1; // Mounted -> FileOpen
    if (from == 2 and to == 2) return 1; // FileOpen -> FileOpen (more opens)
    if (from == 2 and to == 1) return 1; // FileOpen -> Mounted (all closed)
    if (from == 2 and to == 3) return 1; // FileOpen -> Locked
    if (from == 3 and to == 2) return 1; // Locked -> FileOpen (unlock)
    if (from == 2 and to == 4) return 1; // FileOpen -> Busy (I/O)
    if (from == 3 and to == 4) return 1; // Locked -> Busy (I/O)
    if (from == 4 and to == 2) return 1; // Busy -> FileOpen (I/O done)
    if (from == 4 and to == 3) return 1; // Busy -> Locked (I/O done, lock held)
    if (from == 1 and to == 5) return 1; // Mounted -> Unmounting
    if (from == 2 and to == 5) return 1; // FileOpen -> Unmounting
    if (from == 3 and to == 5) return 1; // Locked -> Unmounting
    if (from == 4 and to == 5) return 1; // Busy -> Unmounting
    if (from == 5 and to == 0) return 1; // Unmounting -> Idle
    return 0;
}
