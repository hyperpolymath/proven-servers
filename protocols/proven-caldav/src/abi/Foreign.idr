-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CaldavABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/caldav.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching CaldavABI.Types exactly.

module CaldavABI.Foreign

import CaldavABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Caldav context.
||| Created by caldav_create*(), destroyed by caldav_destroy*().
export
data CaldavContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match caldav_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (10 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | caldav_abi_version                | () -> u32                                   |
-- | caldav_create                     | (port: u16) -> c_int                        |
-- | caldav_destroy                    | (slot: c_int) -> void                       |
-- | caldav_state                      | (slot: c_int) -> u8                         |
-- | caldav_can_serve                  | (slot: c_int) -> u8                         |
-- | caldav_calendar_count             | (slot: c_int) -> u32                        |
-- | caldav_total_resources            | (slot: c_int) -> u32                        |
-- | caldav_shutdown                   | (slot: c_int) -> u8                         |
-- | caldav_cleanup                    | (slot: c_int) -> u8                         |
-- | caldav_can_transition             | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
