-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TriplestoreABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/triplestore.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected store session pool
--   - Triple/quad insertion, deletion, and pattern matching
--   - Transaction begin/commit/rollback
--   - Bulk import with format validation
--   - Index order management
--   - Store state machine (Idle -> Ready -> Transaction/Importing -> Closing)
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching TriplestoreABI.Types exactly.

module TriplestoreABI.Foreign

import TriplestoreABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a triplestore session.
||| Created by triplestore_create(), destroyed by triplestore_destroy().
export
data TriplestoreContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match triplestore_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (18 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_abi_version     | () -> u32                                 |
-- |                             | Returns ABI version.                      |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_create          | (backend: u8, isolation: u8)              |
-- |                             |  -> c_int (slot)                          |
-- |                             | Creates store session.                    |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_destroy         | (slot: c_int) -> void                     |
-- |                             | Releases a session slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_state           | (slot: c_int) -> u8 (StoreState tag)      |
-- |                             | Returns current store state.              |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_add_triple      | (slot: c_int, s_ptr: ptr, s_len: u32,     |
-- |                             |  p_ptr: ptr, p_len: u32,                  |
-- |                             |  o_ptr: ptr, o_len: u32)                  |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Adds an RDF triple.                       |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_add_quad        | (slot: c_int, g_ptr: ptr, g_len: u32,     |
-- |                             |  s_ptr: ptr, s_len: u32,                  |
-- |                             |  p_ptr: ptr, p_len: u32,                  |
-- |                             |  o_ptr: ptr, o_len: u32)                  |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Adds an RDF quad.                         |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_remove          | (slot: c_int, s_ptr: ptr, s_len: u32,     |
-- |                             |  p_ptr: ptr, p_len: u32,                  |
-- |                             |  o_ptr: ptr, o_len: u32)                  |
-- |                             |  -> u8 (0=ok, 1=not_found)                |
-- |                             | Removes a triple by exact match.          |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_count           | (slot: c_int) -> u32                      |
-- |                             | Returns total triple count.               |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_has             | (slot: c_int, s_ptr: ptr, s_len: u32,     |
-- |                             |  p_ptr: ptr, p_len: u32,                  |
-- |                             |  o_ptr: ptr, o_len: u32)                  |
-- |                             |  -> u8 (1=exists, 0=not found)            |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_txn_begin       | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Ready -> Transaction.         |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_txn_commit      | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Transaction -> Ready.         |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_txn_rollback    | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Transaction -> Ready.         |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_import_begin    | (slot: c_int, format: u8)                 |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Transitions Ready -> Importing.           |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_import_end      | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Importing -> Ready.           |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_disconnect      | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Closing.                   |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_cleanup         | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Closing -> Idle.              |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_can_transition  | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless transition check.               |
-- +-----------------------------+-------------------------------------------+
-- | triplestore_session_count   | () -> u32                                 |
-- |                             | Returns number of active sessions.        |
-- +-----------------------------+-------------------------------------------+
