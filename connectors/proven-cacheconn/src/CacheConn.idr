-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CacheConn: Top-level module for proven-cacheconn.
-- Re-exports CacheConn.Types and provides cache-related constants.

module CacheConn

import public CacheConn.Types

%default total

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------

||| Default time-to-live for cache entries, in seconds (1 hour).
public export
defaultTTL : Nat
defaultTTL = 3600

||| Maximum key length in bytes.
public export
maxKeyLength : Nat
maxKeyLength = 512

||| Maximum value size in bytes (1 MiB).
public export
maxValueSize : Nat
maxValueSize = 1048576
