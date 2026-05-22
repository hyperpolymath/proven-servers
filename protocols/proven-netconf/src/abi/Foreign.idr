-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NetconfABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/netconf.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Datastore lock tracking per session
--   - Edit-config operation queuing
--   - Candidate datastore validation and commit
--   - Lifecycle state machine transitions

module NetconfABI.Foreign

import NetconfABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a NETCONF session.
||| Created by netconf_create(), destroyed by netconf_destroy().
export
data NetconfContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match netconf_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | netconf_abi_version         | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | netconf_create              | (host_ptr: ptr, host_len: u32,            |
-- |                             |  port: u16) -> c_int (slot)               |
-- |                             | Creates session in Connected state.       |
-- +-----------------------------+-------------------------------------------+
-- | netconf_destroy             | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | netconf_state               | (slot: c_int) -> u8 (NetconfState tag)    |
-- +-----------------------------+-------------------------------------------+
-- | netconf_lock                | (slot: c_int, datastore: u8)              |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Connected -> Locked.                      |
-- +-----------------------------+-------------------------------------------+
-- | netconf_unlock              | (slot: c_int, datastore: u8)              |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Locked -> Connected.                      |
-- +-----------------------------+-------------------------------------------+
-- | netconf_get_config          | (slot: c_int, datastore: u8)              |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | netconf_edit_config         | (slot: c_int, datastore: u8,              |
-- |                             |  edit_op: u8, xpath_ptr: ptr,             |
-- |                             |  xpath_len: u32) -> u8 (0=ok, 1=rej)     |
-- |                             | Connected/Locked -> Editing.              |
-- +-----------------------------+-------------------------------------------+
-- | netconf_commit              | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Editing -> Connected.                     |
-- +-----------------------------+-------------------------------------------+
-- | netconf_discard             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Editing -> Connected.                     |
-- +-----------------------------+-------------------------------------------+
-- | netconf_validate            | (slot: c_int, datastore: u8)              |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | netconf_close_session       | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Any non-Idle -> Closing.                  |
-- +-----------------------------+-------------------------------------------+
-- | netconf_kill_session        | (slot: c_int, session_id: u32)            |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | netconf_cleanup             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Closing/Terminated -> Idle.               |
-- +-----------------------------+-------------------------------------------+
-- | netconf_can_transition      | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
