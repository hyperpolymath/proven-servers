-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CacheABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/cache.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot cache session pool
--   - Per-session eviction policy and replication mode tracking
--   - Command dispatch with type-safe error codes
--   - Hit/miss statistics per session
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching CacheABI.Types exactly.

module CacheABI.Foreign

import CacheABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a cache session.
||| Created by cache_create(), destroyed by cache_destroy().
export
data CacheContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match cache_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +---------------------------+-----------------------------------------------+
-- | Function                  | Signature                                     |
-- +---------------------------+-----------------------------------------------+
-- | cache_abi_version         | () -> u32                                     |
-- |                           | Returns ABI version (must equal abiVersion).  |
-- +---------------------------+-----------------------------------------------+
-- | cache_create              | (eviction: u8, replication: u8,               |
-- |                           |  max_keys: u32) -> c_int (slot)               |
-- |                           | Creates session. Returns -1 on failure        |
-- |                           | (no free slots or invalid tag).               |
-- +---------------------------+-----------------------------------------------+
-- | cache_destroy             | (slot: c_int) -> void                         |
-- |                           | Releases a session slot.                      |
-- +---------------------------+-----------------------------------------------+
-- | cache_execute             | (slot: c_int, cmd: u8) -> u8                  |
-- |                           | Execute a command. Returns 0 on success,      |
-- |                           | or an ErrorCode tag on failure.               |
-- +---------------------------+-----------------------------------------------+
-- | cache_eviction_policy     | (slot: c_int) -> u8 (EvictionPolicy tag)      |
-- |                           | Returns the eviction policy for this session. |
-- +---------------------------+-----------------------------------------------+
-- | cache_replication_mode    | (slot: c_int) -> u8 (ReplicationMode tag)     |
-- |                           | Returns the replication mode for this session.|
-- +---------------------------+-----------------------------------------------+
-- | cache_key_count           | (slot: c_int) -> u32                          |
-- |                           | Returns the number of keys stored.            |
-- +---------------------------+-----------------------------------------------+
-- | cache_max_keys            | (slot: c_int) -> u32                          |
-- |                           | Returns the maximum key capacity.             |
-- +---------------------------+-----------------------------------------------+
-- | cache_hits                | (slot: c_int) -> u32                          |
-- |                           | Returns the cache hit count.                  |
-- +---------------------------+-----------------------------------------------+
-- | cache_misses              | (slot: c_int) -> u32                          |
-- |                           | Returns the cache miss count.                 |
-- +---------------------------+-----------------------------------------------+
-- | cache_is_full             | (slot: c_int) -> u8 (1=yes, 0=no)            |
-- |                           | Whether the cache has reached max_keys.       |
-- +---------------------------+-----------------------------------------------+
-- | cache_set_eviction        | (slot: c_int, policy: u8) -> u8              |
-- |                           | Change eviction policy. Returns 0 on success, |
-- |                           | 1 on invalid tag.                             |
-- +---------------------------+-----------------------------------------------+
