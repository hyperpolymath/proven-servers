// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// smb.zig -- Zig FFI implementation of proven-smb.
//
// Implements an SMB2/3 session state machine with:
//   - 64-slot mutex-protected SMB session pool
//   - Dialect negotiation (SMB 2.0.2 through 3.1.1)
//   - Session authentication tracking
//   - Tree connection management (max 16 per session)
//   - File handle tracking (max 64 per session)
//   - Command validation against session state
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching SMBABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching SMBABI.Types.idr tag assignments)
// =========================================================================

/// SMB2 command codes (ABI tags 0-15).
pub const Command = enum(u8) {
    negotiate = 0,
    session_setup = 1,
    logoff = 2,
    tree_connect = 3,
    tree_disconnect = 4,
    create = 5,
    close = 6,
    read = 7,
    write = 8,
    lock = 9,
    ioctl = 10,
    cancel = 11,
    query_directory = 12,
    change_notify = 13,
    query_info = 14,
    set_info = 15,
};

/// SMB dialect versions (ABI tags 0-4).
pub const Dialect = enum(u8) {
    smb2_0_2 = 0,
    smb2_1 = 1,
    smb3_0 = 2,
    smb3_0_2 = 3,
    smb3_1_1 = 4,
};

/// SMB share types (ABI tags 0-2).
pub const ShareType = enum(u8) {
    disk = 0,
    pipe = 1,
    print = 2,
};

/// Session lifecycle states (ABI tags 0-5).
pub const SessionState = enum(u8) {
    idle = 0,
    negotiated = 1,
    authenticated = 2,
    tree_connected = 3,
    file_open = 4,
    disconnecting = 5,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum tree connections per session.
const MAX_TREES: usize = 16;

/// Maximum file handles per session.
const MAX_FILES: usize = 64;

/// Maximum name length.
const MAX_NAME_LEN: usize = 256;

/// A tree connection.
const TreeEntry = struct {
    share_name: [MAX_NAME_LEN]u8,
    name_len: u32,
    share_type: ShareType,
    tree_id: u16,
    active: bool,
};

/// A file handle.
const FileEntry = struct {
    file_name: [MAX_NAME_LEN]u8,
    name_len: u32,
    tree_id: u16,
    file_id: u16,
    active: bool,
};

/// Default (empty) tree.
const empty_tree: TreeEntry = .{
    .share_name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .share_type = .disk,
    .tree_id = 0,
    .active = false,
};

/// Default (empty) file.
const empty_file: FileEntry = .{
    .file_name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .tree_id = 0,
    .file_id = 0,
    .active = false,
};

/// An SMB session.
const Session = struct {
    /// Current session lifecycle state.
    state: SessionState,
    /// Negotiated dialect.
    dialect: Dialect,
    /// Tree connections.
    trees: [MAX_TREES]TreeEntry,
    /// Tree count.
    tree_count: u16,
    /// Next tree ID.
    next_tree_id: u16,
    /// File handles.
    files: [MAX_FILES]FileEntry,
    /// File count.
    file_count: u16,
    /// Next file ID.
    next_file_id: u16,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .dialect = .smb2_0_2,
    .trees = [_]TreeEntry{empty_tree} ** MAX_TREES,
    .tree_count = 0,
    .next_tree_id = 1,
    .files = [_]FileEntry{empty_file} ** MAX_FILES,
    .file_count = 0,
    .next_file_id = 1,
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
pub export fn smb_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new SMB session. Returns slot index or -1 on failure.
/// State: Idle -> Negotiated.
pub export fn smb_create(dialect: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (dialect > 4) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.dialect = @enumFromInt(dialect);
            s.state = .negotiated;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session.
pub export fn smb_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current SessionState tag.
pub export fn smb_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Authenticate. Transitions Negotiated -> Authenticated.
pub export fn smb_authenticate(slot: c_int, user_ptr: [*]const u8, user_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    _ = user_ptr;

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .negotiated) return 1;
    if (user_len == 0 or user_len > MAX_NAME_LEN) return 1;
    sessions[idx].state = .authenticated;
    return 0;
}

/// Connect to a share. Returns 0 on success, 1 on rejection.
/// Transitions Authenticated -> TreeConnected.
pub export fn smb_tree_connect(slot: c_int, share_ptr: [*]const u8, share_len: u32, share_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .authenticated and sessions[idx].state != .tree_connected and
        sessions[idx].state != .file_open) return 1;
    if (share_len == 0 or share_len > MAX_NAME_LEN) return 1;
    if (share_type > 2) return 1;
    if (sessions[idx].tree_count >= MAX_TREES) return 1;

    for (&sessions[idx].trees) |*t| {
        if (!t.active) {
            @memcpy(t.share_name[0..share_len], share_ptr[0..share_len]);
            t.name_len = share_len;
            t.share_type = @enumFromInt(share_type);
            t.tree_id = sessions[idx].next_tree_id;
            sessions[idx].next_tree_id += 1;
            t.active = true;
            sessions[idx].tree_count += 1;
            if (sessions[idx].state == .authenticated) {
                sessions[idx].state = .tree_connected;
            }
            return 0;
        }
    }
    return 1;
}

/// Disconnect from a tree. Returns 0 on success, 1 on rejection.
pub export fn smb_tree_disconnect(slot: c_int, tree_id: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;

    // Close all files on this tree first
    for (&sessions[idx].files) |*f| {
        if (f.active and f.tree_id == tree_id) {
            f.active = false;
            sessions[idx].file_count -= 1;
        }
    }

    for (&sessions[idx].trees) |*t| {
        if (t.active and t.tree_id == tree_id) {
            t.active = false;
            sessions[idx].tree_count -= 1;

            // State transitions
            if (sessions[idx].file_count == 0 and sessions[idx].state == .file_open) {
                if (sessions[idx].tree_count == 0) {
                    sessions[idx].state = .authenticated;
                } else {
                    sessions[idx].state = .tree_connected;
                }
            } else if (sessions[idx].tree_count == 0 and sessions[idx].state == .tree_connected) {
                sessions[idx].state = .authenticated;
            }
            return 0;
        }
    }
    return 1;
}

/// Returns the number of tree connections.
pub export fn smb_tree_count(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].tree_count;
}

/// Open a file. Returns 0 on success, 1 on rejection.
/// Transitions TreeConnected -> FileOpen.
pub export fn smb_file_open(slot: c_int, tree_id: u16, name_ptr: [*]const u8, name_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .tree_connected and sessions[idx].state != .file_open) return 1;
    if (name_len == 0 or name_len > MAX_NAME_LEN) return 1;
    if (sessions[idx].file_count >= MAX_FILES) return 1;

    // Verify tree exists
    var tree_found = false;
    for (&sessions[idx].trees) |*t| {
        if (t.active and t.tree_id == tree_id) {
            tree_found = true;
            break;
        }
    }
    if (!tree_found) return 1;

    for (&sessions[idx].files) |*f| {
        if (!f.active) {
            @memcpy(f.file_name[0..name_len], name_ptr[0..name_len]);
            f.name_len = name_len;
            f.tree_id = tree_id;
            f.file_id = sessions[idx].next_file_id;
            sessions[idx].next_file_id += 1;
            f.active = true;
            sessions[idx].file_count += 1;
            sessions[idx].state = .file_open;
            return 0;
        }
    }
    return 1;
}

/// Close a file. Returns 0 on success, 1 on rejection.
pub export fn smb_file_close(slot: c_int, file_id: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;

    for (&sessions[idx].files) |*f| {
        if (f.active and f.file_id == file_id) {
            f.active = false;
            sessions[idx].file_count -= 1;
            if (sessions[idx].file_count == 0 and sessions[idx].state == .file_open) {
                sessions[idx].state = .tree_connected;
            }
            return 0;
        }
    }
    return 1;
}

/// Returns the number of open files.
pub export fn smb_file_count(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].file_count;
}

/// Read from a file. Returns 0 on success, 1 on rejection.
pub export fn smb_file_read(slot: c_int, file_id: u16, offset: u64, length: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    _ = offset;
    _ = length;

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .file_open) return 1;

    for (&sessions[idx].files) |*f| {
        if (f.active and f.file_id == file_id) return 0;
    }
    return 1;
}

/// Write to a file. Returns 0 on success, 1 on rejection.
pub export fn smb_file_write(slot: c_int, file_id: u16, offset: u64, length: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    _ = offset;
    _ = length;

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .file_open) return 1;

    for (&sessions[idx].files) |*f| {
        if (f.active and f.file_id == file_id) return 0;
    }
    return 1;
}

/// Returns the Dialect tag.
pub export fn smb_dialect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].dialect);
}

/// Check if a command is valid in the current state.
pub export fn smb_can_command(slot: c_int, cmd: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    if (cmd > 15) return 0;

    const state = sessions[idx].state;
    return switch (@as(Command, @enumFromInt(cmd))) {
        .negotiate => if (state == .idle) 1 else 0,
        .session_setup => if (state == .negotiated) 1 else 0,
        .logoff => if (state != .idle and state != .disconnecting) 1 else 0,
        .tree_connect => if (state == .authenticated or state == .tree_connected or state == .file_open) 1 else 0,
        .tree_disconnect => if (state == .tree_connected or state == .file_open) 1 else 0,
        .create => if (state == .tree_connected or state == .file_open) 1 else 0,
        .close => if (state == .file_open) 1 else 0,
        .read, .write, .lock, .ioctl, .query_info, .set_info => if (state == .file_open) 1 else 0,
        .cancel => if (state != .idle and state != .disconnecting) 1 else 0,
        .query_directory, .change_notify => if (state == .file_open) 1 else 0,
    };
}

/// Disconnect. Transitions any active -> Disconnecting.
pub export fn smb_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .idle or state == .disconnecting) return 1;
    sessions[idx].state = .disconnecting;
    return 0;
}

/// Cleanup. Transitions Disconnecting -> Idle.
pub export fn smb_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnecting) return 1;
    sessions[idx].state = .idle;
    sessions[idx].trees = [_]TreeEntry{empty_tree} ** MAX_TREES;
    sessions[idx].tree_count = 0;
    sessions[idx].files = [_]FileEntry{empty_file} ** MAX_FILES;
    sessions[idx].file_count = 0;
    return 0;
}

/// Check if a session state transition is valid.
pub export fn smb_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Negotiated
    if (from == 1 and to == 2) return 1; // Negotiated -> Authenticated
    if (from == 2 and to == 3) return 1; // Authenticated -> TreeConnected
    if (from == 3 and to == 4) return 1; // TreeConnected -> FileOpen
    if (from == 4 and to == 3) return 1; // FileOpen -> TreeConnected (all files closed)
    if (from == 3 and to == 2) return 1; // TreeConnected -> Authenticated (all trees gone)
    if (from == 1 and to == 5) return 1; // Negotiated -> Disconnecting
    if (from == 2 and to == 5) return 1; // Authenticated -> Disconnecting
    if (from == 3 and to == 5) return 1; // TreeConnected -> Disconnecting
    if (from == 4 and to == 5) return 1; // FileOpen -> Disconnecting
    if (from == 5 and to == 0) return 1; // Disconnecting -> Idle
    return 0;
}

/// Returns number of active sessions.
pub export fn smb_active_count() callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    var count: u32 = 0;
    for (&sessions) |*s| {
        if (s.active) count += 1;
    }
    return count;
}

/// Returns 1 if the dialect requires encryption (>= SMB 3.0), 0 otherwise.
pub export fn smb_encryption_required(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const d = @intFromEnum(sessions[idx].dialect);
    return if (d >= 2) 1 else 0; // SMB 3.0+ (tags 2-4)
}
