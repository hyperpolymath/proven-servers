-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- BgpABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/bgp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching BgpABI.Types exactly.

module BgpABI.Foreign

import BgpABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Bgp context.
||| Created by bgp_create*(), destroyed by bgp_destroy*().
export
data BgpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match bgp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (15 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | bgp_abi_version                   | () -> u32                                   |
-- | bgp_create                        | (local_as: u32, peer_as: u32, hold_time:... |
-- | bgp_destroy                       | (slot: c_int) -> void                       |
-- | bgp_state                         | (slot: c_int) -> u8                         |
-- | bgp_apply_event                   | (slot: c_int, event: u8) -> u8              |
-- | bgp_is_established                | (slot: c_int) -> u8                         |
-- | bgp_connect_retry_count           | (slot: c_int) -> u32                        |
-- | bgp_routes_received               | (slot: c_int) -> u32                        |
-- | bgp_add_route                     | (slot: c_int) -> u8                         |
-- | bgp_withdraw_route                | (slot: c_int) -> u8                         |
-- | bgp_can_exchange                  | (slot: c_int) -> u8                         |
-- | bgp_can_transition                | (from: u8, to: u8) -> u8                    |
-- | bgp_hold_time                     | (slot: c_int) -> u16                        |
-- | bgp_local_as                      | (slot: c_int) -> u32                        |
-- | bgp_peer_as                       | (slot: c_int) -> u32                        |
-- +───────────────────────────────────+─────────────────────────────────────────────+
