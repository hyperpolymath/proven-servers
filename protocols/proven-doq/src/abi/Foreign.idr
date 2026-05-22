-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DoqABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/doq.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DoqABI.Types exactly.

module DoqABI.Foreign

import DoqABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Doq context.
||| Created by doq_create*(), destroyed by doq_destroy*().
export
data DoqContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match doq_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (12 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | doq_abi_version                   | () -> u32                                   |
-- | doq_create                        | (port: u16) -> c_int                        |
-- | doq_destroy                       | (slot: c_int) -> void                       |
-- | doq_state                         | (slot: c_int) -> u8                         |
-- | doq_can_serve                     | (slot: c_int) -> u8                         |
-- | doq_open_stream                   | (slot: c_int, stream_type: u8) -> u8        |
-- | doq_close_stream                  | (slot: c_int, stream_id: u32) -> u8         |
-- | doq_stream_count                  | (slot: c_int) -> u32                        |
-- | doq_queries_handled               | (slot: c_int) -> u64                        |
-- | doq_drain                         | (slot: c_int) -> u8                         |
-- | doq_cleanup                       | (slot: c_int) -> u8                         |
-- | doq_can_transition                | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
