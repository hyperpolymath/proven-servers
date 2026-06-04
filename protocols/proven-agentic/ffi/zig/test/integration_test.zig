// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-agentic FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const agentic = @import("agentic");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), agentic.agentic_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "AgentState encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(agentic.AgentState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(agentic.AgentState.planning));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(agentic.AgentState.acting));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(agentic.AgentState.observing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(agentic.AgentState.reflecting));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(agentic.AgentState.blocked));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(agentic.AgentState.terminated));
}

test "ToolCall encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(agentic.ToolCall.execute));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(agentic.ToolCall.query));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(agentic.ToolCall.transform));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(agentic.ToolCall.communicate));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(agentic.ToolCall.delegate));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(agentic.ToolCall.escalate));
}

test "PlanStep encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(agentic.PlanStep.action));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(agentic.PlanStep.condition));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(agentic.PlanStep.loop));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(agentic.PlanStep.branch));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(agentic.PlanStep.parallel));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(agentic.PlanStep.checkpoint));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(agentic.PlanStep.rollback));
}

test "Coordination encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(agentic.Coordination.solo));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(agentic.Coordination.collaborative));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(agentic.Coordination.competitive));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(agentic.Coordination.hierarchical));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(agentic.Coordination.swarm));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(agentic.Coordination.consensus));
}

test "SafetyCheck encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(agentic.SafetyCheck.approved));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(agentic.SafetyCheck.denied));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(agentic.SafetyCheck.escalated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(agentic.SafetyCheck.timeout));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(agentic.SafetyCheck.sandboxed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(agentic.SafetyCheck.human_required));
}

test "MemoryType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(agentic.MemoryType.working));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(agentic.MemoryType.episodic));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(agentic.MemoryType.semantic));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(agentic.MemoryType.procedural));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(agentic.MemoryType.shared));
}

test "AgenticError encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(agentic.AgenticError.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(agentic.AgenticError.invalid_slot));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(agentic.AgenticError.not_active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(agentic.AgenticError.invalid_transition));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(agentic.AgenticError.blocked));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(agentic.AgenticError.tool_limit_exceeded));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(agentic.AgenticError.plan_depth_exceeded));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(agentic.AgenticError.safety_denied));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = agentic.agentic_create(0, 0, 0);
    try std.testing.expect(slot >= 0);
    defer agentic.agentic_destroy(slot);
    const state = agentic.agentic_get_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    agentic.agentic_destroy(-1);
    agentic.agentic_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), agentic.agentic_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), agentic.agentic_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = agentic.agentic_get_state(-1);
    _ = agentic.agentic_get_state(-1);
    _ = agentic.agentic_get_coordination(-1);
    _ = agentic.agentic_get_safety(-1);
}

