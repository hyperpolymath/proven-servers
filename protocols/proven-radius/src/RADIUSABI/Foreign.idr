-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- RADIUSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/radius.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching RADIUSABI.Layout and RADIUSABI.Transitions exactly.

module RADIUSABI.Foreign

import RADIUSABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Radius context.
||| Created by radius_create*(), destroyed by radius_destroy*().
export
data RadiusContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match radius_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (18 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | radius_abi_version                | () -> u32                                   |
-- | radius_session_create             | (auth_method: u8) -> c_int                  |
-- | radius_session_destroy            | (slot: c_int) -> void                       |
-- | radius_session_state              | (slot: c_int) -> u8                         |
-- | radius_get_auth_method            | (slot: c_int) -> u8                         |
-- | radius_get_packet_id              | (slot: c_int) -> u8                         |
-- | radius_get_attribute_count        | (slot: c_int) -> u8                         |
-- | radius_begin_auth                 | (slot: c_int, pkt_id: u8) -> u8             |
-- | radius_accept_auth                | (slot: c_int) -> u8                         |
-- | radius_reject_auth                | (slot: c_int) -> u8                         |
-- | radius_challenge_auth             | (slot: c_int) -> u8                         |
-- | radius_respond_challenge          | (slot: c_int) -> u8                         |
-- | radius_begin_accounting           | (slot: c_int) -> u8                         |
-- | radius_end_accounting             | (slot: c_int) -> u8                         |
-- | radius_end_session                | (slot: c_int) -> u8                         |
-- | radius_can_transition             | (from: u8, to: u8) -> u8                    |
-- | radius_set_secret                 | (slot: c_int, secret_ptr: ptr, secret_le... |
-- | radius_add_attribute              | (slot: c_int, attr_type: u8, value_ptr: ... |
-- +───────────────────────────────────+─────────────────────────────────────────────+
