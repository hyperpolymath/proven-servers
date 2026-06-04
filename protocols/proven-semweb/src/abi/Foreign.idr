-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- SemwebABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/semweb.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected graph store pool
--   - Triple storage (subject/predicate/object as name slices)
--   - Named graph management
--   - Content negotiation for serialisation format selection
--   - SPARQL-like pattern matching on triple store
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SemwebABI.Types exactly.

module SemwebABI.Foreign

import SemwebABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a semantic web graph store session.
||| Created by semweb_create(), destroyed by semweb_destroy().
export
data SemwebContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match semweb_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-------------------------------------------+
-- | Function                      | Signature                                 |
-- +-------------------------------+-------------------------------------------+
-- | semweb_abi_version            | () -> u32                                 |
-- +-------------------------------+-------------------------------------------+
-- | semweb_create                 | (base_uri_ptr: ptr, base_uri_len: u32)    |
-- |                               |  -> c_int (slot)                          |
-- |                               | Creates graph store with base URI.        |
-- |                               | Returns -1 on failure.                    |
-- +-------------------------------+-------------------------------------------+
-- | semweb_destroy                | (slot: c_int) -> void                     |
-- +-------------------------------+-------------------------------------------+
-- | semweb_state                  | (slot: c_int) -> u8 (StoreState tag)      |
-- +-------------------------------+-------------------------------------------+
-- | semweb_add_triple             | (slot: c_int,                             |
-- |                               |  subj_ptr: ptr, subj_len: u32,           |
-- |                               |  pred_ptr: ptr, pred_len: u32,           |
-- |                               |  obj_ptr: ptr, obj_len: u32)             |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- +-------------------------------+-------------------------------------------+
-- | semweb_remove_triple          | (slot: c_int,                             |
-- |                               |  subj_ptr: ptr, subj_len: u32,           |
-- |                               |  pred_ptr: ptr, pred_len: u32,           |
-- |                               |  obj_ptr: ptr, obj_len: u32)             |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- +-------------------------------+-------------------------------------------+
-- | semweb_triple_count           | (slot: c_int) -> u32                      |
-- +-------------------------------+-------------------------------------------+
-- | semweb_has_triple             | (slot: c_int,                             |
-- |                               |  subj_ptr: ptr, subj_len: u32,           |
-- |                               |  pred_ptr: ptr, pred_len: u32,           |
-- |                               |  obj_ptr: ptr, obj_len: u32)             |
-- |                               |  -> u8 (1=yes, 0=no)                     |
-- +-------------------------------+-------------------------------------------+
-- | semweb_negotiate_format       | (accept_ptr: ptr, accept_len: u32)        |
-- |                               |  -> u8 (Format tag, 255=unsupported)      |
-- +-------------------------------+-------------------------------------------+
-- | semweb_set_format             | (slot: c_int, format: u8)                 |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- +-------------------------------+-------------------------------------------+
-- | semweb_get_format             | (slot: c_int) -> u8 (Format tag)          |
-- +-------------------------------+-------------------------------------------+
-- | semweb_handle_request         | (slot: c_int, method: u8,                 |
-- |                               |  uri_ptr: ptr, uri_len: u32)             |
-- |                               |  -> u8 (ErrorCode tag, 255=ok)            |
-- +-------------------------------+-------------------------------------------+
-- | semweb_disconnect             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- +-------------------------------+-------------------------------------------+
-- | semweb_cleanup                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- +-------------------------------+-------------------------------------------+
-- | semweb_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-------------------------------+-------------------------------------------+
-- | semweb_active_count           | () -> u32                                 |
-- +-------------------------------+-------------------------------------------+
