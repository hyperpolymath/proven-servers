-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- KmsABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/kms.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching KmsABI.Types exactly.

module KmsABI.Foreign

import KmsABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Kms context.
||| Created by kms_create*(), destroyed by kms_destroy*().
export
data KmsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match kms_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (11 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | kms_abi_version                   | () -> u32                                   |
-- | kms_create                        | (obj_type: u8, algorithm: u8) -> c_int      |
-- | kms_destroy                       | (slot: c_int) -> void                       |
-- | kms_get_state                     | (slot: c_int) -> u8                         |
-- | kms_get_object_type               | (slot: c_int) -> u8                         |
-- | kms_get_algorithm                 | (slot: c_int) -> u8                         |
-- | kms_get_operation_count           | (slot: c_int) -> u32                        |
-- | kms_get_last_error                | (slot: c_int) -> u8                         |
-- | kms_transition                    | (slot: c_int, new_state: u8) -> u8          |
-- | kms_perform_operation             | (slot: c_int, operation: u8) -> u8          |
-- | kms_can_transition                | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
