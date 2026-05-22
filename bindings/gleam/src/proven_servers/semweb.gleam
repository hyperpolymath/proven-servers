//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Semantic Web protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `SemwebABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// RdfFormat
// ===========================================================================

/// RDF serialization formats.
/// 
/// Matches `RdfFormat` in `SemwebABI.Types`.
pub type RdfFormat {
  /// RDF/XML (tag 0).
  RdfXml
  /// Turtle (tag 1).
  Turtle
  /// NTriples (tag 2).
  NTriples
  /// NQuads (tag 3).
  NQuads
  /// JSON-LD (tag 4).
  JsonLd
  /// Trig (tag 5).
  Trig
}

/// Convert a `RdfFormat` to its C-ABI tag value.
pub fn rdf_format_to_int(value: RdfFormat) -> Int {
  case value {
    RdfXml -> 0
    Turtle -> 1
    NTriples -> 2
    NQuads -> 3
    JsonLd -> 4
    Trig -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn rdf_format_from_int(tag: Int) -> Result(RdfFormat, Nil) {
  case tag {
    0 -> Ok(RdfXml)
    1 -> Ok(Turtle)
    2 -> Ok(NTriples)
    3 -> Ok(NQuads)
    4 -> Ok(JsonLd)
    5 -> Ok(Trig)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SemwebResourceType
// ===========================================================================

/// Semantic web resource types.
/// 
/// Matches `SemwebResourceType` in `SemwebABI.Types`.
pub type SemwebResourceType {
  /// Class (tag 0).
  Class
  /// Property (tag 1).
  Property
  /// Individual (tag 2).
  Individual
  /// Ontology (tag 3).
  Ontology
  /// NamedGraph (tag 4).
  NamedGraph
}

/// Convert a `SemwebResourceType` to its C-ABI tag value.
pub fn semweb_resource_type_to_int(value: SemwebResourceType) -> Int {
  case value {
    Class -> 0
    Property -> 1
    Individual -> 2
    Ontology -> 3
    NamedGraph -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn semweb_resource_type_from_int(tag: Int) -> Result(SemwebResourceType, Nil) {
  case tag {
    0 -> Ok(Class)
    1 -> Ok(Property)
    2 -> Ok(Individual)
    3 -> Ok(Ontology)
    4 -> Ok(NamedGraph)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HttpMethod
// ===========================================================================

/// Semantic web HTTP methods.
/// 
/// Matches `HttpMethod` in `SemwebABI.Types`.
pub type HttpMethod {
  /// Get (tag 0).
  Get
  /// Post (tag 1).
  Post
  /// Put (tag 2).
  Put
  /// Patch (tag 3).
  Patch
  /// Delete (tag 4).
  Delete
}

/// Convert a `HttpMethod` to its C-ABI tag value.
pub fn http_method_to_int(value: HttpMethod) -> Int {
  case value {
    Get -> 0
    Post -> 1
    Put -> 2
    Patch -> 3
    Delete -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn http_method_from_int(tag: Int) -> Result(HttpMethod, Nil) {
  case tag {
    0 -> Ok(Get)
    1 -> Ok(Post)
    2 -> Ok(Put)
    3 -> Ok(Patch)
    4 -> Ok(Delete)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ContentNegotiation
// ===========================================================================

/// Content negotiation preferences.
/// 
/// Matches `ContentNegotiation` in `SemwebABI.Types`.
pub type ContentNegotiation {
  /// RDF/XML (tag 0).
  NegRdfXml
  /// Turtle (tag 1).
  NegTurtle
  /// JSON-LD (tag 2).
  NegJsonLd
  /// HTML (tag 3).
  NegHtml
}

/// Convert a `ContentNegotiation` to its C-ABI tag value.
pub fn content_negotiation_to_int(value: ContentNegotiation) -> Int {
  case value {
    NegRdfXml -> 0
    NegTurtle -> 1
    NegJsonLd -> 2
    NegHtml -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn content_negotiation_from_int(tag: Int) -> Result(ContentNegotiation, Nil) {
  case tag {
    0 -> Ok(NegRdfXml)
    1 -> Ok(NegTurtle)
    2 -> Ok(NegJsonLd)
    3 -> Ok(NegHtml)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SemwebErrorCode
// ===========================================================================

/// Semantic web error codes.
/// 
/// Matches `SemwebErrorCode` in `SemwebABI.Types`.
pub type SemwebErrorCode {
  /// NotFound (tag 0).
  NotFound
  /// Invalid URI (tag 1).
  InvalidUri
  /// Malformed RDF (tag 2).
  MalformedRdf
  /// UnsupportedFormat (tag 3).
  UnsupportedFormat
  /// ConflictingTriples (tag 4).
  ConflictingTriples
}

/// Convert a `SemwebErrorCode` to its C-ABI tag value.
pub fn semweb_error_code_to_int(value: SemwebErrorCode) -> Int {
  case value {
    NotFound -> 0
    InvalidUri -> 1
    MalformedRdf -> 2
    UnsupportedFormat -> 3
    ConflictingTriples -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn semweb_error_code_from_int(tag: Int) -> Result(SemwebErrorCode, Nil) {
  case tag {
    0 -> Ok(NotFound)
    1 -> Ok(InvalidUri)
    2 -> Ok(MalformedRdf)
    3 -> Ok(UnsupportedFormat)
    4 -> Ok(ConflictingTriples)
    _ -> Error(Nil)
  }
}

