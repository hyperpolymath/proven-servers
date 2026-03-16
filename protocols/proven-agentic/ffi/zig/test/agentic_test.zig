// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// agentic_test.zig — Integration tests for the proven-agentic FFI.
//
// Tests cover:
//   - ABI version check
//   - Agent lifecycle (create, destroy, state queries)
//   - State machine transitions (valid and invalid)
//   - Tool call tracking and limits
//   - Plan step stack and depth limits
//   - Safety check logic
//   - Memory type and coordination setters
//   - Stateless transition validation
//   - Blocking and unblocking
//   - Task completion counting
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const ag = @import("agentic");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), ag.agentic_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = ag.agentic_create(0, 1000, 50);
    try expect(slot >= 0);
    ag.agentic_destroy(slot);
}

test "create with invalid coordination returns -1" {
    const slot = ag.agentic_create(99, 1000, 50);
    try expectEqual(@as(c_int, -1), slot);
}

test "create with zero max_tools returns -1" {
    const slot = ag.agentic_create(0, 0, 50);
    try expectEqual(@as(c_int, -1), slot);
}

test "create with zero max_depth returns -1" {
    const slot = ag.agentic_create(0, 1000, 0);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    ag.agentic_destroy(-1);
    ag.agentic_destroy(999);
}

test "double destroy is safe" {
    const slot = ag.agentic_create(0, 1000, 50);
    ag.agentic_destroy(slot);
    ag.agentic_destroy(slot);
}

// ── State Queries on Fresh Agent ────────────────────────────────────────

test "fresh agent is in Idle state" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 0), ag.agentic_get_state(slot)); // Idle
}

test "fresh agent has Solo coordination" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 0), ag.agentic_get_coordination(slot)); // Solo
}

test "fresh agent has Hierarchical coordination when created with 3" {
    const slot = ag.agentic_create(3, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 3), ag.agentic_get_coordination(slot)); // Hierarchical
}

test "fresh agent has Working memory" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 0), ag.agentic_get_memory_type(slot)); // Working
}

test "fresh agent has Approved safety" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 0), ag.agentic_get_safety(slot)); // Approved
}

test "fresh agent has zero tool count" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u32, 0), ag.agentic_get_tool_count(slot));
}

test "fresh agent has zero plan depth" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u32, 0), ag.agentic_get_plan_depth(slot));
}

test "fresh agent has zero completed tasks" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u32, 0), ag.agentic_get_completed_tasks(slot));
}

test "fresh agent has no error (255)" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 255), ag.agentic_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_state on invalid slot returns Idle" {
    try expectEqual(@as(u8, 0), ag.agentic_get_state(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), ag.agentic_get_last_error(-1));
}

test "get_tool_count on invalid slot returns 0" {
    try expectEqual(@as(u32, 0), ag.agentic_get_tool_count(-1));
}

// ── Valid State Transitions ─────────────────────────────────────────────

test "Idle -> Planning (AssignTask)" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 1)); // Ok
    try expectEqual(@as(u8, 1), ag.agentic_get_state(slot)); // Planning
}

test "Planning -> Acting (BeginAction)" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // Idle -> Planning
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 2)); // Ok
    try expectEqual(@as(u8, 2), ag.agentic_get_state(slot)); // Acting
}

test "Acting -> Observing (ObserveResult)" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 2); // -> Acting
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 3)); // Ok
    try expectEqual(@as(u8, 3), ag.agentic_get_state(slot)); // Observing
}

test "Observing -> Reflecting (ReflectOnResult)" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 2); // -> Acting
    _ = ag.agentic_transition(slot, 3); // -> Observing
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 4)); // Ok
    try expectEqual(@as(u8, 4), ag.agentic_get_state(slot)); // Reflecting
}

test "Reflecting -> Idle (CompletePlan) increments completed_tasks" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 2); // -> Acting
    _ = ag.agentic_transition(slot, 3); // -> Observing
    _ = ag.agentic_transition(slot, 4); // -> Reflecting
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 0)); // Ok -> Idle
    try expectEqual(@as(u32, 1), ag.agentic_get_completed_tasks(slot));
}

test "Reflecting -> Acting (ResumeAction)" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 2); // -> Acting
    _ = ag.agentic_transition(slot, 3); // -> Observing
    _ = ag.agentic_transition(slot, 4); // -> Reflecting
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 2)); // Ok -> Acting
    try expectEqual(@as(u8, 2), ag.agentic_get_state(slot));
}

test "Reflecting -> Planning (RevisePlan)" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 2); // -> Acting
    _ = ag.agentic_transition(slot, 3); // -> Observing
    _ = ag.agentic_transition(slot, 4); // -> Reflecting
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 1)); // Ok -> Planning
    try expectEqual(@as(u8, 1), ag.agentic_get_state(slot));
}

// ── Invalid State Transitions ───────────────────────────────────────────

test "Idle -> Acting is invalid" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 3), ag.agentic_transition(slot, 2)); // InvalidTransition
}

test "Idle -> Observing is invalid" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 3), ag.agentic_transition(slot, 3)); // InvalidTransition
}

test "Acting -> Planning is invalid" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 2); // -> Acting
    try expectEqual(@as(u8, 3), ag.agentic_transition(slot, 1)); // InvalidTransition
}

test "Terminated -> anything is invalid" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 6); // Idle -> Terminated
    try expectEqual(@as(u8, 3), ag.agentic_transition(slot, 0)); // InvalidTransition
    try expectEqual(@as(u8, 3), ag.agentic_transition(slot, 1)); // InvalidTransition
}

test "transition on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), ag.agentic_transition(-1, 1)); // InvalidSlot
}

// ── Blocking and Unblocking ─────────────────────────────────────────────

test "Acting -> Blocked -> Acting roundtrip" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 2); // -> Acting
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 5)); // -> Blocked
    try expectEqual(@as(u8, 5), ag.agentic_get_state(slot));
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 2)); // -> Acting
    try expectEqual(@as(u8, 2), ag.agentic_get_state(slot));
}

test "Planning -> Blocked -> Planning roundtrip" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 5)); // -> Blocked
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 1)); // -> Planning
}

test "Blocked -> Terminated" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 5); // -> Blocked
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 6)); // -> Terminated
}

// ── Tool Call Tracking ──────────────────────────────────────────────────

test "record tool call increments count" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 2); // -> Acting
    try expectEqual(@as(u8, 0), ag.agentic_record_tool_call(slot, 0)); // Execute
    try expectEqual(@as(u32, 1), ag.agentic_get_tool_count(slot));
    try expectEqual(@as(u8, 0), ag.agentic_record_tool_call(slot, 1)); // Query
    try expectEqual(@as(u32, 2), ag.agentic_get_tool_count(slot));
}

test "tool call not in Acting state fails" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    // Agent is Idle
    try expectEqual(@as(u8, 3), ag.agentic_record_tool_call(slot, 0)); // InvalidTransition
}

test "tool call with invalid kind fails" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1);
    _ = ag.agentic_transition(slot, 2);
    try expectEqual(@as(u8, 3), ag.agentic_record_tool_call(slot, 99)); // InvalidTransition
}

test "tool call exceeding limit fails" {
    const slot = ag.agentic_create(0, 3, 50); // max 3 tool calls
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1);
    _ = ag.agentic_transition(slot, 2);
    try expectEqual(@as(u8, 0), ag.agentic_record_tool_call(slot, 0));
    try expectEqual(@as(u8, 0), ag.agentic_record_tool_call(slot, 0));
    try expectEqual(@as(u8, 0), ag.agentic_record_tool_call(slot, 0));
    try expectEqual(@as(u8, 5), ag.agentic_record_tool_call(slot, 0)); // ToolLimitExceeded
}

test "tool count resets after task completion" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 2); // -> Acting
    _ = ag.agentic_record_tool_call(slot, 0);
    _ = ag.agentic_record_tool_call(slot, 1);
    try expectEqual(@as(u32, 2), ag.agentic_get_tool_count(slot));
    _ = ag.agentic_transition(slot, 3); // -> Observing
    _ = ag.agentic_transition(slot, 4); // -> Reflecting
    _ = ag.agentic_transition(slot, 0); // -> Idle (complete)
    try expectEqual(@as(u32, 0), ag.agentic_get_tool_count(slot));
}

// ── Plan Step Stack ─────────────────────────────────────────────────────

test "push plan step increments depth" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    try expectEqual(@as(u8, 0), ag.agentic_push_plan_step(slot, 0)); // Action
    try expectEqual(@as(u32, 1), ag.agentic_get_plan_depth(slot));
    try expectEqual(@as(u8, 0), ag.agentic_push_plan_step(slot, 4)); // Parallel
    try expectEqual(@as(u32, 2), ag.agentic_get_plan_depth(slot));
}

test "pop plan step decrements depth" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1);
    _ = ag.agentic_push_plan_step(slot, 0);
    _ = ag.agentic_push_plan_step(slot, 1);
    try expectEqual(@as(u32, 2), ag.agentic_get_plan_depth(slot));
    try expectEqual(@as(u8, 0), ag.agentic_pop_plan_step(slot));
    try expectEqual(@as(u32, 1), ag.agentic_get_plan_depth(slot));
}

test "pop on empty stack fails" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 3), ag.agentic_pop_plan_step(slot)); // InvalidTransition
}

test "push not in Planning state fails" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    // Agent is Idle
    try expectEqual(@as(u8, 3), ag.agentic_push_plan_step(slot, 0)); // InvalidTransition
}

test "push with invalid step kind fails" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1);
    try expectEqual(@as(u8, 3), ag.agentic_push_plan_step(slot, 99)); // InvalidTransition
}

test "plan depth limit enforced" {
    const slot = ag.agentic_create(0, 1000, 3); // max depth 3
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1);
    try expectEqual(@as(u8, 0), ag.agentic_push_plan_step(slot, 0));
    try expectEqual(@as(u8, 0), ag.agentic_push_plan_step(slot, 1));
    try expectEqual(@as(u8, 0), ag.agentic_push_plan_step(slot, 2));
    try expectEqual(@as(u8, 6), ag.agentic_push_plan_step(slot, 3)); // PlanDepthExceeded
}

test "plan depth resets after task completion" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_push_plan_step(slot, 0);
    _ = ag.agentic_push_plan_step(slot, 1);
    try expectEqual(@as(u32, 2), ag.agentic_get_plan_depth(slot));
    _ = ag.agentic_transition(slot, 2); // -> Acting
    _ = ag.agentic_transition(slot, 3); // -> Observing
    _ = ag.agentic_transition(slot, 4); // -> Reflecting
    _ = ag.agentic_transition(slot, 0); // -> Idle (complete)
    try expectEqual(@as(u32, 0), ag.agentic_get_plan_depth(slot));
}

// ── Safety Checks ───────────────────────────────────────────────────────

test "safety check approves normal Execute" {
    const slot = ag.agentic_create(0, 1000, 50); // Solo coordination
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 0), ag.agentic_safety_check(slot, 0)); // Approved
}

test "safety check approves Query" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 0), ag.agentic_safety_check(slot, 1)); // Approved
}

test "safety check requires human for Escalate" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 5), ag.agentic_safety_check(slot, 5)); // HumanRequired
}

test "safety check escalates Delegate in Competitive mode" {
    const slot = ag.agentic_create(2, 1000, 50); // Competitive
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 2), ag.agentic_safety_check(slot, 4)); // Escalated
}

test "safety check sandboxes Execute in Competitive mode" {
    const slot = ag.agentic_create(2, 1000, 50); // Competitive
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 4), ag.agentic_safety_check(slot, 0)); // Sandboxed
}

test "safety check denies invalid tool kind" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 1), ag.agentic_safety_check(slot, 99)); // Denied
}

test "safety check on invalid slot returns Denied" {
    try expectEqual(@as(u8, 1), ag.agentic_safety_check(-1, 0)); // Denied
}

// ── Memory and Coordination Setters ─────────────────────────────────────

test "set memory type" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 0), ag.agentic_set_memory_type(slot, 3)); // Procedural
    try expectEqual(@as(u8, 3), ag.agentic_get_memory_type(slot));
}

test "set memory type with invalid value fails" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 3), ag.agentic_set_memory_type(slot, 99)); // InvalidTransition
}

test "set coordination" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 0), ag.agentic_set_coordination(slot, 4)); // Swarm
    try expectEqual(@as(u8, 4), ag.agentic_get_coordination(slot));
}

test "set coordination with invalid value fails" {
    const slot = ag.agentic_create(0, 1000, 50);
    defer ag.agentic_destroy(slot);
    try expectEqual(@as(u8, 3), ag.agentic_set_coordination(slot, 99)); // InvalidTransition
}

// ── Stateless Transition Validation ─────────────────────────────────────

test "can_transition: valid transitions return 1" {
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(0, 1)); // Idle -> Planning
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(1, 2)); // Planning -> Acting
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(2, 3)); // Acting -> Observing
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(3, 4)); // Observing -> Reflecting
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(4, 0)); // Reflecting -> Idle
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(4, 2)); // Reflecting -> Acting
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(4, 1)); // Reflecting -> Planning
}

test "can_transition: blocking transitions return 1" {
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(1, 5)); // Planning -> Blocked
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(2, 5)); // Acting -> Blocked
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(3, 5)); // Observing -> Blocked
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(5, 1)); // Blocked -> Planning
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(5, 2)); // Blocked -> Acting
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(5, 3)); // Blocked -> Observing
}

test "can_transition: termination from any non-terminated state returns 1" {
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(0, 6)); // Idle -> Terminated
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(1, 6)); // Planning -> Terminated
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(2, 6)); // Acting -> Terminated
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(3, 6)); // Observing -> Terminated
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(4, 6)); // Reflecting -> Terminated
    try expectEqual(@as(u8, 1), ag.agentic_can_transition(5, 6)); // Blocked -> Terminated
}

test "can_transition: invalid transitions return 0" {
    try expectEqual(@as(u8, 0), ag.agentic_can_transition(0, 2)); // Idle -> Acting
    try expectEqual(@as(u8, 0), ag.agentic_can_transition(0, 3)); // Idle -> Observing
    try expectEqual(@as(u8, 0), ag.agentic_can_transition(2, 1)); // Acting -> Planning
    try expectEqual(@as(u8, 0), ag.agentic_can_transition(6, 0)); // Terminated -> Idle
    try expectEqual(@as(u8, 0), ag.agentic_can_transition(6, 1)); // Terminated -> Planning
    try expectEqual(@as(u8, 0), ag.agentic_can_transition(2, 4)); // Acting -> Reflecting
    try expectEqual(@as(u8, 0), ag.agentic_can_transition(3, 2)); // Observing -> Acting
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full task lifecycle: plan, act, observe, reflect, complete" {
    const slot = ag.agentic_create(1, 100, 10); // Collaborative
    defer ag.agentic_destroy(slot);

    // Plan
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 1)); // -> Planning
    try expectEqual(@as(u8, 0), ag.agentic_push_plan_step(slot, 0)); // Action
    try expectEqual(@as(u8, 0), ag.agentic_push_plan_step(slot, 1)); // Condition

    // Act
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 2)); // -> Acting
    try expectEqual(@as(u8, 0), ag.agentic_record_tool_call(slot, 0)); // Execute
    try expectEqual(@as(u8, 0), ag.agentic_record_tool_call(slot, 1)); // Query

    // Observe
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 3)); // -> Observing

    // Reflect
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 4)); // -> Reflecting

    // Complete
    try expectEqual(@as(u8, 0), ag.agentic_transition(slot, 0)); // -> Idle
    try expectEqual(@as(u32, 1), ag.agentic_get_completed_tasks(slot));
    try expectEqual(@as(u32, 0), ag.agentic_get_tool_count(slot));
    try expectEqual(@as(u32, 0), ag.agentic_get_plan_depth(slot));
}

test "multi-loop lifecycle: plan, act, observe, reflect, act again, complete" {
    const slot = ag.agentic_create(0, 100, 10);
    defer ag.agentic_destroy(slot);

    _ = ag.agentic_transition(slot, 1); // -> Planning
    _ = ag.agentic_transition(slot, 2); // -> Acting
    _ = ag.agentic_record_tool_call(slot, 0);
    _ = ag.agentic_transition(slot, 3); // -> Observing
    _ = ag.agentic_transition(slot, 4); // -> Reflecting
    _ = ag.agentic_transition(slot, 2); // -> Acting (resume)
    _ = ag.agentic_record_tool_call(slot, 1);
    _ = ag.agentic_transition(slot, 3); // -> Observing
    _ = ag.agentic_transition(slot, 4); // -> Reflecting
    _ = ag.agentic_transition(slot, 0); // -> Idle (complete)

    try expectEqual(@as(u32, 1), ag.agentic_get_completed_tasks(slot));
}

test "two consecutive tasks" {
    const slot = ag.agentic_create(0, 100, 10);
    defer ag.agentic_destroy(slot);

    // Task 1
    _ = ag.agentic_transition(slot, 1);
    _ = ag.agentic_transition(slot, 2);
    _ = ag.agentic_transition(slot, 3);
    _ = ag.agentic_transition(slot, 4);
    _ = ag.agentic_transition(slot, 0);

    // Task 2
    _ = ag.agentic_transition(slot, 1);
    _ = ag.agentic_transition(slot, 2);
    _ = ag.agentic_transition(slot, 3);
    _ = ag.agentic_transition(slot, 4);
    _ = ag.agentic_transition(slot, 0);

    try expectEqual(@as(u32, 2), ag.agentic_get_completed_tasks(slot));
}
