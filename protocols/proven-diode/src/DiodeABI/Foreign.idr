-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DiodeABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/diode.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected gateway pool
--   - Unidirectional data transfer enforcement
--   - Segment queuing per gateway (max 128 segments)
--   - Integrity verification per segment
--   - Validation before transit
--   - Transfer statistics tracking
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DiodeABI.Types exactly.

module DiodeABI.Foreign

import DiodeABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a data diode gateway instance.
||| Created by diode_create(), destroyed by diode_destroy().
export
data DiodeContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match diode_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | diode_abi_version              | () -> u32                               |
-- |                                | Returns ABI version (must equal         |
-- |                                | abiVersion).                            |
-- +-------------------------------+-----------------------------------------+
-- | diode_create                   | (direction: u8, protocol: u8)           |
-- |                                | -> c_int (slot)                         |
-- |                                | Creates gateway in Configured state.    |
-- |                                | Returns -1 on failure.                  |
-- +-------------------------------+-----------------------------------------+
-- | diode_destroy                  | (slot: c_int) -> void                   |
-- |                                | Releases a gateway slot.                |
-- +-------------------------------+-----------------------------------------+
-- | diode_state                    | (slot: c_int) -> u8 (GatewayState tag)  |
-- |                                | Returns current gateway state.          |
-- +-------------------------------+-----------------------------------------+
-- | diode_enqueue                  | (slot: c_int,                           |
-- |                                |  data_ptr: ptr, data_len: u32,          |
-- |                                |  integrity: u8) -> u8 (0=ok, 1=rej)    |
-- |                                | Enqueues a data segment for transfer.   |
-- +-------------------------------+-----------------------------------------+
-- | diode_validate                 | (slot: c_int)                           |
-- |                                | -> u8 (ValidationResult tag)            |
-- |                                | Validates the next queued segment.      |
-- |                                | Transitions Configured -> Validating.   |
-- +-------------------------------+-----------------------------------------+
-- | diode_transfer                 | (slot: c_int)                           |
-- |                                | -> u8 (0=ok, 1=rejected)                |
-- |                                | Transfers next validated segment.       |
-- |                                | Transitions Validating -> Transferring. |
-- +-------------------------------+-----------------------------------------+
-- | diode_confirm                  | (slot: c_int)                           |
-- |                                | -> u8 (0=ok, 1=rejected)                |
-- |                                | Confirms transfer completion.           |
-- +-------------------------------+-----------------------------------------+
-- | diode_queue_depth              | (slot: c_int) -> u32                    |
-- |                                | Returns number of queued segments.      |
-- +-------------------------------+-----------------------------------------+
-- | diode_transferred_count        | (slot: c_int) -> u64                    |
-- |                                | Returns total segments transferred.     |
-- +-------------------------------+-----------------------------------------+
-- | diode_can_transfer             | (slot: c_int) -> u8 (1=yes, 0=no)      |
-- +-------------------------------+-----------------------------------------+
-- | diode_shutdown                 | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                                | Transitions to Shutdown state.          |
-- +-------------------------------+-----------------------------------------+
-- | diode_cleanup                  | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                                | Transitions Shutdown -> Idle.           |
-- +-------------------------------+-----------------------------------------+
-- | diode_can_transition           | (from: u8, to: u8) -> u8 (1=yes, 0=no) |
-- |                                | Stateless transition validity check.    |
-- +-------------------------------+-----------------------------------------+
