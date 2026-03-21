-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TelnetABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/telnet.zig) must provide.
--
-- INSECURE PROTOCOL -- for legacy interoperability only.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Option negotiation state tracking per session
--   - Command send/receive with IAC escaping
--   - Subnegotiation data handling
--   - Session state machine (Idle -> Negotiating -> Active -> Closing)
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching TelnetABI.Types exactly.

module TelnetABI.Foreign

import TelnetABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Telnet session.
||| Created by telnet_create(), destroyed by telnet_destroy().
||| INSECURE PROTOCOL -- for legacy interoperability only.
export
data TelnetContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match telnet_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | telnet_abi_version          | () -> u32                                 |
-- |                             | Returns ABI version.                      |
-- +-----------------------------+-------------------------------------------+
-- | telnet_create               | () -> c_int (slot)                        |
-- |                             | Creates session. Returns -1 on failure.   |
-- +-----------------------------+-------------------------------------------+
-- | telnet_destroy              | (slot: c_int) -> void                     |
-- |                             | Releases a session slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | telnet_state                | (slot: c_int) -> u8 (SessionState tag)    |
-- |                             | Returns current session state.            |
-- +-----------------------------+-------------------------------------------+
-- | telnet_send_command         | (slot: c_int, cmd: u8) -> u8              |
-- |                             | (0=ok, 1=rejected)                        |
-- |                             | Sends a Telnet command.                   |
-- +-----------------------------+-------------------------------------------+
-- | telnet_negotiate            | (slot: c_int, cmd: u8, option: u8)        |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Sends WILL/WONT/DO/DONT for an option.    |
-- |                             | Transitions Idle -> Negotiating.          |
-- +-----------------------------+-------------------------------------------+
-- | telnet_option_state         | (slot: c_int, option: u8)                 |
-- |                             |  -> u8 (NegotiationState tag)             |
-- |                             | Returns negotiation state for an option.  |
-- +-----------------------------+-------------------------------------------+
-- | telnet_activate             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Negotiating -> Active.        |
-- +-----------------------------+-------------------------------------------+
-- | telnet_subneg_begin         | (slot: c_int, option: u8)                 |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Begins subnegotiation.                    |
-- |                             | Transitions Active -> Subneg.             |
-- +-----------------------------+-------------------------------------------+
-- | telnet_subneg_data          | (slot: c_int, data_ptr: ptr,              |
-- |                             |  data_len: u32) -> u8 (0=ok, 1=rejected) |
-- |                             | Sends subnegotiation data.                |
-- +-----------------------------+-------------------------------------------+
-- | telnet_subneg_end           | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Ends subnegotiation.                      |
-- |                             | Transitions Subneg -> Active.             |
-- +-----------------------------+-------------------------------------------+
-- | telnet_send_data            | (slot: c_int, data_ptr: ptr,              |
-- |                             |  data_len: u32) -> u8 (0=ok, 1=rejected) |
-- |                             | Sends application data.                   |
-- +-----------------------------+-------------------------------------------+
-- | telnet_disconnect           | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Closing.                   |
-- +-----------------------------+-------------------------------------------+
-- | telnet_cleanup              | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Closing -> Idle.              |
-- +-----------------------------+-------------------------------------------+
-- | telnet_can_transition       | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks session state           |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
-- | telnet_session_count        | () -> u32                                 |
-- |                             | Returns number of active sessions.        |
-- +-----------------------------+-------------------------------------------+
