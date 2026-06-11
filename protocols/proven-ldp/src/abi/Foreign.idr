-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- LdpABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ldp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching LdpABI.Types exactly.

module LdpABI.Foreign

import LdpABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Ldp context.
||| Created by ldp_create*(), destroyed by ldp_destroy*().
export
data LdpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ldp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (12 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | ldp_abi_version                   | () -> u32                                   |
-- | ldp_create                        | (res_type: u8, container_type: u8, inter... |
-- | ldp_destroy                       | (slot: c_int) -> void                       |
-- | ldp_get_resource_type             | (slot: c_int) -> u8                         |
-- | ldp_get_container_type            | (slot: c_int) -> u8                         |
-- | ldp_get_interaction_model         | (slot: c_int) -> u8                         |
-- | ldp_get_preference                | (slot: c_int) -> u8                         |
-- | ldp_get_child_count               | (slot: c_int) -> u32                        |
-- | ldp_get_last_error                | (slot: c_int) -> u8                         |
-- | ldp_set_preference                | (slot: c_int, pref: u8) -> u8               |
-- | ldp_add_child                     | (slot: c_int, child_type: u8) -> u8         |
-- | ldp_check_constraint              | (slot: c_int, op: u8) -> u8                 |
-- +───────────────────────────────────+─────────────────────────────────────────────+
