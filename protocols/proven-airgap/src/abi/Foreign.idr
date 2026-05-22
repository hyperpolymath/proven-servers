-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AirgapABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/airgap.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected transfer pool
--   - Content scanning pipeline per transfer
--   - Validation check tracking (max 16 checks per transfer)
--   - Transfer lifecycle state machine
--   - Media type registration
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching AirgapABI.Types exactly.

module AirgapABI.Foreign

import AirgapABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an airgap transfer gateway context.
||| Created by airgap_create(), destroyed by airgap_destroy().
export
data AirgapContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match airgap_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | airgap_abi_version          | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | airgap_create               | (direction: u8, media: u8) -> c_int       |
-- |                             | Creates transfer in Pending state.        |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | airgap_destroy              | (slot: c_int) -> void                     |
-- |                             | Releases a transfer slot.                 |
-- +-----------------------------+-------------------------------------------+
-- | airgap_state                | (slot: c_int) -> u8 (TransferState tag)   |
-- |                             | Returns current transfer state.           |
-- +-----------------------------+-------------------------------------------+
-- | airgap_direction            | (slot: c_int) -> u8 (TransferDirection)   |
-- |                             | Returns transfer direction tag.           |
-- +-----------------------------+-------------------------------------------+
-- | airgap_media                | (slot: c_int) -> u8 (MediaType tag)       |
-- |                             | Returns media type tag.                   |
-- +-----------------------------+-------------------------------------------+
-- | airgap_start_scan           | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Pending -> Scanning.          |
-- +-----------------------------+-------------------------------------------+
-- | airgap_submit_scan_result   | (slot: c_int, result: u8)                 |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Sets scan result; transitions Scanning -> |
-- |                             | Approved (if Clean) or Rejected.          |
-- +-----------------------------+-------------------------------------------+
-- | airgap_begin_transfer       | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Approved -> InProgress.       |
-- +-----------------------------+-------------------------------------------+
-- | airgap_complete_transfer    | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions InProgress -> Complete.       |
-- +-----------------------------+-------------------------------------------+
-- | airgap_fail_transfer        | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions InProgress -> Failed.         |
-- +-----------------------------+-------------------------------------------+
-- | airgap_add_validation       | (slot: c_int, check: u8)                  |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Adds a validation check to the transfer.  |
-- +-----------------------------+-------------------------------------------+
-- | airgap_validation_count     | (slot: c_int) -> u32                      |
-- |                             | Returns number of validation checks.      |
-- +-----------------------------+-------------------------------------------+
-- | airgap_can_transition       | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks transfer state          |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
