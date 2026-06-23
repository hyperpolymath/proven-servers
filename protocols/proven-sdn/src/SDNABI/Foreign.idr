-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- SDNABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/sdn.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected controller session pool
--   - Switch registration and port tracking
--   - Flow table management (install/remove/match)
--   - OpenFlow message type validation
--   - Port state tracking per switch
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SDNABI.Types exactly.

module SDNABI.Foreign

import SDNABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an SDN controller session.
||| Created by sdn_create(), destroyed by sdn_destroy().
export
data SdnContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match sdn_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (18 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-------------------------------------------+
-- | Function                      | Signature                                 |
-- +-------------------------------+-------------------------------------------+
-- | sdn_abi_version               | () -> u32                                 |
-- +-------------------------------+-------------------------------------------+
-- | sdn_create                    | (dpid: u64) -> c_int (slot)               |
-- |                               | Creates controller session for switch     |
-- |                               | identified by datapath ID. Returns -1     |
-- |                               | on failure. State: Idle -> Connected.     |
-- +-------------------------------+-------------------------------------------+
-- | sdn_destroy                   | (slot: c_int) -> void                     |
-- +-------------------------------+-------------------------------------------+
-- | sdn_state                     | (slot: c_int) -> u8 (ControllerState tag) |
-- +-------------------------------+-------------------------------------------+
-- | sdn_send_message              | (slot: c_int, msg_type: u8)               |
-- |                               |  -> u8 (0=ok, 1=rejected)                 |
-- +-------------------------------+-------------------------------------------+
-- | sdn_flow_add                  | (slot: c_int, table_id: u8,               |
-- |                               |  priority: u16, match_field: u8,          |
-- |                               |  action: u8) -> u8 (0=ok, 1=rejected)    |
-- +-------------------------------+-------------------------------------------+
-- | sdn_flow_remove               | (slot: c_int, table_id: u8,              |
-- |                               |  priority: u16, match_field: u8)         |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- +-------------------------------+-------------------------------------------+
-- | sdn_flow_count                | (slot: c_int) -> u32                      |
-- +-------------------------------+-------------------------------------------+
-- | sdn_port_set_state            | (slot: c_int, port_no: u16,              |
-- |                               |  state: u8) -> u8 (0=ok, 1=rejected)     |
-- +-------------------------------+-------------------------------------------+
-- | sdn_port_get_state            | (slot: c_int, port_no: u16) -> u8        |
-- |                               | Returns PortState tag (Down=1 fallback). |
-- +-------------------------------+-------------------------------------------+
-- | sdn_port_count                | (slot: c_int) -> u16                      |
-- +-------------------------------+-------------------------------------------+
-- | sdn_features_request          | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions Connected -> FeaturesWait.   |
-- +-------------------------------+-------------------------------------------+
-- | sdn_features_reply            | (slot: c_int, n_ports: u16)              |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- |                               | Transitions FeaturesWait -> Ready.       |
-- +-------------------------------+-------------------------------------------+
-- | sdn_disconnect                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions any active -> Disconnecting. |
-- +-------------------------------+-------------------------------------------+
-- | sdn_cleanup                   | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions Disconnecting -> Idle.       |
-- +-------------------------------+-------------------------------------------+
-- | sdn_can_transition            | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-------------------------------+-------------------------------------------+
-- | sdn_barrier                   | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Sends a barrier request for ordering.    |
-- +-------------------------------+-------------------------------------------+
-- | sdn_active_count              | () -> u32                                 |
-- +-------------------------------+-------------------------------------------+
