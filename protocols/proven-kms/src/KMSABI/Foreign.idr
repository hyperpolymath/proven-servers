-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- KMSABI.Foreign: Foreign function declarations for the KMS C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (KeyContext) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function kms_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module KMSABI.Foreign

import KMS.Types
import KMSABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a KMS key context instance.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via kms_create() and destroyed via
||| kms_destroy().
export
data KeyContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's kms_abi_version() function MUST return
||| this exact value.
|||
||| Increment this value whenever:
|||   - A new function is added to the FFI
|||   - An existing function signature changes
|||   - Tag values in Layout.idr change
|||   - Handle semantics change
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/kms.zig) must export.
--
-- +--------------------------------------------------------------------------+
-- | Function                      | Signature                                |
-- +-------------------------------+------------------------------------------+
-- | kms_abi_version               | () -> u32                                |
-- |                               | Must return abiVersion (currently 1).    |
-- +-------------------------------+------------------------------------------+
-- | kms_create                    | (obj_type: u8, algorithm: u8)            |
-- |                               |  -> c_int                                |
-- |                               | Creates a new key in PreActive state.    |
-- |                               | Returns -1 if no slots available.        |
-- +-------------------------------+------------------------------------------+
-- | kms_destroy                   | (slot: c_int) -> void                    |
-- |                               | Frees the key context. Safe with any     |
-- |                               | slot.                                    |
-- +-------------------------------+------------------------------------------+
-- | kms_get_state                 | (slot: c_int) -> u8                      |
-- |                               | Returns the KeyState tag.                |
-- |                               | Returns PreActive (0) if slot invalid.   |
-- +-------------------------------+------------------------------------------+
-- | kms_get_object_type           | (slot: c_int) -> u8                      |
-- |                               | Returns the ObjectType tag.              |
-- |                               | Returns SymmetricKey (0) if invalid.     |
-- +-------------------------------+------------------------------------------+
-- | kms_get_algorithm             | (slot: c_int) -> u8                      |
-- |                               | Returns the Algorithm tag.               |
-- |                               | Returns AES128 (0) if slot invalid.      |
-- +-------------------------------+------------------------------------------+
-- | kms_get_operation_count       | (slot: c_int) -> u32                     |
-- |                               | Returns the number of operations         |
-- |                               | performed on this key.                   |
-- +-------------------------------+------------------------------------------+
-- | kms_get_last_error            | (slot: c_int) -> u8                      |
-- |                               | Returns the last KMSError tag,           |
-- |                               | or 255 if no error occurred.             |
-- +-------------------------------+------------------------------------------+
-- | kms_transition                | (slot: c_int, new_state: u8)             |
-- |                               |  -> u8 (KMSError tag)                    |
-- |                               | Advance key to new_state if valid.       |
-- +-------------------------------+------------------------------------------+
-- | kms_perform_operation         | (slot: c_int, operation: u8)             |
-- |                               |  -> u8 (KMSError tag)                    |
-- |                               | Record an operation on the key.          |
-- +-------------------------------+------------------------------------------+
-- | kms_can_transition            | (from: u8, to: u8) -> u8                 |
-- |                               | Returns 1 if transition is valid.        |
-- |                               | Stateless -- validates against schema.   |
-- +-------------------------------+------------------------------------------+
