// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ws.zig -- Zig FFI implementation of proven-ws.
//
// Implements the WebSocket connection state machine with:
//   - 64-slot mutex-protected connection pool
//   - Connection lifecycle (Connecting/Open/Closing/Closed)
//   - Frame send/receive with opcode validation
//   - Ping/pong heartbeat tracking
//   - Close handshake protocol (with CloseCode)
//   - Frame counter statistics
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching WSABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching WSABI.Types.idr tag assignments)
// =========================================================================

/// WebSocket opcodes (ABI tags 0-5).
pub const Opcode = enum(u8) {
    continuation = 0,
    text = 1,
    binary = 2,
    close = 3,
    ping = 4,
    pong = 5,
};

/// WebSocket close codes (ABI tags 0-10).
pub const CloseCode = enum(u8) {
    normal = 0,
    going_away = 1,
    protocol_error = 2,
    unsupported_data = 3,
    no_status = 4,
    abnormal = 5,
    invalid_payload = 6,
    policy_violation = 7,
    message_too_big = 8,
    mandatory_extension = 9,
    internal_error = 10,
};

/// WebSocket connection states (ABI tags 0-3).
pub const ConnState = enum(u8) {
    connecting = 0,
    open = 1,
    closing = 2,
    closed = 3,
};

// =========================================================================
// Internal data structures
// =========================================================================

const MAX_SESSIONS: usize = 64;

/// A WebSocket connection.
const Connection = struct {
    /// Current connection state.
    state: ConnState,
    /// Close code (set when closing).
    close_code: CloseCode,
    /// Total frames sent.
    frames_sent: u32,
    /// Total frames received.
    frames_received: u32,
    /// Total pings sent.
    ping_count: u32,
    /// Whether we initiated the close.
    close_sent: bool,
    /// Whether we received a close.
    close_received: bool,
    /// Whether this slot is in use.
    active: bool,
};

const empty_connection: Connection = .{
    .state = .connecting,
    .close_code = .normal,
    .frames_sent = 0,
    .frames_received = 0,
    .ping_count = 0,
    .close_sent = false,
    .close_received = false,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var connections: [MAX_SESSIONS]Connection = [_]Connection{empty_connection} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!connections[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

pub export fn ws_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a WebSocket connection. Returns slot (>=0) or -1 on failure.
pub export fn ws_create() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    for (&connections, 0..) |*c, i| {
        if (!c.active) {
            c.* = empty_connection;
            c.state = .connecting;
            c.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

pub export fn ws_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    connections[@intCast(slot)] = empty_connection;
}

pub export fn ws_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(connections[idx].state);
}

/// Transition Connecting -> Open. Returns 0 on success.
pub export fn ws_open(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (connections[idx].state != .connecting) return 1;
    connections[idx].state = .open;
    return 0;
}

/// Send a frame. Returns 0 on success, 1 on rejection.
pub export fn ws_send_frame(slot: c_int, opcode: u8, fin: u8, payload_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = fin;
    _ = payload_len;

    const idx = validSlot(slot) orelse return 1;
    if (connections[idx].state != .open) return 1;
    if (opcode > 5) return 1;

    connections[idx].frames_sent += 1;
    return 0;
}

/// Receive a frame. Returns 0 on success, 1 on rejection.
pub export fn ws_recv_frame(slot: c_int, opcode: u8, fin: u8, payload_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = fin;
    _ = payload_len;

    const idx = validSlot(slot) orelse return 1;
    if (connections[idx].state != .open) return 1;
    if (opcode > 5) return 1;

    connections[idx].frames_received += 1;
    return 0;
}

/// Send a Ping frame. Returns 0 on success.
pub export fn ws_send_ping(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (connections[idx].state != .open) return 1;

    connections[idx].frames_sent += 1;
    connections[idx].ping_count += 1;
    return 0;
}

/// Receive a Pong frame. Returns 0 on success.
pub export fn ws_recv_pong(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (connections[idx].state != .open) return 1;

    connections[idx].frames_received += 1;
    return 0;
}

/// Initiate close with a CloseCode. Returns 0 on success.
pub export fn ws_close(slot: c_int, code: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (connections[idx].state != .open) return 1;
    if (code > 10) return 1;

    connections[idx].close_code = @enumFromInt(code);
    connections[idx].close_sent = true;
    connections[idx].state = .closing;
    connections[idx].frames_sent += 1;
    return 0;
}

/// Receive a close frame (completes handshake). Returns 0 on success.
pub export fn ws_recv_close(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (connections[idx].state != .closing and connections[idx].state != .open) return 1;

    connections[idx].close_received = true;
    connections[idx].frames_received += 1;

    if (connections[idx].close_sent) {
        connections[idx].state = .closed;
    } else {
        connections[idx].state = .closing;
    }
    return 0;
}

/// Returns 1 if connection is in Closing state, 0 otherwise.
pub export fn ws_is_closing(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (connections[idx].state == .closing) 1 else 0;
}

pub export fn ws_frames_sent(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return connections[idx].frames_sent;
}

pub export fn ws_frames_received(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return connections[idx].frames_received;
}

pub export fn ws_ping_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return connections[idx].ping_count;
}

/// Check if a connection state transition is valid.
pub export fn ws_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Connecting -> Open
    if (from == 1 and to == 2) return 1; // Open -> Closing
    if (from == 2 and to == 3) return 1; // Closing -> Closed
    if (from == 1 and to == 3) return 1; // Open -> Closed (abnormal)
    return 0;
}
