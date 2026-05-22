-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AgenticABI.Foreign: Foreign function declarations for the agentic C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (AgentContext) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function agentic_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module AgenticABI.Foreign

import Agentic.Types
import AgenticABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an agent context instance.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via agentic_create() and destroyed via
||| agentic_destroy().
export
data AgentContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's agentic_abi_version() function MUST return
||| this exact value.
|||
||| Increment this value whenever:
|||   - A new function is added to the FFI
|||   - An existing function signature changes
|||   - Tag values in Layout.idr change
|||   - Handle semantics change
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/agentic.zig) must export.
--
-- +--------------------------------------------------------------------------+
-- | Function                      | Signature                                |
-- +-------------------------------+------------------------------------------+
-- | agentic_abi_version           | () -> u32                                |
-- |                               | Must return abiVersion (currently 1).    |
-- +-------------------------------+------------------------------------------+
-- | agentic_create                | (coordination: u8, max_tools: u32,      |
-- |                               |  max_depth: u32) -> c_int               |
-- |                               | Creates a new agent in Idle state.       |
-- |                               | Returns -1 if no slots available.        |
-- +-------------------------------+------------------------------------------+
-- | agentic_destroy               | (slot: c_int) -> void                    |
-- |                               | Frees the agent context. Safe with any   |
-- |                               | slot.                                    |
-- +-------------------------------+------------------------------------------+
-- | agentic_get_state             | (slot: c_int) -> u8                      |
-- |                               | Returns the AgentState tag.              |
-- |                               | Returns Idle (0) if slot invalid.        |
-- +-------------------------------+------------------------------------------+
-- | agentic_get_coordination      | (slot: c_int) -> u8                      |
-- |                               | Returns the Coordination tag.            |
-- |                               | Returns Solo (0) if slot invalid.        |
-- +-------------------------------+------------------------------------------+
-- | agentic_get_safety            | (slot: c_int) -> u8                      |
-- |                               | Returns the last SafetyCheck tag.        |
-- |                               | Returns Approved (0) if slot invalid.    |
-- +-------------------------------+------------------------------------------+
-- | agentic_get_memory_type       | (slot: c_int) -> u8                      |
-- |                               | Returns the active MemoryType tag.       |
-- |                               | Returns Working (0) if slot invalid.     |
-- +-------------------------------+------------------------------------------+
-- | agentic_get_tool_count        | (slot: c_int) -> u32                     |
-- |                               | Returns the number of tool calls made.   |
-- +-------------------------------+------------------------------------------+
-- | agentic_get_plan_depth        | (slot: c_int) -> u32                     |
-- |                               | Returns the current plan depth.          |
-- +-------------------------------+------------------------------------------+
-- | agentic_get_last_error        | (slot: c_int) -> u8                      |
-- |                               | Returns the last AgenticError tag,       |
-- |                               | or 255 if no error occurred.             |
-- +-------------------------------+------------------------------------------+
-- | agentic_transition            | (slot: c_int, new_state: u8)             |
-- |                               |  -> u8 (AgenticError tag)                |
-- |                               | Advance agent to new_state if valid.     |
-- +-------------------------------+------------------------------------------+
-- | agentic_record_tool_call      | (slot: c_int, tool_kind: u8)             |
-- |                               |  -> u8 (AgenticError tag)                |
-- |                               | Record a tool call. Fails if limit       |
-- |                               | exceeded.                                |
-- +-------------------------------+------------------------------------------+
-- | agentic_push_plan_step        | (slot: c_int, step_kind: u8)             |
-- |                               |  -> u8 (AgenticError tag)                |
-- |                               | Push a plan step. Fails if depth         |
-- |                               | exceeded.                                |
-- +-------------------------------+------------------------------------------+
-- | agentic_pop_plan_step         | (slot: c_int) -> u8 (AgenticError tag)   |
-- |                               | Pop the top plan step.                   |
-- +-------------------------------+------------------------------------------+
-- | agentic_safety_check          | (slot: c_int, tool_kind: u8)             |
-- |                               |  -> u8 (SafetyCheck tag)                 |
-- |                               | Run a safety check for a tool call.      |
-- |                               | Returns the safety verdict.              |
-- +-------------------------------+------------------------------------------+
-- | agentic_set_memory_type       | (slot: c_int, mem_type: u8)              |
-- |                               |  -> u8 (AgenticError tag)                |
-- |                               | Set the active memory type.              |
-- +-------------------------------+------------------------------------------+
-- | agentic_set_coordination      | (slot: c_int, coord: u8)                 |
-- |                               |  -> u8 (AgenticError tag)                |
-- |                               | Set the coordination strategy.           |
-- +-------------------------------+------------------------------------------+
-- | agentic_can_transition        | (from: u8, to: u8) -> u8                 |
-- |                               | Returns 1 if transition is valid.        |
-- |                               | Stateless -- validates against schema.   |
-- +-------------------------------+------------------------------------------+
-- | agentic_get_completed_tasks   | (slot: c_int) -> u32                     |
-- |                               | Returns number of completed tasks.       |
-- +-------------------------------+------------------------------------------+
