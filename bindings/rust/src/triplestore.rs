// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Triple Store types for the proven-servers ABI.
//!
//! Formally verified RDF triple store types.
//! Mirrors the Idris2 module `TriplestoreABI.Types`.
//!
//! - `Statement` -- RDF statement types.
//! - `IndexOrder` -- Triple index orderings.
//! - `StorageBackend` -- Triple store storage backends.
//! - `ImportFormat` -- RDF import formats.
//! - `TransactionIsolation` -- Triple store transaction isolation.
//! - `StoreState` -- Triple store states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Statement (tags 0-1)
// ===========================================================================

/// RDF statement types.
///
/// Matches `Statement` in `TriplestoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Statement {
    /// Triple (tag 0).
    Triple = 0,
    /// Quad (tag 1).
    Quad = 1,
}

impl Statement {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Triple),
            1 => Some(Self::Quad),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Statement; 2] = [
        Self::Triple, Self::Quad,
    ];
}

impl fmt::Display for Statement {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// IndexOrder (tags 0-5)
// ===========================================================================

/// Triple index orderings.
///
/// Matches `IndexOrder` in `TriplestoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum IndexOrder {
    /// SPO (tag 0).
    Spo = 0,
    /// POS (tag 1).
    Pos = 1,
    /// OSP (tag 2).
    Osp = 2,
    /// GSPO (tag 3).
    Gspo = 3,
    /// GPOS (tag 4).
    Gpos = 4,
    /// GOSP (tag 5).
    Gosp = 5,
}

impl IndexOrder {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Spo),
            1 => Some(Self::Pos),
            2 => Some(Self::Osp),
            3 => Some(Self::Gspo),
            4 => Some(Self::Gpos),
            5 => Some(Self::Gosp),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [IndexOrder; 6] = [
        Self::Spo, Self::Pos, Self::Osp, Self::Gspo, Self::Gpos, Self::Gosp,
    ];
}

impl fmt::Display for IndexOrder {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// StorageBackend (tags 0-3)
// ===========================================================================

/// Triple store storage backends.
///
/// Matches `StorageBackend` in `TriplestoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StorageBackend {
    /// InMemory (tag 0).
    InMemory = 0,
    /// BTree (tag 1).
    BTree = 1,
    /// LSM (tag 2).
    Lsm = 2,
    /// Persistent (tag 3).
    Persistent = 3,
}

impl StorageBackend {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::InMemory),
            1 => Some(Self::BTree),
            2 => Some(Self::Lsm),
            3 => Some(Self::Persistent),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [StorageBackend; 4] = [
        Self::InMemory, Self::BTree, Self::Lsm, Self::Persistent,
    ];
}

impl fmt::Display for StorageBackend {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ImportFormat (tags 0-5)
// ===========================================================================

/// RDF import formats.
///
/// Matches `ImportFormat` in `TriplestoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ImportFormat {
    /// NTriples (tag 0).
    NTriples = 0,
    /// Turtle (tag 1).
    Turtle = 1,
    /// RDF/XML (tag 2).
    RdfXml = 2,
    /// JSON-LD (tag 3).
    JsonLd = 3,
    /// NQuads (tag 4).
    NQuads = 4,
    /// Trig (tag 5).
    Trig = 5,
}

impl ImportFormat {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NTriples),
            1 => Some(Self::Turtle),
            2 => Some(Self::RdfXml),
            3 => Some(Self::JsonLd),
            4 => Some(Self::NQuads),
            5 => Some(Self::Trig),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ImportFormat; 6] = [
        Self::NTriples, Self::Turtle, Self::RdfXml, Self::JsonLd, Self::NQuads, Self::Trig,
    ];
}

impl fmt::Display for ImportFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TransactionIsolation (tags 0-2)
// ===========================================================================

/// Triple store transaction isolation.
///
/// Matches `TransactionIsolation` in `TriplestoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransactionIsolation {
    /// ReadCommitted (tag 0).
    ReadCommitted = 0,
    /// Serializable (tag 1).
    Serializable = 1,
    /// Snapshot (tag 2).
    Snapshot = 2,
}

impl TransactionIsolation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ReadCommitted),
            1 => Some(Self::Serializable),
            2 => Some(Self::Snapshot),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [TransactionIsolation; 3] = [
        Self::ReadCommitted, Self::Serializable, Self::Snapshot,
    ];
}

impl fmt::Display for TransactionIsolation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// StoreState (tags 0-4)
// ===========================================================================

/// Triple store states.
///
/// Matches `StoreState` in `TriplestoreABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StoreState {
    /// Idle (tag 0).
    Idle = 0,
    /// Ready (tag 1).
    Ready = 1,
    /// In transaction (tag 2).
    InTransaction = 2,
    /// Importing (tag 3).
    Importing = 3,
    /// Closing (tag 4).
    Closing = 4,
}

impl StoreState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Ready),
            2 => Some(Self::InTransaction),
            3 => Some(Self::Importing),
            4 => Some(Self::Closing),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [StoreState; 5] = [
        Self::Idle, Self::Ready, Self::InTransaction, Self::Importing, Self::Closing,
    ];
}

impl fmt::Display for StoreState {
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
    fn statement_roundtrip() {
        for v in Statement::ALL {
            let tag = v.to_tag();
            let decoded = Statement::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Statement::from_tag(2).is_none());
    }

    #[test]
    fn index_order_roundtrip() {
        for v in IndexOrder::ALL {
            let tag = v.to_tag();
            let decoded = IndexOrder::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(IndexOrder::from_tag(6).is_none());
    }

    #[test]
    fn storage_backend_roundtrip() {
        for v in StorageBackend::ALL {
            let tag = v.to_tag();
            let decoded = StorageBackend::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(StorageBackend::from_tag(4).is_none());
    }

    #[test]
    fn import_format_roundtrip() {
        for v in ImportFormat::ALL {
            let tag = v.to_tag();
            let decoded = ImportFormat::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ImportFormat::from_tag(6).is_none());
    }

    #[test]
    fn transaction_isolation_roundtrip() {
        for v in TransactionIsolation::ALL {
            let tag = v.to_tag();
            let decoded = TransactionIsolation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(TransactionIsolation::from_tag(3).is_none());
    }

    #[test]
    fn store_state_roundtrip() {
        for v in StoreState::ALL {
            let tag = v.to_tag();
            let decoded = StoreState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(StoreState::from_tag(5).is_none());
    }

}
