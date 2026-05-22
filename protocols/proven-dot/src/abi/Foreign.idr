-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DotABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/dot.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DotABI.Types exactly.

module DotABI.Foreign

import DotABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Dot context.
||| Created by dot_create*(), destroyed by dot_destroy*().
export
data DotContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match dot_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (12 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | dot_abi_version                   | () -> u32                                   |
-- | dot_create                        | (port: u16, padding: u8) -> c_int           |
-- | dot_destroy                       | (slot: c_int) -> void                       |
-- | dot_state                         | (slot: c_int) -> u8                         |
-- | dot_can_serve                     | (slot: c_int) -> u8                         |
-- | dot_accept_session                | (slot: c_int) -> u8                         |
-- | dot_close_session                 | (slot: c_int, session_id: u32) -> u8        |
-- | dot_session_count                 | (slot: c_int) -> u32                        |
-- | dot_queries_handled               | (slot: c_int) -> u64                        |
-- | dot_shutdown                      | (slot: c_int) -> u8                         |
-- | dot_cleanup                       | (slot: c_int) -> u8                         |
-- | dot_can_transition                | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
