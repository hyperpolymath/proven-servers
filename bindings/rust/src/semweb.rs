// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Semantic Web types for the proven-servers ABI.
//!
//! Formally verified Semantic Web types.
//! Mirrors the Idris2 module `SemwebABI.Types`.
//!
//! - `RdfFormat` -- RDF serialization formats.
//! - `SemwebResourceType` -- Semantic web resource types.
//! - `HttpMethod` -- Semantic web HTTP methods.
//! - `ContentNegotiation` -- Content negotiation preferences.
//! - `SemwebErrorCode` -- Semantic web error codes.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// RdfFormat (tags 0-5)
// ===========================================================================

/// RDF serialization formats.
///
/// Matches `RdfFormat` in `SemwebABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RdfFormat {
    /// RDF/XML (tag 0).
    RdfXml = 0,
    /// Turtle (tag 1).
    Turtle = 1,
    /// NTriples (tag 2).
    NTriples = 2,
    /// NQuads (tag 3).
    NQuads = 3,
    /// JSON-LD (tag 4).
    JsonLd = 4,
    /// Trig (tag 5).
    Trig = 5,
}

impl RdfFormat {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::RdfXml),
            1 => Some(Self::Turtle),
            2 => Some(Self::NTriples),
            3 => Some(Self::NQuads),
            4 => Some(Self::JsonLd),
            5 => Some(Self::Trig),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [RdfFormat; 6] = [
        Self::RdfXml, Self::Turtle, Self::NTriples, Self::NQuads, Self::JsonLd, Self::Trig,
    ];
}

impl fmt::Display for RdfFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SemwebResourceType (tags 0-4)
// ===========================================================================

/// Semantic web resource types.
///
/// Matches `SemwebResourceType` in `SemwebABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SemwebResourceType {
    /// Class (tag 0).
    Class = 0,
    /// Property (tag 1).
    Property = 1,
    /// Individual (tag 2).
    Individual = 2,
    /// Ontology (tag 3).
    Ontology = 3,
    /// NamedGraph (tag 4).
    NamedGraph = 4,
}

impl SemwebResourceType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Class),
            1 => Some(Self::Property),
            2 => Some(Self::Individual),
            3 => Some(Self::Ontology),
            4 => Some(Self::NamedGraph),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SemwebResourceType; 5] = [
        Self::Class, Self::Property, Self::Individual, Self::Ontology, Self::NamedGraph,
    ];
}

impl fmt::Display for SemwebResourceType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HttpMethod (tags 0-4)
// ===========================================================================

/// Semantic web HTTP methods.
///
/// Matches `HttpMethod` in `SemwebABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HttpMethod {
    /// Get (tag 0).
    Get = 0,
    /// Post (tag 1).
    Post = 1,
    /// Put (tag 2).
    Put = 2,
    /// Patch (tag 3).
    Patch = 3,
    /// Delete (tag 4).
    Delete = 4,
}

impl HttpMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Get),
            1 => Some(Self::Post),
            2 => Some(Self::Put),
            3 => Some(Self::Patch),
            4 => Some(Self::Delete),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HttpMethod; 5] = [
        Self::Get, Self::Post, Self::Put, Self::Patch, Self::Delete,
    ];
}

impl fmt::Display for HttpMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ContentNegotiation (tags 0-3)
// ===========================================================================

/// Content negotiation preferences.
///
/// Matches `ContentNegotiation` in `SemwebABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ContentNegotiation {
    /// RDF/XML (tag 0).
    NegRdfXml = 0,
    /// Turtle (tag 1).
    NegTurtle = 1,
    /// JSON-LD (tag 2).
    NegJsonLd = 2,
    /// HTML (tag 3).
    NegHtml = 3,
}

impl ContentNegotiation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NegRdfXml),
            1 => Some(Self::NegTurtle),
            2 => Some(Self::NegJsonLd),
            3 => Some(Self::NegHtml),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ContentNegotiation; 4] = [
        Self::NegRdfXml, Self::NegTurtle, Self::NegJsonLd, Self::NegHtml,
    ];
}

impl fmt::Display for ContentNegotiation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SemwebErrorCode (tags 0-4)
// ===========================================================================

/// Semantic web error codes.
///
/// Matches `SemwebErrorCode` in `SemwebABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SemwebErrorCode {
    /// NotFound (tag 0).
    NotFound = 0,
    /// Invalid URI (tag 1).
    InvalidUri = 1,
    /// Malformed RDF (tag 2).
    MalformedRdf = 2,
    /// UnsupportedFormat (tag 3).
    UnsupportedFormat = 3,
    /// ConflictingTriples (tag 4).
    ConflictingTriples = 4,
}

impl SemwebErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NotFound),
            1 => Some(Self::InvalidUri),
            2 => Some(Self::MalformedRdf),
            3 => Some(Self::UnsupportedFormat),
            4 => Some(Self::ConflictingTriples),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SemwebErrorCode; 5] = [
        Self::NotFound, Self::InvalidUri, Self::MalformedRdf, Self::UnsupportedFormat, Self::ConflictingTriples,
    ];
}

impl fmt::Display for SemwebErrorCode {
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
    fn rdf_format_roundtrip() {
        for v in RdfFormat::ALL {
            let tag = v.to_tag();
            let decoded = RdfFormat::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RdfFormat::from_tag(6).is_none());
    }

    #[test]
    fn semweb_resource_type_roundtrip() {
        for v in SemwebResourceType::ALL {
            let tag = v.to_tag();
            let decoded = SemwebResourceType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SemwebResourceType::from_tag(5).is_none());
    }

    #[test]
    fn http_method_roundtrip() {
        for v in HttpMethod::ALL {
            let tag = v.to_tag();
            let decoded = HttpMethod::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HttpMethod::from_tag(5).is_none());
    }

    #[test]
    fn content_negotiation_roundtrip() {
        for v in ContentNegotiation::ALL {
            let tag = v.to_tag();
            let decoded = ContentNegotiation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ContentNegotiation::from_tag(4).is_none());
    }

    #[test]
    fn semweb_error_code_roundtrip() {
        for v in SemwebErrorCode::ALL {
            let tag = v.to_tag();
            let decoded = SemwebErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SemwebErrorCode::from_tag(5).is_none());
    }

}
