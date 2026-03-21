-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CarddavABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/carddav.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching CarddavABI.Types exactly.

module CarddavABI.Foreign

import CarddavABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Carddav context.
||| Created by carddav_create*(), destroyed by carddav_destroy*().
export
data CarddavContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match carddav_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (9 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | carddav_abi_version               | () -> u32                                   |
-- | carddav_create                    | (port: u16) -> c_int                        |
-- | carddav_destroy                   | (slot: c_int) -> void                       |
-- | carddav_state                     | (slot: c_int) -> u8                         |
-- | carddav_addressbook_count         | (slot: c_int) -> u32                        |
-- | carddav_total_vcards              | (slot: c_int) -> u32                        |
-- | carddav_shutdown                  | (slot: c_int) -> u8                         |
-- | carddav_cleanup                   | (slot: c_int) -> u8                         |
-- | carddav_can_transition            | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
