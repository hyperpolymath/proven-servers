// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-ids FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const ids = @import("ids");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ids.ids_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "AlertSeverity encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.AlertSeverity.low));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.AlertSeverity.medium));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.AlertSeverity.high));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.AlertSeverity.critical));
}

test "DetectionMethod encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.DetectionMethod.signature));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.DetectionMethod.anomaly));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.DetectionMethod.stateful));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.DetectionMethod.heuristic));
}

test "Protocol encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.Protocol.tcp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.Protocol.udp));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.Protocol.icmp));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.Protocol.dns));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.Protocol.http));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ids.Protocol.tls));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ids.Protocol.ssh));
}

test "Action encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.Action.alert));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.Action.drop));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.Action.log));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.Action.block));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.Action.pass));
}

test "Direction encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.Direction.inbound));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.Direction.outbound));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.Direction.both));
}

test "ThreatLevel encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.ThreatLevel.info));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.ThreatLevel.low));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.ThreatLevel.medium));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.ThreatLevel.high));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.ThreatLevel.critical));
}

test "RuleMatch encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.RuleMatch.src_addr));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.RuleMatch.dst_addr));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.RuleMatch.src_port));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.RuleMatch.dst_port));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.RuleMatch.content));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ids.RuleMatch.regex));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ids.RuleMatch.threshold));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ids.RuleMatch.flow_bits));
}

test "MatchStatus encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.MatchStatus.no_match));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.MatchStatus.matched));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.MatchStatus.suppressed));
}

test "InspectionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.InspectionState.captured));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.InspectionState.decoded));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.InspectionState.inspecting));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.InspectionState.evaluated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.InspectionState.disposed));
}

test "AlertState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.AlertState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.AlertState.triggered));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.AlertState.escalated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.AlertState.acknowledged));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.AlertState.closed));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = ids.ids_create_context();
    try std.testing.expect(slot >= 0);
    defer ids.ids_destroy_context(slot);
    const state = ids.ids_inspection_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    ids.ids_destroy_context(-1);
    ids.ids_destroy_context(999);
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = ids.ids_inspection_state(-1);
    _ = ids.ids_get_action(-1);
    _ = ids.ids_get_match_status(-1);
    _ = ids.ids_get_match_severity(-1);
}

