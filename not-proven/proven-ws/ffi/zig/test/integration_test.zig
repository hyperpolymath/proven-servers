// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-ws FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Connection lifecycle (create/destroy)
//   - State transitions (Connecting -> Open -> Closing -> Closed)
//   - Frame send/receive with opcode validation
//   - Ping/pong heartbeat tracking
//   - Close handshake protocol
//   - Frame counter statistics
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const ws = @import("ws");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ws.ws_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Opcode encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ws.Opcode.continuation));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ws.Opcode.text));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ws.Opcode.binary));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ws.Opcode.close));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ws.Opcode.ping));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ws.Opcode.pong));
}

test "CloseCode encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ws.CloseCode.normal));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ws.CloseCode.going_away));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ws.CloseCode.protocol_error));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ws.CloseCode.unsupported_data));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ws.CloseCode.no_status));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ws.CloseCode.abnormal));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ws.CloseCode.invalid_payload));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ws.CloseCode.policy_violation));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(ws.CloseCode.message_too_big));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(ws.CloseCode.mandatory_extension));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(ws.CloseCode.internal_error));
}

test "ConnState encoding matches lifecycle (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ws.ConnState.connecting));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ws.ConnState.open));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ws.ConnState.closing));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ws.ConnState.closed));
}

// =========================================================================
// Connection lifecycle
// =========================================================================

test "create returns valid slot in Connecting state" {
    const slot = ws.ws_create();
    try std.testing.expect(slot >= 0);
    defer ws.ws_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ws.ws_state(slot)); // Connecting
}

test "destroy is safe with invalid slot" {
    ws.ws_destroy(-1);
    ws.ws_destroy(999);
}

// =========================================================================
// State transitions
// =========================================================================

test "open transitions Connecting -> Open" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ws.ws_open(slot));
    try std.testing.expectEqual(@as(u8, 1), ws.ws_state(slot)); // Open
}

test "open rejected from Open" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);

    _ = ws.ws_open(slot);
    try std.testing.expectEqual(@as(u8, 1), ws.ws_open(slot));
}

// =========================================================================
// Frame send/receive
// =========================================================================

test "send_frame succeeds from Open" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);
    _ = ws.ws_open(slot);

    try std.testing.expectEqual(@as(u8, 0), ws.ws_send_frame(slot, 1, 1, 100)); // text, fin
    try std.testing.expectEqual(@as(u32, 1), ws.ws_frames_sent(slot));
}

test "recv_frame succeeds from Open" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);
    _ = ws.ws_open(slot);

    try std.testing.expectEqual(@as(u8, 0), ws.ws_recv_frame(slot, 2, 1, 50)); // binary, fin
    try std.testing.expectEqual(@as(u32, 1), ws.ws_frames_received(slot));
}

test "send_frame rejected from Connecting" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ws.ws_send_frame(slot, 1, 1, 0));
}

test "send_frame rejects invalid opcode" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);
    _ = ws.ws_open(slot);

    try std.testing.expectEqual(@as(u8, 1), ws.ws_send_frame(slot, 99, 1, 0));
}

// =========================================================================
// Ping/pong
// =========================================================================

test "send_ping increments ping_count and frames_sent" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);
    _ = ws.ws_open(slot);

    try std.testing.expectEqual(@as(u8, 0), ws.ws_send_ping(slot));
    try std.testing.expectEqual(@as(u32, 1), ws.ws_ping_count(slot));
    try std.testing.expectEqual(@as(u32, 1), ws.ws_frames_sent(slot));
}

test "recv_pong increments frames_received" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);
    _ = ws.ws_open(slot);

    try std.testing.expectEqual(@as(u8, 0), ws.ws_recv_pong(slot));
    try std.testing.expectEqual(@as(u32, 1), ws.ws_frames_received(slot));
}

test "send_ping rejected from Connecting" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ws.ws_send_ping(slot));
}

// =========================================================================
// Close handshake
// =========================================================================

test "close transitions Open -> Closing" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);
    _ = ws.ws_open(slot);

    try std.testing.expectEqual(@as(u8, 0), ws.ws_close(slot, 0)); // Normal
    try std.testing.expectEqual(@as(u8, 2), ws.ws_state(slot)); // Closing
    try std.testing.expectEqual(@as(u8, 1), ws.ws_is_closing(slot));
}

test "recv_close completes handshake -> Closed" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);
    _ = ws.ws_open(slot);

    _ = ws.ws_close(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), ws.ws_recv_close(slot));
    try std.testing.expectEqual(@as(u8, 3), ws.ws_state(slot)); // Closed
}

test "close rejected from Connecting" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ws.ws_close(slot, 0));
}

test "close rejects invalid code" {
    const slot = ws.ws_create();
    defer ws.ws_destroy(slot);
    _ = ws.ws_open(slot);

    try std.testing.expectEqual(@as(u8, 1), ws.ws_close(slot, 99));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "ws_can_transition matches connection lifecycle" {
    // Valid
    try std.testing.expectEqual(@as(u8, 1), ws.ws_can_transition(0, 1)); // Connecting -> Open
    try std.testing.expectEqual(@as(u8, 1), ws.ws_can_transition(1, 2)); // Open -> Closing
    try std.testing.expectEqual(@as(u8, 1), ws.ws_can_transition(2, 3)); // Closing -> Closed
    try std.testing.expectEqual(@as(u8, 1), ws.ws_can_transition(1, 3)); // Open -> Closed (abnormal)

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), ws.ws_can_transition(0, 2)); // Connecting -/-> Closing
    try std.testing.expectEqual(@as(u8, 0), ws.ws_can_transition(3, 1)); // Closed -/-> Open
    try std.testing.expectEqual(@as(u8, 0), ws.ws_can_transition(2, 1)); // Closing -/-> Open
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), ws.ws_state(-1));
    try std.testing.expectEqual(@as(u32, 0), ws.ws_frames_sent(-1));
    try std.testing.expectEqual(@as(u32, 0), ws.ws_frames_received(-1));
    try std.testing.expectEqual(@as(u32, 0), ws.ws_ping_count(-1));
    try std.testing.expectEqual(@as(u8, 0), ws.ws_is_closing(-1));
    try std.testing.expectEqual(@as(u8, 1), ws.ws_open(-1));
    try std.testing.expectEqual(@as(u8, 1), ws.ws_close(-1, 0));
}
