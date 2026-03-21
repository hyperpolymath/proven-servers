-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DohABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/doh.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DohABI.Types exactly.

module DohABI.Foreign

import DohABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Doh context.
||| Created by doh_create*(), destroyed by doh_destroy*().
export
data DohContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match doh_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (10 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | doh_abi_version                   | () -> u32                                   |
-- | doh_create                        | (port: u16) -> c_int                        |
-- | doh_destroy                       | (slot: c_int) -> void                       |
-- | doh_state                         | (slot: c_int) -> u8                         |
-- | doh_can_serve                     | (slot: c_int) -> u8                         |
-- | doh_path_count                    | (slot: c_int) -> u32                        |
-- | doh_queries_handled               | (slot: c_int) -> u64                        |
-- | doh_shutdown                      | (slot: c_int) -> u8                         |
-- | doh_cleanup                       | (slot: c_int) -> u8                         |
-- | doh_can_transition                | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
