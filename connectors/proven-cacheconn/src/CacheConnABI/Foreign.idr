-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CacheConnABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares opaque handle types and documents the FFI function contract
-- that the Zig implementation must provide.

module CacheConnABI.Foreign

import CacheConn.Types
import CacheConnABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle types
---------------------------------------------------------------------------

||| Opaque handle to a cache connection.
||| Created by cacheconn_connect(), destroyed by cacheconn_disconnect().
export
data CacheHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-------------------------------+------------------------------------------------+
-- | Function                      | Signature                                      |
-- +-------------------------------+------------------------------------------------+
-- | cacheconn_abi_version         | () -> Bits32                                   |
-- |                               | Must return abiVersion (currently 1).          |
-- +-------------------------------+------------------------------------------------+
-- | cacheconn_connect             | (host: Ptr, port: Bits16, policy: Bits8,       |
-- |                               |  err: Ptr) -> Ptr CacheHandle                  |
-- |                               | policy is an EvictionPolicy tag.               |
-- |                               | Returns NULL on failure, sets *err.            |
-- +-------------------------------+------------------------------------------------+
-- | cacheconn_disconnect          | (h: Ptr CacheHandle) -> Bits8                  |
-- |                               | Returns CacheError tag (0 = success).          |
-- +-------------------------------+------------------------------------------------+
-- | cacheconn_state               | (h: Ptr CacheHandle) -> Bits8                  |
-- |                               | Returns CacheState tag.                        |
-- +-------------------------------+------------------------------------------------+
-- | cacheconn_get                 | (h: Ptr CacheHandle, key: Ptr, key_len: Bits32,|
-- |                               |  val_buf: Ptr, val_cap: Bits32,                |
-- |                               |  val_len: Ptr) -> Bits8                        |
-- |                               | Requires: CanOperate.  Returns CacheResult tag.|
-- +-------------------------------+------------------------------------------------+
-- | cacheconn_set                 | (h: Ptr CacheHandle, key: Ptr, key_len: Bits32,|
-- |                               |  val: Ptr, val_len: Bits32,                    |
-- |                               |  ttl: Bits32) -> Bits8                         |
-- |                               | Requires: CanOperate.  Returns CacheResult tag.|
-- +-------------------------------+------------------------------------------------+
-- | cacheconn_delete              | (h: Ptr CacheHandle, key: Ptr,                 |
-- |                               |  key_len: Bits32) -> Bits8                     |
-- |                               | Requires: CanOperate.  Returns CacheResult tag.|
-- +-------------------------------+------------------------------------------------+
-- | cacheconn_exists              | (h: Ptr CacheHandle, key: Ptr,                 |
-- |                               |  key_len: Bits32) -> Bits8                     |
-- |                               | Requires: CanOperate.  Returns CacheResult tag.|
-- +-------------------------------+------------------------------------------------+
-- | cacheconn_flush               | (h: Ptr CacheHandle) -> Bits8                  |
-- |                               | Requires: CanFlush (Connected only).           |
-- |                               | Returns CacheError tag (0 = success).          |
-- +-------------------------------+------------------------------------------------+
