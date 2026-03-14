-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ComposeABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module ComposeABI.Foreign

import Compose.Types
import ComposeABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a composition pipeline session.
||| Created by compose_create(), destroyed by compose_destroy().
export
data ComposeHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match compose_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function                  | Signature                                 |
-- +---------------------------+-------------------------------------------+
-- | compose_abi_version       | () -> Bits32                              |
-- +---------------------------+-------------------------------------------+
-- | compose_create            | (combinator: u8) -> c_int (slot)          |
-- |                           | Creates pipeline in Idle state.           |
-- +---------------------------+-------------------------------------------+
-- | compose_destroy           | (slot: c_int) -> ()                       |
-- +---------------------------+-------------------------------------------+
-- | compose_state             | (slot: c_int) -> u8 (PipelineState tag)   |
-- +---------------------------+-------------------------------------------+
-- | compose_combinator        | (slot: c_int) -> u8 (Combinator tag)      |
-- +---------------------------+-------------------------------------------+
-- | compose_direction         | (slot: c_int) -> u8 (Direction tag)       |
-- +---------------------------+-------------------------------------------+
-- | compose_set_direction     | (slot: c_int, dir: u8) -> u8 (result)     |
-- +---------------------------+-------------------------------------------+
-- | compose_configure         | (slot: c_int) -> u8 (TransitionResult)    |
-- +---------------------------+-------------------------------------------+
-- | compose_assemble          | (slot: c_int) -> u8 (TransitionResult)    |
-- +---------------------------+-------------------------------------------+
-- | compose_activate          | (slot: c_int) -> u8 (TransitionResult)    |
-- +---------------------------+-------------------------------------------+
-- | compose_deactivate        | (slot: c_int) -> u8 (TransitionResult)    |
-- +---------------------------+-------------------------------------------+
-- | compose_fail              | (slot: c_int, err: u8) -> u8              |
-- +---------------------------+-------------------------------------------+
-- | compose_reset             | (slot: c_int) -> u8 (TransitionResult)    |
-- +---------------------------+-------------------------------------------+
-- | compose_last_error        | (slot: c_int) -> u8                       |
-- +---------------------------+-------------------------------------------+
-- | compose_check_compat      | (a: u8, b: u8) -> u8 (Compatibility tag) |
-- +---------------------------+-------------------------------------------+
-- | compose_stage_count       | (slot: c_int) -> u8                       |
-- +---------------------------+-------------------------------------------+
-- | compose_add_stage         | (slot: c_int, stage: u8) -> u8            |
-- +---------------------------+-------------------------------------------+
-- | compose_can_transition    | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +---------------------------+-------------------------------------------+
