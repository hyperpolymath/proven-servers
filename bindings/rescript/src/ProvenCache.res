// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Cache protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module CacheABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard Redis port.
let redisPort = 6379

/// Standard Memcached port.
let memcachedPort = 11211

// ===========================================================================
// Command (tags 0-12)
// ===========================================================================

/// Standard Redis port.
type command =
  | @as(0) Get
  | @as(1) Set
  | @as(2) Delete
  | @as(3) Exists
  | @as(4) Expire
  | @as(5) Ttl
  | @as(6) Keys
  | @as(7) Flush
  | @as(8) Incr
  | @as(9) Decr
  | @as(10) Append
  | @as(11) Prepend
  | @as(12) Cas

/// Decode from the C-ABI tag value.
let commandFromTag = (tag: int): option<command> =>
  switch tag {
  | 0 => Some(Get)
  | 1 => Some(Set)
  | 2 => Some(Delete)
  | 3 => Some(Exists)
  | 4 => Some(Expire)
  | 5 => Some(Ttl)
  | 6 => Some(Keys)
  | 7 => Some(Flush)
  | 8 => Some(Incr)
  | 9 => Some(Decr)
  | 10 => Some(Append)
  | 11 => Some(Prepend)
  | 12 => Some(Cas)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let commandToTag = (v: command): int =>
  switch v {
  | Get => 0
  | Set => 1
  | Delete => 2
  | Exists => 3
  | Expire => 4
  | Ttl => 5
  | Keys => 6
  | Flush => 7
  | Incr => 8
  | Decr => 9
  | Append => 10
  | Prepend => 11
  | Cas => 12
  }

/// Whether this command modifies stored data.
let commandIsWrite = (v: command): bool =>
  switch v {
  | Get | Exists | Ttl | Keys => false
  | _ => true
  }

/// Whether this command is read-only.
let commandIsRead = (v: command): bool =>
  switch v {
  | Get | Exists | Ttl | Keys => true
  | _ => false
  }

// ===========================================================================
// EvictionPolicy (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type evictionPolicy =
  | @as(0) Lru
  | @as(1) Lfu
  | @as(2) Random
  | @as(3) EvictTtl
  | @as(4) NoEviction

/// Decode from the C-ABI tag value.
let evictionPolicyFromTag = (tag: int): option<evictionPolicy> =>
  switch tag {
  | 0 => Some(Lru)
  | 1 => Some(Lfu)
  | 2 => Some(Random)
  | 3 => Some(EvictTtl)
  | 4 => Some(NoEviction)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let evictionPolicyToTag = (v: evictionPolicy): int =>
  switch v {
  | Lru => 0
  | Lfu => 1
  | Random => 2
  | EvictTtl => 3
  | NoEviction => 4
  }

/// Whether this policy can cause data loss under memory pressure.
let evictionPolicyMayEvict = (v: evictionPolicy): bool =>
  switch v {
  | NoEviction => false
  | _ => true
  }

// ===========================================================================
// DataType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type dataType =
  | @as(0) StringVal
  | @as(1) IntVal
  | @as(2) ListVal
  | @as(3) SetVal
  | @as(4) HashVal

/// Decode from the C-ABI tag value.
let dataTypeFromTag = (tag: int): option<dataType> =>
  switch tag {
  | 0 => Some(StringVal)
  | 1 => Some(IntVal)
  | 2 => Some(ListVal)
  | 3 => Some(SetVal)
  | 4 => Some(HashVal)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let dataTypeToTag = (v: dataType): int =>
  switch v {
  | StringVal => 0
  | IntVal => 1
  | ListVal => 2
  | SetVal => 3
  | HashVal => 4
  }

/// Whether this type is a collection (list, set, or hash).
let dataTypeIsCollection = (v: dataType): bool =>
  switch v {
  | ListVal | SetVal | HashVal => true
  | _ => false
  }

/// Whether this type is a scalar (string or integer).
let dataTypeIsScalar = (v: dataType): bool =>
  switch v {
  | StringVal | IntVal => true
  | _ => false
  }

// ===========================================================================
// ErrorCode (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type errorCode =
  | @as(0) NotFound
  | @as(1) TypeMismatch
  | @as(2) OutOfMemory
  | @as(3) KeyTooLong
  | @as(4) ValueTooLarge
  | @as(5) CasConflict

/// Decode from the C-ABI tag value.
let errorCodeFromTag = (tag: int): option<errorCode> =>
  switch tag {
  | 0 => Some(NotFound)
  | 1 => Some(TypeMismatch)
  | 2 => Some(OutOfMemory)
  | 3 => Some(KeyTooLong)
  | 4 => Some(ValueTooLarge)
  | 5 => Some(CasConflict)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorCodeToTag = (v: errorCode): int =>
  switch v {
  | NotFound => 0
  | TypeMismatch => 1
  | OutOfMemory => 2
  | KeyTooLong => 3
  | ValueTooLarge => 4
  | CasConflict => 5
  }

/// Whether this error is transient (may succeed on retry).
let errorCodeIsTransient = (v: errorCode): bool =>
  switch v {
  | OutOfMemory | CasConflict => true
  | _ => false
  }

/// Whether this error indicates a client programming error.
let errorCodeIsClientError = (v: errorCode): bool =>
  switch v {
  | TypeMismatch | KeyTooLong | ValueTooLarge => true
  | _ => false
  }

// ===========================================================================
// ReplicationMode (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type replicationMode =
  | @as(0) None
  | @as(1) Primary
  | @as(2) Replica
  | @as(3) Sentinel

/// Decode from the C-ABI tag value.
let replicationModeFromTag = (tag: int): option<replicationMode> =>
  switch tag {
  | 0 => Some(None)
  | 1 => Some(Primary)
  | 2 => Some(Replica)
  | 3 => Some(Sentinel)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let replicationModeToTag = (v: replicationMode): int =>
  switch v {
  | None => 0
  | Primary => 1
  | Replica => 2
  | Sentinel => 3
  }

/// Whether this node accepts write operations.
let replicationModeAcceptsWrites = (v: replicationMode): bool =>
  switch v {
  | None | Primary => true
  | _ => false
  }

/// Whether this is a data-serving node (not sentinel).
let replicationModeServesData = (v: replicationMode): bool =>
  switch v {
  | Sentinel => false
  | _ => true
  }

