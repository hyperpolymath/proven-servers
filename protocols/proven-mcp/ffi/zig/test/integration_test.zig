// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-mcp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Capability management (add/has/bitmask)
//   - Initialize handshake (Connecting -> Ready)
//   - Tool call / complete / cancel
//   - Pending request tracking
//   - Ping from Ready/Processing
//   - Disconnect / Cleanup
//   - Stateless session transition table
//   - Transport selection
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const mcp = @import("mcp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), mcp.mcp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "MessageType encoding matches Types.idr (14 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mcp.MessageType.initialize));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mcp.MessageType.initialized));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mcp.MessageType.ping));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mcp.MessageType.call_tool));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mcp.MessageType.tool_result));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(mcp.MessageType.list_tools));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(mcp.MessageType.list_resources));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(mcp.MessageType.read_resource));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(mcp.MessageType.list_prompts));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(mcp.MessageType.get_prompt));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(mcp.MessageType.subscribe));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(mcp.MessageType.unsubscribe));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(mcp.MessageType.notification));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(mcp.MessageType.cancel));
}

test "Transport encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mcp.Transport.stdio));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mcp.Transport.sse));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mcp.Transport.websocket));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mcp.Transport.streamable_http));
}

test "ContentType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mcp.ContentType.text));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mcp.ContentType.image));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mcp.ContentType.resource));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mcp.ContentType.embedding));
}

test "ErrorCode encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mcp.ErrorCode.parse_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mcp.ErrorCode.invalid_request));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mcp.ErrorCode.method_not_found));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mcp.ErrorCode.invalid_params));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mcp.ErrorCode.internal_error));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(mcp.ErrorCode.timeout));
}

test "Capability encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mcp.Capability.tools));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mcp.Capability.resources));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mcp.Capability.prompts));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mcp.Capability.logging));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mcp.Capability.sampling));
}

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mcp.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mcp.SessionState.connecting));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mcp.SessionState.ready));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mcp.SessionState.processing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mcp.SessionState.disconnecting));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Connecting state" {
    const name = "test-server";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    try std.testing.expect(slot >= 0);
    defer mcp.mcp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_state(slot)); // Connecting
}

test "create rejects invalid transport" {
    const name = "test";
    try std.testing.expectEqual(@as(c_int, -1), mcp.mcp_create(99, name.ptr, name.len));
}

test "create rejects empty name" {
    const name = "x";
    try std.testing.expectEqual(@as(c_int, -1), mcp.mcp_create(0, name.ptr, 0));
}

test "destroy is safe with invalid slot" {
    mcp.mcp_destroy(-1);
    mcp.mcp_destroy(999);
}

// =========================================================================
// Initialize handshake
// =========================================================================

test "initialize transitions Connecting -> Ready" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_initialize(slot, 0x03)); // Tools + Resources
    try std.testing.expectEqual(@as(u8, 2), mcp.mcp_state(slot)); // Ready
}

test "initialize rejected from Ready" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);

    _ = mcp.mcp_initialize(slot, 0);
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_initialize(slot, 0)); // Already Ready
}

// =========================================================================
// Capability management
// =========================================================================

test "add_capability and has_capability" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_has_capability(slot, 0)); // Tools
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_add_capability(slot, 0));
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_has_capability(slot, 0));
}

test "add_capability rejects invalid capability" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_add_capability(slot, 99));
}

// =========================================================================
// Tool call / complete / cancel
// =========================================================================

test "call_tool transitions Ready -> Processing" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);
    _ = mcp.mcp_initialize(slot, 0x01);

    const tool = "search";
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_call_tool(slot, tool.ptr, tool.len, 1));
    try std.testing.expectEqual(@as(u8, 3), mcp.mcp_state(slot)); // Processing
    try std.testing.expectEqual(@as(u32, 1), mcp.mcp_pending_count(slot));
}

test "complete_request transitions Processing -> Ready when last" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);
    _ = mcp.mcp_initialize(slot, 0x01);

    const tool = "search";
    _ = mcp.mcp_call_tool(slot, tool.ptr, tool.len, 42);
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_complete_request(slot, 42));
    try std.testing.expectEqual(@as(u8, 2), mcp.mcp_state(slot)); // Ready
    try std.testing.expectEqual(@as(u32, 0), mcp.mcp_pending_count(slot));
}

test "cancel_request removes pending entry" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);
    _ = mcp.mcp_initialize(slot, 0x01);

    const tool = "search";
    _ = mcp.mcp_call_tool(slot, tool.ptr, tool.len, 7);
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_cancel_request(slot, 7));
    try std.testing.expectEqual(@as(u32, 0), mcp.mcp_pending_count(slot));
}

test "multiple pending requests stay Processing" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);
    _ = mcp.mcp_initialize(slot, 0x01);

    const t1 = "a";
    const t2 = "b";
    _ = mcp.mcp_call_tool(slot, t1.ptr, t1.len, 1);
    _ = mcp.mcp_call_tool(slot, t2.ptr, t2.len, 2);
    try std.testing.expectEqual(@as(u32, 2), mcp.mcp_pending_count(slot));

    _ = mcp.mcp_complete_request(slot, 1);
    try std.testing.expectEqual(@as(u8, 3), mcp.mcp_state(slot)); // Still Processing
    try std.testing.expectEqual(@as(u32, 1), mcp.mcp_pending_count(slot));
}

// =========================================================================
// Ping
// =========================================================================

test "ping succeeds from Ready" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);
    _ = mcp.mcp_initialize(slot, 0);

    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_ping(slot));
}

test "ping rejected from Connecting" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_ping(slot));
}

// =========================================================================
// Transport
// =========================================================================

test "transport returns correct value" {
    const name = "srv";
    const slot = mcp.mcp_create(2, name.ptr, name.len); // WebSocket
    defer mcp.mcp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 2), mcp.mcp_transport(slot));
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Ready -> Disconnecting" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);
    _ = mcp.mcp_initialize(slot, 0);

    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 4), mcp.mcp_state(slot));
}

test "cleanup transitions Disconnecting -> Idle" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);
    _ = mcp.mcp_initialize(slot, 0x1F);

    _ = mcp.mcp_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_state(slot)); // Idle
}

test "cleanup rejected from non-Disconnecting" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "mcp_can_transition matches state machine" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_can_transition(0, 1)); // Idle -> Connecting
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_can_transition(1, 2)); // Connecting -> Ready
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_can_transition(2, 3)); // Ready -> Processing
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_can_transition(3, 3)); // Processing -> Processing
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_can_transition(3, 2)); // Processing -> Ready
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_can_transition(1, 4)); // Connecting -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_can_transition(2, 4)); // Ready -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_can_transition(3, 4)); // Processing -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_can_transition(4, 0)); // Disconnecting -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_can_transition(0, 2)); // Idle -/-> Ready
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_can_transition(0, 3)); // Idle -/-> Processing
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_can_transition(4, 1)); // Disconnecting -/-> Connecting
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_can_transition(0, 4)); // Idle -/-> Disconnecting
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_state(-1));
    try std.testing.expectEqual(@as(u32, 0), mcp.mcp_pending_count(-1));
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_has_capability(-1, 0));
    try std.testing.expectEqual(@as(u8, 0), mcp.mcp_transport(-1));
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_cleanup(-1));
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_ping(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot call_tool from Connecting" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);

    const tool = "search";
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_call_tool(slot, tool.ptr, tool.len, 1));
}

test "cannot call_tool from Disconnecting" {
    const name = "srv";
    const slot = mcp.mcp_create(0, name.ptr, name.len);
    defer mcp.mcp_destroy(slot);
    _ = mcp.mcp_initialize(slot, 0);
    _ = mcp.mcp_disconnect(slot);

    const tool = "search";
    try std.testing.expectEqual(@as(u8, 1), mcp.mcp_call_tool(slot, tool.ptr, tool.len, 1));
}
