// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ftp.zig -- Zig FFI implementation of proven-ftp.
//
// Implements verified FTP session state machine with:
//   - Slot-based session management (up to 64 concurrent)
//   - State machine enforcement matching Idris2 Transitions.idr
//   - Thread-safe via per-slot mutex pool (64 mutexes)
//   - Directory tracking with traversal prevention
//   - Transfer mode and type management
//   - Reply code tracking

const std = @import("std");

// -- Enums (matching FTPABI.Layout.idr tag assignments) ---------------------

/// FTP session states (5 constructors, tags 0-4).
pub const SessionState = enum(u8) {
    connected = 0,
    user_ok = 1,
    authenticated = 2,
    renaming = 3,
    quit = 4,
};

/// Transfer types (2 constructors, tags 0-1).
pub const TransferType = enum(u8) {
    ascii = 0,
    binary = 1,
};

/// Data connection mode discriminator (2 constructors, tags 0-1).
pub const DataModeTag = enum(u8) {
    active = 0,
    passive = 1,
};

/// Transfer state discriminator (4 constructors, tags 0-3).
pub const TransferStateTag = enum(u8) {
    idle = 0,
    in_progress = 1,
    completed = 2,
    aborted = 3,
};

/// Reply category (5 constructors, tags 0-4).
pub const ReplyCategory = enum(u8) {
    preliminary = 0,
    completion = 1,
    intermediate = 2,
    transient_neg = 3,
    permanent_neg = 4,
};

/// FTP command tags (23 constructors, tags 0-22).
pub const CommandTag = enum(u8) {
    user = 0,
    pass = 1,
    acct = 2,
    cwd = 3,
    cdup = 4,
    quit = 5,
    pasv = 6,
    port = 7,
    type_cmd = 8,
    retr = 9,
    stor = 10,
    dele = 11,
    rmd = 12,
    mkd = 13,
    pwd = 14,
    list = 15,
    nlst = 16,
    syst = 17,
    stat = 18,
    noop = 19,
    rnfr = 20,
    rnto = 21,
    size = 22,
};

// -- FTP session ------------------------------------------------------------

/// Maximum length for the current working directory path.
const MAX_CWD_LEN: usize = 4096;

/// An FTP session slot with all state.
const Session = struct {
    state: SessionState,
    transfer_type: TransferType,
    data_mode: u8, // DataModeTag value, 255 = not set
    transfer_state: TransferStateTag,
    bytes_transferred: u64,
    file_count: u32,
    last_reply: u16, // numeric reply code, 0 = none
    active_port: u16, // port for active mode
    cwd_len: u32,
    cwd: [MAX_CWD_LEN]u8,
    active: bool,
};

const MAX_SESSIONS: usize = 64;

/// Default (inactive) session value.
const DEFAULT_SESSION: Session = .{
    .state = .connected,
    .transfer_type = .ascii,
    .data_mode = 255,
    .transfer_state = .idle,
    .bytes_transferred = 0,
    .file_count = 0,
    .last_reply = 0,
    .active_port = 0,
    .cwd_len = 1,
    .cwd = initCwd(),
    .active = false,
};

/// Initialise the CWD buffer with "/" followed by zeroes.
fn initCwd() [MAX_CWD_LEN]u8 {
    var buf: [MAX_CWD_LEN]u8 = [_]u8{0} ** MAX_CWD_LEN;
    buf[0] = '/';
    return buf;
}

var sessions: [MAX_SESSIONS]Session = [_]Session{DEFAULT_SESSION} ** MAX_SESSIONS;

/// Per-slot mutex pool -- avoids global lock contention.
var mutexes: [MAX_SESSIONS]std.Thread.Mutex = [_]std.Thread.Mutex{.{}} ** MAX_SESSIONS;

/// Global mutex for slot allocation only.
var alloc_mutex: std.Thread.Mutex = .{};

/// Validate a slot index. Returns null for invalid or inactive slots.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

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

// -- Path validation --------------------------------------------------------

/// Check whether a path component is safe (no traversal, no null bytes).
/// Returns false for ".." that would escape root, empty segments, or null bytes.
fn validatePath(path: [*]const u8, len: u32) bool {
    if (len == 0) return false;
    const slice = path[0..len];
    // Check for null bytes
    for (slice) |c| {
        if (c == 0) return false;
    }
    // Check depth: walk segments, reject if depth goes below 0
    var depth: i32 = 0;
    var seg_start: u32 = 0;
    var i: u32 = 0;
    while (i <= len) : (i += 1) {
        const at_end = i == len;
        const is_sep = if (at_end) true else slice[i] == '/';
        if (is_sep) {
            const seg_len = i - seg_start;
            if (seg_len == 2 and slice[seg_start] == '.' and slice[seg_start + 1] == '.') {
                depth -= 1;
                if (depth < 0) return false; // traversal escape
            } else if (seg_len > 0 and !(seg_len == 1 and slice[seg_start] == '.')) {
                depth += 1;
            }
            seg_start = i + 1;
        }
    }
    return true;
}

/// Apply a validated path to the CWD buffer. Handles absolute and relative paths.
fn applyCwd(session: *Session, path: [*]const u8, len: u32) void {
    const slice = path[0..len];
    if (len > 0 and slice[0] == '/') {
        // Absolute path: replace CWD entirely
        const copy_len = @min(len, MAX_CWD_LEN);
        @memcpy(session.cwd[0..copy_len], slice[0..copy_len]);
        session.cwd_len = copy_len;
    } else {
        // Relative path: append to CWD with separator
        var pos = session.cwd_len;
        if (pos > 0 and session.cwd[pos - 1] != '/') {
            if (pos < MAX_CWD_LEN) {
                session.cwd[pos] = '/';
                pos += 1;
            }
        }
        const remaining = MAX_CWD_LEN - pos;
        const copy_len = @min(len, @as(u32, @intCast(remaining)));
        @memcpy(session.cwd[pos .. pos + copy_len], slice[0..copy_len]);
        session.cwd_len = pos + copy_len;
    }
}

// -- ABI version ------------------------------------------------------------

pub export fn ftp_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle --------------------------------------------------------------

pub export fn ftp_create() callconv(.c) c_int {
    alloc_mutex.lock();
    defer alloc_mutex.unlock();
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = DEFAULT_SESSION;
            s.active = true;
            s.last_reply = 220; // ServiceReady
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

pub export fn ftp_destroy(slot: c_int) callconv(.c) void {
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    const idx: usize = @intCast(slot);
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    sessions[idx].active = false;
}

// -- State queries ----------------------------------------------------------

pub export fn ftp_state(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 4; // quit as fallback
    defer unlockSlot(idx);
    return @intFromEnum(sessions[idx].state);
}

pub export fn ftp_transfer_type(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 255;
    defer unlockSlot(idx);
    return @intFromEnum(sessions[idx].transfer_type);
}

pub export fn ftp_data_mode(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 255;
    defer unlockSlot(idx);
    return sessions[idx].data_mode;
}

pub export fn ftp_transfer_state(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 255;
    defer unlockSlot(idx);
    return @intFromEnum(sessions[idx].transfer_state);
}

pub export fn ftp_bytes_transferred(slot: c_int) callconv(.c) u64 {
    const idx = lockSlot(slot) orelse return 0;
    defer unlockSlot(idx);
    return sessions[idx].bytes_transferred;
}

pub export fn ftp_file_count(slot: c_int) callconv(.c) u32 {
    const idx = lockSlot(slot) orelse return 0;
    defer unlockSlot(idx);
    return sessions[idx].file_count;
}

pub export fn ftp_last_reply_code(slot: c_int) callconv(.c) u16 {
    const idx = lockSlot(slot) orelse return 0;
    defer unlockSlot(idx);
    return sessions[idx].last_reply;
}

pub export fn ftp_cwd(slot: c_int, buf: [*]u8, buf_len: u32) callconv(.c) u32 {
    const idx = lockSlot(slot) orelse return 0;
    defer unlockSlot(idx);
    const copy_len = @min(sessions[idx].cwd_len, buf_len);
    @memcpy(buf[0..copy_len], sessions[idx].cwd[0..copy_len]);
    return copy_len;
}

// -- Commands: Authentication -----------------------------------------------

pub export fn ftp_user(slot: c_int, _: [*]const u8, _: u32) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    switch (s.state) {
        .connected => {
            s.state = .user_ok;
            s.last_reply = 331; // NeedPassword
            return 0;
        },
        .user_ok => {
            // Re-USER: stay in UserOk
            s.last_reply = 331;
            return 0;
        },
        .authenticated => {
            // Re-login
            s.state = .user_ok;
            s.last_reply = 331;
            return 0;
        },
        else => {
            s.last_reply = 503; // BadSequence
            return 1;
        },
    }
}

pub export fn ftp_pass(slot: c_int, _: [*]const u8, _: u32) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .user_ok) {
        s.last_reply = 503; // BadSequence
        return 1;
    }
    s.state = .authenticated;
    s.last_reply = 230; // UserLoggedIn
    return 0;
}

pub export fn ftp_quit(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state == .quit) {
        return 1;
    }
    s.state = .quit;
    s.last_reply = 221; // ServiceClosing
    return 0;
}

// -- Commands: Navigation ---------------------------------------------------

pub export fn ftp_cwd_cmd(slot: c_int, path: [*]const u8, path_len: u32) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .authenticated) {
        s.last_reply = if (s.state == .connected or s.state == .user_ok) @as(u16, 530) else 503;
        return 1;
    }
    if (!validatePath(path, path_len)) {
        s.last_reply = 550; // ActionNotTaken
        return 2; // bad path
    }
    applyCwd(s, path, path_len);
    s.last_reply = 250; // FileActionOk
    return 0;
}

pub export fn ftp_cdup(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .authenticated) {
        s.last_reply = if (s.state == .connected or s.state == .user_ok) @as(u16, 530) else 503;
        return 1;
    }
    // Go to parent: find last '/' and truncate
    if (s.cwd_len > 1) {
        var i: u32 = s.cwd_len - 1;
        while (i > 0) : (i -= 1) {
            if (s.cwd[i] == '/') break;
        }
        s.cwd_len = if (i == 0) 1 else i; // keep at least "/"
    }
    s.last_reply = 250; // FileActionOk
    return 0;
}

// -- Commands: Transfer parameters ------------------------------------------

pub export fn ftp_set_type(slot: c_int, type_tag: u8) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .authenticated) {
        s.last_reply = if (s.state == .connected or s.state == .user_ok) @as(u16, 530) else 503;
        return 1;
    }
    if (type_tag > 1) {
        s.last_reply = 504; // ParamNotImplemented
        return 1;
    }
    s.transfer_type = @enumFromInt(type_tag);
    s.last_reply = 200; // CommandOk
    return 0;
}

pub export fn ftp_set_passive(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .authenticated) {
        s.last_reply = if (s.state == .connected or s.state == .user_ok) @as(u16, 530) else 503;
        return 1;
    }
    s.data_mode = @intFromEnum(DataModeTag.passive);
    s.last_reply = 227; // EnteringPassive
    return 0;
}

pub export fn ftp_set_active(slot: c_int, port: u16) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .authenticated) {
        s.last_reply = if (s.state == .connected or s.state == .user_ok) @as(u16, 530) else 503;
        return 1;
    }
    s.data_mode = @intFromEnum(DataModeTag.active);
    s.active_port = port;
    s.last_reply = 200; // CommandOk
    return 0;
}

// -- Commands: Data transfer ------------------------------------------------

pub export fn ftp_begin_transfer(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    // Must be authenticated
    if (s.state != .authenticated) {
        s.last_reply = if (s.state == .connected or s.state == .user_ok) @as(u16, 530) else 503;
        return 1;
    }
    // Must have data mode set
    if (s.data_mode == 255) {
        s.last_reply = 425; // CantOpenData
        return 1;
    }
    // Must not already be transferring
    if (s.transfer_state == .in_progress) {
        s.last_reply = 503;
        return 1;
    }
    s.transfer_state = .in_progress;
    s.bytes_transferred = 0;
    s.last_reply = 150; // FileStatusOk
    return 0;
}

pub export fn ftp_add_bytes(slot: c_int, count: u64) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.transfer_state != .in_progress) return 1;
    s.bytes_transferred +|= count; // saturating add
    return 0;
}

pub export fn ftp_complete_transfer(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.transfer_state != .in_progress) return 1;
    s.transfer_state = .completed;
    s.file_count +|= 1;
    s.last_reply = 226; // TransferComplete
    return 0;
}

pub export fn ftp_abort_transfer(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.transfer_state != .in_progress) return 1;
    s.transfer_state = .aborted;
    s.last_reply = 426; // TransferAborted
    return 0;
}

// -- Commands: Rename -------------------------------------------------------

pub export fn ftp_begin_rename(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .authenticated) {
        s.last_reply = if (s.state == .connected or s.state == .user_ok) @as(u16, 530) else 503;
        return 1;
    }
    s.state = .renaming;
    s.last_reply = 350; // PendingInfo
    return 0;
}

pub export fn ftp_complete_rename(slot: c_int) callconv(.c) u8 {
    const idx = lockSlot(slot) orelse return 1;
    defer unlockSlot(idx);
    const s = &sessions[idx];
    if (s.state != .renaming) {
        s.last_reply = 503; // BadSequence
        return 1;
    }
    s.state = .authenticated;
    s.last_reply = 250; // FileActionOk
    return 0;
}

// -- Stateless queries ------------------------------------------------------

pub export fn ftp_can_transfer(state_tag: u8) callconv(.c) u8 {
    // Only Authenticated (tag 2) can transfer
    return if (state_tag == 2) 1 else 0;
}

pub export fn ftp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Matches Transitions.idr validateSessionTransition exactly
    if (from == 0 and to == 1) return 1; // Connected -> UserOk (AcceptUser)
    if (from == 0 and to == 4) return 1; // Connected -> Quit (QuitConnected)
    if (from == 1 and to == 2) return 1; // UserOk -> Authenticated (AcceptPass)
    if (from == 1 and to == 1) return 1; // UserOk -> UserOk (ReUser)
    if (from == 1 and to == 4) return 1; // UserOk -> Quit (QuitUserOk)
    if (from == 2 and to == 2) return 1; // Authenticated -> Authenticated (FileOp)
    if (from == 2 and to == 3) return 1; // Authenticated -> Renaming (BeginRename)
    if (from == 2 and to == 1) return 1; // Authenticated -> UserOk (ReLogin)
    if (from == 2 and to == 4) return 1; // Authenticated -> Quit (QuitAuth)
    if (from == 3 and to == 2) return 1; // Renaming -> Authenticated (CompleteRename)
    if (from == 3 and to == 3) return 1; // Renaming -> Renaming (RenamingNoop)
    if (from == 3 and to == 4) return 1; // Renaming -> Quit (QuitRenaming)
    return 0;
}
