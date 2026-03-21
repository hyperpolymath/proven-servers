// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-neurosym FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Neural inference dispatch
//   - Symbolic reasoning dispatch
//   - Fusion and completion
//   - Knowledge base management
//   - Stateless transition table
//   - Invalid slot safety

const std = @import("std");
const neurosym = @import("neurosym");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), neurosym.neurosym_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "InferenceMode encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(neurosym.InferenceMode.neural));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(neurosym.InferenceMode.symbolic));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(neurosym.InferenceMode.hybrid));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(neurosym.InferenceMode.cascade));
}

test "SymbolicOp encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(neurosym.SymbolicOp.unify));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(neurosym.SymbolicOp.prove));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(neurosym.SymbolicOp.constrain));
}

test "FusionStrategy encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(neurosym.FusionStrategy.neural_then_symbolic));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(neurosym.FusionStrategy.parallel));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(neurosym.FusionStrategy.gated));
}

test "NeurosymState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(neurosym.NeurosymState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(neurosym.NeurosymState.ready));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(neurosym.NeurosymState.inferring));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(neurosym.NeurosymState.reasoning));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(neurosym.NeurosymState.fusing));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(neurosym.NeurosymState.shutdown));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Ready state" {
    const slot = neurosym.neurosym_create(2); // Parallel strategy
    try std.testing.expect(slot >= 0);
    defer neurosym.neurosym_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_state(slot)); // Ready
}

test "create rejects invalid strategy" {
    const slot = neurosym.neurosym_create(99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    neurosym.neurosym_destroy(-1);
    neurosym.neurosym_destroy(999);
}

// =========================================================================
// Neural inference
// =========================================================================

test "infer transitions Ready -> Inferring" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    const input = "classify this text";
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_infer(
        slot, 0, input.ptr, input.len,
    ));
    try std.testing.expectEqual(@as(u8, 2), neurosym.neurosym_state(slot)); // Inferring
}

test "infer rejects invalid mode" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    const input = "x";
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_infer(
        slot, 99, input.ptr, input.len,
    ));
}

// =========================================================================
// Symbolic reasoning
// =========================================================================

test "reason transitions Ready -> Reasoning" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    const input = "unify A with B";
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_reason(
        slot, 0, input.ptr, input.len,
    ));
    try std.testing.expectEqual(@as(u8, 3), neurosym.neurosym_state(slot)); // Reasoning
}

test "reason rejects invalid op" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    const input = "x";
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_reason(
        slot, 99, input.ptr, input.len,
    ));
}

// =========================================================================
// Fusion and completion
// =========================================================================

test "fuse transitions Inferring -> Fusing" {
    const slot = neurosym.neurosym_create(2);
    defer neurosym.neurosym_destroy(slot);

    const input = "test";
    _ = neurosym.neurosym_infer(slot, 0, input.ptr, input.len);
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_fuse(slot));
    try std.testing.expectEqual(@as(u8, 4), neurosym.neurosym_state(slot)); // Fusing
}

test "complete transitions Fusing -> Ready" {
    const slot = neurosym.neurosym_create(2);
    defer neurosym.neurosym_destroy(slot);

    const input = "test";
    _ = neurosym.neurosym_infer(slot, 0, input.ptr, input.len);
    _ = neurosym.neurosym_fuse(slot);
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_complete(slot, 0)); // Proven
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_state(slot)); // Ready
}

test "complete rejects from Ready state" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_complete(slot, 0));
}

test "fuse rejects from Ready state" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_fuse(slot));
}

// =========================================================================
// Knowledge base
// =========================================================================

test "add_knowledge adds an entry" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    const data = "All humans are mortal";
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_add_knowledge(
        slot, 0, data.ptr, data.len,
    ));
    try std.testing.expectEqual(@as(u32, 1), neurosym.neurosym_knowledge_count(slot));
}

test "add_knowledge rejects invalid kind" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    const data = "bad";
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_add_knowledge(
        slot, 99, data.ptr, data.len,
    ));
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Ready -> Shutdown" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 5), neurosym.neurosym_state(slot)); // Shutdown
}

test "cleanup transitions Shutdown -> Idle" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    _ = neurosym.neurosym_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_state(slot)); // Idle
}

test "cleanup rejected from non-Shutdown state" {
    const slot = neurosym.neurosym_create(0);
    defer neurosym.neurosym_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "neurosym_can_transition matches state machine" {
    // Valid
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_can_transition(0, 1)); // Idle -> Ready
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_can_transition(1, 2)); // Ready -> Inferring
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_can_transition(1, 3)); // Ready -> Reasoning
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_can_transition(2, 4)); // Inferring -> Fusing
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_can_transition(3, 4)); // Reasoning -> Fusing
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_can_transition(4, 1)); // Fusing -> Ready
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_can_transition(5, 0)); // Shutdown -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_can_transition(0, 2)); // Idle -/-> Inferring
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_can_transition(0, 4)); // Idle -/-> Fusing
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_can_transition(5, 1)); // Shutdown -/-> Ready
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), neurosym.neurosym_state(-1));
    try std.testing.expectEqual(@as(u32, 0), neurosym.neurosym_knowledge_count(-1));
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), neurosym.neurosym_cleanup(-1));
}
