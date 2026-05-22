-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- OCSPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ocsp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected responder pool
--   - Certificate status cache (max 256 entries per responder)
--   - Hash algorithm selection
--   - OCSP request/response lifecycle
--   - Nonce tracking for replay protection
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching OCSPABI.Types exactly.

module OCSPABI.Foreign

import OCSPABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an OCSP responder session.
||| Created by ocsp_create(), destroyed by ocsp_destroy().
export
data OcspContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ocsp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_abi_version            | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_create                 | (ca_name_ptr: ptr, ca_name_len: u32,     |
-- |                             |  hash_alg: u8) -> c_int (slot)           |
-- |                             | Creates responder in Ready state.         |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_destroy                | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_state                  | (slot: c_int) -> u8 (ResponderState tag)  |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_set_cert_status        | (slot: c_int, serial_ptr: ptr,            |
-- |                             |  serial_len: u32, status: u8) -> u8      |
-- |                             | (0=ok, 1=rejected)                        |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_query                  | (slot: c_int, serial_ptr: ptr,            |
-- |                             |  serial_len: u32, nonce_ptr: ptr,        |
-- |                             |  nonce_len: u32) -> u8                   |
-- |                             | Transitions Ready -> Processing.          |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_respond                | (slot: c_int) -> u8 (CertStatus tag)     |
-- |                             | Returns status, transitions              |
-- |                             | Processing -> Signing -> Ready.           |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_get_response_status    | (slot: c_int) -> u8                       |
-- |                             | Returns ResponseStatus tag.               |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_cache_count            | (slot: c_int) -> u32                      |
-- |                             | Returns number of cached cert statuses.   |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_set_hash_algorithm     | (slot: c_int, alg: u8) -> u8             |
-- |                             | (0=ok, 1=rejected)                        |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_close                  | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_cleanup                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Closing -> Idle.              |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
-- | ocsp_is_ready               | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- +-----------------------------+-------------------------------------------+
