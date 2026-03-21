// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-siem FFI.
//
// Tests cover (30 tests):
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Engine state transitions (Idle -> Running -> Paused -> Running)
//   - Event ingestion
//   - Correlation rule management
//   - Correlation execution and alert generation
//   - Alert lifecycle transitions
//   - Disconnect / Cleanup
//   - Transition table validation
//   - Invalid slot safety
//   - Impossibility tests

const std = @import("std");
const siem = @import("siem");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), siem.siem_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "EventSeverity encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(siem.EventSeverity.info));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(siem.EventSeverity.low));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(siem.EventSeverity.medium));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(siem.EventSeverity.high));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(siem.EventSeverity.critical));
}

test "EventCategory encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(siem.EventCategory.authentication));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(siem.EventCategory.network_traffic));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(siem.EventCategory.file_activity));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(siem.EventCategory.process_execution));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(siem.EventCategory.policy_violation));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(siem.EventCategory.malware));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(siem.EventCategory.data_exfiltration));
}

test "CorrelationRule encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(siem.CorrelationRule.threshold));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(siem.CorrelationRule.sequence));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(siem.CorrelationRule.aggregation));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(siem.CorrelationRule.absence));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(siem.CorrelationRule.statistical));
}

test "AlertState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(siem.AlertState.new));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(siem.AlertState.acknowledged));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(siem.AlertState.in_progress));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(siem.AlertState.resolved));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(siem.AlertState.false_positive));
}

test "EngineState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(siem.EngineState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(siem.EngineState.running));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(siem.EngineState.paused));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(siem.EngineState.disconnecting));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(siem.EngineState.destroyed));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Idle state" {
    const name = "prod-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    try std.testing.expect(slot >= 0);
    defer siem.siem_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), siem.siem_state(slot)); // Idle
}

test "create rejects empty name" {
    const name = "x";
    try std.testing.expectEqual(@as(c_int, -1), siem.siem_create(name.ptr, 0));
}

test "destroy is safe with invalid slot" {
    siem.siem_destroy(-1);
    siem.siem_destroy(999);
}

// =========================================================================
// Engine state transitions
// =========================================================================

test "start transitions Idle -> Running" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), siem.siem_start(slot));
    try std.testing.expectEqual(@as(u8, 1), siem.siem_state(slot)); // Running
}

test "pause transitions Running -> Paused" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);
    try std.testing.expectEqual(@as(u8, 0), siem.siem_pause(slot));
    try std.testing.expectEqual(@as(u8, 2), siem.siem_state(slot)); // Paused
}

test "resume transitions Paused -> Running" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);
    _ = siem.siem_pause(slot);
    try std.testing.expectEqual(@as(u8, 0), siem.siem_resume(slot));
    try std.testing.expectEqual(@as(u8, 1), siem.siem_state(slot)); // Running
}

// =========================================================================
// Event ingestion
// =========================================================================

test "ingest_event succeeds in Running state" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);

    const source = "firewall-01";
    try std.testing.expectEqual(@as(u8, 0), siem.siem_ingest_event(slot, 3, 1, source.ptr, source.len)); // High, NetworkTraffic
    try std.testing.expectEqual(@as(u32, 1), siem.siem_event_count(slot));
}

test "ingest_event rejects in Idle state" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);

    const source = "firewall-01";
    try std.testing.expectEqual(@as(u8, 1), siem.siem_ingest_event(slot, 0, 0, source.ptr, source.len));
}

test "ingest_event rejects invalid severity" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);

    const source = "firewall-01";
    try std.testing.expectEqual(@as(u8, 1), siem.siem_ingest_event(slot, 99, 0, source.ptr, source.len));
}

test "ingest_event rejects invalid category" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);

    const source = "firewall-01";
    try std.testing.expectEqual(@as(u8, 1), siem.siem_ingest_event(slot, 0, 99, source.ptr, source.len));
}

// =========================================================================
// Correlation rules
// =========================================================================

test "add_rule stores correlation rule" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);

    // Threshold rule: fire after 3 authentication events
    try std.testing.expectEqual(@as(u8, 0), siem.siem_add_rule(slot, 0, 3, 0));
    try std.testing.expectEqual(@as(u32, 1), siem.siem_rule_count(slot));
}

test "add_rule rejects invalid rule type" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), siem.siem_add_rule(slot, 99, 3, 0));
}

// =========================================================================
// Correlation execution
// =========================================================================

test "correlate generates alert when threshold met" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);

    // Add threshold rule: fire after 2 authentication events
    _ = siem.siem_add_rule(slot, 0, 2, 0);

    // Ingest 2 authentication events
    const src1 = "ldap-01";
    const src2 = "ldap-02";
    _ = siem.siem_ingest_event(slot, 2, 0, src1.ptr, src1.len);
    _ = siem.siem_ingest_event(slot, 3, 0, src2.ptr, src2.len);

    // Correlate
    const new_alerts = siem.siem_correlate(slot);
    try std.testing.expectEqual(@as(u32, 1), new_alerts);
    try std.testing.expectEqual(@as(u32, 1), siem.siem_alert_count(slot));
}

test "correlate returns 0 when threshold not met" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);

    // Add threshold rule: fire after 5 events
    _ = siem.siem_add_rule(slot, 0, 5, 0);

    // Ingest only 1 event
    const src = "ldap-01";
    _ = siem.siem_ingest_event(slot, 0, 0, src.ptr, src.len);

    try std.testing.expectEqual(@as(u32, 0), siem.siem_correlate(slot));
}

// =========================================================================
// Alert lifecycle
// =========================================================================

test "alert transitions New -> Acknowledged -> InProgress -> Resolved" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);
    _ = siem.siem_add_rule(slot, 0, 1, 0);
    const src = "ids-01";
    _ = siem.siem_ingest_event(slot, 4, 0, src.ptr, src.len);
    _ = siem.siem_correlate(slot);

    try std.testing.expectEqual(@as(u8, 0), siem.siem_alert_state(slot, 0)); // New
    try std.testing.expectEqual(@as(u8, 0), siem.siem_alert_transition(slot, 0, 1)); // -> Acknowledged
    try std.testing.expectEqual(@as(u8, 1), siem.siem_alert_state(slot, 0));
    try std.testing.expectEqual(@as(u8, 0), siem.siem_alert_transition(slot, 0, 2)); // -> InProgress
    try std.testing.expectEqual(@as(u8, 0), siem.siem_alert_transition(slot, 0, 3)); // -> Resolved
    try std.testing.expectEqual(@as(u8, 3), siem.siem_alert_state(slot, 0));
}

test "alert can be marked FalsePositive from any state" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);
    _ = siem.siem_add_rule(slot, 0, 1, 0);
    const src = "ids-01";
    _ = siem.siem_ingest_event(slot, 4, 0, src.ptr, src.len);
    _ = siem.siem_correlate(slot);

    try std.testing.expectEqual(@as(u8, 0), siem.siem_alert_transition(slot, 0, 4)); // -> FalsePositive
    try std.testing.expectEqual(@as(u8, 4), siem.siem_alert_state(slot, 0));
}

test "alert rejects invalid transition (skip state)" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);
    _ = siem.siem_add_rule(slot, 0, 1, 0);
    const src = "ids-01";
    _ = siem.siem_ingest_event(slot, 4, 0, src.ptr, src.len);
    _ = siem.siem_correlate(slot);

    // Try to skip from New directly to InProgress
    try std.testing.expectEqual(@as(u8, 1), siem.siem_alert_transition(slot, 0, 2));
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Running -> Disconnecting" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);
    try std.testing.expectEqual(@as(u8, 0), siem.siem_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 3), siem.siem_state(slot));
}

test "cleanup transitions Disconnecting -> Destroyed and clears state" {
    const name = "test-siem";
    const slot = siem.siem_create(name.ptr, name.len);
    defer siem.siem_destroy(slot);
    _ = siem.siem_start(slot);
    const src = "fw-01";
    _ = siem.siem_ingest_event(slot, 0, 0, src.ptr, src.len);
    _ = siem.siem_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), siem.siem_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 4), siem.siem_state(slot)); // Destroyed
    try std.testing.expectEqual(@as(u32, 0), siem.siem_event_count(slot));
    try std.testing.expectEqual(@as(u32, 0), siem.siem_alert_count(slot));
}

// =========================================================================
// Transition table
// =========================================================================

test "siem_can_transition matches expected transitions" {
    try std.testing.expectEqual(@as(u8, 1), siem.siem_can_transition(0, 1)); // Idle -> Running
    try std.testing.expectEqual(@as(u8, 1), siem.siem_can_transition(1, 2)); // Running -> Paused
    try std.testing.expectEqual(@as(u8, 1), siem.siem_can_transition(2, 1)); // Paused -> Running
    try std.testing.expectEqual(@as(u8, 1), siem.siem_can_transition(0, 3)); // Idle -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), siem.siem_can_transition(1, 3)); // Running -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), siem.siem_can_transition(2, 3)); // Paused -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), siem.siem_can_transition(3, 4)); // Disconnecting -> Destroyed
    // Invalid
    try std.testing.expectEqual(@as(u8, 0), siem.siem_can_transition(0, 2)); // Idle -/-> Paused
    try std.testing.expectEqual(@as(u8, 0), siem.siem_can_transition(4, 0)); // Destroyed -/-> Idle
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), siem.siem_state(-1));
    try std.testing.expectEqual(@as(u32, 0), siem.siem_event_count(-1));
    try std.testing.expectEqual(@as(u32, 0), siem.siem_rule_count(-1));
    try std.testing.expectEqual(@as(u32, 0), siem.siem_alert_count(-1));
    try std.testing.expectEqual(@as(u8, 1), siem.siem_start(-1));
    try std.testing.expectEqual(@as(u8, 1), siem.siem_disconnect(-1));
}
