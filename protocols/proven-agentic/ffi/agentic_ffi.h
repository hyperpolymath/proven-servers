/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * agentic_ffi.h: C header for the proven-agentic FFI.
 * Generated from Idris2 ABI definitions, implemented in Zig.
 * This header is consumed by the V-lang triple adapter and
 * any other language binding that needs C ABI compatibility.
 */

#ifndef AGENTIC_FFI_H
#define AGENTIC_FFI_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* --- AgentState (7 variants) --- */
typedef enum {
    AGENT_STATE_IDLE       = 0,
    AGENT_STATE_PLANNING   = 1,
    AGENT_STATE_ACTING     = 2,
    AGENT_STATE_OBSERVING  = 3,
    AGENT_STATE_REFLECTING = 4,
    AGENT_STATE_BLOCKED    = 5,
    AGENT_STATE_TERMINATED = 6
} AgentState;

/* --- ToolCall (6 variants) --- */
typedef enum {
    TOOL_CALL_EXECUTE     = 0,
    TOOL_CALL_QUERY       = 1,
    TOOL_CALL_TRANSFORM   = 2,
    TOOL_CALL_COMMUNICATE = 3,
    TOOL_CALL_DELEGATE    = 4,
    TOOL_CALL_ESCALATE    = 5
} ToolCall;

/* --- PlanStep (7 variants) --- */
typedef enum {
    PLAN_STEP_ACTION     = 0,
    PLAN_STEP_CONDITION  = 1,
    PLAN_STEP_LOOP       = 2,
    PLAN_STEP_BRANCH     = 3,
    PLAN_STEP_PARALLEL   = 4,
    PLAN_STEP_CHECKPOINT = 5,
    PLAN_STEP_ROLLBACK   = 6
} PlanStep;

/* --- Coordination (6 variants) --- */
typedef enum {
    COORDINATION_SOLO          = 0,
    COORDINATION_COLLABORATIVE = 1,
    COORDINATION_COMPETITIVE   = 2,
    COORDINATION_HIERARCHICAL  = 3,
    COORDINATION_SWARM         = 4,
    COORDINATION_CONSENSUS     = 5
} Coordination;

/* --- SafetyCheck (6 variants) --- */
typedef enum {
    SAFETY_CHECK_APPROVED       = 0,
    SAFETY_CHECK_DENIED         = 1,
    SAFETY_CHECK_ESCALATED      = 2,
    SAFETY_CHECK_TIMEOUT        = 3,
    SAFETY_CHECK_SANDBOXED      = 4,
    SAFETY_CHECK_HUMAN_REQUIRED = 5
} SafetyCheck;

/* --- MemoryType (5 variants) --- */
typedef enum {
    MEMORY_TYPE_WORKING    = 0,
    MEMORY_TYPE_EPISODIC   = 1,
    MEMORY_TYPE_SEMANTIC   = 2,
    MEMORY_TYPE_PROCEDURAL = 3,
    MEMORY_TYPE_SHARED     = 4
} MemoryType;

/* --- AgentContext --- */
typedef struct {
    AgentState    state;
    Coordination  coordination;
    SafetyCheck   last_safety_check;
    MemoryType    memory_type;
    uint32_t      agent_id;
    uint8_t       _pad[3];
} AgentContext;

/* --- Label functions --- */
const char* agentic_agent_state_label(AgentState state);
const char* agentic_tool_call_label(ToolCall tc);
const char* agentic_plan_step_label(PlanStep ps);
const char* agentic_coordination_label(Coordination c);
const char* agentic_safety_check_label(SafetyCheck sc);
const char* agentic_memory_type_label(MemoryType mt);

/* --- Predicate functions --- */
bool agentic_agent_state_can_transition(AgentState from, AgentState to);
bool agentic_tool_call_has_side_effects(ToolCall tc);
bool agentic_tool_call_requires_safety_check(ToolCall tc);
bool agentic_plan_step_is_control_flow(PlanStep ps);
bool agentic_coordination_is_multi_agent(Coordination c);
bool agentic_safety_check_allows_execution(SafetyCheck sc);
bool agentic_safety_check_needs_human(SafetyCheck sc);
bool agentic_memory_type_is_persistent(MemoryType mt);

/* --- Context lifecycle --- */
AgentContext agentic_context_create(uint32_t agent_id);
bool agentic_context_transition(AgentContext* ctx, AgentState new_state);

#ifdef __cplusplus
}
#endif

#endif /* AGENTIC_FFI_H */
