-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FSMABI.Foreign: Foreign function declarations for the C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (MachineHandle) that cannot be inspected or
--      forged from Idris2 code — it exists only as a pointer managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function fsm_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module FSMABI.Foreign

import FSM.Types
import FSMABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a state machine instance.
||| This type has no Idris2-visible constructors — values can only be
||| created by the Zig FFI via fsm_create() and destroyed via fsm_destroy().
export
data MachineHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's fsm_abi_version() function MUST return
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
-- Zig implementation (ffi/zig/src/fsm.zig) must export.
--
-- +-----------------------------------------------------------------------+
-- | Function             | Signature                                      |
-- +----------------------+------------------------------------------------+
-- | fsm_abi_version      | () -> Bits32                                   |
-- |                      | Must return abiVersion (currently 1).          |
-- +----------------------+------------------------------------------------+
-- | fsm_create           | (max_states: u16, max_transitions: u32)        |
-- |                      |  -> Ptr MachineHandle                          |
-- |                      | Creates a new FSM in Initial state.            |
-- |                      | Returns NULL if max_states/transitions invalid. |
-- +----------------------+------------------------------------------------+
-- | fsm_destroy          | (h: Ptr MachineHandle) -> ()                   |
-- |                      | Frees the machine handle. Safe with NULL.      |
-- +----------------------+------------------------------------------------+
-- | fsm_state            | (h: Ptr MachineHandle) -> Bits8                |
-- |                      | Returns the MachineState tag for handle h.     |
-- |                      | Returns Initial (0) if h is NULL.              |
-- +----------------------+------------------------------------------------+
-- | fsm_start            | (h: Ptr MachineHandle) -> Bits8                |
-- |                      | Transitions: Initial -> Running.               |
-- |                      | Returns TransitionResult tag.                  |
-- +----------------------+------------------------------------------------+
-- | fsm_complete         | (h: Ptr MachineHandle) -> Bits8                |
-- |                      | Transitions: Running -> Terminal.              |
-- |                      | Returns TransitionResult tag.                  |
-- +----------------------+------------------------------------------------+
-- | fsm_fault            | (h: Ptr MachineHandle) -> Bits8                |
-- |                      | Transitions: Initial|Running -> Faulted.       |
-- |                      | Returns TransitionResult tag.                  |
-- +----------------------+------------------------------------------------+
-- | fsm_reset            | (h: Ptr MachineHandle) -> Bits8                |
-- |                      | Transitions: Faulted -> Initial.               |
-- |                      | Returns TransitionResult tag.                  |
-- +----------------------+------------------------------------------------+
-- | fsm_submit_event     | (h: Ptr MachineHandle,                         |
-- |                      |  event_id: u32) -> Bits8                       |
-- |                      | Submits an event to the machine.               |
-- |                      | Returns EventDisposition tag.                  |
-- |                      | Only valid in Running state.                   |
-- +----------------------+------------------------------------------------+
-- | fsm_can_transition   | (from: Bits8, to: Bits8) -> Bits8              |
-- |                      | Returns 1 if the transition is valid, 0 if not.|
-- |                      | Stateless — validates against the schema.      |
-- +----------------------+------------------------------------------------+
-- | fsm_last_error       | (h: Ptr MachineHandle) -> Bits8                |
-- |                      | Returns the last ValidationError tag,          |
-- |                      | or 255 if no error occurred.                   |
-- +----------------------+------------------------------------------------+
