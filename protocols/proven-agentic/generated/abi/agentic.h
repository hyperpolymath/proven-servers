// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
/* SPDX-License-Identifier: MPL-2.0
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * agentic.h -- C-ABI header for proven-agentic.
 *
 * Generated from AgenticABI.Layout.idr tag assignments.
 * Tag values MUST match:
 *   - Idris2 ABI (src/AgenticABI/Layout.idr)
 *   - Zig FFI   (ffi/zig/src/agentic.zig)
 *
 * Multi-agent coordination protocol definitions.
 */

#ifndef PROVEN_AGENTIC_H
#define PROVEN_AGENTIC_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- AgentState (7 constructors, tags 0-6) -------------------------------- */
/* Agent lifecycle state machine.                                            */
#define AG_STATE_IDLE        0
#define AG_STATE_PLANNING    1
#define AG_STATE_ACTING      2
#define AG_STATE_OBSERVING   3
#define AG_STATE_REFLECTING  4
#define AG_STATE_BLOCKED     5
#define AG_STATE_TERMINATED  6

/* -- ToolCall (6 constructors, tags 0-5) ---------------------------------- */
/* Classification of tool invocations an agent may issue.                    */
#define AG_TOOL_EXECUTE      0
#define AG_TOOL_QUERY        1
#define AG_TOOL_TRANSFORM    2
#define AG_TOOL_COMMUNICATE  3
#define AG_TOOL_DELEGATE     4
#define AG_TOOL_ESCALATE     5

/* -- PlanStep (7 constructors, tags 0-6) ---------------------------------- */
/* Node types in an agent's execution plan tree.                             */
#define AG_PLAN_ACTION       0
#define AG_PLAN_CONDITION    1
#define AG_PLAN_LOOP         2
#define AG_PLAN_BRANCH       3
#define AG_PLAN_PARALLEL     4
#define AG_PLAN_CHECKPOINT   5
#define AG_PLAN_ROLLBACK     6

/* -- Coordination (6 constructors, tags 0-5) ------------------------------ */
/* Strategy for coordinating multiple agents.                                */
#define AG_COORD_SOLO          0
#define AG_COORD_COLLABORATIVE 1
#define AG_COORD_COMPETITIVE   2
#define AG_COORD_HIERARCHICAL  3
#define AG_COORD_SWARM         4
#define AG_COORD_CONSENSUS     5

/* -- SafetyCheck (6 constructors, tags 0-5) ------------------------------- */
/* Result of a safety evaluation before agent action.                        */
#define AG_SAFETY_APPROVED       0
#define AG_SAFETY_DENIED         1
#define AG_SAFETY_ESCALATED      2
#define AG_SAFETY_TIMED_OUT      3
#define AG_SAFETY_SANDBOXED      4
#define AG_SAFETY_HUMAN_REQUIRED 5

/* -- MemoryType (5 constructors, tags 0-4) -------------------------------- */
/* Classification of agent memory systems.                                   */
#define AG_MEM_WORKING    0
#define AG_MEM_EPISODIC   1
#define AG_MEM_SEMANTIC   2
#define AG_MEM_PROCEDURAL 3
#define AG_MEM_SHARED     4

/* -- AgenticError (8 constructors, tags 0-7) ------------------------------ */
/* Error codes returned by agentic FFI operations.                           */
#define AG_ERR_OK                  0
#define AG_ERR_INVALID_SLOT        1
#define AG_ERR_NOT_ACTIVE          2
#define AG_ERR_INVALID_TRANSITION  3
#define AG_ERR_BLOCKED             4
#define AG_ERR_TOOL_LIMIT_EXCEEDED 5
#define AG_ERR_PLAN_DEPTH_EXCEEDED 6
#define AG_ERR_SAFETY_DENIED       7

/* -- Sentinel values ------------------------------------------------------ */
#define AG_NO_ERROR  255

/* -- Protocol constants --------------------------------------------------- */
#define AG_PORT              9600
#define AG_MAX_AGENTS        256
#define AG_MAX_PLAN_DEPTH    50
#define AG_SAFETY_TIMEOUT_SECS 10
#define AG_MAX_TOOL_CALLS    1000

/* -- ABI ------------------------------------------------------------------ */
uint32_t agentic_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      agentic_create(uint8_t coordination, uint32_t max_tools, uint32_t max_depth);
void     agentic_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  agentic_get_state(int slot);
uint8_t  agentic_get_coordination(int slot);
uint8_t  agentic_get_safety(int slot);
uint8_t  agentic_get_memory_type(int slot);
uint32_t agentic_get_tool_count(int slot);
uint32_t agentic_get_plan_depth(int slot);
uint8_t  agentic_get_last_error(int slot);
uint32_t agentic_get_completed_tasks(int slot);

/* -- State transitions ---------------------------------------------------- */
uint8_t agentic_transition(int slot, uint8_t new_state);

/* -- Tool call tracking --------------------------------------------------- */
uint8_t agentic_record_tool_call(int slot, uint8_t tool_kind);

/* -- Plan step management ------------------------------------------------- */
uint8_t agentic_push_plan_step(int slot, uint8_t step_kind);
uint8_t agentic_pop_plan_step(int slot);

/* -- Safety checks -------------------------------------------------------- */
uint8_t agentic_safety_check(int slot, uint8_t tool_kind);

/* -- Configuration -------------------------------------------------------- */
uint8_t agentic_set_memory_type(int slot, uint8_t mem_type);
uint8_t agentic_set_coordination(int slot, uint8_t coord);

/* -- Stateless transition checks ------------------------------------------ */
uint8_t agentic_can_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_AGENTIC_H */
