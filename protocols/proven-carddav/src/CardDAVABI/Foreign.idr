-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CardDAVABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/carddav.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected server pool
--   - Address book collection management (max 16 per server)
--   - vCard resource storage per address book (max 128)
--   - UID uniqueness enforcement per address book
--   - ETag tracking for conditional requests
--   - vCard version validation
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching CardDAVABI.Types exactly.

module CardDAVABI.Foreign

import CardDAVABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a CardDAV server instance.
||| Created by carddav_create(), destroyed by carddav_destroy().
export
data CarddavContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match carddav_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +--------------------------------+----------------------------------------+
-- | Function                       | Signature                              |
-- +--------------------------------+----------------------------------------+
-- | carddav_abi_version            | () -> u32                              |
-- +--------------------------------+----------------------------------------+
-- | carddav_create                 | (port: u16) -> c_int (slot)            |
-- |                                | Creates server in Bound state.         |
-- +--------------------------------+----------------------------------------+
-- | carddav_destroy                | (slot: c_int) -> void                  |
-- +--------------------------------+----------------------------------------+
-- | carddav_state                  | (slot: c_int) -> u8 (ServerState tag)  |
-- +--------------------------------+----------------------------------------+
-- | carddav_create_addressbook     | (slot: c_int,                          |
-- |                                |  path_ptr: ptr, path_len: u32)         |
-- |                                | -> u8 (0=ok, 1=rejected)              |
-- |                                | Transitions Bound -> Serving.          |
-- +--------------------------------+----------------------------------------+
-- | carddav_delete_addressbook     | (slot: c_int,                          |
-- |                                |  path_ptr: ptr, path_len: u32)         |
-- |                                | -> u8 (0=ok, 1=rejected)              |
-- +--------------------------------+----------------------------------------+
-- | carddav_addressbook_count      | (slot: c_int) -> u32                   |
-- +--------------------------------+----------------------------------------+
-- | carddav_put_vcard              | (slot: c_int,                          |
-- |                                |  ab_path_ptr: ptr, ab_path_len: u32,   |
-- |                                |  uid_ptr: ptr, uid_len: u32,           |
-- |                                |  version: u8, etag: u32)               |
-- |                                | -> u8 (0=ok, 1=rejected)              |
-- +--------------------------------+----------------------------------------+
-- | carddav_delete_vcard           | (slot: c_int,                          |
-- |                                |  ab_path_ptr: ptr, ab_path_len: u32,   |
-- |                                |  uid_ptr: ptr, uid_len: u32)           |
-- |                                | -> u8 (0=ok, 1=rejected)              |
-- +--------------------------------+----------------------------------------+
-- | carddav_vcard_count            | (slot: c_int,                          |
-- |                                |  ab_path_ptr: ptr, ab_path_len: u32)   |
-- |                                | -> u32                                 |
-- +--------------------------------+----------------------------------------+
-- | carddav_total_vcards           | (slot: c_int) -> u32                   |
-- +--------------------------------+----------------------------------------+
-- | carddav_shutdown               | (slot: c_int) -> u8                    |
-- +--------------------------------+----------------------------------------+
-- | carddav_cleanup                | (slot: c_int) -> u8                    |
-- +--------------------------------+----------------------------------------+
-- | carddav_can_transition         | (from: u8, to: u8) -> u8              |
-- +--------------------------------+----------------------------------------+
