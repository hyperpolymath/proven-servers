-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- LogcollectorABI.Foreign: Foreign function declarations for the log
-- collector C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (LogPipeline) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function lc_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module LogcollectorABI.Foreign

import Logcollector.Types
import LogcollectorABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a log collector pipeline instance.
export
data LogPipeline : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +--------------------------------------------------------------------------+
-- | Function                      | Signature                                |
-- +-------------------------------+------------------------------------------+
-- | lc_abi_version                | () -> u32                                |
-- +-------------------------------+------------------------------------------+
-- | lc_create                     | (input_fmt: u8, output_target: u8,       |
-- |                               |  min_level: u8) -> c_int                 |
-- +-------------------------------+------------------------------------------+
-- | lc_destroy                    | (slot: c_int) -> void                    |
-- +-------------------------------+------------------------------------------+
-- | lc_get_input_format           | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lc_get_output_target          | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lc_get_min_level              | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lc_get_current_stage          | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lc_get_entries_processed      | (slot: c_int) -> u32                     |
-- +-------------------------------+------------------------------------------+
-- | lc_get_entries_dropped        | (slot: c_int) -> u32                     |
-- +-------------------------------+------------------------------------------+
-- | lc_get_last_error             | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lc_ingest                     | (slot: c_int, level: u8) -> u8           |
-- +-------------------------------+------------------------------------------+
-- | lc_apply_filter               | (slot: c_int, filter_op: u8) -> u8       |
-- +-------------------------------+------------------------------------------+
-- | lc_advance_stage              | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lc_set_min_level              | (slot: c_int, level: u8) -> u8           |
-- +-------------------------------+------------------------------------------+
