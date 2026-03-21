-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TACACSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/tacacs.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Authentication start/continue/reply per session
--   - Authorization request/reply per session
--   - Accounting start/stop/watchdog per session
--   - Session state machine (Idle -> Authenticating -> Authorizing -> Active -> Closing)
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching TACACSABI.Types exactly.

module TACACSABI.Foreign

import TACACSABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a TACACS+ session.
||| Created by tacacs_create(), destroyed by tacacs_destroy().
export
data TacacsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match tacacs_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (15 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_abi_version          | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_create               | (secret_ptr: ptr, secret_len: u32)        |
-- |                             |  -> c_int (slot)                          |
-- |                             | Creates session with shared secret.       |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_destroy              | (slot: c_int) -> void                     |
-- |                             | Releases a session slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_state                | (slot: c_int) -> u8 (SessionState tag)    |
-- |                             | Returns current session state.            |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_authen_start         | (slot: c_int, action: u8, type: u8,      |
-- |                             |  user_ptr: ptr, user_len: u32,            |
-- |                             |  port_ptr: ptr, port_len: u32)            |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Starts authentication.                    |
-- |                             | Transitions Idle -> Authenticating.       |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_authen_continue      | (slot: c_int, data_ptr: ptr,              |
-- |                             |  data_len: u32) -> u8 (AuthenStatus tag)  |
-- |                             | Continues multi-step authentication.      |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_authen_status        | (slot: c_int) -> u8 (AuthenStatus tag)    |
-- |                             | Returns last authentication status.       |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_author_request       | (slot: c_int, user_ptr: ptr,              |
-- |                             |  user_len: u32, service_ptr: ptr,         |
-- |                             |  service_len: u32) -> u8 (AuthorStatus)   |
-- |                             | Requests authorization.                   |
-- |                             | Transitions Authenticating -> Authorizing.|
-- +-----------------------------+-------------------------------------------+
-- | tacacs_author_status        | (slot: c_int) -> u8 (AuthorStatus tag)    |
-- |                             | Returns last authorization status.        |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_acct_record          | (slot: c_int, flag: u8, user_ptr: ptr,    |
-- |                             |  user_len: u32) -> u8 (AcctStatus tag)    |
-- |                             | Sends an accounting record.               |
-- |                             | Transitions Authorizing -> Active.        |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_acct_status          | (slot: c_int) -> u8 (AcctStatus tag)      |
-- |                             | Returns last accounting status.           |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_disconnect           | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                             | Transitions to Closing.                   |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_cleanup              | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                             | Transitions Closing -> Idle.              |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_can_transition       | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks session state           |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_session_count        | () -> u32                                 |
-- |                             | Returns number of active sessions.        |
-- +-----------------------------+-------------------------------------------+
