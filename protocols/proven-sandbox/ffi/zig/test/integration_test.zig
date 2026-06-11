// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-sandbox FFI.
//
// Tests cover (25 tests):
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - State transitions (Ready -> Running -> Suspended -> Running -> Terminated -> Destroyed)
//   - Resource limits (set/get)
//   - Policy queries (execution policy, syscall policy)
//   - Exit reason tracking
//   - Transition table validation
//   - Invalid slot safety
//   - Impossibility tests (invalid transitions)
//   - Active count tracking

const std = @import("std");
const sandbox = @import("sandbox");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), sandbox.sandbox_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ExecutionPolicy encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(sandbox.ExecutionPolicy.unrestricted));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(sandbox.ExecutionPolicy.read_only));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(sandbox.ExecutionPolicy.network_denied));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(sandbox.ExecutionPolicy.isolated));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(sandbox.ExecutionPolicy.ephemeral));
}

test "ResourceLimit encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(sandbox.ResourceLimit.cpu_time));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(sandbox.ResourceLimit.memory));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(sandbox.ResourceLimit.disk_io));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(sandbox.ResourceLimit.network_io));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(sandbox.ResourceLimit.file_descriptors));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(sandbox.ResourceLimit.processes));
}

test "SandboxState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(sandbox.SandboxState.creating));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(sandbox.SandboxState.ready));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(sandbox.SandboxState.running));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(sandbox.SandboxState.suspended));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(sandbox.SandboxState.terminated));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(sandbox.SandboxState.destroyed));
}

test "ExitReason encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(sandbox.ExitReason.normal));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(sandbox.ExitReason.timeout));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(sandbox.ExitReason.memory_exceeded));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(sandbox.ExitReason.policy_violation));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(sandbox.ExitReason.killed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(sandbox.ExitReason.err));
}

test "SyscallPolicy encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(sandbox.SyscallPolicy.allow));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(sandbox.SyscallPolicy.deny));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(sandbox.SyscallPolicy.log));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(sandbox.SyscallPolicy.trap));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Ready state" {
    const slot = sandbox.sandbox_create(3, 1); // Isolated, Deny
    try std.testing.expect(slot >= 0);
    defer sandbox.sandbox_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_state(slot)); // Ready
}

test "create rejects invalid policy" {
    try std.testing.expectEqual(@as(c_int, -1), sandbox.sandbox_create(99, 0));
}

test "create rejects invalid syscall policy" {
    try std.testing.expectEqual(@as(c_int, -1), sandbox.sandbox_create(0, 99));
}

test "destroy is safe with invalid slot" {
    sandbox.sandbox_destroy(-1);
    sandbox.sandbox_destroy(999);
}

// =========================================================================
// State transitions
// =========================================================================

test "start transitions Ready -> Running" {
    const slot = sandbox.sandbox_create(3, 1);
    defer sandbox.sandbox_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_start(slot));
    try std.testing.expectEqual(@as(u8, 2), sandbox.sandbox_state(slot)); // Running
}

test "suspend transitions Running -> Suspended" {
    const slot = sandbox.sandbox_create(3, 1);
    defer sandbox.sandbox_destroy(slot);
    _ = sandbox.sandbox_start(slot);
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_suspend(slot));
    try std.testing.expectEqual(@as(u8, 3), sandbox.sandbox_state(slot)); // Suspended
}

test "resume transitions Suspended -> Running" {
    const slot = sandbox.sandbox_create(3, 1);
    defer sandbox.sandbox_destroy(slot);
    _ = sandbox.sandbox_start(slot);
    _ = sandbox.sandbox_suspend(slot);
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_resume(slot));
    try std.testing.expectEqual(@as(u8, 2), sandbox.sandbox_state(slot)); // Running
}

test "terminate transitions Running -> Terminated with exit reason" {
    const slot = sandbox.sandbox_create(3, 1);
    defer sandbox.sandbox_destroy(slot);
    _ = sandbox.sandbox_start(slot);
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_terminate(slot, 1)); // Timeout
    try std.testing.expectEqual(@as(u8, 4), sandbox.sandbox_state(slot)); // Terminated
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_exit_reason(slot)); // Timeout
}

test "cleanup transitions Terminated -> Destroyed" {
    const slot = sandbox.sandbox_create(3, 1);
    defer sandbox.sandbox_destroy(slot);
    _ = sandbox.sandbox_start(slot);
    _ = sandbox.sandbox_terminate(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 5), sandbox.sandbox_state(slot)); // Destroyed
}

// =========================================================================
// Resource limits
// =========================================================================

test "set and get resource limits" {
    const slot = sandbox.sandbox_create(3, 1);
    defer sandbox.sandbox_destroy(slot);
    // Set CPU time limit
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_set_limit(slot, 0, 300));
    try std.testing.expectEqual(@as(u64, 300), sandbox.sandbox_get_limit(slot, 0));
    // Set memory limit
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_set_limit(slot, 1, 1073741824));
    try std.testing.expectEqual(@as(u64, 1073741824), sandbox.sandbox_get_limit(slot, 1));
}

test "set_limit rejects invalid limit type" {
    const slot = sandbox.sandbox_create(3, 1);
    defer sandbox.sandbox_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_set_limit(slot, 99, 100));
}

// =========================================================================
// Policy queries
// =========================================================================

test "policy returns correct execution policy" {
    const slot = sandbox.sandbox_create(4, 2); // Ephemeral, Log
    defer sandbox.sandbox_destroy(slot);
    try std.testing.expectEqual(@as(u8, 4), sandbox.sandbox_policy(slot)); // Ephemeral
    try std.testing.expectEqual(@as(u8, 2), sandbox.sandbox_syscall_policy(slot)); // Log
}

// =========================================================================
// Transition table
// =========================================================================

test "sandbox_can_transition matches Types.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_can_transition(0, 1)); // Creating -> Ready
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_can_transition(1, 2)); // Ready -> Running
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_can_transition(2, 3)); // Running -> Suspended
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_can_transition(3, 2)); // Suspended -> Running
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_can_transition(2, 4)); // Running -> Terminated
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_can_transition(3, 4)); // Suspended -> Terminated
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_can_transition(4, 5)); // Terminated -> Destroyed
    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_can_transition(0, 2)); // Creating -/-> Running
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_can_transition(1, 4)); // Ready -/-> Terminated
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_can_transition(5, 1)); // Destroyed -/-> Ready
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_can_transition(4, 2)); // Terminated -/-> Running
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot start from Terminated" {
    const slot = sandbox.sandbox_create(3, 1);
    defer sandbox.sandbox_destroy(slot);
    _ = sandbox.sandbox_start(slot);
    _ = sandbox.sandbox_terminate(slot, 0);
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_start(slot));
}

test "cannot suspend from Ready" {
    const slot = sandbox.sandbox_create(3, 1);
    defer sandbox.sandbox_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_suspend(slot));
}

test "cannot set limits in Terminated state" {
    const slot = sandbox.sandbox_create(3, 1);
    defer sandbox.sandbox_destroy(slot);
    _ = sandbox.sandbox_start(slot);
    _ = sandbox.sandbox_terminate(slot, 0);
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_set_limit(slot, 0, 100));
}

// =========================================================================
// Active count
// =========================================================================

test "active_count tracks sessions" {
    const before = sandbox.sandbox_active_count();
    const slot = sandbox.sandbox_create(0, 0);
    try std.testing.expectEqual(before + 1, sandbox.sandbox_active_count());
    sandbox.sandbox_destroy(slot);
    try std.testing.expectEqual(before, sandbox.sandbox_active_count());
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), sandbox.sandbox_state(-1));
    try std.testing.expectEqual(@as(u64, 0), sandbox.sandbox_get_limit(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_start(-1));
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_suspend(-1));
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_resume(-1));
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_terminate(-1, 0));
    try std.testing.expectEqual(@as(u8, 1), sandbox.sandbox_cleanup(-1));
}
