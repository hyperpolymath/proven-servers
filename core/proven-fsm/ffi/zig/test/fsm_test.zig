// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// fsm_test.zig — Integration tests for proven-fsm FFI.
//
// Tests the C-ABI contract between Idris2 proofs and Zig implementation.
// Every test here has a corresponding formal proof in Transitions.idr.

const std = @import("std");
const fsm = @import("fsm");

// ═══════════════════════════════════════════════════════════════════════
// ABI version seam
// ═══════════════════════════════════════════════════════════════════════

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), fsm.fsm_abi_version());
}

// ═══════════════════════════════════════════════════════════════════════
// Enum encoding seams (must match Layout.idr tag assignments)
// ═══════════════════════════════════════════════════════════════════════

test "TransitionResult encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fsm.TransitionResult.accepted));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fsm.TransitionResult.rejected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fsm.TransitionResult.deferred));
}

test "ValidationError encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fsm.ValidationError.invalid_transition));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fsm.ValidationError.precondition_failed));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fsm.ValidationError.postcondition_failed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fsm.ValidationError.guard_failed));
}

test "MachineState encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fsm.MachineState.initial));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fsm.MachineState.running));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fsm.MachineState.terminal));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fsm.MachineState.faulted));
}

test "EventDisposition encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(fsm.EventDisposition.consumed));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(fsm.EventDisposition.ignored));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(fsm.EventDisposition.queued));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(fsm.EventDisposition.dropped));
}

// ═══════════════════════════════════════════════════════════════════════
// Lifecycle tests
// ═══════════════════════════════════════════════════════════════════════

test "create returns valid slot" {
    const slot = fsm.fsm_create(16, 256);
    try std.testing.expect(slot >= 0);
    defer fsm.fsm_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_state(slot)); // Initial
}

test "create rejects zero max_states" {
    const slot = fsm.fsm_create(0, 256);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects zero max_transitions" {
    const slot = fsm.fsm_create(16, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy makes slot reusable" {
    const slot1 = fsm.fsm_create(16, 256);
    try std.testing.expect(slot1 >= 0);
    fsm.fsm_destroy(slot1);

    const slot2 = fsm.fsm_create(16, 256);
    try std.testing.expect(slot2 >= 0);
    defer fsm.fsm_destroy(slot2);
    // Slot should be recycled
    try std.testing.expectEqual(slot1, slot2);
}

test "destroy is safe with invalid slot" {
    fsm.fsm_destroy(-1);
    fsm.fsm_destroy(999);
    // No crash = pass
}

// ═══════════════════════════════════════════════════════════════════════
// Valid transition tests (matching Transitions.idr ValidMachineTransition)
// ═══════════════════════════════════════════════════════════════════════

test "StartMachine: Initial -> Running" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_start(slot)); // Accepted
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_state(slot)); // Running
}

test "CompleteMachine: Running -> Terminal" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    _ = fsm.fsm_start(slot);
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_complete(slot)); // Accepted
    try std.testing.expectEqual(@as(u8, 2), fsm.fsm_state(slot)); // Terminal
}

test "FaultRunning: Running -> Faulted" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    _ = fsm.fsm_start(slot);
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_fault(slot)); // Accepted
    try std.testing.expectEqual(@as(u8, 3), fsm.fsm_state(slot)); // Faulted
}

test "FaultInitial: Initial -> Faulted" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_fault(slot)); // Accepted
    try std.testing.expectEqual(@as(u8, 3), fsm.fsm_state(slot)); // Faulted
}

test "ResetMachine: Faulted -> Initial" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    _ = fsm.fsm_fault(slot); // Initial -> Faulted
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_reset(slot)); // Accepted
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_state(slot)); // Initial
}

// ═══════════════════════════════════════════════════════════════════════
// Invalid transition tests (matching Transitions.idr impossibility proofs)
// ═══════════════════════════════════════════════════════════════════════

test "Terminal cannot start (terminalCannotRun)" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    _ = fsm.fsm_start(slot);
    _ = fsm.fsm_complete(slot); // Now Terminal
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_start(slot)); // Rejected
    try std.testing.expectEqual(@as(u8, 2), fsm.fsm_state(slot)); // Still Terminal
}

test "Terminal cannot reset" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    _ = fsm.fsm_start(slot);
    _ = fsm.fsm_complete(slot); // Now Terminal
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_reset(slot)); // Rejected
}

test "Running cannot restart (runningCannotRestart)" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    _ = fsm.fsm_start(slot); // Now Running
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_start(slot)); // Rejected — can't start again
}

test "Initial cannot complete" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_complete(slot)); // Rejected
}

test "Initial cannot reset" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_reset(slot)); // Rejected
}

// ═══════════════════════════════════════════════════════════════════════
// Event processing tests
// ═══════════════════════════════════════════════════════════════════════

test "Running machine consumes events" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    _ = fsm.fsm_start(slot);
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_submit_event(slot, 42)); // Consumed
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_submit_event(slot, 43)); // Consumed
}

test "Non-running machine ignores events" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    // Initial state — not running
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_submit_event(slot, 42)); // Ignored
}

test "Invalid slot drops events" {
    try std.testing.expectEqual(@as(u8, 3), fsm.fsm_submit_event(-1, 42)); // Dropped
}

// ═══════════════════════════════════════════════════════════════════════
// Stateless validation (matching Transitions.idr validateTransition)
// ═══════════════════════════════════════════════════════════════════════

test "can_transition matches Transitions.idr validateTransition" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_can_transition(0, 1)); // Initial -> Running
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_can_transition(1, 2)); // Running -> Terminal
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_can_transition(1, 3)); // Running -> Faulted
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_can_transition(0, 3)); // Initial -> Faulted
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_can_transition(3, 0)); // Faulted -> Initial

    // Invalid transitions (impossibility proofs)
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_can_transition(2, 1)); // Terminal -/-> Running
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_can_transition(2, 0)); // Terminal -/-> Initial
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_can_transition(1, 0)); // Running -/-> Initial
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_can_transition(0, 2)); // Initial -/-> Terminal
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_can_transition(3, 1)); // Faulted -/-> Running
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_can_transition(3, 2)); // Faulted -/-> Terminal
}

// ═══════════════════════════════════════════════════════════════════════
// Error tracking
// ═══════════════════════════════════════════════════════════════════════

test "last_error is 255 after successful transition" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    _ = fsm.fsm_start(slot);
    try std.testing.expectEqual(@as(u8, 255), fsm.fsm_last_error(slot));
}

test "last_error is InvalidTransition after failed transition" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);
    _ = fsm.fsm_complete(slot); // Rejected — Initial can't complete
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_last_error(slot)); // InvalidTransition
}

// ═══════════════════════════════════════════════════════════════════════
// Full lifecycle round-trip
// ═══════════════════════════════════════════════════════════════════════

test "full lifecycle: create -> start -> events -> complete -> destroy" {
    const slot = fsm.fsm_create(32, 1024);
    try std.testing.expect(slot >= 0);

    // Initial -> Running
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_start(slot));
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_state(slot));

    // Process some events
    _ = fsm.fsm_submit_event(slot, 1);
    _ = fsm.fsm_submit_event(slot, 2);
    _ = fsm.fsm_submit_event(slot, 3);

    // Running -> Terminal
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_complete(slot));
    try std.testing.expectEqual(@as(u8, 2), fsm.fsm_state(slot));

    // Terminal — events ignored
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_submit_event(slot, 99)); // Ignored

    fsm.fsm_destroy(slot);
}

test "fault-reset cycle: create -> start -> fault -> reset -> start" {
    const slot = fsm.fsm_create(16, 256);
    defer fsm.fsm_destroy(slot);

    _ = fsm.fsm_start(slot); // Initial -> Running
    _ = fsm.fsm_fault(slot); // Running -> Faulted
    try std.testing.expectEqual(@as(u8, 3), fsm.fsm_state(slot));

    _ = fsm.fsm_reset(slot); // Faulted -> Initial
    try std.testing.expectEqual(@as(u8, 0), fsm.fsm_state(slot));

    _ = fsm.fsm_start(slot); // Initial -> Running (second time)
    try std.testing.expectEqual(@as(u8, 1), fsm.fsm_state(slot));
}
