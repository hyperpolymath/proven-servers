-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LdpABI.Foreign: Foreign function declarations for the LDP C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (LdpResource) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function ldp_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module LdpABI.Foreign

import Ldp.Types
import LdpABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an LDP resource context instance.
||| This type has no Idris2-visible constructors -- values can only be
||| created by the Zig FFI via ldp_create() and destroyed via
||| ldp_destroy().
export
data LdpResource : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's ldp_abi_version() function MUST return
||| this exact value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/ldp.zig) must export.
--
-- +--------------------------------------------------------------------------+
-- | Function                      | Signature                                |
-- +-------------------------------+------------------------------------------+
-- | ldp_abi_version               | () -> u32                                |
-- +-------------------------------+------------------------------------------+
-- | ldp_create                    | (res_type: u8, container_type: u8,       |
-- |                               |  interaction: u8) -> c_int               |
-- +-------------------------------+------------------------------------------+
-- | ldp_destroy                   | (slot: c_int) -> void                    |
-- +-------------------------------+------------------------------------------+
-- | ldp_get_resource_type         | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | ldp_get_container_type        | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | ldp_get_interaction_model     | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | ldp_get_preference            | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | ldp_get_child_count           | (slot: c_int) -> u32                     |
-- +-------------------------------+------------------------------------------+
-- | ldp_get_last_error            | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | ldp_set_preference            | (slot: c_int, pref: u8) -> u8            |
-- +-------------------------------+------------------------------------------+
-- | ldp_add_child                 | (slot: c_int, child_type: u8) -> u8      |
-- +-------------------------------+------------------------------------------+
-- | ldp_check_constraint          | (slot: c_int, op: u8) -> u8              |
-- +-------------------------------+------------------------------------------+
