-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ODNSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/odns.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - HPKE key pair management
--   - Query/response encapsulation tracking
--   - Role-based access enforcement (Client/Proxy/Target)
--   - Nonce management for replay protection
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching ODNSABI.Types exactly.

module ODNSABI.Foreign

import ODNSABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an Oblivious DNS session.
||| Created by odns_create(), destroyed by odns_destroy().
export
data OdnsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match odns_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | odns_abi_version            | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | odns_create                 | (role: u8, config_ptr: ptr,               |
-- |                             |  config_len: u32) -> c_int (slot)        |
-- |                             | Creates session in KeyExchange state.     |
-- +-----------------------------+-------------------------------------------+
-- | odns_destroy                | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | odns_state                  | (slot: c_int) -> u8 (SessionState tag)    |
-- +-----------------------------+-------------------------------------------+
-- | odns_key_exchange           | (slot: c_int, pubkey_ptr: ptr,            |
-- |                             |  pubkey_len: u32) -> u8                  |
-- |                             | (0=ok, 1=rejected)                        |
-- |                             | Transitions KeyExchange -> Ready.         |
-- +-----------------------------+-------------------------------------------+
-- | odns_submit_query           | (slot: c_int, query_ptr: ptr,             |
-- |                             |  query_len: u32) -> u8                   |
-- |                             | Transitions Ready -> Processing.          |
-- +-----------------------------+-------------------------------------------+
-- | odns_get_response           | (slot: c_int) -> u8                       |
-- |                             | Returns response status,                  |
-- |                             | transitions Processing -> Ready.          |
-- +-----------------------------+-------------------------------------------+
-- | odns_get_role               | (slot: c_int) -> u8 (Role tag)            |
-- +-----------------------------+-------------------------------------------+
-- | odns_get_format             | (slot: c_int) -> u8                       |
-- |                             | Returns EncapsulationFormat tag.           |
-- +-----------------------------+-------------------------------------------+
-- | odns_query_count            | (slot: c_int) -> u32                      |
-- |                             | Returns number of processed queries.      |
-- +-----------------------------+-------------------------------------------+
-- | odns_close                  | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- +-----------------------------+-------------------------------------------+
-- | odns_cleanup                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Closing -> Idle.              |
-- +-----------------------------+-------------------------------------------+
-- | odns_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
-- | odns_is_ready               | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- +-----------------------------+-------------------------------------------+
