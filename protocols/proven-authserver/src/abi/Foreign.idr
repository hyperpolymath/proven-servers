-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AuthserverABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/authserver.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Authentication attempts with configurable methods
--   - MFA challenge/response workflow
--   - Token issuance and revocation
--   - Session lifecycle (Active -> Expired/Revoked/Locked)
--   - Failed attempt tracking with lockout
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching AuthserverABI.Types exactly.

module AuthserverABI.Foreign

import AuthserverABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an authentication server context.
||| Created by authserver_create(), destroyed by authserver_destroy().
export
data AuthserverContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match authserver_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +------------------------------+------------------------------------------+
-- | Function                     | Signature                                |
-- +------------------------------+------------------------------------------+
-- | authserver_abi_version       | () -> u32                                |
-- |                              | Returns ABI version.                     |
-- +------------------------------+------------------------------------------+
-- | authserver_create            | (method: u8) -> c_int (slot)             |
-- |                              | Creates session in Active state.         |
-- |                              | Returns -1 on failure.                   |
-- +------------------------------+------------------------------------------+
-- | authserver_destroy           | (slot: c_int) -> void                    |
-- |                              | Releases a session slot.                 |
-- +------------------------------+------------------------------------------+
-- | authserver_session_state     | (slot: c_int) -> u8 (SessionState tag)   |
-- |                              | Returns current session state.           |
-- +------------------------------+------------------------------------------+
-- | authserver_authenticate      | (slot: c_int, method: u8)                |
-- |                              | -> u8 (AuthResult tag)                   |
-- |                              | Attempt authentication with method.      |
-- +------------------------------+------------------------------------------+
-- | authserver_require_mfa       | (slot: c_int, mfa_method: u8)           |
-- |                              | -> u8 (0=ok, 1=rejected)                 |
-- |                              | Set MFA requirement on session.          |
-- +------------------------------+------------------------------------------+
-- | authserver_verify_mfa        | (slot: c_int, mfa_method: u8)           |
-- |                              | -> u8 (0=ok, 1=rejected)                 |
-- |                              | Verify MFA challenge response.           |
-- +------------------------------+------------------------------------------+
-- | authserver_issue_token       | (slot: c_int, token_type: u8)           |
-- |                              | -> u8 (0=ok, 1=rejected)                 |
-- |                              | Issue a token of the given type.         |
-- +------------------------------+------------------------------------------+
-- | authserver_token_count       | (slot: c_int) -> u32                     |
-- |                              | Returns number of active tokens.         |
-- +------------------------------+------------------------------------------+
-- | authserver_revoke_session    | (slot: c_int) -> u8 (0=ok, 1=rejected)  |
-- |                              | Transitions Active -> Revoked.           |
-- +------------------------------+------------------------------------------+
-- | authserver_expire_session    | (slot: c_int) -> u8 (0=ok, 1=rejected)  |
-- |                              | Transitions Active -> Expired.           |
-- +------------------------------+------------------------------------------+
-- | authserver_lock_session      | (slot: c_int) -> u8 (0=ok, 1=rejected)  |
-- |                              | Transitions Active -> Locked.            |
-- +------------------------------+------------------------------------------+
-- | authserver_failed_attempts   | (slot: c_int) -> u32                     |
-- |                              | Returns failed authentication count.     |
-- +------------------------------+------------------------------------------+
-- | authserver_can_transition    | (from: u8, to: u8) -> u8 (1=yes, 0=no)  |
-- |                              | Stateless: checks session state          |
-- |                              | transition validity.                     |
-- +------------------------------+------------------------------------------+
