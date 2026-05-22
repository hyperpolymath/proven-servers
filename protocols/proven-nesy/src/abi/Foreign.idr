-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NeSyABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/nesy.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Query submission with reasoning mode selection
--   - Proof obligation tracking (max 16 per session)
--   - Neural backend selection
--   - Confidence assessment
--   - Drift detection between symbolic and neural results
--   - Lifecycle state machine transitions

module NeSyABI.Foreign

import NeSyABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a NeSy reasoning session.
||| Created by nesy_create(), destroyed by nesy_destroy().
export
data NeSyContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match nesy_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | nesy_abi_version            | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | nesy_create                 | (backend: u8) -> c_int (slot)             |
-- |                             | Creates session in Ready state.           |
-- +-----------------------------+-------------------------------------------+
-- | nesy_destroy                | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | nesy_state                  | (slot: c_int) -> u8 (NeSyState tag)       |
-- +-----------------------------+-------------------------------------------+
-- | nesy_submit_query           | (slot: c_int, mode: u8,                   |
-- |                             |  query_ptr: ptr, query_len: u32)          |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Ready -> Reasoning.                       |
-- +-----------------------------+-------------------------------------------+
-- | nesy_complete_query         | (slot: c_int, confidence: u8)             |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Reasoning -> Ready.                       |
-- +-----------------------------+-------------------------------------------+
-- | nesy_add_proof              | (slot: c_int, kind: u8,                   |
-- |                             |  desc_ptr: ptr, desc_len: u32)            |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | nesy_verify_proof           | (slot: c_int, index: u32)                 |
-- |                             |  -> u8 (ProofStatus tag)                  |
-- |                             | Ready -> Verifying -> Ready.              |
-- +-----------------------------+-------------------------------------------+
-- | nesy_proof_count            | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | nesy_detect_drift           | (slot: c_int) -> u8 (DriftKind tag)       |
-- |                             | May transition to Drift state.            |
-- +-----------------------------+-------------------------------------------+
-- | nesy_resolve_drift          | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Drift -> Ready.                           |
-- +-----------------------------+-------------------------------------------+
-- | nesy_shutdown               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Any non-Idle/Shutdown -> Shutdown.        |
-- +-----------------------------+-------------------------------------------+
-- | nesy_cleanup                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Shutdown -> Idle.                         |
-- +-----------------------------+-------------------------------------------+
-- | nesy_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
