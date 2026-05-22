// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Semantic Web types for the proven-servers ABI.
//
// Mirrors the Idris2 module SemwebABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// RdfFormat (tags 0-5)
// ===========================================================================

/// RDF serialization formats.
type rdfFormat =
  | @as(0) RdfXml
  | @as(1) Turtle
  | @as(2) NTriples
  | @as(3) NQuads
  | @as(4) JsonLd
  | @as(5) Trig

/// Decode from the C-ABI tag value.
let rdfFormatFromTag = (tag: int): option<rdfFormat> =>
  switch tag {
  | 0 => Some(RdfXml)
  | 1 => Some(Turtle)
  | 2 => Some(NTriples)
  | 3 => Some(NQuads)
  | 4 => Some(JsonLd)
  | 5 => Some(Trig)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let rdfFormatToTag = (v: rdfFormat): int =>
  switch v {
  | RdfXml => 0
  | Turtle => 1
  | NTriples => 2
  | NQuads => 3
  | JsonLd => 4
  | Trig => 5
  }

// ===========================================================================
// SemwebResourceType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type semwebResourceType =
  | @as(0) Class
  | @as(1) Property
  | @as(2) Individual
  | @as(3) Ontology
  | @as(4) NamedGraph

/// Decode from the C-ABI tag value.
let semwebResourceTypeFromTag = (tag: int): option<semwebResourceType> =>
  switch tag {
  | 0 => Some(Class)
  | 1 => Some(Property)
  | 2 => Some(Individual)
  | 3 => Some(Ontology)
  | 4 => Some(NamedGraph)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let semwebResourceTypeToTag = (v: semwebResourceType): int =>
  switch v {
  | Class => 0
  | Property => 1
  | Individual => 2
  | Ontology => 3
  | NamedGraph => 4
  }

// ===========================================================================
// HttpMethod (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type httpMethod =
  | @as(0) Get
  | @as(1) Post
  | @as(2) Put
  | @as(3) Patch
  | @as(4) Delete

/// Decode from the C-ABI tag value.
let httpMethodFromTag = (tag: int): option<httpMethod> =>
  switch tag {
  | 0 => Some(Get)
  | 1 => Some(Post)
  | 2 => Some(Put)
  | 3 => Some(Patch)
  | 4 => Some(Delete)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let httpMethodToTag = (v: httpMethod): int =>
  switch v {
  | Get => 0
  | Post => 1
  | Put => 2
  | Patch => 3
  | Delete => 4
  }

// ===========================================================================
// ContentNegotiation (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type contentNegotiation =
  | @as(0) NegRdfXml
  | @as(1) NegTurtle
  | @as(2) NegJsonLd
  | @as(3) NegHtml

/// Decode from the C-ABI tag value.
let contentNegotiationFromTag = (tag: int): option<contentNegotiation> =>
  switch tag {
  | 0 => Some(NegRdfXml)
  | 1 => Some(NegTurtle)
  | 2 => Some(NegJsonLd)
  | 3 => Some(NegHtml)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let contentNegotiationToTag = (v: contentNegotiation): int =>
  switch v {
  | NegRdfXml => 0
  | NegTurtle => 1
  | NegJsonLd => 2
  | NegHtml => 3
  }

// ===========================================================================
// SemwebErrorCode (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type semwebErrorCode =
  | @as(0) NotFound
  | @as(1) InvalidUri
  | @as(2) MalformedRdf
  | @as(3) UnsupportedFormat
  | @as(4) ConflictingTriples

/// Decode from the C-ABI tag value.
let semwebErrorCodeFromTag = (tag: int): option<semwebErrorCode> =>
  switch tag {
  | 0 => Some(NotFound)
  | 1 => Some(InvalidUri)
  | 2 => Some(MalformedRdf)
  | 3 => Some(UnsupportedFormat)
  | 4 => Some(ConflictingTriples)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let semwebErrorCodeToTag = (v: semwebErrorCode): int =>
  switch v {
  | NotFound => 0
  | InvalidUri => 1
  | MalformedRdf => 2
  | UnsupportedFormat => 3
  | ConflictingTriples => 4
  }

