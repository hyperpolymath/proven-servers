-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AuthConnABI.Foreign: Foreign function declarations for the C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle types (SessionHandle, TokenHandle) that cannot be
--      inspected or forged from Idris2 code — they exist only as pointers
--      managed by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function authconn_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module AuthConnABI.Foreign

import AuthConn.Types
import AuthConnABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle types
---------------------------------------------------------------------------

||| Opaque handle to an authentication session.
||| Created by authconn_create_session(), destroyed by authconn_destroy_session().
||| Tracks the session lifecycle state machine internally.
export
data SessionHandle : Type where [external]

||| Opaque handle to an authentication token.
||| Created by authconn_issue_token(), revoked by authconn_revoke_token().
||| Token material is never exposed to Idris2 code — only the handle
||| and its lifecycle state are visible.
export
data TokenHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's authconn_abi_version() function MUST return
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
-- Zig implementation (ffi/zig/src/authconn.zig) must export.
--
-- +---------------------------------+-----------------------------------------------+
-- | Function                        | Signature                                     |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_abi_version            | () -> Bits32                                  |
-- |                                 | Must return abiVersion (currently 1).         |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_create_session         | (method: Bits8, err: Ptr) -> Ptr SessionHandle|
-- |                                 | method is an AuthMethod tag.                  |
-- |                                 | Returns NULL on failure, sets *err.           |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_destroy_session        | (h: Ptr SessionHandle) -> ()                  |
-- |                                 | Frees a session handle.                       |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_session_state          | (h: Ptr SessionHandle) -> Bits8               |
-- |                                 | Returns AuthState tag for session h.          |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_authenticate           | (h: Ptr SessionHandle,                        |
-- |                                 |  cred: Ptr, cred_len: Bits32,                 |
-- |                                 |  cred_type: Bits8) -> Bits8                   |
-- |                                 | cred_type is a CredentialType tag.            |
-- |                                 | Requires: CanAuthenticate state.              |
-- |                                 | Transitions: Unauth -> Authenticated|         |
-- |                                 |              Challenging|Locked.              |
-- |                                 | Returns AuthError tag (0 = success).          |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_challenge_respond      | (h: Ptr SessionHandle,                        |
-- |                                 |  response: Ptr, resp_len: Bits32) -> Bits8    |
-- |                                 | Transitions: Challenging -> Authenticated|    |
-- |                                 |              Unauthenticated|Locked.          |
-- |                                 | Returns AuthError tag (0 = success).          |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_revoke                 | (h: Ptr SessionHandle) -> Bits8               |
-- |                                 | Transitions: Authenticated -> Revoked.        |
-- |                                 | Returns AuthError tag (0 = success).          |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_reset                  | (h: Ptr SessionHandle) -> Bits8               |
-- |                                 | Transitions: Expired|Revoked|Locked ->        |
-- |                                 |              Unauthenticated.                 |
-- |                                 | Returns AuthError tag (0 = success).          |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_issue_token            | (h: Ptr SessionHandle,                        |
-- |                                 |  err: Ptr) -> Ptr TokenHandle                 |
-- |                                 | Requires: CanAccessResource state.            |
-- |                                 | Returns NULL on failure, sets *err.           |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_token_state            | (t: Ptr TokenHandle) -> Bits8                 |
-- |                                 | Returns TokenState tag.                       |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_refresh_token          | (t: Ptr TokenHandle, err: Ptr)                |
-- |                                 |  -> Ptr TokenHandle                           |
-- |                                 | Returns new token handle, old becomes invalid.|
-- |                                 | Returns NULL on failure, sets *err.           |
-- +---------------------------------+-----------------------------------------------+
-- | authconn_revoke_token           | (t: Ptr TokenHandle) -> ()                    |
-- |                                 | Revokes and frees a token handle.             |
-- +---------------------------------+-----------------------------------------------+
