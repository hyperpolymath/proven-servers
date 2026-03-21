-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LPDABI.Foreign: Foreign function declarations for the LPD C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (LpdQueue) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function lpd_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module LPDABI.Foreign

import LPDABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an LPD print queue instance.
export
data LpdQueue : Type where [external]

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
-- | lpd_abi_version               | () -> u32                                |
-- +-------------------------------+------------------------------------------+
-- | lpd_create                    | (max_depth: u32, max_job_size: u32)      |
-- |                               |  -> c_int                                |
-- +-------------------------------+------------------------------------------+
-- | lpd_destroy                   | (slot: c_int) -> void                    |
-- +-------------------------------+------------------------------------------+
-- | lpd_get_job_count             | (slot: c_int) -> u32                     |
-- +-------------------------------+------------------------------------------+
-- | lpd_get_max_depth             | (slot: c_int) -> u32                     |
-- +-------------------------------+------------------------------------------+
-- | lpd_get_total_submitted       | (slot: c_int) -> u32                     |
-- +-------------------------------+------------------------------------------+
-- | lpd_get_total_completed       | (slot: c_int) -> u32                     |
-- +-------------------------------+------------------------------------------+
-- | lpd_is_accepting              | (slot: c_int) -> u8 (0=no, 1=yes)       |
-- +-------------------------------+------------------------------------------+
-- | lpd_get_last_error            | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lpd_enqueue                   | (slot: c_int, data_size: u32)            |
-- |                               |  -> c_int (job_id or -1)                 |
-- +-------------------------------+------------------------------------------+
-- | lpd_dequeue                   | (slot: c_int) -> c_int (job_id or -1)    |
-- +-------------------------------+------------------------------------------+
-- | lpd_get_job_status            | (slot: c_int, job_id: u32) -> u8         |
-- +-------------------------------+------------------------------------------+
-- | lpd_complete_job              | (slot: c_int, job_id: u32) -> u8         |
-- +-------------------------------+------------------------------------------+
-- | lpd_fail_job                  | (slot: c_int, job_id: u32) -> u8         |
-- +-------------------------------+------------------------------------------+
-- | lpd_pause_queue               | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lpd_resume_queue              | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lpd_parse_command             | (code: u8) -> u8 (CommandCode or 255)    |
-- +-------------------------------+------------------------------------------+
