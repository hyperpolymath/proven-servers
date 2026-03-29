-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NTSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/nts.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - NTS-KE record parsing and validation
--   - Cookie management (max 8 cookies per session)
--   - AEAD algorithm negotiation
--   - Handshake state machine transitions
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching NTSABI.Types exactly.

module NTSABI.Foreign

import NTSABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an NTS-KE session.
||| Created by nts_create(), destroyed by nts_destroy().
export
data NtsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match nts_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | nts_abi_version             | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | nts_create                  | (server_ptr: ptr, server_len: u32,        |
-- |                             |  port: u16) -> c_int (slot)               |
-- |                             | Creates session in Handshaking state.     |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | nts_destroy                 | (slot: c_int) -> void                     |
-- |                             | Releases a session slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | nts_state                   | (slot: c_int) -> u8 (SessionState tag)    |
-- |                             | Returns current session state.            |
-- +-----------------------------+-------------------------------------------+
-- | nts_negotiate               | (slot: c_int, aead: u8) -> u8             |
-- |                             | (0=ok, 1=rejected)                        |
-- |                             | Proposes AEAD algorithm. Transitions      |
-- |                             | Handshaking -> Negotiating.               |
-- +-----------------------------+-------------------------------------------+
-- | nts_accept                  | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Accepts negotiation. Transitions          |
-- |                             | Negotiating -> Established.               |
-- +-----------------------------+-------------------------------------------+
-- | nts_add_cookie              | (slot: c_int, cookie_ptr: ptr,            |
-- |                             |  cookie_len: u32) -> u8                   |
-- |                             | (0=ok, 1=rejected)                        |
-- +-----------------------------+-------------------------------------------+
-- | nts_cookie_count            | (slot: c_int) -> u32                      |
-- |                             | Returns number of stored cookies.         |
-- +-----------------------------+-------------------------------------------+
-- | nts_get_aead                | (slot: c_int) -> u8                       |
-- |                             | Returns negotiated AEAD algorithm tag.    |
-- +-----------------------------+-------------------------------------------+
-- | nts_close                   | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Closing.                   |
-- +-----------------------------+-------------------------------------------+
-- | nts_cleanup                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Closing -> Idle.              |
-- +-----------------------------+-------------------------------------------+
-- | nts_can_transition          | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks session state           |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
-- | nts_error_for_state         | (state: u8) -> u8 (error code tag)        |
-- |                             | Stateless: returns error code for a       |
-- |                             | failed state.                             |
-- +-----------------------------+-------------------------------------------+
-- | nts_is_established          | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                             | Whether session is ready for NTP queries. |
-- +-----------------------------+-------------------------------------------+
