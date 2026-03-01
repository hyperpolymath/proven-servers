-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ResolverConnABI.Foreign: Foreign function declarations for the C bridge.

module ResolverConnABI.Foreign

import ResolverConn.Types
import ResolverConnABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle types
---------------------------------------------------------------------------

||| Opaque handle to a DNS resolver instance.
export
data ResolverHandle : Type where [external]

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
-- | resolverconn_abi_version      | () -> Bits32                                   |
-- +-------------------------------+------------------------------------------------+
-- | resolverconn_create           | (upstream: Ptr, port: Bits16,                  |
-- |                               |  err: Ptr) -> Ptr ResolverHandle               |
-- +-------------------------------+------------------------------------------------+
-- | resolverconn_destroy          | (h: Ptr ResolverHandle) -> ()                  |
-- +-------------------------------+------------------------------------------------+
-- | resolverconn_state            | (h: Ptr ResolverHandle) -> Bits8               |
-- +-------------------------------+------------------------------------------------+
-- | resolverconn_resolve          | (h: Ptr ResolverHandle, name: Ptr,             |
-- |                               |  name_len: Bits32, rtype: Bits8,               |
-- |                               |  policy: Bits8, buf: Ptr,                      |
-- |                               |  buf_cap: Bits32, buf_len: Ptr,                |
-- |                               |  dnssec: Ptr) -> Bits8                         |
-- |                               | Requires: CanResolve (Ready state).            |
-- |                               | rtype is a RecordType tag.                     |
-- |                               | policy is a CachePolicy tag.                   |
-- |                               | Sets *dnssec to DNSSECStatus tag.              |
-- |                               | Returns ResolverError tag (0 = success).       |
-- +-------------------------------+------------------------------------------------+
-- | resolverconn_reset            | (h: Ptr ResolverHandle) -> Bits8               |
-- |                               | Failed -> Ready.                               |
-- +-------------------------------+------------------------------------------------+
-- | resolverconn_cache_flush      | (h: Ptr ResolverHandle) -> Bits8               |
-- |                               | Flush the local resolver cache.                |
-- +-------------------------------+------------------------------------------------+
