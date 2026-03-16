// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ids_test.zig -- Integration tests for proven-ids FFI.

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

test "AlertSeverity encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.AlertSeverity.low));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.AlertSeverity.medium));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.AlertSeverity.high));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.AlertSeverity.critical));
}

test "DetectionMethod encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.DetectionMethod.signature));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.DetectionMethod.anomaly));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.DetectionMethod.stateful));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.DetectionMethod.heuristic));
}

test "Protocol encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.Protocol.tcp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.Protocol.udp));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.Protocol.icmp));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.Protocol.dns));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.Protocol.http));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ids.Protocol.tls));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ids.Protocol.ssh));
}

test "Action encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.Action.alert));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.Action.drop));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.Action.log));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.Action.block));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.Action.pass));
}

test "Direction encoding matches Layout.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.Direction.inbound));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.Direction.outbound));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.Direction.both));
}

test "ThreatLevel encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.ThreatLevel.info));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.ThreatLevel.low));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.ThreatLevel.medium));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.ThreatLevel.high));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.ThreatLevel.critical));
}

test "RuleMatch encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.RuleMatch.src_addr));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.RuleMatch.dst_addr));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.RuleMatch.src_port));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.RuleMatch.dst_port));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.RuleMatch.content));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ids.RuleMatch.regex));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ids.RuleMatch.threshold));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ids.RuleMatch.flow_bits));
}

test "MatchStatus encoding matches Layout.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.MatchStatus.no_match));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.MatchStatus.matched));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.MatchStatus.suppressed));
}

test "InspectionState encoding matches Transitions.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.InspectionState.captured));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.InspectionState.decoded));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.InspectionState.inspecting));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.InspectionState.evaluated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.InspectionState.disposed));
}

test "AlertState encoding matches Transitions.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ids.AlertState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ids.AlertState.triggered));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ids.AlertState.escalated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ids.AlertState.acknowledged));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ids.AlertState.closed));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot in Captured/Idle state" {
    const slot = ids.ids_create_context();
    try std.testing.expect(slot >= 0);
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 0), ids.ids_inspection_state(slot)); // captured
    try std.testing.expectEqual(@as(u8, 0), ids.ids_alert_state(slot)); // idle
}

test "destroy is safe with invalid slot" {
    ids.ids_destroy_context(-1);
    ids.ids_destroy_context(999);
}

test "slot reuse after destroy" {
    const slot1 = ids.ids_create_context();
    try std.testing.expect(slot1 >= 0);
    ids.ids_destroy_context(slot1);

    const slot2 = ids.ids_create_context();
    try std.testing.expect(slot2 >= 0);
    defer ids.ids_destroy_context(slot2);
    // Should get same slot back (first free)
    try std.testing.expectEqual(slot1, slot2);
}

// =========================================================================
// Full inspection lifecycle: Captured -> Decoded -> Inspecting -> Evaluated -> Disposed
// =========================================================================

test "full inspection lifecycle without rules" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    // Captured -> Decoded (TCP, Inbound, 10.0.0.1 -> 10.0.0.2, 12345 -> 80)
    try std.testing.expectEqual(@as(u8, 0), ids.ids_decode_packet(slot, 0, 0, 0x0A000001, 0x0A000002, 12345, 80));
    try std.testing.expectEqual(@as(u8, 1), ids.ids_inspection_state(slot)); // decoded

    // Decoded -> Inspecting
    try std.testing.expectEqual(@as(u8, 0), ids.ids_begin_inspection(slot));
    try std.testing.expectEqual(@as(u8, 2), ids.ids_inspection_state(slot)); // inspecting

    // Inspecting -> Evaluated
    try std.testing.expectEqual(@as(u8, 0), ids.ids_evaluate_rules(slot));
    try std.testing.expectEqual(@as(u8, 3), ids.ids_inspection_state(slot)); // evaluated

    // No rules loaded => no match, default action (pass)
    try std.testing.expectEqual(@as(u8, 0), ids.ids_get_match_status(slot)); // no_match
    try std.testing.expectEqual(@as(u8, 4), ids.ids_get_action(slot)); // pass

    // Evaluated -> Disposed
    try std.testing.expectEqual(@as(u8, 0), ids.ids_dispose(slot));
    try std.testing.expectEqual(@as(u8, 4), ids.ids_inspection_state(slot)); // disposed
}

// =========================================================================
// Packet decoding field queries
// =========================================================================

test "decoded packet fields are queryable" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    // Decode HTTP outbound packet
    _ = ids.ids_decode_packet(slot, 4, 1, 0xC0A80001, 0xC0A80002, 54321, 443);

    try std.testing.expectEqual(@as(u8, 4), ids.ids_packet_proto(slot)); // http
    try std.testing.expectEqual(@as(u8, 1), ids.ids_packet_direction(slot)); // outbound
    try std.testing.expectEqual(@as(u32, 0xC0A80001), ids.ids_packet_src_ip(slot));
    try std.testing.expectEqual(@as(u32, 0xC0A80002), ids.ids_packet_dst_ip(slot));
    try std.testing.expectEqual(@as(u16, 54321), ids.ids_packet_src_port(slot));
    try std.testing.expectEqual(@as(u16, 443), ids.ids_packet_dst_port(slot));
}

test "decode rejects invalid protocol tag" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_decode_packet(slot, 99, 0, 0, 0, 0, 0));
    try std.testing.expectEqual(@as(u8, 0), ids.ids_inspection_state(slot)); // still captured
}

test "decode rejects invalid direction tag" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_decode_packet(slot, 0, 5, 0, 0, 0, 0));
    try std.testing.expectEqual(@as(u8, 0), ids.ids_inspection_state(slot)); // still captured
}

// =========================================================================
// Rule loading and evaluation
// =========================================================================

test "add rule and evaluate matching src_addr" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    // Add rule: match src_addr 10.0.0.1, action=drop, severity=high, detection=signature, priority=10
    _ = ids.ids_add_rule(slot, 0, 0x0A000001, 1, 2, 0, 10);

    // Decode matching packet
    _ = ids.ids_decode_packet(slot, 0, 0, 0x0A000001, 0x0A000002, 1234, 80);
    _ = ids.ids_begin_inspection(slot);
    _ = ids.ids_evaluate_rules(slot);

    try std.testing.expectEqual(@as(u8, 1), ids.ids_get_match_status(slot)); // matched
    try std.testing.expectEqual(@as(u8, 1), ids.ids_get_action(slot)); // drop
    try std.testing.expectEqual(@as(u8, 2), ids.ids_get_match_severity(slot)); // high
    try std.testing.expectEqual(@as(u8, 0), ids.ids_get_match_detection(slot)); // signature
    try std.testing.expectEqual(@as(u8, 3), ids.ids_get_threat_level(slot)); // high
}

test "rule priority: lower number wins" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    // Rule 1: match src_addr, action=log, priority=100
    _ = ids.ids_add_rule(slot, 0, 0x0A000001, 2, 0, 0, 100);
    // Rule 2: match src_addr, action=block, priority=5 (higher priority)
    _ = ids.ids_add_rule(slot, 0, 0x0A000001, 3, 3, 1, 5);

    _ = ids.ids_decode_packet(slot, 0, 0, 0x0A000001, 0x0A000002, 1234, 80);
    _ = ids.ids_begin_inspection(slot);
    _ = ids.ids_evaluate_rules(slot);

    try std.testing.expectEqual(@as(u8, 3), ids.ids_get_action(slot)); // block (priority 5 wins)
    try std.testing.expectEqual(@as(u8, 3), ids.ids_get_match_severity(slot)); // critical
    try std.testing.expectEqual(@as(u8, 1), ids.ids_get_match_detection(slot)); // anomaly
}

test "no matching rule uses default action" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    // Set default action to Log
    _ = ids.ids_set_default_action(slot, 2);

    // Rule for a different IP
    _ = ids.ids_add_rule(slot, 0, 0x0B000001, 1, 2, 0, 10);

    // Decode packet that does NOT match
    _ = ids.ids_decode_packet(slot, 0, 0, 0x0A000001, 0x0A000002, 1234, 80);
    _ = ids.ids_begin_inspection(slot);
    _ = ids.ids_evaluate_rules(slot);

    try std.testing.expectEqual(@as(u8, 0), ids.ids_get_match_status(slot)); // no_match
    try std.testing.expectEqual(@as(u8, 2), ids.ids_get_action(slot)); // log (default)
}

test "dst_port rule matching" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    // Rule: match dst_port 22, action=alert, severity=medium
    _ = ids.ids_add_rule(slot, 3, 22, 0, 1, 2, 1);

    _ = ids.ids_decode_packet(slot, 6, 0, 0x0A000001, 0x0A000002, 54321, 22); // SSH
    _ = ids.ids_begin_inspection(slot);
    _ = ids.ids_evaluate_rules(slot);

    try std.testing.expectEqual(@as(u8, 1), ids.ids_get_match_status(slot)); // matched
    try std.testing.expectEqual(@as(u8, 0), ids.ids_get_action(slot)); // alert
}

test "content rule matches when value is nonzero" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    // Rule: content match (hash=0xDEADBEEF), action=block, severity=critical
    _ = ids.ids_add_rule(slot, 4, 0xDEADBEEF, 3, 3, 3, 1);

    _ = ids.ids_decode_packet(slot, 4, 0, 0x0A000001, 0x0A000002, 1234, 80); // HTTP
    _ = ids.ids_begin_inspection(slot);
    _ = ids.ids_evaluate_rules(slot);

    try std.testing.expectEqual(@as(u8, 1), ids.ids_get_match_status(slot)); // matched
    try std.testing.expectEqual(@as(u8, 3), ids.ids_get_action(slot)); // block
}

test "add rule rejects invalid match_type" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_add_rule(slot, 99, 0, 0, 0, 0, 0));
}

test "add rule rejects invalid action" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_add_rule(slot, 0, 0, 99, 0, 0, 0));
}

test "add rule rejects invalid severity" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_add_rule(slot, 0, 0, 0, 99, 0, 0));
}

test "add rule rejects invalid detection method" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_add_rule(slot, 0, 0, 0, 0, 99, 0));
}

test "rule_count tracks loaded rules" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u16, 0), ids.ids_rule_count(slot));
    _ = ids.ids_add_rule(slot, 0, 0x0A000001, 0, 0, 0, 1);
    try std.testing.expectEqual(@as(u16, 1), ids.ids_rule_count(slot));
    _ = ids.ids_add_rule(slot, 1, 0x0A000002, 1, 1, 1, 2);
    try std.testing.expectEqual(@as(u16, 2), ids.ids_rule_count(slot));
}

// =========================================================================
// Alert lifecycle: Idle -> Triggered -> Escalated -> Acknowledged -> Closed
// =========================================================================

test "full alert lifecycle: trigger -> escalate -> acknowledge -> close" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    // Idle -> Triggered
    try std.testing.expectEqual(@as(u8, 0), ids.ids_trigger_alert(slot, 2)); // high
    try std.testing.expectEqual(@as(u8, 1), ids.ids_alert_state(slot)); // triggered
    try std.testing.expectEqual(@as(u8, 2), ids.ids_get_alert_severity(slot)); // high

    // Triggered -> Escalated
    try std.testing.expectEqual(@as(u8, 0), ids.ids_escalate_alert(slot));
    try std.testing.expectEqual(@as(u8, 2), ids.ids_alert_state(slot)); // escalated

    // Escalated -> Acknowledged
    try std.testing.expectEqual(@as(u8, 0), ids.ids_acknowledge_alert(slot));
    try std.testing.expectEqual(@as(u8, 3), ids.ids_alert_state(slot)); // acknowledged

    // Acknowledged -> Closed
    try std.testing.expectEqual(@as(u8, 0), ids.ids_close_alert(slot));
    try std.testing.expectEqual(@as(u8, 4), ids.ids_alert_state(slot)); // closed
}

test "alert lifecycle: trigger -> acknowledge directly -> close" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    _ = ids.ids_trigger_alert(slot, 1); // medium
    try std.testing.expectEqual(@as(u8, 0), ids.ids_acknowledge_alert(slot));
    try std.testing.expectEqual(@as(u8, 3), ids.ids_alert_state(slot)); // acknowledged
    try std.testing.expectEqual(@as(u8, 0), ids.ids_close_alert(slot));
    try std.testing.expectEqual(@as(u8, 4), ids.ids_alert_state(slot)); // closed
}

test "alert lifecycle: trigger -> auto-close (suppression)" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    _ = ids.ids_trigger_alert(slot, 0); // low
    try std.testing.expectEqual(@as(u8, 0), ids.ids_auto_close_alert(slot));
    try std.testing.expectEqual(@as(u8, 4), ids.ids_alert_state(slot)); // closed
}

test "alert_count increments on trigger" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    try std.testing.expectEqual(@as(u16, 0), ids.ids_alert_count(slot));
    _ = ids.ids_trigger_alert(slot, 0);
    try std.testing.expectEqual(@as(u16, 1), ids.ids_alert_count(slot));
}

// =========================================================================
// Invalid transitions (impossibility proofs from Transitions.idr)
// =========================================================================

test "cannot decode from non-Captured state" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    _ = ids.ids_decode_packet(slot, 0, 0, 0, 0, 0, 0); // -> Decoded
    // Try decoding again from Decoded
    try std.testing.expectEqual(@as(u8, 1), ids.ids_decode_packet(slot, 0, 0, 0, 0, 0, 0));
}

test "cannot begin inspection from Captured" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_begin_inspection(slot)); // must decode first
}

test "cannot evaluate rules from Decoded" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    _ = ids.ids_decode_packet(slot, 0, 0, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_evaluate_rules(slot)); // must begin inspection first
}

test "cannot dispose from Inspecting" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    _ = ids.ids_decode_packet(slot, 0, 0, 0, 0, 0, 0);
    _ = ids.ids_begin_inspection(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_dispose(slot)); // must evaluate first
}

test "cannot trigger alert from non-Idle state" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    _ = ids.ids_trigger_alert(slot, 0); // -> Triggered
    try std.testing.expectEqual(@as(u8, 1), ids.ids_trigger_alert(slot, 1)); // cannot double trigger
}

test "cannot escalate from Idle" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_escalate_alert(slot)); // must trigger first
}

test "cannot close alert from Idle" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_close_alert(slot)); // must acknowledge first
}

test "cannot close alert directly from Escalated" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    _ = ids.ids_trigger_alert(slot, 2);
    _ = ids.ids_escalate_alert(slot); // -> Escalated
    try std.testing.expectEqual(@as(u8, 1), ids.ids_close_alert(slot)); // must acknowledge first
}

test "cannot auto-close from Escalated" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    _ = ids.ids_trigger_alert(slot, 2);
    _ = ids.ids_escalate_alert(slot); // -> Escalated
    try std.testing.expectEqual(@as(u8, 1), ids.ids_auto_close_alert(slot)); // only from Triggered
}

test "Closed alert is terminal" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    _ = ids.ids_trigger_alert(slot, 0);
    _ = ids.ids_auto_close_alert(slot); // -> Closed

    // All alert transitions from Closed should be rejected
    try std.testing.expectEqual(@as(u8, 1), ids.ids_trigger_alert(slot, 0));
    try std.testing.expectEqual(@as(u8, 1), ids.ids_escalate_alert(slot));
    try std.testing.expectEqual(@as(u8, 1), ids.ids_acknowledge_alert(slot));
    try std.testing.expectEqual(@as(u8, 1), ids.ids_close_alert(slot));
    try std.testing.expectEqual(@as(u8, 1), ids.ids_auto_close_alert(slot));
}

test "trigger rejects invalid severity tag" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_trigger_alert(slot, 99));
    try std.testing.expectEqual(@as(u8, 0), ids.ids_alert_state(slot)); // still idle
}

// =========================================================================
// Default action configuration
// =========================================================================

test "set_default_action changes no-match result" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);

    _ = ids.ids_set_default_action(slot, 1); // drop
    _ = ids.ids_decode_packet(slot, 0, 0, 0, 0, 0, 0);
    _ = ids.ids_begin_inspection(slot);
    _ = ids.ids_evaluate_rules(slot);

    try std.testing.expectEqual(@as(u8, 1), ids.ids_get_action(slot)); // drop
}

test "set_default_action rejects invalid action tag" {
    const slot = ids.ids_create_context();
    defer ids.ids_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), ids.ids_set_default_action(slot, 99));
}

// =========================================================================
// Stateless inspection transition table
// =========================================================================

test "ids_can_inspection_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_inspection_transition(0, 1)); // Captured -> Decoded
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_inspection_transition(1, 2)); // Decoded -> Inspecting
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_inspection_transition(2, 3)); // Inspecting -> Evaluated
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_inspection_transition(3, 4)); // Evaluated -> Disposed
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_inspection_transition(0, 4)); // Captured -> Disposed (abort)
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_inspection_transition(1, 4)); // Decoded -> Disposed (abort)
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_inspection_transition(2, 4)); // Inspecting -> Disposed (abort)

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_inspection_transition(4, 0)); // Disposed is terminal
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_inspection_transition(4, 1)); // Disposed is terminal
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_inspection_transition(0, 3)); // Cannot skip to Evaluated
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_inspection_transition(3, 0)); // Cannot go backwards
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_inspection_transition(2, 0)); // Cannot go backwards
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_inspection_transition(3, 1)); // Cannot go backwards
}

// =========================================================================
// Stateless alert transition table
// =========================================================================

test "ids_can_alert_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_alert_transition(0, 1)); // Idle -> Triggered
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_alert_transition(1, 2)); // Triggered -> Escalated
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_alert_transition(1, 3)); // Triggered -> Acknowledged
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_alert_transition(2, 3)); // Escalated -> Acknowledged
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_alert_transition(3, 4)); // Acknowledged -> Closed
    try std.testing.expectEqual(@as(u8, 1), ids.ids_can_alert_transition(1, 4)); // Triggered -> Closed (auto)

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_alert_transition(4, 0)); // Closed is terminal
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_alert_transition(4, 1)); // Closed is terminal
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_alert_transition(0, 2)); // Cannot skip to Escalated
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_alert_transition(0, 4)); // Cannot skip to Closed
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_alert_transition(2, 4)); // Cannot close from Escalated
    try std.testing.expectEqual(@as(u8, 0), ids.ids_can_alert_transition(1, 1)); // Cannot double trigger
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 4), ids.ids_inspection_state(-1));    // disposed fallback
    try std.testing.expectEqual(@as(u8, 4), ids.ids_alert_state(-1));         // closed fallback
    try std.testing.expectEqual(@as(u8, 4), ids.ids_get_action(-1));          // pass fallback
    try std.testing.expectEqual(@as(u8, 0), ids.ids_get_match_status(-1));    // no_match fallback
    try std.testing.expectEqual(@as(u8, 0), ids.ids_get_match_severity(-1));  // low fallback
    try std.testing.expectEqual(@as(u8, 0), ids.ids_get_match_detection(-1)); // signature fallback
    try std.testing.expectEqual(@as(u8, 0), ids.ids_get_threat_level(-1));    // info fallback
    try std.testing.expectEqual(@as(u16, 0), ids.ids_rule_count(-1));
    try std.testing.expectEqual(@as(u16, 0), ids.ids_alert_count(-1));
    try std.testing.expectEqual(@as(u8, 0), ids.ids_packet_proto(-1));
    try std.testing.expectEqual(@as(u8, 0), ids.ids_packet_direction(-1));
    try std.testing.expectEqual(@as(u32, 0), ids.ids_packet_src_ip(-1));
    try std.testing.expectEqual(@as(u32, 0), ids.ids_packet_dst_ip(-1));
    try std.testing.expectEqual(@as(u16, 0), ids.ids_packet_src_port(-1));
    try std.testing.expectEqual(@as(u16, 0), ids.ids_packet_dst_port(-1));
    try std.testing.expectEqual(@as(u8, 0), ids.ids_get_alert_severity(-1));
}

// =========================================================================
// Slot exhaustion
// =========================================================================

test "pool exhaustion returns -1" {
    var slots: [64]c_int = undefined;
    var count: usize = 0;
    for (&slots) |*s| {
        s.* = ids.ids_create_context();
        if (s.* >= 0) count += 1;
    }
    defer {
        for (slots[0..count]) |s| ids.ids_destroy_context(s);
    }

    // 65th should fail
    try std.testing.expectEqual(@as(c_int, -1), ids.ids_create_context());
}
