// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! Cache protocol types for the proven-servers ABI.
//!
//! Covers Redis-compatible and Memcached-compatible cache server types.
//! Mirrors the Idris2 module `CacheABI.Types` and its type definitions:
//! - `Command`         — cache commands (13 constructors, tags 0-12)
//! - `EvictionPolicy`  — eviction strategies (5 constructors, tags 0-4)
//! - `DataType`        — stored value types (5 constructors, tags 0-4)
//! - `ErrorCode`       — cache error codes (6 constructors, tags 0-5)
//! - `ReplicationMode` — replication topology roles (4 constructors, tags 0-3)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Cache Constants
// ===========================================================================

/// Standard Redis port.
pub const REDIS_PORT: u16 = 6379;

/// Standard Memcached port.
pub const MEMCACHED_PORT: u16 = 11211;

// ===========================================================================
// Command (tags 0-12)
// ===========================================================================

/// Cache server commands.
///
/// Matches `Command` in `CacheABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Command {
    /// Retrieve a value by key (tag 0).
    Get = 0,
    /// Store a key-value pair (tag 1).
    Set = 1,
    /// Remove a key (tag 2).
    Delete = 2,
    /// Check if a key exists (tag 3).
    Exists = 3,
    /// Set TTL on a key (tag 4).
    Expire = 4,
    /// Get remaining TTL for a key (tag 5).
    Ttl = 5,
    /// List keys matching a pattern (tag 6).
    Keys = 6,
    /// Remove all keys (tag 7).
    Flush = 7,
    /// Atomically increment a numeric value (tag 8).
    Incr = 8,
    /// Atomically decrement a numeric value (tag 9).
    Decr = 9,
    /// Append data to a string value (tag 10).
    Append = 10,
    /// Prepend data to a string value (tag 11).
    Prepend = 11,
    /// Compare-and-swap (optimistic locking) (tag 12).
    Cas = 12,
}

impl Command {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Get),
            1 => Some(Self::Set),
            2 => Some(Self::Delete),
            3 => Some(Self::Exists),
            4 => Some(Self::Expire),
            5 => Some(Self::Ttl),
            6 => Some(Self::Keys),
            7 => Some(Self::Flush),
            8 => Some(Self::Incr),
            9 => Some(Self::Decr),
            10 => Some(Self::Append),
            11 => Some(Self::Prepend),
            12 => Some(Self::Cas),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this command modifies stored data.
    pub fn is_write(self) -> bool {
        !matches!(self, Self::Get | Self::Exists | Self::Ttl | Self::Keys)
    }

    /// Whether this command is read-only.
    pub fn is_read(self) -> bool {
        matches!(self, Self::Get | Self::Exists | Self::Ttl | Self::Keys)
    }

    /// All supported commands.
    pub const ALL: [Command; 13] = [
        Self::Get, Self::Set, Self::Delete, Self::Exists, Self::Expire,
        Self::Ttl, Self::Keys, Self::Flush, Self::Incr, Self::Decr,
        Self::Append, Self::Prepend, Self::Cas,
    ];
}

impl fmt::Display for Command {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// EvictionPolicy (tags 0-4)
// ===========================================================================

/// Cache eviction policy strategies.
///
/// Matches `EvictionPolicy` in `CacheABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum EvictionPolicy {
    /// Least Recently Used (tag 0).
    Lru = 0,
    /// Least Frequently Used (tag 1).
    Lfu = 1,
    /// Random eviction (tag 2).
    Random = 2,
    /// Evict keys with expiry (TTL-based) (tag 3).
    EvictTtl = 3,
    /// No eviction — return errors when memory is full (tag 4).
    NoEviction = 4,
}

impl EvictionPolicy {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Lru),
            1 => Some(Self::Lfu),
            2 => Some(Self::Random),
            3 => Some(Self::EvictTtl),
            4 => Some(Self::NoEviction),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this policy can cause data loss under memory pressure.
    pub fn may_evict(self) -> bool {
        !matches!(self, Self::NoEviction)
    }
}

impl fmt::Display for EvictionPolicy {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DataType (tags 0-4)
// ===========================================================================

/// Cache stored value types.
///
/// Matches `DataType` in `CacheABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DataType {
    /// String value (tag 0).
    StringVal = 0,
    /// Integer value (tag 1).
    IntVal = 1,
    /// List (ordered collection) (tag 2).
    ListVal = 2,
    /// Set (unordered unique collection) (tag 3).
    SetVal = 3,
    /// Hash map (field-value pairs) (tag 4).
    HashVal = 4,
}

impl DataType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::StringVal),
            1 => Some(Self::IntVal),
            2 => Some(Self::ListVal),
            3 => Some(Self::SetVal),
            4 => Some(Self::HashVal),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this type is a collection (list, set, or hash).
    pub fn is_collection(self) -> bool {
        matches!(self, Self::ListVal | Self::SetVal | Self::HashVal)
    }

    /// Whether this type is a scalar (string or integer).
    pub fn is_scalar(self) -> bool {
        matches!(self, Self::StringVal | Self::IntVal)
    }
}

impl fmt::Display for DataType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorCode (tags 0-5)
// ===========================================================================

/// Cache error codes.
///
/// Matches `ErrorCode` in `CacheABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCode {
    /// Key not found in cache (tag 0).
    NotFound = 0,
    /// Operation attempted on wrong data type (tag 1).
    TypeMismatch = 1,
    /// Cache server is out of memory (tag 2).
    OutOfMemory = 2,
    /// Key exceeds maximum length (tag 3).
    KeyTooLong = 3,
    /// Value exceeds maximum size (tag 4).
    ValueTooLarge = 4,
    /// Compare-and-swap version conflict (tag 5).
    CasConflict = 5,
}

impl ErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NotFound),
            1 => Some(Self::TypeMismatch),
            2 => Some(Self::OutOfMemory),
            3 => Some(Self::KeyTooLong),
            4 => Some(Self::ValueTooLarge),
            5 => Some(Self::CasConflict),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this error is transient (may succeed on retry).
    pub fn is_transient(self) -> bool {
        matches!(self, Self::OutOfMemory | Self::CasConflict)
    }

    /// Whether this error indicates a client programming error.
    pub fn is_client_error(self) -> bool {
        matches!(self, Self::TypeMismatch | Self::KeyTooLong | Self::ValueTooLarge)
    }
}

impl fmt::Display for ErrorCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for ErrorCode {}

// ===========================================================================
// ReplicationMode (tags 0-3)
// ===========================================================================

/// Cache replication topology roles.
///
/// Matches `ReplicationMode` in `CacheABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ReplicationMode {
    /// Standalone, no replication (tag 0).
    None = 0,
    /// Primary (leader) node accepting writes (tag 1).
    Primary = 1,
    /// Replica (follower) node serving reads (tag 2).
    Replica = 2,
    /// Sentinel node monitoring cluster health (tag 3).
    Sentinel = 3,
}

impl ReplicationMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::None),
            1 => Some(Self::Primary),
            2 => Some(Self::Replica),
            3 => Some(Self::Sentinel),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this node accepts write operations.
    pub fn accepts_writes(self) -> bool {
        matches!(self, Self::None | Self::Primary)
    }

    /// Whether this is a data-serving node (not sentinel).
    pub fn serves_data(self) -> bool {
        !matches!(self, Self::Sentinel)
    }
}

impl fmt::Display for ReplicationMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn command_roundtrip() {
        for cmd in Command::ALL {
            let tag = cmd.to_tag();
            let decoded = Command::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, cmd);
        }
        assert!(Command::from_tag(13).is_none());
    }

    #[test]
    fn command_classification() {
        assert!(Command::Get.is_read());
        assert!(Command::Exists.is_read());
        assert!(!Command::Set.is_read());
        assert!(Command::Set.is_write());
        assert!(Command::Delete.is_write());
        assert!(Command::Cas.is_write());
        assert!(!Command::Get.is_write());
    }

    #[test]
    fn eviction_policy_roundtrip() {
        for tag in 0u8..=4 {
            let ep = EvictionPolicy::from_tag(tag).expect("valid tag");
            assert_eq!(ep.to_tag(), tag);
        }
        assert!(EvictionPolicy::from_tag(5).is_none());
    }

    #[test]
    fn eviction_policy_eviction() {
        assert!(EvictionPolicy::Lru.may_evict());
        assert!(EvictionPolicy::Lfu.may_evict());
        assert!(EvictionPolicy::Random.may_evict());
        assert!(EvictionPolicy::EvictTtl.may_evict());
        assert!(!EvictionPolicy::NoEviction.may_evict());
    }

    #[test]
    fn data_type_roundtrip() {
        for tag in 0u8..=4 {
            let dt = DataType::from_tag(tag).expect("valid tag");
            assert_eq!(dt.to_tag(), tag);
        }
        assert!(DataType::from_tag(5).is_none());
    }

    #[test]
    fn data_type_classification() {
        assert!(DataType::StringVal.is_scalar());
        assert!(DataType::IntVal.is_scalar());
        assert!(!DataType::ListVal.is_scalar());
        assert!(DataType::ListVal.is_collection());
        assert!(DataType::SetVal.is_collection());
        assert!(DataType::HashVal.is_collection());
        assert!(!DataType::StringVal.is_collection());
    }

    #[test]
    fn error_code_roundtrip() {
        for tag in 0u8..=5 {
            let ec = ErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(ec.to_tag(), tag);
        }
        assert!(ErrorCode::from_tag(6).is_none());
    }

    #[test]
    fn error_code_classification() {
        assert!(ErrorCode::OutOfMemory.is_transient());
        assert!(ErrorCode::CasConflict.is_transient());
        assert!(!ErrorCode::NotFound.is_transient());
        assert!(ErrorCode::TypeMismatch.is_client_error());
        assert!(ErrorCode::KeyTooLong.is_client_error());
        assert!(!ErrorCode::NotFound.is_client_error());
    }

    #[test]
    fn replication_mode_roundtrip() {
        for tag in 0u8..=3 {
            let rm = ReplicationMode::from_tag(tag).expect("valid tag");
            assert_eq!(rm.to_tag(), tag);
        }
        assert!(ReplicationMode::from_tag(4).is_none());
    }

    #[test]
    fn replication_mode_writes() {
        assert!(ReplicationMode::None.accepts_writes());
        assert!(ReplicationMode::Primary.accepts_writes());
        assert!(!ReplicationMode::Replica.accepts_writes());
        assert!(!ReplicationMode::Sentinel.accepts_writes());
    }

    #[test]
    fn replication_mode_data() {
        assert!(ReplicationMode::None.serves_data());
        assert!(ReplicationMode::Primary.serves_data());
        assert!(ReplicationMode::Replica.serves_data());
        assert!(!ReplicationMode::Sentinel.serves_data());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(REDIS_PORT, 6379);
        assert_eq!(MEMCACHED_PORT, 11211);
    }
}
