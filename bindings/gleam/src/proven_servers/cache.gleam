//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Cache (Redis/Memcached) protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `CacheABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Cache (Redis/Memcached) Constants
// ===========================================================================

/// Redis Port constant.
pub const redis_port = 6379

/// Memcached Port constant.
pub const memcached_port = 11211

// ===========================================================================
// Command
// ===========================================================================

/// Cache server commands.
/// 
/// Matches `Command` in `CacheABI.Types`.
pub type Command {
  /// Retrieve a value by key (tag 0).
  Get
  /// Store a key-value pair (tag 1).
  Set
  /// Remove a key (tag 2).
  Delete
  /// Check if a key exists (tag 3).
  Exists
  /// Set TTL on a key (tag 4).
  Expire
  /// Get remaining TTL for a key (tag 5).
  Ttl
  /// List keys matching a pattern (tag 6).
  Keys
  /// Remove all keys (tag 7).
  Flush
  /// Atomically increment a numeric value (tag 8).
  Incr
  /// Atomically decrement a numeric value (tag 9).
  Decr
  /// Append data to a string value (tag 10).
  Append
  /// Prepend data to a string value (tag 11).
  Prepend
  /// Compare-and-swap (optimistic locking) (tag 12).
  Cas
}

/// Convert a `Command` to its C-ABI tag value.
pub fn command_to_int(value: Command) -> Int {
  case value {
    Get -> 0
    Set -> 1
    Delete -> 2
    Exists -> 3
    Expire -> 4
    Ttl -> 5
    Keys -> 6
    Flush -> 7
    Incr -> 8
    Decr -> 9
    Append -> 10
    Prepend -> 11
    Cas -> 12
  }
}

/// Decode from a C-ABI tag value.
pub fn command_from_int(tag: Int) -> Result(Command, Nil) {
  case tag {
    0 -> Ok(Get)
    1 -> Ok(Set)
    2 -> Ok(Delete)
    3 -> Ok(Exists)
    4 -> Ok(Expire)
    5 -> Ok(Ttl)
    6 -> Ok(Keys)
    7 -> Ok(Flush)
    8 -> Ok(Incr)
    9 -> Ok(Decr)
    10 -> Ok(Append)
    11 -> Ok(Prepend)
    12 -> Ok(Cas)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// EvictionPolicy
// ===========================================================================

/// Cache eviction policy strategies.
/// 
/// Matches `EvictionPolicy` in `CacheABI.Types`.
pub type EvictionPolicy {
  /// Least Recently Used (tag 0).
  Lru
  /// Least Frequently Used (tag 1).
  Lfu
  /// Random eviction (tag 2).
  Random
  /// Evict keys with expiry (TTL-based) (tag 3).
  EvictTtl
  /// No eviction — return errors when memory is full (tag 4).
  NoEviction
}

/// Convert a `EvictionPolicy` to its C-ABI tag value.
pub fn eviction_policy_to_int(value: EvictionPolicy) -> Int {
  case value {
    Lru -> 0
    Lfu -> 1
    Random -> 2
    EvictTtl -> 3
    NoEviction -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn eviction_policy_from_int(tag: Int) -> Result(EvictionPolicy, Nil) {
  case tag {
    0 -> Ok(Lru)
    1 -> Ok(Lfu)
    2 -> Ok(Random)
    3 -> Ok(EvictTtl)
    4 -> Ok(NoEviction)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DataType
// ===========================================================================

/// Cache stored value types.
/// 
/// Matches `DataType` in `CacheABI.Types`.
pub type DataType {
  /// String value (tag 0).
  StringVal
  /// Integer value (tag 1).
  IntVal
  /// List (ordered collection) (tag 2).
  ListVal
  /// Set (unordered unique collection) (tag 3).
  SetVal
  /// Hash map (field-value pairs) (tag 4).
  HashVal
}

/// Convert a `DataType` to its C-ABI tag value.
pub fn data_type_to_int(value: DataType) -> Int {
  case value {
    StringVal -> 0
    IntVal -> 1
    ListVal -> 2
    SetVal -> 3
    HashVal -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn data_type_from_int(tag: Int) -> Result(DataType, Nil) {
  case tag {
    0 -> Ok(StringVal)
    1 -> Ok(IntVal)
    2 -> Ok(ListVal)
    3 -> Ok(SetVal)
    4 -> Ok(HashVal)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorCode
// ===========================================================================

/// Cache error codes.
/// 
/// Matches `ErrorCode` in `CacheABI.Types`.
pub type ErrorCode {
  /// Key not found in cache (tag 0).
  NotFound
  /// Operation attempted on wrong data type (tag 1).
  TypeMismatch
  /// Cache server is out of memory (tag 2).
  OutOfMemory
  /// Key exceeds maximum length (tag 3).
  KeyTooLong
  /// Value exceeds maximum size (tag 4).
  ValueTooLarge
  /// Compare-and-swap version conflict (tag 5).
  CasConflict
}

/// Convert a `ErrorCode` to its C-ABI tag value.
pub fn error_code_to_int(value: ErrorCode) -> Int {
  case value {
    NotFound -> 0
    TypeMismatch -> 1
    OutOfMemory -> 2
    KeyTooLong -> 3
    ValueTooLarge -> 4
    CasConflict -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn error_code_from_int(tag: Int) -> Result(ErrorCode, Nil) {
  case tag {
    0 -> Ok(NotFound)
    1 -> Ok(TypeMismatch)
    2 -> Ok(OutOfMemory)
    3 -> Ok(KeyTooLong)
    4 -> Ok(ValueTooLarge)
    5 -> Ok(CasConflict)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ReplicationMode
// ===========================================================================

/// Cache replication topology roles.
/// 
/// Matches `ReplicationMode` in `CacheABI.Types`.
pub type ReplicationMode {
  /// Standalone, no replication (tag 0).
  ReplicationModeNone
  /// Primary (leader) node accepting writes (tag 1).
  Primary
  /// Replica (follower) node serving reads (tag 2).
  Replica
  /// Sentinel node monitoring cluster health (tag 3).
  Sentinel
}

/// Convert a `ReplicationMode` to its C-ABI tag value.
pub fn replication_mode_to_int(value: ReplicationMode) -> Int {
  case value {
    ReplicationModeNone -> 0
    Primary -> 1
    Replica -> 2
    Sentinel -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn replication_mode_from_int(tag: Int) -> Result(ReplicationMode, Nil) {
  case tag {
    0 -> Ok(ReplicationModeNone)
    1 -> Ok(Primary)
    2 -> Ok(Replica)
    3 -> Ok(Sentinel)
    _ -> Error(Nil)
  }
}

