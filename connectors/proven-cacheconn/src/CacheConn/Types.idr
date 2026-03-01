-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CacheConn.Types: Core type definitions for cache connector interfaces.
-- Closed sum types representing cache operations, result categories,
-- eviction policies, connection states, and error categories.  These
-- types enforce that any cache backend connector is type-safe at the
-- boundary.

module CacheConn.Types

%default total

---------------------------------------------------------------------------
-- CacheOp — the operation being requested of the cache.
---------------------------------------------------------------------------

||| Operations that can be performed against a cache backend.
public export
data CacheOp : Type where
  ||| Retrieve a value by key.
  Get       : CacheOp
  ||| Store a value under a key.
  Set       : CacheOp
  ||| Remove a key and its associated value.
  Delete    : CacheOp
  ||| Check whether a key exists without retrieving the value.
  Exists    : CacheOp
  ||| Set or update the TTL on an existing key.
  Expire    : CacheOp
  ||| Atomically increment a numeric value.
  Increment : CacheOp
  ||| Atomically decrement a numeric value.
  Decrement : CacheOp
  ||| Remove all entries from the cache.
  Flush     : CacheOp

public export
Show CacheOp where
  show Get       = "Get"
  show Set       = "Set"
  show Delete    = "Delete"
  show Exists    = "Exists"
  show Expire    = "Expire"
  show Increment = "Increment"
  show Decrement = "Decrement"
  show Flush     = "Flush"

---------------------------------------------------------------------------
-- CacheResult — the outcome of a cache operation.
---------------------------------------------------------------------------

||| Result categories returned after executing a cache operation.
public export
data CacheResult : Type where
  ||| The key was found and a value was returned.
  Hit     : CacheResult
  ||| The key was not found in the cache.
  Miss    : CacheResult
  ||| A value was successfully stored.
  Stored  : CacheResult
  ||| A key was successfully deleted.
  Deleted : CacheResult
  ||| A key's TTL has expired and the entry was evicted.
  Expired : CacheResult
  ||| The operation failed with an error.
  Error   : CacheResult

public export
Show CacheResult where
  show Hit     = "Hit"
  show Miss    = "Miss"
  show Stored  = "Stored"
  show Deleted = "Deleted"
  show Expired = "Expired"
  show Error   = "Error"

---------------------------------------------------------------------------
-- EvictionPolicy — how the cache decides what to evict.
---------------------------------------------------------------------------

||| The eviction strategy used when the cache reaches capacity.
public export
data EvictionPolicy : Type where
  ||| Least Recently Used — evict the entry accessed longest ago.
  LRU        : EvictionPolicy
  ||| Least Frequently Used — evict the entry accessed fewest times.
  LFU        : EvictionPolicy
  ||| First In, First Out — evict the oldest entry by insertion time.
  FIFO       : EvictionPolicy
  ||| Evict entries based solely on their TTL expiry.
  TTLBased   : EvictionPolicy
  ||| Evict a random entry.
  Random     : EvictionPolicy
  ||| Never evict — reject writes when at capacity.
  NoEviction : EvictionPolicy

public export
Show EvictionPolicy where
  show LRU        = "LRU"
  show LFU        = "LFU"
  show FIFO       = "FIFO"
  show TTLBased   = "TTLBased"
  show Random     = "Random"
  show NoEviction = "NoEviction"

---------------------------------------------------------------------------
-- CacheState — the state of a cache connection.
---------------------------------------------------------------------------

||| The lifecycle state of a cache connection.
public export
data CacheState : Type where
  ||| No connection established to the cache backend.
  Disconnected : CacheState
  ||| Connection established and operational.
  Connected    : CacheState
  ||| Connection is up but the backend is partially impaired.
  Degraded     : CacheState
  ||| Connection has entered a failed state.
  Failed       : CacheState

public export
Show CacheState where
  show Disconnected = "Disconnected"
  show Connected    = "Connected"
  show Degraded     = "Degraded"
  show Failed       = "Failed"

---------------------------------------------------------------------------
-- CacheError — cache operation error categories.
---------------------------------------------------------------------------

||| Error categories that a cache connector can report.
public export
data CacheError : Type where
  ||| The connection to the cache backend was lost.
  ConnectionLost     : CacheError
  ||| The requested key does not exist.
  KeyNotFound        : CacheError
  ||| The value exceeds the maximum allowed size.
  ValueTooLarge      : CacheError
  ||| The cache has reached its capacity limit.
  CapacityExceeded   : CacheError
  ||| The value could not be serialised or deserialised.
  SerializationError : CacheError
  ||| The operation exceeded the configured timeout.
  Timeout            : CacheError

public export
Show CacheError where
  show ConnectionLost     = "ConnectionLost"
  show KeyNotFound        = "KeyNotFound"
  show ValueTooLarge      = "ValueTooLarge"
  show CapacityExceeded   = "CapacityExceeded"
  show SerializationError = "SerializationError"
  show Timeout            = "Timeout"
