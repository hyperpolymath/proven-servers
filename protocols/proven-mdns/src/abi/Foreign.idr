-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- abi.Foreign: Foreign function declarations for the mDNS C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/mdns.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected responder pool
--   - Per-responder service registration (max 16 services)
--   - Per-responder record cache (max 64 records)
--   - Probing/announcing/running lifecycle
--   - Conflict detection and resolution
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching abi.Types exactly.

module abi.Foreign

import abi.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an mDNS responder session.
||| Created by mdns_create(), destroyed by mdns_destroy().
export
data MdnsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match mdns_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | mdns_abi_version            | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | mdns_create                 | (hostname_ptr: ptr, hostname_len: u32)    |
-- |                             |  -> c_int (slot). Returns -1 on failure.  |
-- +-----------------------------+-------------------------------------------+
-- | mdns_destroy                | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | mdns_state                  | (slot: c_int) -> u8 (ResponderState tag)  |
-- +-----------------------------+-------------------------------------------+
-- | mdns_register_service       | (slot: c_int, name_ptr: ptr,              |
-- |                             |  name_len: u32, stype_ptr: ptr,           |
-- |                             |  stype_len: u32, port: u16,               |
-- |                             |  flag: u8) -> u8 (0=ok, 1=rejected)       |
-- +-----------------------------+-------------------------------------------+
-- | mdns_unregister_service     | (slot: c_int, name_ptr: ptr,              |
-- |                             |  name_len: u32) -> u8 (0=ok, 1=rejected)  |
-- +-----------------------------+-------------------------------------------+
-- | mdns_service_count          | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | mdns_start_probing          | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Idle -> Probing.              |
-- +-----------------------------+-------------------------------------------+
-- | mdns_finish_probing         | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Probing -> Announcing.        |
-- +-----------------------------+-------------------------------------------+
-- | mdns_finish_announcing      | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Announcing -> Running.        |
-- +-----------------------------+-------------------------------------------+
-- | mdns_handle_conflict        | (slot: c_int, action: u8)                 |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | mdns_query                  | (slot: c_int, name_ptr: ptr,              |
-- |                             |  name_len: u32, rtype: u8,                |
-- |                             |  qtype: u8) -> u8 (0=ok, 1=rejected)     |
-- +-----------------------------+-------------------------------------------+
-- | mdns_record_count           | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | mdns_shutdown               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to ShuttingDown.              |
-- +-----------------------------+-------------------------------------------+
-- | mdns_cleanup                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions ShuttingDown -> Idle.         |
-- +-----------------------------+-------------------------------------------+
-- | mdns_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
