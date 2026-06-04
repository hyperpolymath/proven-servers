// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// agentic.zig — Zig FFI implementation of proven-agentic.
//
// Implements the multi-agent coordination primitive with:
//   - Slot-based context management (up to 64 concurrent agents)
//   - Agent lifecycle state machine (Idle -> Planning -> Acting ->
//     Observing -> Reflecting -> Idle/Acting, with Blocked/Terminated)
//   - Tool call tracking with configurable limits
//   - Plan step stack with configurable depth limits
//   - Safety check integration
//   - Coordination strategy management
//   - Memory type selection
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/AgenticABI/Layout.idr)
//   - C header   (generated/abi/agentic.h)

const std = @import("std");

// ── Enums (matching Idris2 Layout.idr tag assignments exactly) ──────────

/// AgentState — matches agentStateToTag
pub const AgentState = enum(u8) {
    idle = 0,
    planning = 1,
    acting = 2,
    observing = 3,
    reflecting = 4,
    blocked = 5,
    terminated = 6,
};

/// ToolCall — matches toolCallToTag
pub const ToolCall = enum(u8) {
    execute = 0,
    query = 1,
    transform = 2,
    communicate = 3,
    delegate = 4,
    escalate = 5,
};

/// PlanStep — matches planStepToTag
pub const PlanStep = enum(u8) {
    action = 0,
    condition = 1,
    loop = 2,
    branch = 3,
    parallel = 4,
    checkpoint = 5,
    rollback = 6,
};

/// Coordination — matches coordinationToTag
pub const Coordination = enum(u8) {
    solo = 0,
    collaborative = 1,
    competitive = 2,
    hierarchical = 3,
    swarm = 4,
    consensus = 5,
};

/// SafetyCheck — matches safetyCheckToTag
pub const SafetyCheck = enum(u8) {
    approved = 0,
    denied = 1,
    escalated = 2,
    timeout = 3,
    sandboxed = 4,
    human_required = 5,
};

/// MemoryType — matches memoryTypeToTag
pub const MemoryType = enum(u8) {
    working = 0,
    episodic = 1,
    semantic = 2,
    procedural = 3,
    shared = 4,
};

/// AgenticError — matches agenticErrorToTag
pub const AgenticError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_transition = 3,
    blocked = 4,
    tool_limit_exceeded = 5,
    plan_depth_exceeded = 6,
    safety_denied = 7,
};

// ── Agent Context instance ──────────────────────────────────────────────

/// Maximum plan step stack depth (hard limit regardless of config).
const MAX_PLAN_STACK: usize = 256;

const AgentCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Current lifecycle state.
    state: AgentState,
    /// Coordination strategy.
    coordination: Coordination,
    /// Active memory type.
    memory_type: MemoryType,
    /// Last safety check result.
    last_safety: SafetyCheck,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Number of tool calls made in the current task.
    tool_count: u32,
    /// Maximum tool calls allowed per task.
    max_tools: u32,
    /// Current plan step stack depth.
    plan_depth: u32,
    /// Maximum plan step depth allowed.
    max_plan_depth: u32,
    /// Number of completed tasks (Reflecting -> Idle transitions).
    completed_tasks: u32,
    /// Plan step stack (kind tags).
    plan_stack: [MAX_PLAN_STACK]u8,
    /// State the agent was in before being blocked (for unblock routing).
    pre_block_state: AgentState,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: AgentCtx = .{
    .active = false,
    .state = .idle,
    .coordination = .solo,
    .memory_type = .working,
    .last_safety = .approved,
    .last_error = 255,
    .tool_count = 0,
    .max_tools = 1000,
    .plan_depth = 0,
    .max_plan_depth = 50,
    .completed_tasks = 0,
    .plan_stack = [_]u8{0} ** MAX_PLAN_STACK,
    .pre_block_state = .idle,
};

var contexts: [MAX_CONTEXTS]AgentCtx = [_]AgentCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*AgentCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match AgenticABI.Foreign.abiVersion (currently 1).
pub export fn agentic_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new agent context.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn agentic_create(coordination: u8, max_tools: u32, max_depth: u32) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate coordination (0-5)
    if (coordination > 5) return -1;
    // Validate limits
    if (max_tools == 0 or max_depth == 0) return -1;
    if (max_depth > MAX_PLAN_STACK) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.coordination = @enumFromInt(coordination);
            ctx.max_tools = max_tools;
            ctx.max_plan_depth = max_depth;
            return @intCast(i);
        }
    }
    return -1; // all slots occupied
}

/// Destroy an agent context, freeing its slot.
/// Safe to call with any slot index (invalid slots are no-ops).
pub export fn agentic_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current AgentState tag for a slot.
/// Returns Idle (0) for invalid/inactive slots.
pub export fn agentic_get_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.state);
}

/// Get the current Coordination tag for a slot.
/// Returns Solo (0) for invalid/inactive slots.
pub export fn agentic_get_coordination(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.coordination);
}

/// Get the last SafetyCheck tag for a slot.
/// Returns Approved (0) for invalid/inactive slots.
pub export fn agentic_get_safety(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.last_safety);
}

/// Get the active MemoryType tag for a slot.
/// Returns Working (0) for invalid/inactive slots.
pub export fn agentic_get_memory_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.memory_type);
}

/// Get the number of tool calls made in the current task.
pub export fn agentic_get_tool_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.tool_count;
}

/// Get the current plan depth.
pub export fn agentic_get_plan_depth(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.plan_depth;
}

/// Get the last AgenticError tag, or 255 if no error.
pub export fn agentic_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

/// Get the number of completed tasks.
pub export fn agentic_get_completed_tasks(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.completed_tasks;
}

// ── State transitions ───────────────────────────────────────────────────

/// Advance an agent to a new state, validating the transition.
/// Returns AgenticError tag.
pub export fn agentic_transition(slot: c_int, new_state: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(AgenticError.invalid_slot);

    const from = @intFromEnum(ctx.state);
    if (agentic_can_transition(from, new_state) == 0) {
        ctx.last_error = @intFromEnum(AgenticError.invalid_transition);
        return @intFromEnum(AgenticError.invalid_transition);
    }

    // Handle blocking: remember pre-block state
    if (new_state == @intFromEnum(AgentState.blocked)) {
        ctx.pre_block_state = ctx.state;
    }

    // Handle completion: Reflecting -> Idle increments completed tasks
    // and resets tool count
    if (from == @intFromEnum(AgentState.reflecting) and new_state == @intFromEnum(AgentState.idle)) {
        ctx.completed_tasks += 1;
        ctx.tool_count = 0;
        ctx.plan_depth = 0;
    }

    ctx.state = @enumFromInt(new_state);
    ctx.last_error = 255;
    return @intFromEnum(AgenticError.ok);
}

// ── Tool call tracking ──────────────────────────────────────────────────

/// Record a tool call of the given kind.
/// Fails with ToolLimitExceeded if the limit has been reached.
/// Agent must be in Acting state.
/// Returns AgenticError tag.
pub export fn agentic_record_tool_call(slot: c_int, tool_kind: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(AgenticError.invalid_slot);

    if (ctx.state != .acting) {
        ctx.last_error = @intFromEnum(AgenticError.invalid_transition);
        return @intFromEnum(AgenticError.invalid_transition);
    }

    // Validate tool kind (0-5)
    if (tool_kind > 5) {
        ctx.last_error = @intFromEnum(AgenticError.invalid_transition);
        return @intFromEnum(AgenticError.invalid_transition);
    }

    if (ctx.tool_count >= ctx.max_tools) {
        ctx.last_error = @intFromEnum(AgenticError.tool_limit_exceeded);
        return @intFromEnum(AgenticError.tool_limit_exceeded);
    }

    ctx.tool_count += 1;
    ctx.last_error = 255;
    return @intFromEnum(AgenticError.ok);
}

// ── Plan step management ────────────────────────────────────────────────

/// Push a plan step onto the stack.
/// Fails with PlanDepthExceeded if the limit has been reached.
/// Agent must be in Planning state.
/// Returns AgenticError tag.
pub export fn agentic_push_plan_step(slot: c_int, step_kind: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(AgenticError.invalid_slot);

    if (ctx.state != .planning) {
        ctx.last_error = @intFromEnum(AgenticError.invalid_transition);
        return @intFromEnum(AgenticError.invalid_transition);
    }

    // Validate step kind (0-6)
    if (step_kind > 6) {
        ctx.last_error = @intFromEnum(AgenticError.invalid_transition);
        return @intFromEnum(AgenticError.invalid_transition);
    }

    if (ctx.plan_depth >= ctx.max_plan_depth) {
        ctx.last_error = @intFromEnum(AgenticError.plan_depth_exceeded);
        return @intFromEnum(AgenticError.plan_depth_exceeded);
    }

    ctx.plan_stack[ctx.plan_depth] = step_kind;
    ctx.plan_depth += 1;
    ctx.last_error = 255;
    return @intFromEnum(AgenticError.ok);
}

/// Pop the top plan step from the stack.
/// Returns AgenticError tag.
pub export fn agentic_pop_plan_step(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(AgenticError.invalid_slot);

    if (ctx.plan_depth == 0) {
        ctx.last_error = @intFromEnum(AgenticError.invalid_transition);
        return @intFromEnum(AgenticError.invalid_transition);
    }

    ctx.plan_depth -= 1;
    ctx.last_error = 255;
    return @intFromEnum(AgenticError.ok);
}

// ── Safety checks ───────────────────────────────────────────────────────

/// Run a safety check for a tool call.
/// Currently implements a simple policy: Escalate and Delegate tool kinds
/// require human approval; Execute tools in Competitive coordination are
/// sandboxed; everything else is approved.
/// Returns SafetyCheck tag.
pub export fn agentic_safety_check(slot: c_int, tool_kind: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SafetyCheck.denied);

    // Validate tool kind
    if (tool_kind > 5) return @intFromEnum(SafetyCheck.denied);

    const kind: ToolCall = @enumFromInt(tool_kind);

    // Escalate tool calls always require human approval
    if (kind == .escalate) {
        ctx.last_safety = .human_required;
        return @intFromEnum(SafetyCheck.human_required);
    }

    // Delegate in competitive mode is escalated (potential adversarial use)
    if (kind == .delegate and ctx.coordination == .competitive) {
        ctx.last_safety = .escalated;
        return @intFromEnum(SafetyCheck.escalated);
    }

    // Execute in competitive mode is sandboxed
    if (kind == .execute and ctx.coordination == .competitive) {
        ctx.last_safety = .sandboxed;
        return @intFromEnum(SafetyCheck.sandboxed);
    }

    ctx.last_safety = .approved;
    return @intFromEnum(SafetyCheck.approved);
}

// ── Configuration setters ───────────────────────────────────────────────

/// Set the active memory type for an agent.
/// Returns AgenticError tag.
pub export fn agentic_set_memory_type(slot: c_int, mem_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(AgenticError.invalid_slot);

    if (mem_type > 4) {
        ctx.last_error = @intFromEnum(AgenticError.invalid_transition);
        return @intFromEnum(AgenticError.invalid_transition);
    }

    ctx.memory_type = @enumFromInt(mem_type);
    ctx.last_error = 255;
    return @intFromEnum(AgenticError.ok);
}

/// Set the coordination strategy for an agent.
/// Returns AgenticError tag.
pub export fn agentic_set_coordination(slot: c_int, coord: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(AgenticError.invalid_slot);

    if (coord > 5) {
        ctx.last_error = @intFromEnum(AgenticError.invalid_transition);
        return @intFromEnum(AgenticError.invalid_transition);
    }

    ctx.coordination = @enumFromInt(coord);
    ctx.last_error = 255;
    return @intFromEnum(AgenticError.ok);
}

// ── Stateless transition validation ─────────────────────────────────────

/// Check whether an agent state transition is valid.
/// Returns 1 if valid, 0 if not.
/// Matches Transitions.idr validateAgentTransition exactly.
pub export fn agentic_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Idle (0) -> Planning (1)
    if (from == 0 and to == 1) return 1;
    // Planning (1) -> Acting (2)
    if (from == 1 and to == 2) return 1;
    // Acting (2) -> Observing (3)
    if (from == 2 and to == 3) return 1;
    // Observing (3) -> Reflecting (4)
    if (from == 3 and to == 4) return 1;
    // Reflecting (4) -> Acting (2) (resume)
    if (from == 4 and to == 2) return 1;
    // Reflecting (4) -> Planning (1) (revise)
    if (from == 4 and to == 1) return 1;
    // Reflecting (4) -> Idle (0) (complete)
    if (from == 4 and to == 0) return 1;
    // Planning (1) -> Blocked (5)
    if (from == 1 and to == 5) return 1;
    // Acting (2) -> Blocked (5)
    if (from == 2 and to == 5) return 1;
    // Observing (3) -> Blocked (5)
    if (from == 3 and to == 5) return 1;
    // Blocked (5) -> Planning (1)
    if (from == 5 and to == 1) return 1;
    // Blocked (5) -> Acting (2)
    if (from == 5 and to == 2) return 1;
    // Blocked (5) -> Observing (3)
    if (from == 5 and to == 3) return 1;
    // Idle (0) -> Terminated (6)
    if (from == 0 and to == 6) return 1;
    // Planning (1) -> Terminated (6)
    if (from == 1 and to == 6) return 1;
    // Acting (2) -> Terminated (6)
    if (from == 2 and to == 6) return 1;
    // Observing (3) -> Terminated (6)
    if (from == 3 and to == 6) return 1;
    // Reflecting (4) -> Terminated (6)
    if (from == 4 and to == 6) return 1;
    // Blocked (5) -> Terminated (6)
    if (from == 5 and to == 6) return 1;
    return 0;
}
