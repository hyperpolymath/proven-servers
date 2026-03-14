-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NTPABI.Foreign: Foreign function declarations for the NTP C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (NtpContext) that cannot be inspected or
--      forged from Idris2 code — it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function ntp_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module NTPABI.Foreign

import NTP.Mode
import NTP.Stratum
import NTP.Timestamp
import NTPABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an NTP context instance.
||| This type has no Idris2-visible constructors — values can only be
||| created by the Zig FFI via ntp_create() and destroyed via ntp_destroy().
export
data NtpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's ntp_abi_version() function MUST return
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
-- Zig implementation (ffi/zig/src/ntp.zig) must export.
--
-- +--------------------------------------------------------------------------+
-- | Function                | Signature                                      |
-- +-------------------------+------------------------------------------------+
-- | ntp_abi_version         | () -> u32                                      |
-- |                         | Must return abiVersion (currently 1).          |
-- +-------------------------+------------------------------------------------+
-- | ntp_create              | (version: u8, mode: u8, stratum: u8)           |
-- |                         |  -> c_int (slot index, or -1)                  |
-- |                         | Creates a new NTP context in Idle state.       |
-- |                         | Returns -1 if no slots available.              |
-- +-------------------------+------------------------------------------------+
-- | ntp_destroy             | (slot: c_int) -> void                          |
-- |                         | Frees the NTP context. Safe with any slot.     |
-- +-------------------------+------------------------------------------------+
-- | ntp_get_exchange_state  | (slot: c_int) -> u8                            |
-- |                         | Returns the ExchangeState tag for context.     |
-- |                         | Returns Idle (0) if slot invalid.              |
-- +-------------------------+------------------------------------------------+
-- | ntp_get_discipline_state| (slot: c_int) -> u8                            |
-- |                         | Returns the ClockDisciplineState tag.          |
-- |                         | Returns Unset (0) if slot invalid.             |
-- +-------------------------+------------------------------------------------+
-- | ntp_get_stratum         | (slot: c_int) -> u8                            |
-- |                         | Returns the current stratum value.             |
-- |                         | Returns 16 (Unsynchronised) if slot invalid.   |
-- +-------------------------+------------------------------------------------+
-- | ntp_get_mode            | (slot: c_int) -> u8                            |
-- |                         | Returns the current NTPMode tag.               |
-- |                         | Returns 0 (Reserved) if slot invalid.          |
-- +-------------------------+------------------------------------------------+
-- | ntp_receive_request     | (slot: c_int,                                  |
-- |                         |  t1_secs: u32, t1_frac: u32,                   |
-- |                         |  t2_secs: u32, t2_frac: u32)                   |
-- |                         |  -> u8 (NtpError tag)                          |
-- |                         | Transition: Idle -> RequestReceived.           |
-- |                         | Records client transmit (t1) and server        |
-- |                         | receive (t2) timestamps.                       |
-- +-------------------------+------------------------------------------------+
-- | ntp_calculate           | (slot: c_int,                                  |
-- |                         |  t3_secs: u32, t3_frac: u32)                   |
-- |                         |  -> u8 (NtpError tag)                          |
-- |                         | Transition: RequestReceived ->                 |
-- |                         |   TimestampCalculated.                         |
-- |                         | Records server transmit time (t3) and          |
-- |                         | computes offset/delay.                         |
-- +-------------------------+------------------------------------------------+
-- | ntp_send_response       | (slot: c_int) -> u8 (NtpError tag)             |
-- |                         | Transition: TimestampCalculated ->             |
-- |                         |   ResponseSent.                                |
-- +-------------------------+------------------------------------------------+
-- | ntp_reset_exchange      | (slot: c_int) -> u8 (NtpError tag)             |
-- |                         | Transition: ResponseSent -> Idle.              |
-- +-------------------------+------------------------------------------------+
-- | ntp_get_offset          | (slot: c_int,                                  |
-- |                         |  out_secs: *u32, out_frac: *u32)               |
-- |                         |  -> u8 (NtpError tag)                          |
-- |                         | Reads the calculated clock offset.             |
-- |                         | Only valid after TimestampCalculated.          |
-- +-------------------------+------------------------------------------------+
-- | ntp_get_delay           | (slot: c_int,                                  |
-- |                         |  out_secs: *u32, out_frac: *u32)               |
-- |                         |  -> u8 (NtpError tag)                          |
-- |                         | Reads the calculated round-trip delay.         |
-- |                         | Only valid after TimestampCalculated.          |
-- +-------------------------+------------------------------------------------+
-- | ntp_set_leap            | (slot: c_int, leap: u8) -> u8                  |
-- |                         | Set the leap indicator for the context.        |
-- +-------------------------+------------------------------------------------+
-- | ntp_get_leap            | (slot: c_int) -> u8                            |
-- |                         | Get the current leap indicator tag.            |
-- +-------------------------+------------------------------------------------+
-- | ntp_check_kiss          | (slot: c_int) -> u8                            |
-- |                         | Returns KissCodeABI tag if last exchange was   |
-- |                         | a Kiss-o'-Death, or 255 if not.                |
-- +-------------------------+------------------------------------------------+
-- | ntp_can_exchange_transition                                              |
-- |                         | (from: u8, to: u8) -> u8                       |
-- |                         | Returns 1 if exchange transition is valid.     |
-- |                         | Stateless — validates against schema.          |
-- +-------------------------+------------------------------------------------+
-- | ntp_can_discipline_transition                                            |
-- |                         | (from: u8, to: u8) -> u8                       |
-- |                         | Returns 1 if discipline transition is valid.   |
-- |                         | Stateless — validates against schema.          |
-- +-------------------------+------------------------------------------------+
-- | ntp_get_last_error      | (slot: c_int) -> u8                            |
-- |                         | Returns the last NtpError tag,                 |
-- |                         | or 255 if no error occurred.                   |
-- +-------------------------+------------------------------------------------+
-- | ntp_get_exchange_count  | (slot: c_int) -> u32                            |
-- |                         | Returns the number of completed exchanges.     |
-- +-------------------------+------------------------------------------------+
