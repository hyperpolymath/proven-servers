// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-deception FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Server lifecycle (create/destroy)
//   - Decoy deployment (deploy/remove/count)
//   - Trigger and response handling
//   - Alert tracking
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const deception = @import("deception");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), deception.deception_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "DecoyType encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(deception.DecoyType.service));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(deception.DecoyType.credential));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(deception.DecoyType.file));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(deception.DecoyType.network));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(deception.DecoyType.token));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(deception.DecoyType.breadcrumb));
}

test "TriggerEvent encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(deception.TriggerEvent.access));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(deception.TriggerEvent.login));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(deception.TriggerEvent.read));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(deception.TriggerEvent.write));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(deception.TriggerEvent.execute));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(deception.TriggerEvent.scan));
}

test "AlertPriority encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(deception.AlertPriority.low));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(deception.AlertPriority.medium));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(deception.AlertPriority.high));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(deception.AlertPriority.critical));
}

test "ServerState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(deception.ServerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(deception.ServerState.configured));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(deception.ServerState.monitoring));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(deception.ServerState.responding));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(deception.ServerState.shutdown));
}

// =========================================================================
// Server lifecycle
// =========================================================================

test "create returns valid slot in Configured state" {
    const slot = deception.deception_create();
    try std.testing.expect(slot >= 0);
    defer deception.deception_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), deception.deception_state(slot)); // Configured
}

test "destroy is safe with invalid slot" {
    deception.deception_destroy(-1);
    deception.deception_destroy(999);
}

// =========================================================================
// Decoy deployment
// =========================================================================

test "deploy_decoy transitions Configured -> Monitoring" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "fake-ssh";
    try std.testing.expectEqual(@as(u8, 0), deception.deception_deploy_decoy(
        slot, name.ptr, name.len, 0, // Service type
    ));
    try std.testing.expectEqual(@as(u8, 2), deception.deception_state(slot)); // Monitoring
    try std.testing.expectEqual(@as(u32, 1), deception.deception_decoy_count(slot));
}

test "deploy_decoy rejects invalid type" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "bad-decoy";
    try std.testing.expectEqual(@as(u8, 1), deception.deception_deploy_decoy(
        slot, name.ptr, name.len, 99,
    ));
}

test "deploy_decoy rejects duplicate name" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "fake-ssh";
    _ = deception.deception_deploy_decoy(slot, name.ptr, name.len, 0);
    try std.testing.expectEqual(@as(u8, 1), deception.deception_deploy_decoy(
        slot, name.ptr, name.len, 1,
    ));
}

test "remove_decoy last decoy transitions Monitoring -> Configured" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "fake-ssh";
    _ = deception.deception_deploy_decoy(slot, name.ptr, name.len, 0);
    try std.testing.expectEqual(@as(u8, 2), deception.deception_state(slot));

    try std.testing.expectEqual(@as(u8, 0), deception.deception_remove_decoy(
        slot, name.ptr, name.len,
    ));
    try std.testing.expectEqual(@as(u8, 1), deception.deception_state(slot)); // Configured
    try std.testing.expectEqual(@as(u32, 0), deception.deception_decoy_count(slot));
}

// =========================================================================
// Trigger and response
// =========================================================================

test "trigger transitions Monitoring -> Responding" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "fake-ssh";
    _ = deception.deception_deploy_decoy(slot, name.ptr, name.len, 0);

    try std.testing.expectEqual(@as(u8, 0), deception.deception_trigger(
        slot, name.ptr, name.len, 0, 2, // Access event, High priority
    ));
    try std.testing.expectEqual(@as(u8, 3), deception.deception_state(slot)); // Responding
    try std.testing.expectEqual(@as(u32, 1), deception.deception_alert_count(slot));
}

test "trigger rejects invalid event" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "fake-ssh";
    _ = deception.deception_deploy_decoy(slot, name.ptr, name.len, 0);

    try std.testing.expectEqual(@as(u8, 1), deception.deception_trigger(
        slot, name.ptr, name.len, 99, 0,
    ));
}

test "respond resolves alert and returns to Monitoring" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "fake-ssh";
    _ = deception.deception_deploy_decoy(slot, name.ptr, name.len, 0);
    _ = deception.deception_trigger(slot, name.ptr, name.len, 0, 2);

    try std.testing.expectEqual(@as(u8, 0), deception.deception_respond(
        slot, name.ptr, name.len, 0, // Alert action
    ));
    try std.testing.expectEqual(@as(u8, 2), deception.deception_state(slot)); // Monitoring
    try std.testing.expectEqual(@as(u32, 0), deception.deception_alert_count(slot));
}

test "can_monitor returns 1 from Monitoring" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "fake-ssh";
    _ = deception.deception_deploy_decoy(slot, name.ptr, name.len, 0);
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_monitor(slot));
}

test "can_monitor returns 0 from Configured" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), deception.deception_can_monitor(slot));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Configured -> Shutdown" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), deception.deception_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), deception.deception_state(slot));
}

test "shutdown transitions Monitoring -> Shutdown" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "fake-ssh";
    _ = deception.deception_deploy_decoy(slot, name.ptr, name.len, 0);

    try std.testing.expectEqual(@as(u8, 0), deception.deception_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), deception.deception_state(slot));
}

test "cleanup transitions Shutdown -> Idle" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    _ = deception.deception_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), deception.deception_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), deception.deception_state(slot)); // Idle
}

test "cleanup clears decoys and alerts" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "fake-ssh";
    _ = deception.deception_deploy_decoy(slot, name.ptr, name.len, 0);
    _ = deception.deception_trigger(slot, name.ptr, name.len, 0, 2);

    _ = deception.deception_shutdown(slot);
    _ = deception.deception_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), deception.deception_decoy_count(slot));
    try std.testing.expectEqual(@as(u32, 0), deception.deception_alert_count(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), deception.deception_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "deception_can_transition matches Types.idr" {
    // Forward lifecycle
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(0, 1)); // Idle -> Configured
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(1, 2)); // Configured -> Monitoring
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(2, 2)); // Monitoring -> Monitoring
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(2, 1)); // Monitoring -> Configured
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(2, 3)); // Monitoring -> Responding
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(3, 3)); // Responding -> Responding
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(3, 2)); // Responding -> Monitoring

    // Shutdown edges
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(1, 4)); // Configured -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(2, 4)); // Monitoring -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(3, 4)); // Responding -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), deception.deception_can_transition(4, 0)); // Shutdown -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), deception.deception_can_transition(0, 2)); // Idle -/-> Monitoring
    try std.testing.expectEqual(@as(u8, 0), deception.deception_can_transition(0, 3)); // Idle -/-> Responding
    try std.testing.expectEqual(@as(u8, 0), deception.deception_can_transition(4, 1)); // Shutdown -/-> Configured
    try std.testing.expectEqual(@as(u8, 0), deception.deception_can_transition(0, 4)); // Idle -/-> Shutdown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), deception.deception_state(-1));
    try std.testing.expectEqual(@as(u8, 0), deception.deception_can_monitor(-1));
    try std.testing.expectEqual(@as(u32, 0), deception.deception_decoy_count(-1));
    try std.testing.expectEqual(@as(u32, 0), deception.deception_alert_count(-1));
    try std.testing.expectEqual(@as(u8, 1), deception.deception_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), deception.deception_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot deploy decoy from Idle" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    _ = deception.deception_shutdown(slot);
    _ = deception.deception_cleanup(slot);
    const name = "decoy";
    try std.testing.expectEqual(@as(u8, 1), deception.deception_deploy_decoy(
        slot, name.ptr, name.len, 0,
    ));
}

test "cannot trigger from Configured" {
    const slot = deception.deception_create();
    defer deception.deception_destroy(slot);

    const name = "decoy";
    try std.testing.expectEqual(@as(u8, 1), deception.deception_trigger(
        slot, name.ptr, name.len, 0, 0,
    ));
}
