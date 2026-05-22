-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- PTPABI.Foreign: Foreign function declarations for the PTP C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (ClockContext) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function ptp_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module PTPABI.Foreign

import PTP.Types
import PTPABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a PTP clock context instance.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via ptp_create() and destroyed via
||| ptp_destroy().
export
data ClockContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's ptp_abi_version() function MUST return
||| this exact value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/ptp.zig) must export.
--
-- +--------------------------------------------------------------------------+
-- | Function                      | Signature                                |
-- +-------------------------------+------------------------------------------+
-- | ptp_abi_version               | () -> u32                                |
-- |                               | Must return abiVersion (currently 1).    |
-- +-------------------------------+------------------------------------------+
-- | ptp_create                    | (clock_class: u8,                        |
-- |                               |  delay_mechanism: u8) -> c_int           |
-- |                               | Creates a new clock in Initializing.     |
-- |                               | Returns -1 if no slots available.        |
-- +-------------------------------+------------------------------------------+
-- | ptp_destroy                   | (slot: c_int) -> void                    |
-- |                               | Frees the clock context.                 |
-- +-------------------------------+------------------------------------------+
-- | ptp_get_port_state            | (slot: c_int) -> u8                      |
-- |                               | Returns the PortState tag.               |
-- |                               | Returns Initializing (0) if invalid.     |
-- +-------------------------------+------------------------------------------+
-- | ptp_get_clock_class           | (slot: c_int) -> u8                      |
-- |                               | Returns the ClockClass tag.              |
-- +-------------------------------+------------------------------------------+
-- | ptp_get_delay_mechanism       | (slot: c_int) -> u8                      |
-- |                               | Returns the DelayMechanism tag.          |
-- +-------------------------------+------------------------------------------+
-- | ptp_transition                | (slot: c_int, new_state: u8)             |
-- |                               |  -> u8 (PTPError tag)                    |
-- |                               | Advance port to new_state.               |
-- +-------------------------------+------------------------------------------+
-- | ptp_send_message              | (slot: c_int, msg_type: u8)              |
-- |                               |  -> u8 (PTPError tag)                    |
-- |                               | Record sending a PTP message.            |
-- +-------------------------------+------------------------------------------+
-- | ptp_get_message_count         | (slot: c_int) -> u32                     |
-- |                               | Returns number of messages sent.         |
-- +-------------------------------+------------------------------------------+
-- | ptp_get_sync_count            | (slot: c_int) -> u32                     |
-- |                               | Returns number of Sync messages.         |
-- +-------------------------------+------------------------------------------+
-- | ptp_get_last_error            | (slot: c_int) -> u8                      |
-- |                               | Returns the last PTPError tag,           |
-- |                               | or 255 if no error occurred.             |
-- +-------------------------------+------------------------------------------+
-- | ptp_can_transition            | (from: u8, to: u8) -> u8                 |
-- |                               | Returns 1 if transition is valid.        |
-- +-------------------------------+------------------------------------------+
