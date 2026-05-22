-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- PqcABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/pqc.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching PqcABI.Types exactly.

module PqcABI.Foreign

import PqcABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Pqc context.
||| Created by pqc_create*(), destroyed by pqc_destroy*().
export
data PqcContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match pqc_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (28 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | pqc_abi_version                   | () -> u32                                   |
-- | pqc_create_context                | (algo: u8, level: u8) -> c_int              |
-- | pqc_destroy_context               | (slot: c_int) -> void                       |
-- | pqc_key_state                     | (slot: c_int) -> u8                         |
-- | pqc_hybrid_state                  | (slot: c_int) -> u8                         |
-- | pqc_algorithm                     | (slot: c_int) -> u8                         |
-- | pqc_nist_level                    | (slot: c_int) -> u8                         |
-- | pqc_hybrid_mode                   | (slot: c_int) -> u8                         |
-- | pqc_category                      | (slot: c_int) -> u8                         |
-- | pqc_begin_keygen                  | (slot: c_int) -> u8                         |
-- | pqc_finish_keygen                 | (slot: c_int, pk: ptr, pk_len: u32, sk: ... |
-- | pqc_activate_key                  | (slot: c_int) -> u8                         |
-- | pqc_expire_key                    | (slot: c_int) -> u8                         |
-- | pqc_compromise_key                | (slot: c_int) -> u8                         |
-- | pqc_encapsulate                   | (slot: c_int, ct: ptr, ct_len: ptr, ss: ... |
-- | pqc_decapsulate                   | (slot: c_int, ct: ptr, ct_len: u32, ss: ... |
-- | pqc_sign                          | (slot: c_int, msg: ptr, msg_len: u32, si... |
-- | pqc_verify                        | (slot: c_int, msg: ptr, msg_len: u32, si... |
-- | pqc_set_hybrid_mode               | (slot: c_int, mode: u8) -> u8               |
-- | pqc_select_classical              | (slot: c_int) -> u8                         |
-- | pqc_select_pqc                    | (slot: c_int) -> u8                         |
-- | pqc_complete_hybrid               | (slot: c_int) -> u8                         |
-- | pqc_public_key_len                | (slot: c_int) -> u32                        |
-- | pqc_secret_key_len                | (slot: c_int) -> u32                        |
-- | pqc_can_key_transition            | (from: u8, to: u8) -> u8                    |
-- | pqc_can_hybrid_transition         | (from: u8, to: u8) -> u8                    |
-- | pqc_valid_algorithm_level         | (algo: u8, level: u8) -> u8                 |
-- | pqc_valid_operation               | (category: u8, op: u8) -> u8                |
-- +───────────────────────────────────+─────────────────────────────────────────────+
