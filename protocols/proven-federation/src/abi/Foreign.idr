-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FederationABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/federation.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected federation session pool
--   - Activity processing and delivery tracking
--   - Actor registration and trust level management
--   - Delivery queue with status tracking
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching FederationABI.Types exactly.

module FederationABI.Foreign

import FederationABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a federation server session.
||| Created by fed_create(), destroyed by fed_destroy().
export
data FedContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match fed_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (15 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | fed_abi_version               | () -> u32                               |
-- +-------------------------------+-----------------------------------------+
-- | fed_create                    | (domain_ptr: ptr, domain_len: u32)      |
-- |                               |  -> c_int (slot)                        |
-- +-------------------------------+-----------------------------------------+
-- | fed_destroy                   | (slot: c_int) -> void                   |
-- +-------------------------------+-----------------------------------------+
-- | fed_state                     | (slot: c_int) -> u8 (ServerState tag)   |
-- +-------------------------------+-----------------------------------------+
-- | fed_register_actor            | (slot: c_int, actor_type: u8,           |
-- |                               |  name_ptr: ptr, name_len: u32)          |
-- |                               |  -> u8 (0=ok, 1=rejected)               |
-- +-------------------------------+-----------------------------------------+
-- | fed_actor_count               | (slot: c_int) -> u32                    |
-- +-------------------------------+-----------------------------------------+
-- | fed_submit_activity           | (slot: c_int, activity_type: u8,        |
-- |                               |  actor_idx: u32, object_type: u8)       |
-- |                               |  -> u8 (0=ok, 1=rejected)               |
-- +-------------------------------+-----------------------------------------+
-- | fed_activity_count            | (slot: c_int) -> u32                    |
-- +-------------------------------+-----------------------------------------+
-- | fed_begin_delivery            | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | fed_finish_delivery           | (slot: c_int, status: u8)               |
-- |                               |  -> u8 (0=ok, 1=rejected)               |
-- +-------------------------------+-----------------------------------------+
-- | fed_set_trust                 | (slot: c_int, actor_idx: u32,           |
-- |                               |  trust: u8) -> u8 (0=ok, 1=rejected)   |
-- +-------------------------------+-----------------------------------------+
-- | fed_get_trust                 | (slot: c_int, actor_idx: u32)           |
-- |                               |  -> u8 (TrustLevel tag)                 |
-- +-------------------------------+-----------------------------------------+
-- | fed_shutdown                  | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | fed_cleanup                   | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | fed_can_transition            | (from: u8, to: u8) -> u8 (1/0)         |
-- +-------------------------------+-----------------------------------------+
