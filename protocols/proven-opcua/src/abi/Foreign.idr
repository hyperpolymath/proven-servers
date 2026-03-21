-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- OPCUAABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/opcua.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Address space node tracking (max 256 nodes per session)
--   - Subscription management (max 16 subscriptions per session)
--   - Monitored item tracking per subscription
--   - Security mode enforcement
--   - Service request validation per session state
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching OPCUAABI.Types exactly.

module OPCUAABI.Foreign

import OPCUAABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an OPC UA session.
||| Created by opcua_create(), destroyed by opcua_destroy().
export
data OpcuaContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match opcua_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (18 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | opcua_abi_version             | () -> u32                               |
-- +-------------------------------+-----------------------------------------+
-- | opcua_create                  | (endpoint_ptr: ptr, endpoint_len: u32,  |
-- |                               |  security_mode: u8) -> c_int (slot)    |
-- |                               | Creates session in Connected state.     |
-- +-------------------------------+-----------------------------------------+
-- | opcua_destroy                 | (slot: c_int) -> void                   |
-- +-------------------------------+-----------------------------------------+
-- | opcua_state                   | (slot: c_int) -> u8 (SessionState tag)  |
-- +-------------------------------+-----------------------------------------+
-- | opcua_create_session          | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                               | Transitions Connected -> Created.       |
-- +-------------------------------+-----------------------------------------+
-- | opcua_activate_session        | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                               | Transitions Created -> Activated.       |
-- +-------------------------------+-----------------------------------------+
-- | opcua_read_node               | (slot: c_int, node_id: u32,             |
-- |                               |  attr_id: u32) -> u8                   |
-- +-------------------------------+-----------------------------------------+
-- | opcua_write_node              | (slot: c_int, node_id: u32,             |
-- |                               |  attr_id: u32, value_ptr: ptr,         |
-- |                               |  value_len: u32) -> u8                 |
-- +-------------------------------+-----------------------------------------+
-- | opcua_browse                  | (slot: c_int, node_id: u32) -> u8       |
-- +-------------------------------+-----------------------------------------+
-- | opcua_add_node                | (slot: c_int, node_id: u32,             |
-- |                               |  node_class: u8, name_ptr: ptr,        |
-- |                               |  name_len: u32) -> u8                  |
-- +-------------------------------+-----------------------------------------+
-- | opcua_create_subscription     | (slot: c_int, interval_ms: u32)         |
-- |                               |  -> u8 (0=ok, 1=rejected)               |
-- |                               | Transitions Activated -> Monitoring.    |
-- +-------------------------------+-----------------------------------------+
-- | opcua_delete_subscription     | (slot: c_int, sub_id: u32) -> u8        |
-- |                               | May transition Monitoring -> Activated. |
-- +-------------------------------+-----------------------------------------+
-- | opcua_subscription_count      | (slot: c_int) -> u32                    |
-- +-------------------------------+-----------------------------------------+
-- | opcua_node_count              | (slot: c_int) -> u32                    |
-- +-------------------------------+-----------------------------------------+
-- | opcua_get_security_mode       | (slot: c_int) -> u8 (SecurityMode tag)  |
-- +-------------------------------+-----------------------------------------+
-- | opcua_close                   | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | opcua_cleanup                 | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                               | Transitions Closing -> Idle.            |
-- +-------------------------------+-----------------------------------------+
-- | opcua_can_transition          | (from: u8, to: u8) -> u8 (1=yes, 0=no) |
-- +-------------------------------+-----------------------------------------+
