-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- PQCABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module PQCABI.Foreign

import PQCABI.Layout
import PQCABI.Transitions

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a PQC key context.
||| Created by pqc_create_context(), destroyed by pqc_destroy_context().
export
data PqcHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match pqc_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function                | Signature                                   |
-- +-------------------------+---------------------------------------------+
-- | pqc_abi_version         | () -> Bits32                                |
-- +-------------------------+---------------------------------------------+
-- | pqc_create_context      | (algo: u8, level: u8) -> c_int (slot)       |
-- |                         | Creates context in Empty key state with     |
-- |                         | hybrid state Idle.                          |
-- +-------------------------+---------------------------------------------+
-- | pqc_destroy_context     | (slot: c_int) -> ()                         |
-- +-------------------------+---------------------------------------------+
-- | pqc_key_state           | (slot: c_int) -> u8 (KeyState tag)          |
-- |                         | 0=Empty, 1=Generating, 2=Generated,         |
-- |                         | 3=Active, 4=Expired, 5=Compromised          |
-- +-------------------------+---------------------------------------------+
-- | pqc_hybrid_state        | (slot: c_int) -> u8 (HybridState tag)       |
-- |                         | 0=Idle, 1=ClassicalSelected,                |
-- |                         | 2=PQCSelected, 3=Negotiated, 4=Complete     |
-- +-------------------------+---------------------------------------------+
-- | pqc_algorithm           | (slot: c_int) -> u8 (PQCAlgorithm tag)      |
-- +-------------------------+---------------------------------------------+
-- | pqc_nist_level          | (slot: c_int) -> u8 (NISTLevel tag)          |
-- +-------------------------+---------------------------------------------+
-- | pqc_hybrid_mode         | (slot: c_int) -> u8 (HybridMode tag)         |
-- +-------------------------+---------------------------------------------+
-- | pqc_begin_keygen        | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- |                         | Empty -> Generating.                        |
-- +-------------------------+---------------------------------------------+
-- | pqc_finish_keygen       | (slot: c_int, pk: *const u8, pk_len: u32,   |
-- |                         |  sk: *const u8, sk_len: u32) -> u8          |
-- |                         | Generating -> Generated.                    |
-- +-------------------------+---------------------------------------------+
-- | pqc_activate_key        | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- |                         | Generated -> Active.                        |
-- +-------------------------+---------------------------------------------+
-- | pqc_expire_key          | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- |                         | Active -> Expired  OR  Generated -> Expired.|
-- +-------------------------+---------------------------------------------+
-- | pqc_compromise_key      | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- |                         | Active -> Compromised.                      |
-- +-------------------------+---------------------------------------------+
-- | pqc_encapsulate         | (slot: c_int, ct: *u8, ct_len: *u32,        |
-- |                         |  ss: *u8, ss_len: *u32) -> u8               |
-- |                         | Requires Active key state, KEM algorithm.   |
-- +-------------------------+---------------------------------------------+
-- | pqc_decapsulate         | (slot: c_int, ct: *const u8, ct_len: u32,   |
-- |                         |  ss: *u8, ss_len: *u32) -> u8               |
-- |                         | Requires Active key state, KEM algorithm.   |
-- +-------------------------+---------------------------------------------+
-- | pqc_sign                | (slot: c_int, msg: *const u8, msg_len: u32, |
-- |                         |  sig: *u8, sig_len: *u32) -> u8             |
-- |                         | Requires Active key state, sig algorithm.   |
-- +-------------------------+---------------------------------------------+
-- | pqc_verify              | (slot: c_int, msg: *const u8, msg_len: u32, |
-- |                         |  sig: *const u8, sig_len: u32) -> u8        |
-- |                         | Requires Active key state, sig algorithm.   |
-- +-------------------------+---------------------------------------------+
-- | pqc_set_hybrid_mode     | (slot: c_int, mode: u8) -> u8               |
-- |                         | Set the hybrid mode for this context.       |
-- +-------------------------+---------------------------------------------+
-- | pqc_select_classical    | (slot: c_int) -> u8                         |
-- |                         | Idle -> ClassicalSelected.                  |
-- +-------------------------+---------------------------------------------+
-- | pqc_select_pqc          | (slot: c_int) -> u8                         |
-- |                         | Idle -> PQCSelected   OR                    |
-- |                         | ClassicalSelected -> HybridNegotiated.      |
-- +-------------------------+---------------------------------------------+
-- | pqc_complete_hybrid     | (slot: c_int) -> u8                         |
-- |                         | HybridNegotiated -> HybridComplete   OR     |
-- |                         | Idle -> HybridComplete (direct).            |
-- +-------------------------+---------------------------------------------+
-- | pqc_public_key_len      | (slot: c_int) -> u32                         |
-- +-------------------------+---------------------------------------------+
-- | pqc_secret_key_len      | (slot: c_int) -> u32                         |
-- +-------------------------+---------------------------------------------+
-- | pqc_category            | (slot: c_int) -> u8 (AlgorithmCategory tag)  |
-- |                         | 0=KEM, 1=Signature                         |
-- +-------------------------+---------------------------------------------+
-- | pqc_can_key_transition  | (from: u8, to: u8) -> u8 (1=yes, 0=no)      |
-- |                         | Stateless key lifecycle transition check.   |
-- +-------------------------+---------------------------------------------+
-- | pqc_can_hybrid_transition| (from: u8, to: u8) -> u8 (1=yes, 0=no)     |
-- |                         | Stateless hybrid transition check.          |
-- +-------------------------+---------------------------------------------+
-- | pqc_valid_algorithm_level| (algo: u8, level: u8) -> u8 (1=yes, 0=no)  |
-- |                         | Check if algorithm+level combination valid. |
-- +-------------------------+---------------------------------------------+
-- | pqc_valid_operation     | (category: u8, op: u8) -> u8 (1=yes, 0=no)  |
-- |                         | Check if operation valid for category.      |
-- +-------------------------+---------------------------------------------+
