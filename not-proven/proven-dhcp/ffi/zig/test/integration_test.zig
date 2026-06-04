// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-dhcp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const dhcp = @import("dhcp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), dhcp.dhcp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "MessageType encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.MessageType.discover));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.MessageType.offer));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dhcp.MessageType.request));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dhcp.MessageType.ack));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dhcp.MessageType.nak));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dhcp.MessageType.release));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(dhcp.MessageType.inform));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(dhcp.MessageType.decline));
}

test "OptionCode encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.OptionCode.subnet_mask));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.OptionCode.router));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dhcp.OptionCode.dns));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dhcp.OptionCode.domain_name));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dhcp.OptionCode.lease_time));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dhcp.OptionCode.server_id));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(dhcp.OptionCode.requested_ip));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(dhcp.OptionCode.msg_type));
}

test "HardwareType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.HardwareType.ethernet));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.HardwareType.ieee802));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dhcp.HardwareType.arcnet));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dhcp.HardwareType.frame_relay));
}

test "DhcpState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.DhcpState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.DhcpState.discover_received));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dhcp.DhcpState.offer_sent));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dhcp.DhcpState.request_received));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dhcp.DhcpState.ack_sent));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dhcp.DhcpState.nak_sent));
}

test "LeaseState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.LeaseState.available));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.LeaseState.offered));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dhcp.LeaseState.bound));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dhcp.LeaseState.renewing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dhcp.LeaseState.rebinding));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dhcp.LeaseState.expired));
}

test "RelaySubOption encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.RelaySubOption.circuit_id));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.RelaySubOption.remote_id));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = dhcp.dhcp_create_context();
    try std.testing.expect(slot >= 0);
    defer dhcp.dhcp_destroy_context(slot);
    const state = dhcp.dhcp_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    dhcp.dhcp_destroy_context(-1);
    dhcp.dhcp_destroy_context(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = dhcp.dhcp_state(-1);
    _ = dhcp.dhcp_pool_count(-1);
    _ = dhcp.dhcp_pool_available_count(-1);
}

