// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-sdn FFI.
//
// Tests cover (28 tests):
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Features request/reply handshake
//   - Flow table management (add/remove/count)
//   - Port state management (set/get/count)
//   - Message sending validation
//   - Barrier requests
//   - Disconnect / Cleanup
//   - Transition table validation
//   - Invalid slot safety
//   - Impossibility tests

const std = @import("std");
const sdn = @import("sdn");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), sdn.sdn_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "MessageType encoding matches Types.idr (12 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(sdn.MessageType.hello));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(sdn.MessageType.err));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(sdn.MessageType.echo_request));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(sdn.MessageType.echo_reply));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(sdn.MessageType.features_request));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(sdn.MessageType.features_reply));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(sdn.MessageType.flow_mod));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(sdn.MessageType.packet_in));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(sdn.MessageType.packet_out));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(sdn.MessageType.port_status));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(sdn.MessageType.barrier_request));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(sdn.MessageType.barrier_reply));
}

test "FlowAction encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(sdn.FlowAction.output));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(sdn.FlowAction.set_field));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(sdn.FlowAction.drop));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(sdn.FlowAction.push_vlan));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(sdn.FlowAction.pop_vlan));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(sdn.FlowAction.set_queue));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(sdn.FlowAction.group));
}

test "MatchField encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(sdn.MatchField.in_port));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(sdn.MatchField.eth_dst));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(sdn.MatchField.eth_src));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(sdn.MatchField.eth_type));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(sdn.MatchField.vlan_id));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(sdn.MatchField.ip_src));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(sdn.MatchField.ip_dst));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(sdn.MatchField.tcp_src));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(sdn.MatchField.tcp_dst));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(sdn.MatchField.udp_src));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(sdn.MatchField.udp_dst));
}

test "PortState encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(sdn.PortState.up));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(sdn.PortState.down));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(sdn.PortState.blocked));
}

test "ControllerState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(sdn.ControllerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(sdn.ControllerState.connected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(sdn.ControllerState.features_wait));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(sdn.ControllerState.ready));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(sdn.ControllerState.operating));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(sdn.ControllerState.disconnecting));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Connected state" {
    const slot = sdn.sdn_create(0xDEADBEEF);
    try std.testing.expect(slot >= 0);
    defer sdn.sdn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_state(slot)); // Connected
}

test "create rejects zero dpid" {
    try std.testing.expectEqual(@as(c_int, -1), sdn.sdn_create(0));
}

test "destroy is safe with invalid slot" {
    sdn.sdn_destroy(-1);
    sdn.sdn_destroy(999);
}

// =========================================================================
// Features handshake
// =========================================================================

test "features_request transitions Connected -> FeaturesWait" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_features_request(slot));
    try std.testing.expectEqual(@as(u8, 2), sdn.sdn_state(slot)); // FeaturesWait
}

test "features_reply transitions FeaturesWait -> Ready with ports" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    _ = sdn.sdn_features_request(slot);
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_features_reply(slot, 4));
    try std.testing.expectEqual(@as(u8, 3), sdn.sdn_state(slot)); // Ready
    try std.testing.expectEqual(@as(u16, 4), sdn.sdn_port_count(slot));
}

// =========================================================================
// Flow management
// =========================================================================

test "flow_add creates flow rule and transitions to Operating" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    _ = sdn.sdn_features_request(slot);
    _ = sdn.sdn_features_reply(slot, 2);
    // Add flow: table 0, priority 100, match InPort, action Output
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_flow_add(slot, 0, 100, 0, 0));
    try std.testing.expectEqual(@as(u32, 1), sdn.sdn_flow_count(slot));
    try std.testing.expectEqual(@as(u8, 4), sdn.sdn_state(slot)); // Operating
}

test "flow_remove removes flow and may return to Ready" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    _ = sdn.sdn_features_request(slot);
    _ = sdn.sdn_features_reply(slot, 2);
    _ = sdn.sdn_flow_add(slot, 0, 100, 0, 0);
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_flow_remove(slot, 0, 100, 0));
    try std.testing.expectEqual(@as(u32, 0), sdn.sdn_flow_count(slot));
    try std.testing.expectEqual(@as(u8, 3), sdn.sdn_state(slot)); // Ready
}

test "flow_add rejects invalid match field" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    _ = sdn.sdn_features_request(slot);
    _ = sdn.sdn_features_reply(slot, 2);
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_flow_add(slot, 0, 100, 99, 0));
}

test "flow_add rejects invalid action" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    _ = sdn.sdn_features_request(slot);
    _ = sdn.sdn_features_reply(slot, 2);
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_flow_add(slot, 0, 100, 0, 99));
}

// =========================================================================
// Port state management
// =========================================================================

test "port_set_state and port_get_state" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    _ = sdn.sdn_features_request(slot);
    _ = sdn.sdn_features_reply(slot, 2);
    // Set port 1 to Blocked
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_port_set_state(slot, 1, 2));
    try std.testing.expectEqual(@as(u8, 2), sdn.sdn_port_get_state(slot, 1)); // Blocked
}

// =========================================================================
// Message sending
// =========================================================================

test "send_message rejects from Disconnecting" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    _ = sdn.sdn_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_send_message(slot, 0));
}

test "send_message rejects invalid type" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_send_message(slot, 99));
}

// =========================================================================
// Barrier
// =========================================================================

test "barrier succeeds from Ready" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    _ = sdn.sdn_features_request(slot);
    _ = sdn.sdn_features_reply(slot, 2);
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_barrier(slot));
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Connected -> Disconnecting" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 5), sdn.sdn_state(slot));
}

test "cleanup transitions Disconnecting -> Idle and clears state" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    _ = sdn.sdn_features_request(slot);
    _ = sdn.sdn_features_reply(slot, 4);
    _ = sdn.sdn_flow_add(slot, 0, 100, 0, 0);
    _ = sdn.sdn_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_state(slot)); // Idle
    try std.testing.expectEqual(@as(u32, 0), sdn.sdn_flow_count(slot));
    try std.testing.expectEqual(@as(u16, 0), sdn.sdn_port_count(slot));
}

// =========================================================================
// Transition table
// =========================================================================

test "sdn_can_transition matches expected transitions" {
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_can_transition(0, 1)); // Idle -> Connected
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_can_transition(1, 2)); // Connected -> FeaturesWait
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_can_transition(2, 3)); // FeaturesWait -> Ready
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_can_transition(3, 4)); // Ready -> Operating
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_can_transition(4, 3)); // Operating -> Ready
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_can_transition(3, 5)); // Ready -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_can_transition(5, 0)); // Disconnecting -> Idle
    // Invalid
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_can_transition(0, 3)); // Idle -/-> Ready
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_can_transition(5, 1)); // Disconnecting -/-> Connected
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot add flow from Connected (not Ready)" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_flow_add(slot, 0, 100, 0, 0));
}

test "cannot features_request from Ready" {
    const slot = sdn.sdn_create(1);
    defer sdn.sdn_destroy(slot);
    _ = sdn.sdn_features_request(slot);
    _ = sdn.sdn_features_reply(slot, 2);
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_features_request(slot));
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), sdn.sdn_state(-1));
    try std.testing.expectEqual(@as(u32, 0), sdn.sdn_flow_count(-1));
    try std.testing.expectEqual(@as(u16, 0), sdn.sdn_port_count(-1));
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), sdn.sdn_cleanup(-1));
}

// =========================================================================
// Active count
// =========================================================================

test "active_count tracks sessions" {
    const before = sdn.sdn_active_count();
    const slot = sdn.sdn_create(42);
    try std.testing.expectEqual(before + 1, sdn.sdn_active_count());
    sdn.sdn_destroy(slot);
    try std.testing.expectEqual(before, sdn.sdn_active_count());
}
