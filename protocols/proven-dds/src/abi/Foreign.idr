-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DdsABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/dds.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DdsABI.Types exactly.

module DdsABI.Foreign

import DdsABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Dds context.
||| Created by dds_create*(), destroyed by dds_destroy*().
export
data DdsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match dds_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (11 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | dds_abi_version                   | () -> u32                                   |
-- | dds_create                        | (domain_id: u32) -> c_int                   |
-- | dds_destroy                       | (slot: c_int) -> void                       |
-- | dds_state                         | (slot: c_int) -> u8                         |
-- | dds_topic_count                   | (slot: c_int) -> u32                        |
-- | dds_writer_count                  | (slot: c_int) -> u32                        |
-- | dds_reader_count                  | (slot: c_int) -> u32                        |
-- | dds_samples_written               | (slot: c_int) -> u64                        |
-- | dds_leave                         | (slot: c_int) -> u8                         |
-- | dds_cleanup                       | (slot: c_int) -> u8                         |
-- | dds_can_transition                | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
