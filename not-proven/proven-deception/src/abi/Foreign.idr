-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DeceptionABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/deception.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DeceptionABI.Types exactly.

module DeceptionABI.Foreign

import DeceptionABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Deception context.
||| Created by deception_create*(), destroyed by deception_destroy*().
export
data DeceptionContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match deception_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (10 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | deception_abi_version             | () -> u32                                   |
-- | deception_create                  | () -> c_int                                 |
-- | deception_destroy                 | (slot: c_int) -> void                       |
-- | deception_state                   | (slot: c_int) -> u8                         |
-- | deception_can_monitor             | (slot: c_int) -> u8                         |
-- | deception_decoy_count             | (slot: c_int) -> u32                        |
-- | deception_alert_count             | (slot: c_int) -> u32                        |
-- | deception_shutdown                | (slot: c_int) -> u8                         |
-- | deception_cleanup                 | (slot: c_int) -> u8                         |
-- | deception_can_transition          | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
