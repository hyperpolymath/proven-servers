// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-nesy FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Query submission and completion
//   - Proof obligation management
//   - Drift detection and resolution
//   - State transitions
//   - Stateless transition table
//   - Invalid slot safety

const std = @import("std");
const nesy = @import("nesy");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), nesy.nesy_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "ReasoningMode encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nesy.ReasoningMode.symbolic));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nesy.ReasoningMode.neural));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nesy.ReasoningMode.sym_to_neural));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(nesy.ReasoningMode.neural_to_sym));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(nesy.ReasoningMode.ensemble));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(nesy.ReasoningMode.cascade));
}

test "ProofStatus encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nesy.ProofStatus.pending));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nesy.ProofStatus.attempting));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nesy.ProofStatus.proved));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(nesy.ProofStatus.failed));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(nesy.ProofStatus.assumed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(nesy.ProofStatus.vacuous));
}

test "ConstraintKind encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nesy.ConstraintKind.type_equality));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nesy.ConstraintKind.subtype));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nesy.ConstraintKind.linearity));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(nesy.ConstraintKind.termination));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(nesy.ConstraintKind.totality));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(nesy.ConstraintKind.invariant));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(nesy.ConstraintKind.refinement));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(nesy.ConstraintKind.dependent_index));
}

test "NeSyState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(nesy.NeSyState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(nesy.NeSyState.ready));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(nesy.NeSyState.reasoning));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(nesy.NeSyState.verifying));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(nesy.NeSyState.drift));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(nesy.NeSyState.shutdown));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Ready state" {
    const slot = nesy.nesy_create(0); // LocalModel
    try std.testing.expect(slot >= 0);
    defer nesy.nesy_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_state(slot)); // Ready
}

test "create rejects invalid backend" {
    const slot = nesy.nesy_create(99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    nesy.nesy_destroy(-1);
    nesy.nesy_destroy(999);
}

// =========================================================================
// Query submission
// =========================================================================

test "submit_query transitions Ready -> Reasoning" {
    const slot = nesy.nesy_create(1); // Claude
    defer nesy.nesy_destroy(slot);

    const query = "Prove P -> Q";
    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_submit_query(
        slot, 0, query.ptr, query.len,
    ));
    try std.testing.expectEqual(@as(u8, 2), nesy.nesy_state(slot)); // Reasoning
}

test "submit_query rejects invalid mode" {
    const slot = nesy.nesy_create(0);
    defer nesy.nesy_destroy(slot);

    const query = "test";
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_submit_query(
        slot, 99, query.ptr, query.len,
    ));
}

test "complete_query transitions Reasoning -> Ready" {
    const slot = nesy.nesy_create(0);
    defer nesy.nesy_destroy(slot);

    const query = "Prove P";
    _ = nesy.nesy_submit_query(slot, 0, query.ptr, query.len);
    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_complete_query(slot, 0)); // Verified
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_state(slot)); // Ready
}

test "complete_query rejects from Ready state" {
    const slot = nesy.nesy_create(0);
    defer nesy.nesy_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_complete_query(slot, 0));
}

// =========================================================================
// Proof obligations
// =========================================================================

test "add_proof and verify_proof cycle" {
    const slot = nesy.nesy_create(0);
    defer nesy.nesy_destroy(slot);

    const desc = "P implies Q";
    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_add_proof(
        slot, 0, desc.ptr, desc.len,
    ));
    try std.testing.expectEqual(@as(u32, 1), nesy.nesy_proof_count(slot));

    // Verify the proof
    try std.testing.expectEqual(@as(u8, 2), nesy.nesy_verify_proof(slot, 0)); // Proved
}

test "add_proof rejects invalid constraint kind" {
    const slot = nesy.nesy_create(0);
    defer nesy.nesy_destroy(slot);

    const desc = "bad";
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_add_proof(
        slot, 99, desc.ptr, desc.len,
    ));
}

// =========================================================================
// Drift detection
// =========================================================================

test "detect_drift returns no_drift by default" {
    const slot = nesy.nesy_create(0);
    defer nesy.nesy_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_detect_drift(slot)); // NoDrift
}

test "resolve_drift rejected from non-Drift state" {
    const slot = nesy.nesy_create(0);
    defer nesy.nesy_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_resolve_drift(slot));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Ready -> Shutdown" {
    const slot = nesy.nesy_create(0);
    defer nesy.nesy_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 5), nesy.nesy_state(slot)); // Shutdown
}

test "cleanup transitions Shutdown -> Idle" {
    const slot = nesy.nesy_create(0);
    defer nesy.nesy_destroy(slot);

    _ = nesy.nesy_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_state(slot)); // Idle
}

test "cleanup rejected from non-Shutdown state" {
    const slot = nesy.nesy_create(0);
    defer nesy.nesy_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "nesy_can_transition matches state machine" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_can_transition(0, 1)); // Idle -> Ready
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_can_transition(1, 2)); // Ready -> Reasoning
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_can_transition(2, 1)); // Reasoning -> Ready
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_can_transition(1, 3)); // Ready -> Verifying
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_can_transition(3, 1)); // Verifying -> Ready
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_can_transition(1, 4)); // Ready -> Drift
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_can_transition(4, 1)); // Drift -> Ready
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_can_transition(5, 0)); // Shutdown -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_can_transition(0, 2)); // Idle -/-> Reasoning
    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_can_transition(0, 4)); // Idle -/-> Drift
    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_can_transition(5, 1)); // Shutdown -/-> Ready
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), nesy.nesy_state(-1));
    try std.testing.expectEqual(@as(u32, 0), nesy.nesy_proof_count(-1));
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), nesy.nesy_cleanup(-1));
}
