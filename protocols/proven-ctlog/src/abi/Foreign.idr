-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CTLogABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ctlog.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected CT Log session pool
--   - Entry submission tracking per session
--   - Merkle tree size tracking
--   - STH (Signed Tree Head) management
--   - Inclusion/consistency proof verification
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching CTLogABI.Types exactly.

module CTLogABI.Foreign

import CTLogABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a CT Log session.
||| Created by ctlog_create(), destroyed by ctlog_destroy().
export
data CtlogContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ctlog_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_abi_version             | () -> u32                               |
-- |                               | Returns ABI version.                    |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_create                  | (name_ptr: ptr, name_len: u32,          |
-- |                               |  max_entries: u32) -> c_int (slot)      |
-- |                               | Creates session in Active state.        |
-- |                               | Returns -1 on failure.                  |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_destroy                 | (slot: c_int) -> void                   |
-- |                               | Releases a session slot.                |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_state                   | (slot: c_int) -> u8 (ServerState tag)   |
-- |                               | Returns current server state.           |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_submit                  | (slot: c_int, entry_type: u8,           |
-- |                               |  data_ptr: ptr, data_len: u32)          |
-- |                               |  -> u8 (SubmissionStatus tag)           |
-- |                               | Submit an entry for inclusion.          |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_entry_count             | (slot: c_int) -> u32                    |
-- |                               | Returns total submitted entries.        |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_tree_size               | (slot: c_int) -> u32                    |
-- |                               | Returns current Merkle tree size.       |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_begin_merge             | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                               | Transitions Active -> Merging.          |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_finish_merge            | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                               | Transitions Merging -> Active or        |
-- |                               | Merging -> Signing.                     |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_sign_sth                | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                               | Transitions Signing -> Active.          |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_verify_inclusion        | (slot: c_int, index: u32)               |
-- |                               |  -> u8 (VerificationResult tag)         |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_verify_consistency      | (slot: c_int, old_size: u32,            |
-- |                               |  new_size: u32)                         |
-- |                               |  -> u8 (VerificationResult tag)         |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_shutdown                | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                               | Transitions to Shutdown.                |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_cleanup                 | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                               | Transitions Shutdown -> Idle.           |
-- +-------------------------------+-----------------------------------------+
-- | ctlog_can_transition          | (from: u8, to: u8) -> u8 (1/0)         |
-- |                               | Stateless transition check.             |
-- +-------------------------------+-----------------------------------------+
