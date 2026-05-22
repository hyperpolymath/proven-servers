-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- VPNABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/vpn.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected tunnel pool
--   - SA table (SPI -> SA record with lifecycle tracking)
--   - Tunnel state machine (TunnelPhase per slot)
--   - Key material tracking (encryption, integrity, DH group per SA)
--   - Stateless transition validation tables
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching VPNABI.Layout exactly.

module VPNABI.Foreign

import VPNABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a VPN tunnel context.
||| Created by vpn_create(), destroyed by vpn_destroy().
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
-- FFI function contract (22+ functions)
---------------------------------------------------------------------------

-- +-----------------------------+-----------------------------------------------+
-- | Function                    | Signature                                     |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_abi_version             | () -> u32                                     |
-- |                             | Returns ABI version (must equal abiVersion).  |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_create                  | (tunnel_type: u8, ike_version: u8)            |
-- |                             |  -> c_int (slot)                              |
-- |                             | Creates tunnel in Idle state. Returns -1 on   |
-- |                             | failure (no free slots or invalid type/ver).  |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_destroy                 | (slot: c_int) -> void                         |
-- |                             | Releases a tunnel slot and all associated SAs.|
-- +-----------------------------+-----------------------------------------------+
-- | vpn_phase                   | (slot: c_int) -> u8 (TunnelPhase tag)         |
-- |                             | Returns current tunnel phase.                 |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_tunnel_type             | (slot: c_int) -> u8 (TunnelType tag)          |
-- |                             | Returns the tunnel protocol type.             |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_ike_version             | (slot: c_int) -> u8 (IKEVersion tag)          |
-- |                             | Returns the IKE version.                      |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_begin_phase1            | (slot: c_int, dh_group: u8) -> u8             |
-- |                             | Begin IKE Phase 1 (SA_INIT). Transitions      |
-- |                             | Idle -> Phase1Init. Returns 0=ok, 1=rejected. |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_complete_phase1_auth    | (slot: c_int, enc: u8, integ: u8) -> u8       |
-- |                             | Complete Phase 1 AUTH exchange. Transitions    |
-- |                             | Phase1Init -> Phase1Auth -> Phase1Done.        |
-- |                             | Returns 0=ok, 1=rejected.                     |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_begin_phase2            | (slot: c_int, enc: u8, integ: u8,             |
-- |                             |  dh_group: u8) -> u8                          |
-- |                             | Begin Phase 2 (CREATE_CHILD_SA). Transitions  |
-- |                             | Phase1Done -> Phase2Negotiating.              |
-- |                             | Returns 0=ok, 1=rejected.                     |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_establish               | (slot: c_int, spi: u32) -> u8                 |
-- |                             | Complete tunnel establishment. Transitions    |
-- |                             | Phase2Negotiating -> Established. Creates SA  |
-- |                             | with given SPI. Returns 0=ok, 1=rejected.     |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_expire                  | (slot: c_int) -> u8                           |
-- |                             | Force-expire the tunnel. Any non-Idle/Expired |
-- |                             | state -> Expired. Returns 0=ok, 1=rejected.   |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_restart                 | (slot: c_int) -> u8                           |
-- |                             | Restart from Expired. Expired -> Idle.         |
-- |                             | Returns 0=ok, 1=rejected.                     |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_can_transfer            | (slot: c_int) -> u8 (1=yes, 0=no)            |
-- |                             | Whether data can flow (Established only).     |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_can_rekey               | (slot: c_int) -> u8 (1=yes, 0=no)            |
-- |                             | Whether a rekey can be initiated.             |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_sa_state                | (slot: c_int, spi: u32) -> u8                 |
-- |                             | Returns SALifecycle tag for the given SPI.    |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_sa_begin_rekey          | (slot: c_int, spi: u32) -> u8                 |
-- |                             | Begin SA rekey. Active -> Rekeying.           |
-- |                             | Returns 0=ok, 1=rejected.                     |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_sa_complete_rekey       | (slot: c_int, old_spi: u32, new_spi: u32)     |
-- |                             |  -> u8                                        |
-- |                             | Complete SA rekey. Old SA -> Deleted,          |
-- |                             | new SA created as Active.                     |
-- |                             | Returns 0=ok, 1=rejected.                     |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_sa_delete               | (slot: c_int, spi: u32) -> u8                 |
-- |                             | Explicitly delete an SA. Active/Rekeying      |
-- |                             | -> Deleted. Returns 0=ok, 1=rejected.         |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_sa_encryption           | (slot: c_int, spi: u32) -> u8                 |
-- |                             | Returns EncryptionAlgorithm tag for an SA.    |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_sa_integrity            | (slot: c_int, spi: u32) -> u8                 |
-- |                             | Returns IntegrityAlgorithm tag for an SA.     |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_sa_dh_group             | (slot: c_int, spi: u32) -> u8                 |
-- |                             | Returns DHGroup tag for an SA.                |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_can_phase_transition    | (from: u8, to: u8) -> u8 (1=yes, 0=no)       |
-- |                             | Stateless: checks if a tunnel phase           |
-- |                             | transition is valid per Transitions.idr.      |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_can_sa_transition       | (from: u8, to: u8) -> u8 (1=yes, 0=no)       |
-- |                             | Stateless: checks if an SA lifecycle          |
-- |                             | transition is valid per Transitions.idr.      |
-- +-----------------------------+-----------------------------------------------+
-- | vpn_sa_count                | (slot: c_int) -> u32                          |
-- |                             | Returns number of active SAs for a tunnel.    |
-- +-----------------------------+-----------------------------------------------+
