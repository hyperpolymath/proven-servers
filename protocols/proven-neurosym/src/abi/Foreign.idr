-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NeurosymABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/neurosym.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Neural inference dispatch
--   - Symbolic reasoning dispatch
--   - Fusion strategy execution
--   - Confidence level tracking
--   - Knowledge base entry management
--   - Lifecycle state machine transitions

module NeurosymABI.Foreign

import NeurosymABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a neurosymbolic inference session.
||| Created by neurosym_create(), destroyed by neurosym_destroy().
export
data NeurosymContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match neurosym_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_abi_version        | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_create             | (strategy: u8) -> c_int (slot)            |
-- |                             | Creates session in Ready state.           |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_destroy            | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_state              | (slot: c_int) -> u8 (NeurosymState tag)   |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_infer              | (slot: c_int, mode: u8,                   |
-- |                             |  input_ptr: ptr, input_len: u32)          |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Ready -> Inferring.                       |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_reason             | (slot: c_int, op: u8,                     |
-- |                             |  input_ptr: ptr, input_len: u32)          |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Ready -> Reasoning.                       |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_fuse               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Inferring/Reasoning -> Fusing.            |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_complete           | (slot: c_int, confidence: u8)             |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Inferring/Reasoning/Fusing -> Ready.      |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_add_knowledge      | (slot: c_int, kind: u8,                   |
-- |                             |  data_ptr: ptr, data_len: u32)            |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_knowledge_count    | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_shutdown           | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Any non-Idle/Shutdown -> Shutdown.        |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_cleanup            | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Shutdown -> Idle.                         |
-- +-----------------------------+-------------------------------------------+
-- | neurosym_can_transition     | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
