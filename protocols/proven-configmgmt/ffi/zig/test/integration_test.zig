// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-configmgmt FFI.
//
// Verifies that the Zig implementation matches the Idris2 formal
// specification in ConfigmgmtABI.Types.

const std = @import("std");
const cm = @import("configmgmt");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), cm.configmgmt_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ResourceType encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cm.ResourceType.file));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cm.ResourceType.package));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cm.ResourceType.service));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cm.ResourceType.user));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(cm.ResourceType.group));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(cm.ResourceType.cron));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(cm.ResourceType.mount));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(cm.ResourceType.firewall));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(cm.ResourceType.registry));
}

test "ResourceState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cm.ResourceState.present));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cm.ResourceState.absent));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cm.ResourceState.running));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cm.ResourceState.stopped));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(cm.ResourceState.enabled));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(cm.ResourceState.disabled));
}

test "ChangeAction encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cm.ChangeAction.create));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cm.ChangeAction.modify));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cm.ChangeAction.delete));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cm.ChangeAction.restart));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(cm.ChangeAction.reload));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(cm.ChangeAction.skip));
}

test "DriftStatus encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cm.DriftStatus.in_sync));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cm.DriftStatus.drifted));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cm.DriftStatus.unknown));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cm.DriftStatus.unmanaged));
}

test "ApplyMode encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cm.ApplyMode.enforce));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cm.ApplyMode.dry_run));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cm.ApplyMode.audit));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot with correct config" {
    const slot = cm.configmgmt_create(2, 2, 0); // Service, Running, Enforce
    try std.testing.expect(slot >= 0);
    defer cm.configmgmt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 2), cm.configmgmt_resource_type(slot)); // Service
    try std.testing.expectEqual(@as(u8, 2), cm.configmgmt_desired_state(slot)); // Running
    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_apply_mode(slot)); // Enforce
}

test "create rejects invalid resource type" {
    try std.testing.expectEqual(@as(c_int, -1), cm.configmgmt_create(99, 0, 0));
}

test "create rejects invalid desired state" {
    try std.testing.expectEqual(@as(c_int, -1), cm.configmgmt_create(0, 99, 0));
}

test "create rejects invalid apply mode" {
    try std.testing.expectEqual(@as(c_int, -1), cm.configmgmt_create(0, 0, 99));
}

test "destroy is safe with invalid slot" {
    cm.configmgmt_destroy(-1);
    cm.configmgmt_destroy(999);
}

// =========================================================================
// Drift detection
// =========================================================================

test "drift status is unknown before setting observed" {
    const slot = cm.configmgmt_create(0, 0, 0); // File, Present, Enforce
    defer cm.configmgmt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 2), cm.configmgmt_drift_status(slot)); // Unknown
}

test "drift status is in_sync when desired equals observed" {
    const slot = cm.configmgmt_create(0, 0, 0); // File, Present, Enforce
    defer cm.configmgmt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_set_observed(slot, 0)); // Present
    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_drift_status(slot)); // InSync
}

test "drift status is drifted when desired differs from observed" {
    const slot = cm.configmgmt_create(0, 0, 0); // File, Present, Enforce
    defer cm.configmgmt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_set_observed(slot, 1)); // Absent
    try std.testing.expectEqual(@as(u8, 1), cm.configmgmt_drift_status(slot)); // Drifted
}

test "set_observed rejects invalid state tag" {
    const slot = cm.configmgmt_create(0, 0, 0);
    defer cm.configmgmt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), cm.configmgmt_set_observed(slot, 99));
}

// =========================================================================
// Action computation
// =========================================================================

test "action is skip when states match" {
    const slot = cm.configmgmt_create(0, 0, 0); // File, Present, Enforce
    defer cm.configmgmt_destroy(slot);

    // Default observed = present (matches desired)
    try std.testing.expectEqual(@as(u8, 5), cm.configmgmt_action(slot)); // Skip
}

test "action is create when desired present, observed absent" {
    const slot = cm.configmgmt_create(0, 0, 0); // File, Present, Enforce
    defer cm.configmgmt_destroy(slot);

    _ = cm.configmgmt_set_observed(slot, 1); // Absent
    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_action(slot)); // Create
}

test "action is delete when desired absent, observed present" {
    const slot = cm.configmgmt_create(0, 1, 0); // File, Absent, Enforce
    defer cm.configmgmt_destroy(slot);

    _ = cm.configmgmt_set_observed(slot, 0); // Present
    try std.testing.expectEqual(@as(u8, 2), cm.configmgmt_action(slot)); // Delete
}

test "action is restart when desired running, observed stopped" {
    const slot = cm.configmgmt_create(2, 2, 0); // Service, Running, Enforce
    defer cm.configmgmt_destroy(slot);

    _ = cm.configmgmt_set_observed(slot, 3); // Stopped
    try std.testing.expectEqual(@as(u8, 3), cm.configmgmt_action(slot)); // Restart
}

// =========================================================================
// Convergence
// =========================================================================

test "converge succeeds in enforce mode" {
    const slot = cm.configmgmt_create(0, 0, 0); // File, Present, Enforce
    defer cm.configmgmt_destroy(slot);

    _ = cm.configmgmt_set_observed(slot, 1); // Absent
    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_converge(slot));
    try std.testing.expectEqual(@as(u32, 1), cm.configmgmt_converge_count(slot));

    // After convergence, observed should match desired
    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_drift_status(slot)); // InSync
}

test "converge rejects in dry_run mode" {
    const slot = cm.configmgmt_create(0, 0, 1); // File, Present, DryRun
    defer cm.configmgmt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), cm.configmgmt_converge(slot));
    try std.testing.expectEqual(@as(u32, 0), cm.configmgmt_converge_count(slot));
}

test "converge rejects in audit mode" {
    const slot = cm.configmgmt_create(0, 0, 2); // File, Present, Audit
    defer cm.configmgmt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), cm.configmgmt_converge(slot));
}

test "converge rejects invalid slot" {
    try std.testing.expectEqual(@as(u8, 2), cm.configmgmt_converge(-1));
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_resource_type(-1));
    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_desired_state(-1));
    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_observed_state(-1));
    try std.testing.expectEqual(@as(u8, 0), cm.configmgmt_apply_mode(-1));
    try std.testing.expectEqual(@as(u32, 0), cm.configmgmt_converge_count(-1));
}
