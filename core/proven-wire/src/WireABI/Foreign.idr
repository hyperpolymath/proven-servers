-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- WireABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module WireABI.Foreign

import Wire.Types
import WireABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a wire codec session.
||| Created by wire_create(), destroyed by wire_destroy().
export
data WireHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match wire_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function              | Signature                                     |
-- +-----------------------+-----------------------------------------------+
-- | wire_abi_version      | () -> Bits32                                  |
-- +-----------------------+-----------------------------------------------+
-- | wire_create           | (endianness: u8) -> c_int (slot)              |
-- |                       | Creates codec in Idle state.                  |
-- +-----------------------+-----------------------------------------------+
-- | wire_destroy          | (slot: c_int) -> ()                           |
-- +-----------------------+-----------------------------------------------+
-- | wire_state            | (slot: c_int) -> u8 (CodecState tag)          |
-- +-----------------------+-----------------------------------------------+
-- | wire_begin_encode     | (slot: c_int) -> u8 (TransitionResult)        |
-- +-----------------------+-----------------------------------------------+
-- | wire_begin_decode     | (slot: c_int) -> u8 (TransitionResult)        |
-- +-----------------------+-----------------------------------------------+
-- | wire_finalize         | (slot: c_int) -> u8 (TransitionResult)        |
-- +-----------------------+-----------------------------------------------+
-- | wire_fail             | (slot: c_int, err: u8) -> u8                  |
-- +-----------------------+-----------------------------------------------+
-- | wire_reset            | (slot: c_int) -> u8 (TransitionResult)        |
-- +-----------------------+-----------------------------------------------+
-- | wire_encode_u8        | (slot: c_int, val: u8) -> u8 (EncodeError)    |
-- +-----------------------+-----------------------------------------------+
-- | wire_encode_u16       | (slot: c_int, val: u16) -> u8                 |
-- +-----------------------+-----------------------------------------------+
-- | wire_encode_u32       | (slot: c_int, val: u32) -> u8                 |
-- +-----------------------+-----------------------------------------------+
-- | wire_encode_u64       | (slot: c_int, val: u64) -> u8                 |
-- +-----------------------+-----------------------------------------------+
-- | wire_decode_u8        | (slot: c_int, out: Ptr u8) -> u8 (DecodeErr)  |
-- +-----------------------+-----------------------------------------------+
-- | wire_decode_u16       | (slot: c_int, out: Ptr u16) -> u8             |
-- +-----------------------+-----------------------------------------------+
-- | wire_decode_u32       | (slot: c_int, out: Ptr u32) -> u8             |
-- +-----------------------+-----------------------------------------------+
-- | wire_decode_u64       | (slot: c_int, out: Ptr u64) -> u8             |
-- +-----------------------+-----------------------------------------------+
-- | wire_bytes_written    | (slot: c_int) -> u32                          |
-- +-----------------------+-----------------------------------------------+
-- | wire_type_byte_size   | (wtype: u8) -> u8 (0 for variable-length)    |
-- +-----------------------+-----------------------------------------------+
-- | wire_is_fixed_size    | (wtype: u8) -> u8 (1=yes, 0=no)              |
-- +-----------------------+-----------------------------------------------+
-- | wire_can_transition   | (from: u8, to: u8) -> u8 (1=yes, 0=no)       |
-- +-----------------------+-----------------------------------------------+
-- | wire_last_error       | (slot: c_int) -> u8                           |
-- +-----------------------+-----------------------------------------------+
