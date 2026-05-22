-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DiodeABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/diode.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DiodeABI.Types exactly.

module DiodeABI.Foreign

import DiodeABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Diode context.
||| Created by diode_create*(), destroyed by diode_destroy*().
export
data DiodeContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match diode_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (13 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | diode_abi_version                 | () -> u32                                   |
-- | diode_create                      | (direction: u8, protocol: u8) -> c_int      |
-- | diode_destroy                     | (slot: c_int) -> void                       |
-- | diode_state                       | (slot: c_int) -> u8                         |
-- | diode_can_transfer                | (slot: c_int) -> u8                         |
-- | diode_validate                    | (slot: c_int) -> u8                         |
-- | diode_transfer                    | (slot: c_int) -> u8                         |
-- | diode_confirm                     | (slot: c_int) -> u8                         |
-- | diode_queue_depth                 | (slot: c_int) -> u32                        |
-- | diode_transferred_count           | (slot: c_int) -> u64                        |
-- | diode_shutdown                    | (slot: c_int) -> u8                         |
-- | diode_cleanup                     | (slot: c_int) -> u8                         |
-- | diode_can_transition              | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
