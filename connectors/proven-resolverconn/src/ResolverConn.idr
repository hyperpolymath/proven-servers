-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ResolverConn: Top-level module for proven-resolverconn.
-- Re-exports ResolverConn.Types and provides DNS-resolver-related constants.

module ResolverConn

import public ResolverConn.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Default query timeout in seconds.
public export
defaultTimeout : Nat
defaultTimeout = 5

||| Maximum number of retry attempts for a failed query.
public export
maxRetries : Nat
maxRetries = 3

||| Maximum number of entries in the resolver cache.
public export
maxCacheEntries : Nat
maxCacheEntries = 10000

||| Minimum TTL in seconds that the resolver will honour.
||| Prevents excessively low TTLs from causing cache thrashing.
public export
minTTL : Nat
minTTL = 60
