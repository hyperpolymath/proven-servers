-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- RADIUSABI.Foreign: Foreign function declarations for the RADIUS C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (SessionHandle) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function radius_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module RADIUSABI.Foreign

import RADIUS.Types
import RADIUSABI.Layout
import RADIUSABI.Transitions

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a RADIUS session instance.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via radius_session_create() and destroyed
||| via radius_session_destroy().
export
data SessionHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's radius_abi_version() function MUST return
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
-- Zig implementation (ffi/zig/src/radius.zig) must export.
--
-- +-----------------------------------------------------------------------+
-- | Function                 | Signature                                  |
-- +--------------------------+--------------------------------------------+
-- | radius_abi_version       | () -> Bits32                               |
-- |                          | Must return abiVersion (currently 1).      |
-- +--------------------------+--------------------------------------------+
-- | radius_session_create    | (auth_method: u8) -> c_int                 |
-- |                          | Creates a new session in Idle state.       |
-- |                          | auth_method is an AuthMethod tag.          |
-- |                          | Returns slot index (0-63) or -1 on error.  |
-- +--------------------------+--------------------------------------------+
-- | radius_session_destroy   | (slot: c_int) -> void                      |
-- |                          | Frees the session slot. Safe with any      |
-- |                          | slot index (invalid slots are no-ops).     |
-- +--------------------------+--------------------------------------------+
-- | radius_session_state     | (slot: c_int) -> u8                        |
-- |                          | Returns the SessionState tag for the slot. |
-- |                          | Returns Idle (0) for invalid/inactive.     |
-- +--------------------------+--------------------------------------------+
-- | radius_begin_auth        | (slot: c_int, pkt_id: u8) -> u8            |
-- |                          | Transition: Idle -> Authenticating.        |
-- |                          | pkt_id = RADIUS Identifier field.          |
-- |                          | Returns RadiusResult tag.                  |
-- +--------------------------+--------------------------------------------+
-- | radius_accept_auth       | (slot: c_int) -> u8                        |
-- |                          | Transition: Authenticating -> Authorized.  |
-- |                          | Returns RadiusResult tag.                  |
-- +--------------------------+--------------------------------------------+
-- | radius_reject_auth       | (slot: c_int) -> u8                        |
-- |                          | Transition: Authenticating -> Rejected.    |
-- |                          | Returns RadiusResult tag.                  |
-- +--------------------------+--------------------------------------------+
-- | radius_challenge_auth    | (slot: c_int) -> u8                        |
-- |                          | Transition: Authenticating -> Challenged.  |
-- |                          | Returns RadiusResult tag.                  |
-- +--------------------------+--------------------------------------------+
-- | radius_respond_challenge | (slot: c_int) -> u8                        |
-- |                          | Transition: Challenged -> Authenticating.  |
-- |                          | Returns RadiusResult tag.                  |
-- +--------------------------+--------------------------------------------+
-- | radius_begin_accounting  | (slot: c_int) -> u8                        |
-- |                          | Transition: Authorized -> Accounting.      |
-- |                          | Returns RadiusResult tag.                  |
-- +--------------------------+--------------------------------------------+
-- | radius_end_accounting    | (slot: c_int) -> u8                        |
-- |                          | Transition: Accounting -> Complete.        |
-- |                          | Returns RadiusResult tag.                  |
-- +--------------------------+--------------------------------------------+
-- | radius_end_session       | (slot: c_int) -> u8                        |
-- |                          | Transition: Authorized -> Complete.        |
-- |                          | Or: Complete|Rejected|Challenged -> Idle.  |
-- |                          | Returns RadiusResult tag.                  |
-- +--------------------------+--------------------------------------------+
-- | radius_can_transition    | (from: u8, to: u8) -> u8                   |
-- |                          | Returns 1 if the transition is valid,      |
-- |                          | 0 if not. Stateless validation.            |
-- +--------------------------+--------------------------------------------+
-- | radius_set_secret        | (slot: c_int, secret_ptr: [*]const u8,     |
-- |                          |  secret_len: u32) -> u8                    |
-- |                          | Sets the shared secret for a session.      |
-- |                          | Returns RadiusResult tag.                  |
-- +--------------------------+--------------------------------------------+
-- | radius_add_attribute     | (slot: c_int, attr_type: u8,               |
-- |                          |  value_ptr: [*]const u8,                   |
-- |                          |  value_len: u8) -> u8                      |
-- |                          | Adds an attribute to the session.          |
-- |                          | Returns RadiusResult tag.                  |
-- +--------------------------+--------------------------------------------+
-- | radius_get_attribute_count | (slot: c_int) -> u8                      |
-- |                          | Returns the number of attributes stored.   |
-- +--------------------------+--------------------------------------------+
-- | radius_get_auth_method   | (slot: c_int) -> u8                        |
-- |                          | Returns the AuthMethod tag for the session.|
-- +--------------------------+--------------------------------------------+
-- | radius_get_packet_id     | (slot: c_int) -> u8                        |
-- |                          | Returns the RADIUS Identifier field.       |
-- +--------------------------+--------------------------------------------+
