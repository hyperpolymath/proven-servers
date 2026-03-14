// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// firewall_test.zig -- Integration tests for proven-firewall FFI.

const std = @import("std");
const fw = @import("firewall");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), fw.fw_abi_version());
}

// =========================================================================
// Enum encoding seams -- Action (8 tags)
// =========================================================================

test "Action encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fw.Action.accept));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fw.Action.drop));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fw.Action.reject));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fw.Action.log));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fw.Action.redirect));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(fw.Action.dnat));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(fw.Action.snat));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(fw.Action.masquerade));
}

// =========================================================================
// Enum encoding seams -- Protocol (8 tags)
// =========================================================================

test "Protocol encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fw.Protocol.tcp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fw.Protocol.udp));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fw.Protocol.icmp));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fw.Protocol.icmpv6));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fw.Protocol.gre));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(fw.Protocol.esp));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(fw.Protocol.ah));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(fw.Protocol.any));
}

// =========================================================================
// Enum encoding seams -- ChainType (5 tags)
// =========================================================================

test "ChainType encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fw.ChainType.input));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fw.ChainType.output));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fw.ChainType.forward));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fw.ChainType.pre_routing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fw.ChainType.post_routing));
}

// =========================================================================
// Enum encoding seams -- RuleMatchType (8 tags)
// =========================================================================

test "RuleMatchType encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fw.RuleMatchType.source_ip));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fw.RuleMatchType.dest_ip));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fw.RuleMatchType.source_port));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fw.RuleMatchType.dest_port));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fw.RuleMatchType.match_proto));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(fw.RuleMatchType.interface));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(fw.RuleMatchType.state));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(fw.RuleMatchType.mark));
}

// =========================================================================
// Enum encoding seams -- ConnState (4 tags)
// =========================================================================

test "ConnState encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fw.ConnState.new));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fw.ConnState.established));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fw.ConnState.related));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fw.ConnState.invalid));
}

// =========================================================================
// Enum encoding seams -- PacketState (5 tags)
// =========================================================================

test "PacketState encoding matches Transitions.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fw.PacketState.arrived));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fw.PacketState.classified));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fw.PacketState.chain_traversal));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fw.PacketState.decided));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(fw.PacketState.committed));
}

// =========================================================================
// Enum encoding seams -- ConnTrackState (4 tags)
// =========================================================================

test "ConnTrackState encoding matches Transitions.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fw.ConnTrackState.untracked));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fw.ConnTrackState.tracking));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fw.ConnTrackState.tracked));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fw.ConnTrackState.expired));
}

// =========================================================================
// Lifecycle -- create and destroy
// =========================================================================

test "create returns valid slot" {
    const slot = fw.fw_create_context();
    try std.testing.expect(slot >= 0);
    defer fw.fw_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 0), fw.fw_packet_state(slot)); // arrived
    try std.testing.expectEqual(@as(u8, 0), fw.fw_conntrack_state(slot)); // untracked
}

test "destroy is safe with invalid slot" {
    fw.fw_destroy_context(-1);
    fw.fw_destroy_context(999);
}

// =========================================================================
// Full lifecycle -- Arrived -> Classified -> ChainTraversal -> Decided -> Committed
// =========================================================================

test "full lifecycle: Arrived -> Classified -> ChainTraversal -> Decided -> Committed" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    // Arrived -> Classified (TCP, INPUT, 192.168.1.100 -> 10.0.0.1, port 12345 -> 80)
    const src_ip: u32 = (192 << 24) | (168 << 16) | (1 << 8) | 100;
    const dst_ip: u32 = (10 << 24) | (0 << 16) | (0 << 8) | 1;
    try std.testing.expectEqual(@as(u8, 0), fw.fw_classify_packet(slot, 0, 0, src_ip, dst_ip, 12345, 80));
    try std.testing.expectEqual(@as(u8, 1), fw.fw_packet_state(slot)); // classified
    try std.testing.expectEqual(@as(u8, 0), fw.fw_packet_proto(slot)); // TCP
    try std.testing.expectEqual(@as(u8, 0), fw.fw_packet_chain(slot)); // INPUT
    try std.testing.expectEqual(src_ip, fw.fw_packet_src_ip(slot));
    try std.testing.expectEqual(dst_ip, fw.fw_packet_dst_ip(slot));
    try std.testing.expectEqual(@as(u16, 12345), fw.fw_packet_src_port(slot));
    try std.testing.expectEqual(@as(u16, 80), fw.fw_packet_dst_port(slot));

    // Classified -> ChainTraversal
    try std.testing.expectEqual(@as(u8, 0), fw.fw_begin_chain(slot));
    try std.testing.expectEqual(@as(u8, 2), fw.fw_packet_state(slot)); // chain_traversal

    // Add a rule: match dst_port 80, action=accept, priority=10
    try std.testing.expectEqual(@as(u8, 0), fw.fw_add_rule(slot, 3, 80, 0, 10));
    try std.testing.expectEqual(@as(u16, 1), fw.fw_rule_count(slot));

    // ChainTraversal -> Decided (evaluate rules)
    try std.testing.expectEqual(@as(u8, 0), fw.fw_evaluate_rules(slot));
    try std.testing.expectEqual(@as(u8, 3), fw.fw_packet_state(slot)); // decided
    try std.testing.expectEqual(@as(u8, 0), fw.fw_get_decision(slot)); // accept

    // Decided -> Committed
    try std.testing.expectEqual(@as(u8, 0), fw.fw_commit(slot));
    try std.testing.expectEqual(@as(u8, 4), fw.fw_packet_state(slot)); // committed
}

// =========================================================================
// Classify rejects invalid protocol/chain
// =========================================================================

test "classify rejects invalid protocol tag" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_classify_packet(slot, 99, 0, 0, 0, 0, 0));
    try std.testing.expectEqual(@as(u8, 0), fw.fw_packet_state(slot)); // still arrived
}

test "classify rejects invalid chain tag" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_classify_packet(slot, 0, 99, 0, 0, 0, 0));
}

// =========================================================================
// Default action applied when no rules match
// =========================================================================

test "default action applied when no rules match" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    _ = fw.fw_classify_packet(slot, 0, 0, 0, 0, 0, 80);
    _ = fw.fw_begin_chain(slot);

    // No rules added -- evaluate should apply default (drop=1)
    try std.testing.expectEqual(@as(u8, 0), fw.fw_evaluate_rules(slot));
    try std.testing.expectEqual(@as(u8, 1), fw.fw_get_decision(slot)); // drop (default)
}

test "set_default_action changes the default" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    // Change default to accept
    try std.testing.expectEqual(@as(u8, 0), fw.fw_set_default_action(slot, 0));

    _ = fw.fw_classify_packet(slot, 0, 0, 0, 0, 0, 80);
    _ = fw.fw_begin_chain(slot);
    _ = fw.fw_evaluate_rules(slot);
    try std.testing.expectEqual(@as(u8, 0), fw.fw_get_decision(slot)); // accept
}

test "set_default_action rejects invalid tag" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_set_default_action(slot, 99));
}

// =========================================================================
// Rule matching -- source IP
// =========================================================================

test "rule matches on source IP" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    const src_ip: u32 = (10 << 24) | (1 << 16) | (2 << 8) | 3;
    _ = fw.fw_classify_packet(slot, 0, 0, src_ip, 0, 0, 0);
    _ = fw.fw_begin_chain(slot);

    // Rule: match source_ip == 10.1.2.3, action=reject
    _ = fw.fw_add_rule(slot, 0, src_ip, 2, 10);
    _ = fw.fw_evaluate_rules(slot);
    try std.testing.expectEqual(@as(u8, 2), fw.fw_get_decision(slot)); // reject
}

// =========================================================================
// Rule matching -- destination IP
// =========================================================================

test "rule matches on destination IP" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    const dst_ip: u32 = (172 << 24) | (16 << 16) | (0 << 8) | 1;
    _ = fw.fw_classify_packet(slot, 1, 1, 0, dst_ip, 0, 0);
    _ = fw.fw_begin_chain(slot);

    // Rule: match dest_ip, action=drop
    _ = fw.fw_add_rule(slot, 1, dst_ip, 1, 5);
    _ = fw.fw_evaluate_rules(slot);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_get_decision(slot)); // drop
}

// =========================================================================
// Rule matching -- protocol
// =========================================================================

test "rule matches on protocol" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    _ = fw.fw_classify_packet(slot, 2, 0, 0, 0, 0, 0); // ICMP
    _ = fw.fw_begin_chain(slot);

    // Rule: match protocol=ICMP(2), action=accept
    _ = fw.fw_add_rule(slot, 4, 2, 0, 10);
    _ = fw.fw_evaluate_rules(slot);
    try std.testing.expectEqual(@as(u8, 0), fw.fw_get_decision(slot)); // accept
}

// =========================================================================
// Rule priority ordering
// =========================================================================

test "rules evaluated in priority order (lowest first)" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    const dst_ip: u32 = (10 << 24) | (0 << 16) | (0 << 8) | 1;
    _ = fw.fw_classify_packet(slot, 0, 0, 0, dst_ip, 0, 80);
    _ = fw.fw_begin_chain(slot);

    // Rule 1: match dst_port 80, action=drop, priority=20
    _ = fw.fw_add_rule(slot, 3, 80, 1, 20);
    // Rule 2: match dst_port 80, action=accept, priority=5 (higher priority)
    _ = fw.fw_add_rule(slot, 3, 80, 0, 5);

    _ = fw.fw_evaluate_rules(slot);
    // Priority 5 rule should win (accept)
    try std.testing.expectEqual(@as(u8, 0), fw.fw_get_decision(slot)); // accept
}

// =========================================================================
// Rule chain full (64 rules max)
// =========================================================================

test "rule chain rejects beyond 64 rules" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    _ = fw.fw_classify_packet(slot, 0, 0, 0, 0, 0, 0);
    _ = fw.fw_begin_chain(slot);

    // Fill all 64 slots
    var i: u16 = 0;
    while (i < 64) : (i += 1) {
        try std.testing.expectEqual(@as(u8, 0), fw.fw_add_rule(slot, 0, 0, 0, i));
    }
    try std.testing.expectEqual(@as(u16, 64), fw.fw_rule_count(slot));

    // 65th rule should be rejected
    try std.testing.expectEqual(@as(u8, 1), fw.fw_add_rule(slot, 0, 0, 0, 100));
}

// =========================================================================
// add_rule rejects invalid match_type and action
// =========================================================================

test "add_rule rejects invalid match type" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    _ = fw.fw_classify_packet(slot, 0, 0, 0, 0, 0, 0);
    _ = fw.fw_begin_chain(slot);

    try std.testing.expectEqual(@as(u8, 1), fw.fw_add_rule(slot, 99, 0, 0, 10));
}

test "add_rule rejects invalid action tag" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    _ = fw.fw_classify_packet(slot, 0, 0, 0, 0, 0, 0);
    _ = fw.fw_begin_chain(slot);

    try std.testing.expectEqual(@as(u8, 1), fw.fw_add_rule(slot, 0, 0, 99, 10));
}

// =========================================================================
// Connection tracking -- full lifecycle
// =========================================================================

test "connection tracking: Untracked -> Tracking -> Tracked -> Expired" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    // Untracked -> Tracking
    try std.testing.expectEqual(@as(u8, 0), fw.fw_begin_tracking(slot));
    try std.testing.expectEqual(@as(u8, 1), fw.fw_conntrack_state(slot)); // tracking

    // Tracking -> Tracked (Established)
    try std.testing.expectEqual(@as(u8, 0), fw.fw_complete_tracking(slot, 1));
    try std.testing.expectEqual(@as(u8, 2), fw.fw_conntrack_state(slot)); // tracked
    try std.testing.expectEqual(@as(u8, 1), fw.fw_conn_state(slot)); // established

    // Tracked -> Expired
    try std.testing.expectEqual(@as(u8, 0), fw.fw_expire_conn(slot));
    try std.testing.expectEqual(@as(u8, 3), fw.fw_conntrack_state(slot)); // expired
}

test "connection tracking: all 4 ConnState values" {
    // Test New
    const s1 = fw.fw_create_context();
    defer fw.fw_destroy_context(s1);
    _ = fw.fw_begin_tracking(s1);
    _ = fw.fw_complete_tracking(s1, 0);
    try std.testing.expectEqual(@as(u8, 0), fw.fw_conn_state(s1)); // new

    // Test Related
    const s2 = fw.fw_create_context();
    defer fw.fw_destroy_context(s2);
    _ = fw.fw_begin_tracking(s2);
    _ = fw.fw_complete_tracking(s2, 2);
    try std.testing.expectEqual(@as(u8, 2), fw.fw_conn_state(s2)); // related

    // Test Invalid
    const s3 = fw.fw_create_context();
    defer fw.fw_destroy_context(s3);
    _ = fw.fw_begin_tracking(s3);
    _ = fw.fw_complete_tracking(s3, 3);
    try std.testing.expectEqual(@as(u8, 3), fw.fw_conn_state(s3)); // invalid
}

test "begin_tracking rejects double tracking" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 0), fw.fw_begin_tracking(slot));
    try std.testing.expectEqual(@as(u8, 1), fw.fw_begin_tracking(slot)); // already tracking
}

test "complete_tracking rejects without begin" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_complete_tracking(slot, 0)); // not tracking
}

test "complete_tracking rejects invalid conn_state tag" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    _ = fw.fw_begin_tracking(slot);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_complete_tracking(slot, 99));
}

test "expire rejects when not tracked" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_expire_conn(slot)); // untracked
}

// =========================================================================
// Impossibility: wrong state transitions
// =========================================================================

test "cannot begin chain from Arrived (skip Classified)" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_begin_chain(slot));
}

test "cannot evaluate rules from Classified (skip ChainTraversal)" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    _ = fw.fw_classify_packet(slot, 0, 0, 0, 0, 0, 0);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_evaluate_rules(slot));
}

test "cannot commit from Arrived" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_commit(slot));
}

test "cannot classify after Committed (terminal)" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    // Complete full lifecycle
    _ = fw.fw_classify_packet(slot, 0, 0, 0, 0, 0, 0);
    _ = fw.fw_begin_chain(slot);
    _ = fw.fw_evaluate_rules(slot);
    _ = fw.fw_commit(slot);

    // Now in Committed state -- cannot classify again
    try std.testing.expectEqual(@as(u8, 4), fw.fw_packet_state(slot)); // committed
    try std.testing.expectEqual(@as(u8, 1), fw.fw_classify_packet(slot, 0, 0, 0, 0, 0, 0));
}

test "cannot add rules in Arrived state" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), fw.fw_add_rule(slot, 0, 0, 0, 10));
}

// =========================================================================
// Stateless transition tables
// =========================================================================

test "fw_can_transition matches Transitions.idr" {
    // Forward lifecycle sequence
    try std.testing.expectEqual(@as(u8, 1), fw.fw_can_transition(0, 1)); // Arrived -> Classified
    try std.testing.expectEqual(@as(u8, 1), fw.fw_can_transition(1, 2)); // Classified -> ChainTraversal
    try std.testing.expectEqual(@as(u8, 1), fw.fw_can_transition(2, 3)); // ChainTraversal -> Decided
    try std.testing.expectEqual(@as(u8, 1), fw.fw_can_transition(3, 4)); // Decided -> Committed

    // Abort edges
    try std.testing.expectEqual(@as(u8, 1), fw.fw_can_transition(0, 4)); // Arrived -> Committed
    try std.testing.expectEqual(@as(u8, 1), fw.fw_can_transition(1, 4)); // Classified -> Committed
    try std.testing.expectEqual(@as(u8, 1), fw.fw_can_transition(2, 4)); // ChainTraversal -> Committed

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), fw.fw_can_transition(4, 0)); // Committed -> Arrived (terminal!)
    try std.testing.expectEqual(@as(u8, 0), fw.fw_can_transition(4, 3)); // Committed -> Decided
    try std.testing.expectEqual(@as(u8, 0), fw.fw_can_transition(0, 3)); // Arrived -> Decided (skip!)
    try std.testing.expectEqual(@as(u8, 0), fw.fw_can_transition(3, 0)); // Decided -> Arrived (backwards!)
    try std.testing.expectEqual(@as(u8, 0), fw.fw_can_transition(2, 1)); // ChainTraversal -> Classified (backwards!)
}

test "fw_can_conntrack_transition matches Transitions.idr" {
    // Forward conntrack sequence
    try std.testing.expectEqual(@as(u8, 1), fw.fw_can_conntrack_transition(0, 1)); // Untracked -> Tracking
    try std.testing.expectEqual(@as(u8, 1), fw.fw_can_conntrack_transition(1, 2)); // Tracking -> Tracked
    try std.testing.expectEqual(@as(u8, 1), fw.fw_can_conntrack_transition(2, 3)); // Tracked -> Expired

    // Invalid conntrack transitions
    try std.testing.expectEqual(@as(u8, 0), fw.fw_can_conntrack_transition(3, 0)); // Expired -> Untracked (no revert!)
    try std.testing.expectEqual(@as(u8, 0), fw.fw_can_conntrack_transition(0, 2)); // Untracked -> Tracked (skip!)
    try std.testing.expectEqual(@as(u8, 0), fw.fw_can_conntrack_transition(0, 3)); // Untracked -> Expired (skip!)
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 4), fw.fw_packet_state(-1)); // committed fallback
    try std.testing.expectEqual(@as(u8, 0), fw.fw_conntrack_state(-1)); // untracked fallback
    try std.testing.expectEqual(@as(u8, 1), fw.fw_get_decision(-1)); // drop fallback
    try std.testing.expectEqual(@as(u16, 0), fw.fw_rule_count(-1));
    try std.testing.expectEqual(@as(u8, 255), fw.fw_packet_proto(-1));
    try std.testing.expectEqual(@as(u8, 255), fw.fw_packet_chain(-1));
    try std.testing.expectEqual(@as(u32, 0), fw.fw_packet_src_ip(-1));
    try std.testing.expectEqual(@as(u32, 0), fw.fw_packet_dst_ip(-1));
    try std.testing.expectEqual(@as(u16, 0), fw.fw_packet_src_port(-1));
    try std.testing.expectEqual(@as(u16, 0), fw.fw_packet_dst_port(-1));
    try std.testing.expectEqual(@as(u8, 255), fw.fw_conn_state(-1));
}

// =========================================================================
// NAT actions with connection tracking
// =========================================================================

test "DNAT action with tracked connection" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    // Set up connection tracking first
    _ = fw.fw_begin_tracking(slot);
    _ = fw.fw_complete_tracking(slot, 0); // New connection

    // Classify and walk chain
    _ = fw.fw_classify_packet(slot, 0, 3, 0, 0, 0, 80); // TCP, PreRouting
    _ = fw.fw_begin_chain(slot);

    // Rule: match dst_port 80, action=DNAT(5)
    _ = fw.fw_add_rule(slot, 3, 80, 5, 10);
    _ = fw.fw_evaluate_rules(slot);
    try std.testing.expectEqual(@as(u8, 5), fw.fw_get_decision(slot)); // DNAT

    _ = fw.fw_commit(slot);
    try std.testing.expectEqual(@as(u8, 4), fw.fw_packet_state(slot)); // committed
}

test "SNAT action with tracked connection" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    _ = fw.fw_begin_tracking(slot);
    _ = fw.fw_complete_tracking(slot, 1); // Established

    _ = fw.fw_classify_packet(slot, 0, 4, 0, 0, 0, 0); // TCP, PostRouting
    _ = fw.fw_begin_chain(slot);

    // Rule: match protocol TCP, action=SNAT(6)
    _ = fw.fw_add_rule(slot, 4, 0, 6, 10);
    _ = fw.fw_evaluate_rules(slot);
    try std.testing.expectEqual(@as(u8, 6), fw.fw_get_decision(slot)); // SNAT
}

test "Masquerade action" {
    const slot = fw.fw_create_context();
    defer fw.fw_destroy_context(slot);

    _ = fw.fw_classify_packet(slot, 0, 4, 0, 0, 0, 0); // TCP, PostRouting
    _ = fw.fw_begin_chain(slot);

    // Rule: match protocol TCP, action=Masquerade(7)
    _ = fw.fw_add_rule(slot, 4, 0, 7, 10);
    _ = fw.fw_evaluate_rules(slot);
    try std.testing.expectEqual(@as(u8, 7), fw.fw_get_decision(slot)); // masquerade
}
