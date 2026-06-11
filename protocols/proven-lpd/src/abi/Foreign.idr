-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- LpdABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/lpd.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching LpdABI.Types exactly.

module LpdABI.Foreign

import LpdABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Lpd context.
||| Created by lpd_create*(), destroyed by lpd_destroy*().
export
data LpdContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match lpd_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (17 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | lpd_abi_version                   | () -> u32                                   |
-- | lpd_create                        | (max_depth: u32, max_job_size: u32) -> c... |
-- | lpd_destroy                       | (slot: c_int) -> void                       |
-- | lpd_get_job_count                 | (slot: c_int) -> u32                        |
-- | lpd_get_max_depth                 | (slot: c_int) -> u32                        |
-- | lpd_get_total_submitted           | (slot: c_int) -> u32                        |
-- | lpd_get_total_completed           | (slot: c_int) -> u32                        |
-- | lpd_is_accepting                  | (slot: c_int) -> u8                         |
-- | lpd_get_last_error                | (slot: c_int) -> u8                         |
-- | lpd_enqueue                       | (slot: c_int, data_size: u32) -> c_int      |
-- | lpd_dequeue                       | (slot: c_int) -> c_int                      |
-- | lpd_get_job_status                | (slot: c_int, job_id: u32) -> u8            |
-- | lpd_complete_job                  | (slot: c_int, job_id: u32) -> u8            |
-- | lpd_fail_job                      | (slot: c_int, job_id: u32) -> u8            |
-- | lpd_pause_queue                   | (slot: c_int) -> u8                         |
-- | lpd_resume_queue                  | (slot: c_int) -> u8                         |
-- | lpd_parse_command                 | (code: u8) -> u8                            |
-- +───────────────────────────────────+─────────────────────────────────────────────+
