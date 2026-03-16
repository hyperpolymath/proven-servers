-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- BGPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/bgp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot session pool (one per BGP peer)
--   - FSM state tracking per session
--   - Route count tracking
--   - Event application with action list generation
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching BGPABI.Layout exactly.

module BGPABI.Foreign

import BGPABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a BGP session.
||| Created by bgp_create(), destroyed by bgp_destroy().
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
-- FFI function contract
---------------------------------------------------------------------------

-- +---------------------------+-----------------------------------------------+
-- | Function                  | Signature                                     |
-- +---------------------------+-----------------------------------------------+
-- | bgp_abi_version           | () -> u32                                     |
-- |                           | Returns ABI version (must equal abiVersion).  |
-- +---------------------------+-----------------------------------------------+
-- | bgp_create                | (local_as: u32, peer_as: u32,                 |
-- |                           |  hold_time: u16) -> c_int (slot)              |
-- |                           | Creates session in Idle state. Returns -1 on  |
-- |                           | failure (no free slots).                      |
-- +---------------------------+-----------------------------------------------+
-- | bgp_destroy               | (slot: c_int) -> void                         |
-- |                           | Releases a session slot.                      |
-- +---------------------------+-----------------------------------------------+
-- | bgp_state                 | (slot: c_int) -> u8 (BGPState tag)            |
-- |                           | Returns current FSM state for the session.    |
-- +---------------------------+-----------------------------------------------+
-- | bgp_apply_event           | (slot: c_int, event: u8) -> u8               |
-- |                           | Apply a BGPEvent to the session FSM.          |
-- |                           | Returns 0 on success, 1 on rejection          |
-- |                           | (invalid slot or unknown event tag).          |
-- +---------------------------+-----------------------------------------------+
-- | bgp_is_established        | (slot: c_int) -> u8 (1=yes, 0=no)            |
-- |                           | Whether the session is in Established state.  |
-- +---------------------------+-----------------------------------------------+
-- | bgp_connect_retry_count   | (slot: c_int) -> u32                          |
-- |                           | Returns the connect retry counter.            |
-- +---------------------------+-----------------------------------------------+
-- | bgp_routes_received       | (slot: c_int) -> u32                          |
-- |                           | Returns the number of routes received.        |
-- +---------------------------+-----------------------------------------------+
-- | bgp_add_route             | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                           | Increment route counter if Established.       |
-- +---------------------------+-----------------------------------------------+
-- | bgp_withdraw_route        | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                           | Decrement route counter if Established        |
-- |                           | and routes > 0.                               |
-- +---------------------------+-----------------------------------------------+
-- | bgp_can_exchange          | (slot: c_int) -> u8 (1=yes, 0=no)            |
-- |                           | Whether the session can exchange routes       |
-- |                           | (Established state).                          |
-- +---------------------------+-----------------------------------------------+
-- | bgp_can_transition        | (from: u8, to: u8) -> u8 (1=yes, 0=no)       |
-- |                           | Stateless: checks if an FSM transition is     |
-- |                           | valid per Transitions.idr.                    |
-- +---------------------------+-----------------------------------------------+
-- | bgp_hold_time             | (slot: c_int) -> u16                          |
-- |                           | Returns the negotiated hold time.             |
-- +---------------------------+-----------------------------------------------+
-- | bgp_local_as              | (slot: c_int) -> u32                          |
-- |                           | Returns the local AS number.                  |
-- +---------------------------+-----------------------------------------------+
-- | bgp_peer_as               | (slot: c_int) -> u32                          |
-- |                           | Returns the peer AS number.                   |
-- +---------------------------+-----------------------------------------------+
