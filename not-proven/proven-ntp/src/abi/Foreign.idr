-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NtpABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ntp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching NtpABI.Types exactly.

module NtpABI.Foreign

import NtpABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Ntp context.
||| Created by ntp_create*(), destroyed by ntp_destroy*().
export
data NtpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ntp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (19 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | ntp_abi_version                   | () -> u32                                   |
-- | ntp_create                        | (version: u8, mode: u8, stratum: u8) -> ... |
-- | ntp_destroy                       | (slot: c_int) -> void                       |
-- | ntp_get_exchange_state            | (slot: c_int) -> u8                         |
-- | ntp_get_discipline_state          | (slot: c_int) -> u8                         |
-- | ntp_get_stratum                   | (slot: c_int) -> u8                         |
-- | ntp_get_mode                      | (slot: c_int) -> u8                         |
-- | ntp_get_last_error                | (slot: c_int) -> u8                         |
-- | ntp_get_exchange_count            | (slot: c_int) -> u32                        |
-- | ntp_send_response                 | (slot: c_int) -> u8                         |
-- | ntp_reset_exchange                | (slot: c_int) -> u8                         |
-- | ntp_set_leap                      | (slot: c_int, leap: u8) -> u8               |
-- | ntp_get_leap                      | (slot: c_int) -> u8                         |
-- | ntp_check_kiss                    | (slot: c_int) -> u8                         |
-- | ntp_set_kiss                      | (slot: c_int, kiss: u8) -> u8               |
-- | ntp_advance_discipline            | (slot: c_int, new_state: u8) -> u8          |
-- | ntp_can_exchange_transition       | (from: u8, to: u8) -> u8                    |
-- | ntp_can_discipline_transition     | (from: u8, to: u8) -> u8                    |
-- | ntp_set_stratum                   | (slot: c_int, stratum: u8) -> u8            |
-- +───────────────────────────────────+─────────────────────────────────────────────+
