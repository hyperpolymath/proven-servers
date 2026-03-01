-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- StorageConnABI.Foreign: Foreign function declarations for the C bridge.

module StorageConnABI.Foreign

import StorageConn.Types
import StorageConnABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle types
---------------------------------------------------------------------------

||| Opaque handle to a storage connection.
export
data StorageHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-------------------------------+------------------------------------------------+
-- | Function                      | Signature                                      |
-- +-------------------------------+------------------------------------------------+
-- | storageconn_abi_version       | () -> Bits32                                   |
-- +-------------------------------+------------------------------------------------+
-- | storageconn_connect           | (endpoint: Ptr, port: Bits16,                  |
-- |                               |  tls: Bits8, err: Ptr)                         |
-- |                               |  -> Ptr StorageHandle                          |
-- +-------------------------------+------------------------------------------------+
-- | storageconn_disconnect        | (h: Ptr StorageHandle) -> Bits8                |
-- +-------------------------------+------------------------------------------------+
-- | storageconn_state             | (h: Ptr StorageHandle) -> Bits8                |
-- +-------------------------------+------------------------------------------------+
-- | storageconn_put               | (h: Ptr StorageHandle, bucket: Ptr,            |
-- |                               |  bucket_len: Bits32, key: Ptr,                 |
-- |                               |  key_len: Bits32, body: Ptr,                   |
-- |                               |  body_len: Bits32,                             |
-- |                               |  integrity: Bits8) -> Bits8                    |
-- |                               | Requires: CanOperate.                          |
-- |                               | integrity is an IntegrityCheck tag.            |
-- +-------------------------------+------------------------------------------------+
-- | storageconn_get               | (h: Ptr StorageHandle, bucket: Ptr,            |
-- |                               |  bucket_len: Bits32, key: Ptr,                 |
-- |                               |  key_len: Bits32, buf: Ptr,                    |
-- |                               |  buf_cap: Bits32, buf_len: Ptr) -> Bits8       |
-- |                               | Requires: CanOperate.                          |
-- +-------------------------------+------------------------------------------------+
-- | storageconn_delete            | (h: Ptr StorageHandle, bucket: Ptr,            |
-- |                               |  bucket_len: Bits32, key: Ptr,                 |
-- |                               |  key_len: Bits32) -> Bits8                     |
-- +-------------------------------+------------------------------------------------+
-- | storageconn_head              | (h: Ptr StorageHandle, bucket: Ptr,            |
-- |                               |  bucket_len: Bits32, key: Ptr,                 |
-- |                               |  key_len: Bits32) -> Bits8                     |
-- |                               | Returns ObjectStatus tag.                      |
-- +-------------------------------+------------------------------------------------+
-- | storageconn_reset             | (h: Ptr StorageHandle) -> Bits8                |
-- +-------------------------------+------------------------------------------------+
