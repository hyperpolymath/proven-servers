// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// tftp.zig -- Zig FFI implementation of proven-tftp.
//
// Implements the TFTP (RFC 1350) transfer state machine with:
//   - 64-slot mutex-protected transfer session pool
//   - Read/write transfer state tracking
//   - Block number and retry count management
//   - Error code propagation
//   - Transfer mode validation
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching TFTPABI.Types exactly.

const std = @import("std");

// =========================================================================
// Enums (matching TFTPABI.Types tag assignments)
// =========================================================================

/// TFTP opcodes (ABI tags 0-4).
pub const Opcode = enum(u8) {
    rrq = 0,
    wrq = 1,
    data = 2,
    ack = 3,
    err = 4,
};

/// TFTP transfer modes (ABI tags 0-2).
pub const TransferMode = enum(u8) {
    netascii = 0,
    octet = 1,
    mail = 2,
};

/// TFTP error codes (ABI tags 0-7).
pub const TFTPError = enum(u8) {
    not_defined = 0,
    file_not_found = 1,
    access_violation = 2,
    disk_full = 3,
    illegal_operation = 4,
    unknown_tid = 5,
    file_exists = 6,
    no_such_user = 7,
};

/// Transfer states (ABI tags 0-4).
pub const TransferState = enum(u8) {
    idle = 0,
    reading = 1,
    writing = 2,
    in_error = 3,
    complete = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum filename length.
const MAX_FILENAME_LEN: usize = 256;

/// Maximum retries before giving up.
const MAX_RETRIES: u32 = 5;

/// TFTP block size (RFC 1350).
const BLOCK_SIZE: u32 = 512;

/// A TFTP transfer session.
const Session = struct {
    /// Current transfer state.
    state: TransferState,
    /// Filename being transferred.
    filename: [MAX_FILENAME_LEN]u8,
    filename_len: u32,
    /// Transfer mode.
    mode: TransferMode,
    /// Whether this is a read (true) or write (false) transfer.
    is_read: bool,
    /// Current block number.
    current_block: u16,
    /// Number of retries for the current block.
    retry_count: u32,
    /// Total bytes transferred.
    bytes_transferred: u32,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .filename = [_]u8{0} ** MAX_FILENAME_LEN,
    .filename_len = 0,
    .mode = .octet,
    .is_read = true,
    .current_block = 0,
    .retry_count = 0,
    .bytes_transferred = 0,
    .last_error = 255,
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
pub export fn tftp_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new TFTP transfer session. Returns slot index (>=0) or -1 on failure.
/// is_read: 1 = read transfer, 0 = write transfer.
pub export fn tftp_create(
    filename_ptr: [*]const u8,
    filename_len: u32,
    mode: u8,
    is_read: u8,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (filename_len == 0 or filename_len > MAX_FILENAME_LEN) return -1;
    if (mode > 2) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.filename[0..filename_len], filename_ptr[0..filename_len]);
            s.filename_len = filename_len;
            s.mode = @enumFromInt(mode);
            s.is_read = (is_read != 0);
            s.current_block = if (is_read != 0) 1 else 0;
            s.state = if (is_read != 0) .reading else .writing;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn tftp_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current TransferState tag for a session.
pub export fn tftp_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Record receipt of a DATA block. Returns 0 on success, 1 on rejection.
pub export fn tftp_recv_data(
    slot: c_int,
    block_num: u16,
    data_len: u32,
    is_last: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .reading and sessions[idx].state != .writing) return 1;

    sessions[idx].current_block = block_num;
    sessions[idx].bytes_transferred += data_len;
    sessions[idx].retry_count = 0;

    if (is_last != 0) {
        sessions[idx].state = .complete;
    }
    return 0;
}

/// Record receipt of an ACK. Returns 0 on success, 1 on rejection.
pub export fn tftp_recv_ack(slot: c_int, block_num: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .writing and sessions[idx].state != .reading) return 1;

    sessions[idx].current_block = block_num;
    sessions[idx].retry_count = 0;
    return 0;
}

/// Record receipt of an ERROR. Returns 0 on success, 1 on rejection.
pub export fn tftp_recv_error(slot: c_int, error_code: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .idle or sessions[idx].state == .complete) return 1;
    if (error_code > 7) return 1;

    sessions[idx].last_error = error_code;
    sessions[idx].state = .in_error;
    return 0;
}

/// Increment retry counter. Returns 0 if retry ok, 1 if exhausted, 2 if rejected.
pub export fn tftp_retry(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 2;
    if (sessions[idx].state != .reading and sessions[idx].state != .writing) return 2;

    sessions[idx].retry_count += 1;
    if (sessions[idx].retry_count > MAX_RETRIES) {
        sessions[idx].state = .in_error;
        sessions[idx].last_error = 0; // Not defined
        return 1;
    }
    return 0;
}

/// Returns current block number.
pub export fn tftp_current_block(slot: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].current_block;
}

/// Returns total bytes transferred.
pub export fn tftp_bytes_transferred(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].bytes_transferred;
}

/// Returns last error code (255 = no error).
pub export fn tftp_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return sessions[idx].last_error;
}

/// Returns transfer mode tag.
pub export fn tftp_mode(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].mode);
}

/// Check if a transfer state transition is valid.
pub export fn tftp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Reading
    if (from == 0 and to == 2) return 1; // Idle -> Writing
    if (from == 1 and to == 4) return 1; // Reading -> Complete
    if (from == 2 and to == 4) return 1; // Writing -> Complete
    if (from == 1 and to == 3) return 1; // Reading -> InError
    if (from == 2 and to == 3) return 1; // Writing -> InError
    return 0;
}

/// Check if a state is terminal (Complete or InError).
pub export fn tftp_is_terminal(state: u8) callconv(.c) u8 {
    if (state == 3 or state == 4) return 1; // InError or Complete
    return 0;
}

/// Returns number of active sessions.
pub export fn tftp_session_count() callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    var count: u32 = 0;
    for (&sessions) |*s| {
        if (s.active) count += 1;
    }
    return count;
}
