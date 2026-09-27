-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- TACACSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the in-memory session model.
-- The Zig FFI has no credential verifier or accounting backend: authentication
-- continuation returns failure, authorization cannot succeed, and accounting
-- is unavailable. Session tags model lifecycle only.
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
-- |                             | Stores session metadata/secret bytes only; |
-- |                             | no credential verifier is connected.      |
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
-- |                             | Starts a modeled conversation only; this  |
-- |                             | does not authenticate the user.           |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_authen_continue      | (slot: c_int, data_ptr: ptr,              |
-- |                             |  data_len: u32) -> u8 (AuthenStatus tag)  |
-- |                             | Always returns Fail; continuation bytes   |
-- |                             | are not checked by a credential verifier.  |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_authen_status        | (slot: c_int) -> u8 (AuthenStatus tag)    |
-- |                             | Returns last authentication status.       |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_author_request       | (slot: c_int, user_ptr: ptr,              |
-- |                             |  user_len: u32, service_ptr: ptr,         |
-- |                             |  service_len: u32) -> u8 (AuthorStatus)   |
-- |                             | Always returns AuthorFail without a       |
-- |                             | successful authentication.                 |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_author_status        | (slot: c_int) -> u8 (AuthorStatus tag)    |
-- |                             | Returns last authorization status.        |
-- +-----------------------------+-------------------------------------------+
-- | tacacs_acct_record          | (slot: c_int, flag: u8, user_ptr: ptr,    |
-- |                             |  user_len: u32) -> u8 (AcctStatus tag)    |
-- |                             | Unavailable: no authorization or         |
-- |                             | accounting backend is connected.          |
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
