// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-container FFI.
//
// Verifies that the Zig implementation matches the Idris2 formal
// specification in ContainerABI.Types.

const std = @import("std");
const ct = @import("container");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ct.container_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ContainerState encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ct.ContainerState.creating));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ct.ContainerState.running));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ct.ContainerState.paused));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ct.ContainerState.restarting));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ct.ContainerState.stopped));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ct.ContainerState.removing));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ct.ContainerState.dead));
}

test "Operation encoding matches Types.idr (11 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ct.Operation.create));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ct.Operation.start));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ct.Operation.stop));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ct.Operation.restart));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ct.Operation.pause));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ct.Operation.unpause));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ct.Operation.kill));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ct.Operation.remove));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(ct.Operation.exec));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(ct.Operation.logs));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(ct.Operation.inspect));
}

test "NetworkMode encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ct.NetworkMode.bridge));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ct.NetworkMode.host));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ct.NetworkMode.none));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ct.NetworkMode.overlay));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ct.NetworkMode.macvlan));
}

test "VolumeType encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ct.VolumeType.bind));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ct.VolumeType.named));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ct.VolumeType.tmpfs));
}

test "RestartPolicy encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ct.RestartPolicy.no));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ct.RestartPolicy.always));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ct.RestartPolicy.on_failure));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ct.RestartPolicy.unless_stopped));
}

test "HealthStatus encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ct.HealthStatus.starting));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ct.HealthStatus.healthy));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ct.HealthStatus.unhealthy));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ct.HealthStatus.no_check));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot in Creating state" {
    const slot = ct.container_create(0, 1); // Bridge, Always
    try std.testing.expect(slot >= 0);
    defer ct.container_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ct.container_state(slot)); // Creating
    try std.testing.expectEqual(@as(u8, 0), ct.container_network_mode(slot)); // Bridge
    try std.testing.expectEqual(@as(u8, 1), ct.container_restart_policy(slot)); // Always
}

test "create rejects invalid network mode" {
    try std.testing.expectEqual(@as(c_int, -1), ct.container_create(99, 0));
}

test "create rejects invalid restart policy" {
    try std.testing.expectEqual(@as(c_int, -1), ct.container_create(0, 99));
}

test "destroy is safe with invalid slot" {
    ct.container_destroy(-1);
    ct.container_destroy(999);
}

// =========================================================================
// State machine: full lifecycle
// =========================================================================

test "full lifecycle: Creating -> Stopped -> Running -> Stopped -> Removing" {
    const slot = ct.container_create(0, 0);
    defer ct.container_destroy(slot);

    // Creating -> Stopped (create op)
    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 0)); // Create
    try std.testing.expectEqual(@as(u8, 4), ct.container_state(slot)); // Stopped

    // Stopped -> Running (start op)
    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 1)); // Start
    try std.testing.expectEqual(@as(u8, 1), ct.container_state(slot)); // Running
    try std.testing.expectEqual(@as(u8, 1), ct.container_is_running(slot));

    // Running -> Stopped (stop op)
    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 2)); // Stop
    try std.testing.expectEqual(@as(u8, 4), ct.container_state(slot)); // Stopped
    try std.testing.expectEqual(@as(u8, 0), ct.container_is_running(slot));

    // Stopped -> Removing (remove op)
    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 7)); // Remove
    try std.testing.expectEqual(@as(u8, 5), ct.container_state(slot)); // Removing
}

// =========================================================================
// State machine: pause/unpause
// =========================================================================

test "pause and unpause" {
    const slot = ct.container_create(0, 0);
    defer ct.container_destroy(slot);

    _ = ct.container_apply_op(slot, 0); // Create
    _ = ct.container_apply_op(slot, 1); // Start

    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 4)); // Pause
    try std.testing.expectEqual(@as(u8, 2), ct.container_state(slot)); // Paused

    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 5)); // Unpause
    try std.testing.expectEqual(@as(u8, 1), ct.container_state(slot)); // Running
}

test "cannot pause a stopped container" {
    const slot = ct.container_create(0, 0);
    defer ct.container_destroy(slot);

    _ = ct.container_apply_op(slot, 0); // Create -> Stopped
    try std.testing.expectEqual(@as(u8, 1), ct.container_apply_op(slot, 4)); // Pause rejected
}

// =========================================================================
// State machine: restart
// =========================================================================

test "restart increments restart count" {
    const slot = ct.container_create(0, 0);
    defer ct.container_destroy(slot);

    _ = ct.container_apply_op(slot, 0); // Create
    _ = ct.container_apply_op(slot, 1); // Start

    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 3)); // Restart
    try std.testing.expectEqual(@as(u8, 1), ct.container_state(slot)); // Running (auto-transition)
    try std.testing.expectEqual(@as(u32, 1), ct.container_restart_count(slot));

    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 3)); // Restart again
    try std.testing.expectEqual(@as(u32, 2), ct.container_restart_count(slot));
}

// =========================================================================
// State machine: kill
// =========================================================================

test "kill stops a running container" {
    const slot = ct.container_create(0, 0);
    defer ct.container_destroy(slot);

    _ = ct.container_apply_op(slot, 0); // Create
    _ = ct.container_apply_op(slot, 1); // Start

    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 6)); // Kill
    try std.testing.expectEqual(@as(u8, 4), ct.container_state(slot)); // Stopped
}

test "kill stops a paused container" {
    const slot = ct.container_create(0, 0);
    defer ct.container_destroy(slot);

    _ = ct.container_apply_op(slot, 0); // Create
    _ = ct.container_apply_op(slot, 1); // Start
    _ = ct.container_apply_op(slot, 4); // Pause

    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 6)); // Kill
    try std.testing.expectEqual(@as(u8, 4), ct.container_state(slot)); // Stopped
}

// =========================================================================
// State machine: exec
// =========================================================================

test "exec only works on running container" {
    const slot = ct.container_create(0, 0);
    defer ct.container_destroy(slot);

    _ = ct.container_apply_op(slot, 0); // Create -> Stopped
    try std.testing.expectEqual(@as(u8, 1), ct.container_apply_op(slot, 8)); // Exec rejected

    _ = ct.container_apply_op(slot, 1); // Start
    try std.testing.expectEqual(@as(u8, 0), ct.container_apply_op(slot, 8)); // Exec ok
    try std.testing.expectEqual(@as(u8, 1), ct.container_state(slot)); // Still Running
}

// =========================================================================
// Health status
// =========================================================================

test "set and get health status" {
    const slot = ct.container_create(0, 0);
    defer ct.container_destroy(slot);

    try std.testing.expectEqual(@as(u8, 3), ct.container_health_status(slot)); // NoCheck
    try std.testing.expectEqual(@as(u8, 0), ct.container_set_health(slot, 1)); // Healthy
    try std.testing.expectEqual(@as(u8, 1), ct.container_health_status(slot));
}

test "set health rejects invalid tag" {
    const slot = ct.container_create(0, 0);
    defer ct.container_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ct.container_set_health(slot, 99));
}

// =========================================================================
// Invalid operation rejection
// =========================================================================

test "apply_op rejects invalid operation tag" {
    const slot = ct.container_create(0, 0);
    defer ct.container_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ct.container_apply_op(slot, 99));
}

test "apply_op rejects invalid slot" {
    try std.testing.expectEqual(@as(u8, 1), ct.container_apply_op(-1, 0));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "container_can_transition matches valid transitions" {
    // Creating -> Stopped
    try std.testing.expectEqual(@as(u8, 1), ct.container_can_transition(0, 4));
    // Stopped -> Running
    try std.testing.expectEqual(@as(u8, 1), ct.container_can_transition(4, 1));
    // Running -> Stopped
    try std.testing.expectEqual(@as(u8, 1), ct.container_can_transition(1, 4));
    // Running -> Paused
    try std.testing.expectEqual(@as(u8, 1), ct.container_can_transition(1, 2));
    // Paused -> Running
    try std.testing.expectEqual(@as(u8, 1), ct.container_can_transition(2, 1));
    // Running -> Restarting
    try std.testing.expectEqual(@as(u8, 1), ct.container_can_transition(1, 3));
    // Restarting -> Running
    try std.testing.expectEqual(@as(u8, 1), ct.container_can_transition(3, 1));
    // Stopped -> Removing
    try std.testing.expectEqual(@as(u8, 1), ct.container_can_transition(4, 5));
    // Dead -> Running
    try std.testing.expectEqual(@as(u8, 1), ct.container_can_transition(6, 1));

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), ct.container_can_transition(0, 1)); // Creating -> Running
    try std.testing.expectEqual(@as(u8, 0), ct.container_can_transition(5, 1)); // Removing -> Running
    try std.testing.expectEqual(@as(u8, 0), ct.container_can_transition(1, 0)); // Running -> Creating
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), ct.container_state(-1));
    try std.testing.expectEqual(@as(u8, 0), ct.container_network_mode(-1));
    try std.testing.expectEqual(@as(u8, 0), ct.container_restart_policy(-1));
    try std.testing.expectEqual(@as(u8, 3), ct.container_health_status(-1)); // NoCheck fallback
    try std.testing.expectEqual(@as(u32, 0), ct.container_restart_count(-1));
    try std.testing.expectEqual(@as(u8, 0), ct.container_is_running(-1));
}
