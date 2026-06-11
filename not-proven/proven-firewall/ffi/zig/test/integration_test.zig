// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-firewall FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const firewall = @import("firewall");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), firewall.fw_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Action encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(firewall.Action.accept));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(firewall.Action.drop));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(firewall.Action.reject));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(firewall.Action.log));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(firewall.Action.redirect));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(firewall.Action.dnat));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(firewall.Action.snat));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(firewall.Action.masquerade));
}

test "Protocol encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(firewall.Protocol.tcp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(firewall.Protocol.udp));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(firewall.Protocol.icmp));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(firewall.Protocol.icmpv6));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(firewall.Protocol.gre));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(firewall.Protocol.esp));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(firewall.Protocol.ah));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(firewall.Protocol.any));
}

test "ChainType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(firewall.ChainType.input));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(firewall.ChainType.output));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(firewall.ChainType.forward));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(firewall.ChainType.pre_routing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(firewall.ChainType.post_routing));
}

test "RuleMatchType encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(firewall.RuleMatchType.source_ip));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(firewall.RuleMatchType.dest_ip));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(firewall.RuleMatchType.source_port));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(firewall.RuleMatchType.dest_port));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(firewall.RuleMatchType.match_proto));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(firewall.RuleMatchType.interface));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(firewall.RuleMatchType.state));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(firewall.RuleMatchType.mark));
}

test "ConnState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(firewall.ConnState.new));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(firewall.ConnState.established));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(firewall.ConnState.related));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(firewall.ConnState.invalid));
}

test "PacketState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(firewall.PacketState.arrived));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(firewall.PacketState.classified));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(firewall.PacketState.chain_traversal));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(firewall.PacketState.decided));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(firewall.PacketState.committed));
}

test "ConnTrackState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(firewall.ConnTrackState.untracked));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(firewall.ConnTrackState.tracking));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(firewall.ConnTrackState.tracked));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(firewall.ConnTrackState.expired));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = firewall.fw_create_context();
    try std.testing.expect(slot >= 0);
    defer firewall.fw_destroy_context(slot);
    const state = firewall.fw_packet_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    firewall.fw_destroy_context(-1);
    firewall.fw_destroy_context(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), firewall.fw_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), firewall.fw_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = firewall.fw_packet_state(-1);
    _ = firewall.fw_get_decision(-1);
    _ = firewall.fw_rule_count(-1);
}

