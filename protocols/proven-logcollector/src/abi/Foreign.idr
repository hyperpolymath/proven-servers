-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LogcollectorABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/logcollector.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching LogcollectorABI.Types exactly.

module LogcollectorABI.Foreign

import LogcollectorABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Logcollector context.
||| Created by logcollector_create*(), destroyed by logcollector_destroy*().
export
data LogcollectorContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match logcollector_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | lc_abi_version                    | () -> u32                                   |
-- | lc_create                         | (input_fmt: u8, output_target: u8, min_l... |
-- | lc_destroy                        | (slot: c_int) -> void                       |
-- | lc_get_input_format               | (slot: c_int) -> u8                         |
-- | lc_get_output_target              | (slot: c_int) -> u8                         |
-- | lc_get_min_level                  | (slot: c_int) -> u8                         |
-- | lc_get_current_stage              | (slot: c_int) -> u8                         |
-- | lc_get_entries_processed          | (slot: c_int) -> u32                        |
-- | lc_get_entries_dropped            | (slot: c_int) -> u32                        |
-- | lc_get_last_error                 | (slot: c_int) -> u8                         |
-- | lc_ingest                         | (slot: c_int, level: u8) -> u8              |
-- | lc_apply_filter                   | (slot: c_int, filter_op: u8) -> u8          |
-- | lc_advance_stage                  | (slot: c_int) -> u8                         |
-- | lc_set_min_level                  | (slot: c_int, level: u8) -> u8              |
-- +───────────────────────────────────+─────────────────────────────────────────────+
