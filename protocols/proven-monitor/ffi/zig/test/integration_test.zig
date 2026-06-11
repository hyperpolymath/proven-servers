// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-monitor FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Check registration (add/remove/count)
//   - State transitions (start/pause/resume/shutdown/cleanup)
//   - Check execution and status queries
//   - Alert firing
//   - Stateless transition table
//   - Invalid slot safety

const std = @import("std");
const monitor = @import("monitor");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), monitor.monitor_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "CheckType encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(monitor.CheckType.http));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(monitor.CheckType.tcp));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(monitor.CheckType.udp));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(monitor.CheckType.icmp));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(monitor.CheckType.dns));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(monitor.CheckType.certificate));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(monitor.CheckType.disk));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(monitor.CheckType.cpu));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(monitor.CheckType.memory));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(monitor.CheckType.process));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(monitor.CheckType.custom));
}

test "Status encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(monitor.Status.up));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(monitor.Status.down));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(monitor.Status.degraded));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(monitor.Status.unknown));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(monitor.Status.maintenance));
}

test "Severity encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(monitor.Severity.info));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(monitor.Severity.warning));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(monitor.Severity.err));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(monitor.Severity.critical));
}

test "MonitorState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(monitor.MonitorState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(monitor.MonitorState.configured));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(monitor.MonitorState.running_state));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(monitor.MonitorState.paused));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(monitor.MonitorState.alerting));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(monitor.MonitorState.shutdown));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Configured state" {
    const name = "test-monitor";
    const slot = monitor.monitor_create(name.ptr, name.len, 30000);
    try std.testing.expect(slot >= 0);
    defer monitor.monitor_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_state(slot)); // Configured
}

test "create rejects empty name" {
    const name = "x";
    const slot = monitor.monitor_create(name.ptr, 0, 30000);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects zero interval" {
    const name = "bad";
    const slot = monitor.monitor_create(name.ptr, name.len, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    monitor.monitor_destroy(-1);
    monitor.monitor_destroy(999);
}

// =========================================================================
// Check management
// =========================================================================

test "add_check registers a check" {
    const name = "check-test";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    const target = "https://example.com";
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_add_check(
        slot, 0, target.ptr, target.len, 1,
    ));
    try std.testing.expectEqual(@as(u32, 1), monitor.monitor_check_count(slot));
}

test "add_check rejects invalid check type" {
    const name = "check-test2";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    const target = "host";
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_add_check(
        slot, 99, target.ptr, target.len, 0,
    ));
}

test "add_check rejects invalid severity" {
    const name = "check-test3";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    const target = "host";
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_add_check(
        slot, 0, target.ptr, target.len, 99,
    ));
}

test "remove_check removes a check" {
    const name = "remove-test";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    const target = "host";
    _ = monitor.monitor_add_check(slot, 0, target.ptr, target.len, 0);
    try std.testing.expectEqual(@as(u32, 1), monitor.monitor_check_count(slot));

    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_remove_check(slot, 0));
    try std.testing.expectEqual(@as(u32, 0), monitor.monitor_check_count(slot));
}

// =========================================================================
// State transitions
// =========================================================================

test "start transitions Configured -> Running" {
    const name = "start-test";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_start(slot));
    try std.testing.expectEqual(@as(u8, 2), monitor.monitor_state(slot)); // Running
}

test "pause transitions Running -> Paused" {
    const name = "pause-test";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    _ = monitor.monitor_start(slot);
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_pause(slot));
    try std.testing.expectEqual(@as(u8, 3), monitor.monitor_state(slot)); // Paused
}

test "resume transitions Paused -> Running" {
    const name = "resume-test";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    _ = monitor.monitor_start(slot);
    _ = monitor.monitor_pause(slot);
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_resume(slot));
    try std.testing.expectEqual(@as(u8, 2), monitor.monitor_state(slot)); // Running
}

test "shutdown transitions Running -> Shutdown" {
    const name = "shutdown-test";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    _ = monitor.monitor_start(slot);
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 5), monitor.monitor_state(slot)); // Shutdown
}

test "cleanup transitions Shutdown -> Idle" {
    const name = "cleanup-test";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    _ = monitor.monitor_start(slot);
    _ = monitor.monitor_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_state(slot)); // Idle
}

test "cleanup rejected from non-Shutdown state" {
    const name = "cleanup-rej";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_cleanup(slot));
}

// =========================================================================
// Check execution
// =========================================================================

test "run_check returns Passed on active check" {
    const name = "run-test";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);

    const target = "https://example.com";
    _ = monitor.monitor_add_check(slot, 0, target.ptr, target.len, 0);
    _ = monitor.monitor_start(slot);

    try std.testing.expectEqual(@as(u8, 2), monitor.monitor_run_check(slot, 0)); // Passed
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_check_status(slot, 0)); // Up
}

test "run_check fails on inactive session" {
    const name = "run-fail";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);
    // Session is in Configured, not Running
    try std.testing.expectEqual(@as(u8, 5), monitor.monitor_run_check(slot, 0)); // CSError
}

// =========================================================================
// Alert firing
// =========================================================================

test "fire_alert transitions Running -> Alerting" {
    const name = "alert-test";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);
    _ = monitor.monitor_start(slot);

    const msg = "CPU high";
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_fire_alert(
        slot, 0, 2, msg.ptr, msg.len,
    ));
    try std.testing.expectEqual(@as(u8, 4), monitor.monitor_state(slot)); // Alerting
}

test "fire_alert rejects invalid channel" {
    const name = "alert-bad";
    const slot = monitor.monitor_create(name.ptr, name.len, 60000);
    defer monitor.monitor_destroy(slot);
    _ = monitor.monitor_start(slot);

    const msg = "x";
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_fire_alert(
        slot, 99, 0, msg.ptr, msg.len,
    ));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "monitor_can_transition matches state machine" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_can_transition(0, 1)); // Idle -> Configured
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_can_transition(1, 2)); // Configured -> Running
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_can_transition(2, 3)); // Running -> Paused
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_can_transition(3, 2)); // Paused -> Running
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_can_transition(2, 4)); // Running -> Alerting
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_can_transition(4, 2)); // Alerting -> Running
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_can_transition(2, 5)); // Running -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_can_transition(5, 0)); // Shutdown -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_can_transition(0, 2)); // Idle -/-> Running
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_can_transition(0, 4)); // Idle -/-> Alerting
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_can_transition(5, 2)); // Shutdown -/-> Running
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), monitor.monitor_state(-1));
    try std.testing.expectEqual(@as(u32, 0), monitor.monitor_check_count(-1));
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_start(-1));
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), monitor.monitor_cleanup(-1));
}
