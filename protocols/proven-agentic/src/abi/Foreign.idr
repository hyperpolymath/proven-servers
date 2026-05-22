-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AgenticABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/agentic.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching AgenticABI.Types exactly.

module AgenticABI.Foreign

import AgenticABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Agentic context.
||| Created by agentic_create*(), destroyed by agentic_destroy*().
export
data AgenticContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match agentic_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (19 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | agentic_abi_version               | () -> u32                                   |
-- | agentic_create                    | (coordination: u8, max_tools: u32, max_d... |
-- | agentic_destroy                   | (slot: c_int) -> void                       |
-- | agentic_get_state                 | (slot: c_int) -> u8                         |
-- | agentic_get_coordination          | (slot: c_int) -> u8                         |
-- | agentic_get_safety                | (slot: c_int) -> u8                         |
-- | agentic_get_memory_type           | (slot: c_int) -> u8                         |
-- | agentic_get_tool_count            | (slot: c_int) -> u32                        |
-- | agentic_get_plan_depth            | (slot: c_int) -> u32                        |
-- | agentic_get_last_error            | (slot: c_int) -> u8                         |
-- | agentic_get_completed_tasks       | (slot: c_int) -> u32                        |
-- | agentic_transition                | (slot: c_int, new_state: u8) -> u8          |
-- | agentic_record_tool_call          | (slot: c_int, tool_kind: u8) -> u8          |
-- | agentic_push_plan_step            | (slot: c_int, step_kind: u8) -> u8          |
-- | agentic_pop_plan_step             | (slot: c_int) -> u8                         |
-- | agentic_safety_check              | (slot: c_int, tool_kind: u8) -> u8          |
-- | agentic_set_memory_type           | (slot: c_int, mem_type: u8) -> u8           |
-- | agentic_set_coordination          | (slot: c_int, coord: u8) -> u8              |
-- | agentic_can_transition            | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
