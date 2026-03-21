-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- VpnABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/vpn.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching VpnABI.Types exactly.

module VpnABI.Foreign

import VpnABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Vpn context.
||| Created by vpn_create*(), destroyed by vpn_destroy*().
export
data VpnContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match vpn_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (24 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | vpn_abi_version                   | () -> u32                                   |
-- | vpn_create                        | (tunnel_type: u8, ike_version: u8) -> c_int |
-- | vpn_destroy                       | (slot: c_int) -> void                       |
-- | vpn_phase                         | (slot: c_int) -> u8                         |
-- | vpn_tunnel_type                   | (slot: c_int) -> u8                         |
-- | vpn_ike_version                   | (slot: c_int) -> u8                         |
-- | vpn_begin_phase1                  | (slot: c_int, dh_group: u8) -> u8           |
-- | vpn_complete_phase1_auth          | (slot: c_int, enc: u8, integ: u8) -> u8     |
-- | vpn_begin_phase2                  | (slot: c_int, enc: u8, integ: u8, dh_gro... |
-- | vpn_establish                     | (slot: c_int, spi: u32) -> u8               |
-- | vpn_expire                        | (slot: c_int) -> u8                         |
-- | vpn_restart                       | (slot: c_int) -> u8                         |
-- | vpn_can_transfer                  | (slot: c_int) -> u8                         |
-- | vpn_can_rekey                     | (slot: c_int) -> u8                         |
-- | vpn_sa_state                      | (slot: c_int, spi: u32) -> u8               |
-- | vpn_sa_begin_rekey                | (slot: c_int, spi: u32) -> u8               |
-- | vpn_sa_complete_rekey             | (slot: c_int, old_spi: u32, new_spi: u32... |
-- | vpn_sa_delete                     | (slot: c_int, spi: u32) -> u8               |
-- | vpn_sa_encryption                 | (slot: c_int, spi: u32) -> u8               |
-- | vpn_sa_integrity                  | (slot: c_int, spi: u32) -> u8               |
-- | vpn_sa_dh_group                   | (slot: c_int, spi: u32) -> u8               |
-- | vpn_sa_count                      | (slot: c_int) -> u32                        |
-- | vpn_can_phase_transition          | (from: u8, to: u8) -> u8                    |
-- | vpn_can_sa_transition             | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
