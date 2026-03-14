// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// agentic_ffi.zig: C-compatible FFI for the proven-agentic protocol.
// Maps the 6 Idris2 ABI type families to C-compatible enums and provides
// state-machine transition validation, serialisation, and lifecycle management.

const std = @import("std");

// -----------------------------------------------------------------------
// AgentState — lifecycle state of an individual agent
// Mirrors: Agentic.Types.AgentState (7 variants)
// -----------------------------------------------------------------------

pub const AgentState = enum(u8) {
    idle = 0,
    planning = 1,
    acting = 2,
    observing = 3,
    reflecting = 4,
    blocked = 5,
    terminated = 6,

    /// Valid OODA-loop transitions. Returns true if from→to is a legal move.
    pub fn canTransition(from: AgentState, to: AgentState) bool {
        return switch (from) {
            .idle => to == .planning or to == .terminated,
            .planning => to == .acting or to == .blocked or to == .terminated,
            .acting => to == .observing or to == .blocked or to == .terminated,
            .observing => to == .reflecting or to == .blocked or to == .terminated,
            .reflecting => to == .planning or to == .acting or to == .idle or to == .terminated,
            .blocked => to == .planning or to == .acting or to == .idle or to == .terminated,
            .terminated => false,
        };
    }

    pub fn label(self: AgentState) [*:0]const u8 {
        return switch (self) {
            .idle => "Idle",
            .planning => "Planning",
            .acting => "Acting",
            .observing => "Observing",
            .reflecting => "Reflecting",
            .blocked => "Blocked",
            .terminated => "Terminated",
        };
    }
};

// -----------------------------------------------------------------------
// ToolCall — kind of tool invocation an agent can make
// Mirrors: Agentic.Types.ToolCall (6 variants)
// -----------------------------------------------------------------------

pub const ToolCall = enum(u8) {
    execute = 0,
    query = 1,
    transform = 2,
    communicate = 3,
    delegate = 4,
    escalate = 5,

    /// Whether this tool call has side effects.
    pub fn hasSideEffects(self: ToolCall) bool {
        return switch (self) {
            .execute, .communicate, .delegate, .escalate => true,
            .query, .transform => false,
        };
    }

    /// Whether this tool call requires safety pre-check.
    pub fn requiresSafetyCheck(self: ToolCall) bool {
        return switch (self) {
            .execute, .delegate, .escalate => true,
            .query, .transform, .communicate => false,
        };
    }

    pub fn label(self: ToolCall) [*:0]const u8 {
        return switch (self) {
            .execute => "Execute",
            .query => "Query",
            .transform => "Transform",
            .communicate => "Communicate",
            .delegate => "Delegate",
            .escalate => "Escalate",
        };
    }
};

// -----------------------------------------------------------------------
// PlanStep — node type in an agent's execution plan
// Mirrors: Agentic.Types.PlanStep (7 variants)
// -----------------------------------------------------------------------

pub const PlanStep = enum(u8) {
    action = 0,
    condition = 1,
    loop = 2,
    branch = 3,
    parallel = 4,
    checkpoint = 5,
    rollback = 6,

    /// Whether this step type is a control-flow node (vs. a leaf action).
    pub fn isControlFlow(self: PlanStep) bool {
        return switch (self) {
            .condition, .loop, .branch, .parallel => true,
            .action, .checkpoint, .rollback => false,
        };
    }

    /// Whether this step type can have child steps.
    pub fn canHaveChildren(self: PlanStep) bool {
        return switch (self) {
            .condition, .loop, .branch, .parallel => true,
            .action, .checkpoint, .rollback => false,
        };
    }

    pub fn label(self: PlanStep) [*:0]const u8 {
        return switch (self) {
            .action => "Action",
            .condition => "Condition",
            .loop => "Loop",
            .branch => "Branch",
            .parallel => "Parallel",
            .checkpoint => "Checkpoint",
            .rollback => "Rollback",
        };
    }
};

// -----------------------------------------------------------------------
// Coordination — strategy for multi-agent coordination
// Mirrors: Agentic.Types.Coordination (6 variants)
// -----------------------------------------------------------------------

pub const Coordination = enum(u8) {
    solo = 0,
    collaborative = 1,
    competitive = 2,
    hierarchical = 3,
    swarm = 4,
    consensus = 5,

    /// Whether this strategy involves multiple agents.
    pub fn isMultiAgent(self: Coordination) bool {
        return self != .solo;
    }

    /// Whether this strategy requires a leader/coordinator.
    pub fn requiresLeader(self: Coordination) bool {
        return switch (self) {
            .hierarchical => true,
            else => false,
        };
    }

    pub fn label(self: Coordination) [*:0]const u8 {
        return switch (self) {
            .solo => "Solo",
            .collaborative => "Collaborative",
            .competitive => "Competitive",
            .hierarchical => "Hierarchical",
            .swarm => "Swarm",
            .consensus => "Consensus",
        };
    }
};

// -----------------------------------------------------------------------
// SafetyCheck — outcome of a safety evaluation
// Mirrors: Agentic.Types.SafetyCheck (6 variants)
// -----------------------------------------------------------------------

pub const SafetyCheck = enum(u8) {
    approved = 0,
    denied = 1,
    escalated = 2,
    timeout = 3,
    sandboxed = 4,
    human_required = 5,

    /// Whether the action may proceed (possibly with constraints).
    pub fn allowsExecution(self: SafetyCheck) bool {
        return switch (self) {
            .approved, .sandboxed => true,
            .denied, .escalated, .timeout, .human_required => false,
        };
    }

    /// Whether the outcome requires human intervention.
    pub fn needsHuman(self: SafetyCheck) bool {
        return switch (self) {
            .escalated, .human_required => true,
            else => false,
        };
    }

    pub fn label(self: SafetyCheck) [*:0]const u8 {
        return switch (self) {
            .approved => "Approved",
            .denied => "Denied",
            .escalated => "Escalated",
            .timeout => "Timeout",
            .sandboxed => "Sandboxed",
            .human_required => "HumanRequired",
        };
    }
};

// -----------------------------------------------------------------------
// MemoryType — cognitive memory classification
// Mirrors: Agentic.Types.MemoryType (5 variants)
// -----------------------------------------------------------------------

pub const MemoryType = enum(u8) {
    working = 0,
    episodic = 1,
    semantic = 2,
    procedural = 3,
    shared = 4,

    /// Whether this memory type is local to a single agent.
    pub fn isAgentLocal(self: MemoryType) bool {
        return self != .shared;
    }

    /// Whether this memory type persists across sessions.
    pub fn isPersistent(self: MemoryType) bool {
        return switch (self) {
            .episodic, .semantic, .procedural, .shared => true,
            .working => false,
        };
    }

    pub fn label(self: MemoryType) [*:0]const u8 {
        return switch (self) {
            .working => "Working",
            .episodic => "Episodic",
            .semantic => "Semantic",
            .procedural => "Procedural",
            .shared => "Shared",
        };
    }
};

// -----------------------------------------------------------------------
// AgentContext — runtime context for an agent instance
// Combines state, coordination strategy, and safety status.
// -----------------------------------------------------------------------

pub const AgentContext = extern struct {
    state: AgentState,
    coordination: Coordination,
    last_safety_check: SafetyCheck,
    memory_type: MemoryType,
    agent_id: u32,
    _pad: [3]u8 = .{ 0, 0, 0 },
};

// -----------------------------------------------------------------------
// C-exported API — extern "C" functions for cross-language FFI
// -----------------------------------------------------------------------

export fn agentic_agent_state_label(state: AgentState) [*:0]const u8 {
    return state.label();
}

export fn agentic_agent_state_can_transition(from: AgentState, to: AgentState) bool {
    return from.canTransition(to);
}

export fn agentic_tool_call_label(tc: ToolCall) [*:0]const u8 {
    return tc.label();
}

export fn agentic_tool_call_has_side_effects(tc: ToolCall) bool {
    return tc.hasSideEffects();
}

export fn agentic_tool_call_requires_safety_check(tc: ToolCall) bool {
    return tc.requiresSafetyCheck();
}

export fn agentic_plan_step_label(ps: PlanStep) [*:0]const u8 {
    return ps.label();
}

export fn agentic_plan_step_is_control_flow(ps: PlanStep) bool {
    return ps.isControlFlow();
}

export fn agentic_coordination_label(c: Coordination) [*:0]const u8 {
    return c.label();
}

export fn agentic_coordination_is_multi_agent(c: Coordination) bool {
    return c.isMultiAgent();
}

export fn agentic_safety_check_label(sc: SafetyCheck) [*:0]const u8 {
    return sc.label();
}

export fn agentic_safety_check_allows_execution(sc: SafetyCheck) bool {
    return sc.allowsExecution();
}

export fn agentic_safety_check_needs_human(sc: SafetyCheck) bool {
    return sc.needsHuman();
}

export fn agentic_memory_type_label(mt: MemoryType) [*:0]const u8 {
    return mt.label();
}

export fn agentic_memory_type_is_persistent(mt: MemoryType) bool {
    return mt.isPersistent();
}

/// Create a new agent context with default values.
export fn agentic_context_create(agent_id: u32) AgentContext {
    return AgentContext{
        .state = .idle,
        .coordination = .solo,
        .last_safety_check = .approved,
        .memory_type = .working,
        .agent_id = agent_id,
    };
}

/// Attempt a state transition. Returns true if the transition succeeded.
export fn agentic_context_transition(ctx: *AgentContext, new_state: AgentState) bool {
    if (ctx.state.canTransition(new_state)) {
        ctx.state = new_state;
        return true;
    }
    return false;
}

// -----------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------

test "AgentState transitions follow OODA loop" {
    try std.testing.expect(AgentState.idle.canTransition(.planning));
    try std.testing.expect(AgentState.planning.canTransition(.acting));
    try std.testing.expect(AgentState.acting.canTransition(.observing));
    try std.testing.expect(AgentState.observing.canTransition(.reflecting));
    try std.testing.expect(AgentState.reflecting.canTransition(.planning));
    // Cannot go backward from idle
    try std.testing.expect(!AgentState.idle.canTransition(.reflecting));
    // Terminated is absorbing
    try std.testing.expect(!AgentState.terminated.canTransition(.idle));
}

test "ToolCall side effects are correct" {
    try std.testing.expect(ToolCall.execute.hasSideEffects());
    try std.testing.expect(!ToolCall.query.hasSideEffects());
    try std.testing.expect(!ToolCall.transform.hasSideEffects());
    try std.testing.expect(ToolCall.delegate.hasSideEffects());
}

test "SafetyCheck execution permission" {
    try std.testing.expect(SafetyCheck.approved.allowsExecution());
    try std.testing.expect(SafetyCheck.sandboxed.allowsExecution());
    try std.testing.expect(!SafetyCheck.denied.allowsExecution());
    try std.testing.expect(!SafetyCheck.human_required.allowsExecution());
}

test "AgentContext transitions" {
    var ctx = AgentContext{
        .state = .idle,
        .coordination = .solo,
        .last_safety_check = .approved,
        .memory_type = .working,
        .agent_id = 1,
    };
    try std.testing.expect(ctx.state == .idle);
    // Valid transition
    const ok = agentic_context_transition(&ctx, .planning);
    try std.testing.expect(ok);
    try std.testing.expect(ctx.state == .planning);
    // Invalid transition (planning → observing)
    const bad = agentic_context_transition(&ctx, .observing);
    try std.testing.expect(!bad);
    try std.testing.expect(ctx.state == .planning);
}

test "MemoryType persistence" {
    try std.testing.expect(!MemoryType.working.isPersistent());
    try std.testing.expect(MemoryType.episodic.isPersistent());
    try std.testing.expect(MemoryType.shared.isPersistent());
    try std.testing.expect(!MemoryType.shared.isAgentLocal());
}
