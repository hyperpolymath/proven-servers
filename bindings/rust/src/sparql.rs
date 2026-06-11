// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! SPARQL types for the proven-servers ABI.
//!
//! Formally verified SPARQL endpoint types.
//! Mirrors the Idris2 module `SparqlABI.Types`.
//!
//! - `SparqlQueryType` -- SPARQL query types.
//! - `UpdateType` -- SPARQL update types.
//! - `ResultFormat` -- SPARQL result formats.
//! - `SparqlErrorType` -- SPARQL error types.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// SparqlQueryType (tags 0-3)
// ===========================================================================

/// SPARQL query types.
///
/// Matches `SparqlQueryType` in `SparqlABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SparqlQueryType {
    /// Select (tag 0).
    Select = 0,
    /// Construct (tag 1).
    Construct = 1,
    /// Ask (tag 2).
    Ask = 2,
    /// Describe (tag 3).
    Describe = 3,
}

impl SparqlQueryType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Select),
            1 => Some(Self::Construct),
            2 => Some(Self::Ask),
            3 => Some(Self::Describe),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SparqlQueryType; 4] = [
        Self::Select, Self::Construct, Self::Ask, Self::Describe,
    ];
}

impl fmt::Display for SparqlQueryType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// UpdateType (tags 0-5)
// ===========================================================================

/// SPARQL update types.
///
/// Matches `UpdateType` in `SparqlABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum UpdateType {
    /// Insert (tag 0).
    Insert = 0,
    /// Delete (tag 1).
    Delete = 1,
    /// Load (tag 2).
    Load = 2,
    /// Clear (tag 3).
    Clear = 3,
    /// Create (tag 4).
    Create = 4,
    /// Drop (tag 5).
    Drop = 5,
}

impl UpdateType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Insert),
            1 => Some(Self::Delete),
            2 => Some(Self::Load),
            3 => Some(Self::Clear),
            4 => Some(Self::Create),
            5 => Some(Self::Drop),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [UpdateType; 6] = [
        Self::Insert, Self::Delete, Self::Load, Self::Clear, Self::Create, Self::Drop,
    ];
}

impl fmt::Display for UpdateType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ResultFormat (tags 0-3)
// ===========================================================================

/// SPARQL result formats.
///
/// Matches `ResultFormat` in `SparqlABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResultFormat {
    /// XML (tag 0).
    Xml = 0,
    /// JSON (tag 1).
    Json = 1,
    /// CSV (tag 2).
    Csv = 2,
    /// TSV (tag 3).
    Tsv = 3,
}

impl ResultFormat {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Xml),
            1 => Some(Self::Json),
            2 => Some(Self::Csv),
            3 => Some(Self::Tsv),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ResultFormat; 4] = [
        Self::Xml, Self::Json, Self::Csv, Self::Tsv,
    ];
}

impl fmt::Display for ResultFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SparqlErrorType (tags 0-4)
// ===========================================================================

/// SPARQL error types.
///
/// Matches `SparqlErrorType` in `SparqlABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SparqlErrorType {
    /// ParseError (tag 0).
    ParseError = 0,
    /// QueryTimeout (tag 1).
    QueryTimeout = 1,
    /// ResultsTooLarge (tag 2).
    ResultsTooLarge = 2,
    /// UnknownGraph (tag 3).
    UnknownGraph = 3,
    /// AccessDenied (tag 4).
    AccessDenied = 4,
}

impl SparqlErrorType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ParseError),
            1 => Some(Self::QueryTimeout),
            2 => Some(Self::ResultsTooLarge),
            3 => Some(Self::UnknownGraph),
            4 => Some(Self::AccessDenied),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SparqlErrorType; 5] = [
        Self::ParseError, Self::QueryTimeout, Self::ResultsTooLarge, Self::UnknownGraph, Self::AccessDenied,
    ];
}

impl fmt::Display for SparqlErrorType {
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
    fn sparql_query_type_roundtrip() {
        for v in SparqlQueryType::ALL {
            let tag = v.to_tag();
            let decoded = SparqlQueryType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SparqlQueryType::from_tag(4).is_none());
    }

    #[test]
    fn update_type_roundtrip() {
        for v in UpdateType::ALL {
            let tag = v.to_tag();
            let decoded = UpdateType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(UpdateType::from_tag(6).is_none());
    }

    #[test]
    fn result_format_roundtrip() {
        for v in ResultFormat::ALL {
            let tag = v.to_tag();
            let decoded = ResultFormat::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ResultFormat::from_tag(4).is_none());
    }

    #[test]
    fn sparql_error_type_roundtrip() {
        for v in SparqlErrorType::ALL {
            let tag = v.to_tag();
            let decoded = SparqlErrorType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SparqlErrorType::from_tag(5).is_none());
    }

}
