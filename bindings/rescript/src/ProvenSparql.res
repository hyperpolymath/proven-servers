// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SPARQL types for the proven-servers ABI.
//
// Mirrors the Idris2 module SparqlABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// SparqlQueryType (tags 0-3)
// ===========================================================================

/// SPARQL query types.
type sparqlQueryType =
  | @as(0) Select
  | @as(1) Construct
  | @as(2) Ask
  | @as(3) Describe

/// Decode from the C-ABI tag value.
let sparqlQueryTypeFromTag = (tag: int): option<sparqlQueryType> =>
  switch tag {
  | 0 => Some(Select)
  | 1 => Some(Construct)
  | 2 => Some(Ask)
  | 3 => Some(Describe)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sparqlQueryTypeToTag = (v: sparqlQueryType): int =>
  switch v {
  | Select => 0
  | Construct => 1
  | Ask => 2
  | Describe => 3
  }

// ===========================================================================
// UpdateType (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type updateType =
  | @as(0) Insert
  | @as(1) Delete
  | @as(2) Load
  | @as(3) Clear
  | @as(4) Create
  | @as(5) Drop

/// Decode from the C-ABI tag value.
let updateTypeFromTag = (tag: int): option<updateType> =>
  switch tag {
  | 0 => Some(Insert)
  | 1 => Some(Delete)
  | 2 => Some(Load)
  | 3 => Some(Clear)
  | 4 => Some(Create)
  | 5 => Some(Drop)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let updateTypeToTag = (v: updateType): int =>
  switch v {
  | Insert => 0
  | Delete => 1
  | Load => 2
  | Clear => 3
  | Create => 4
  | Drop => 5
  }

// ===========================================================================
// ResultFormat (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type resultFormat =
  | @as(0) Xml
  | @as(1) Json
  | @as(2) Csv
  | @as(3) Tsv

/// Decode from the C-ABI tag value.
let resultFormatFromTag = (tag: int): option<resultFormat> =>
  switch tag {
  | 0 => Some(Xml)
  | 1 => Some(Json)
  | 2 => Some(Csv)
  | 3 => Some(Tsv)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let resultFormatToTag = (v: resultFormat): int =>
  switch v {
  | Xml => 0
  | Json => 1
  | Csv => 2
  | Tsv => 3
  }

// ===========================================================================
// SparqlErrorType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sparqlErrorType =
  | @as(0) ParseError
  | @as(1) QueryTimeout
  | @as(2) ResultsTooLarge
  | @as(3) UnknownGraph
  | @as(4) AccessDenied

/// Decode from the C-ABI tag value.
let sparqlErrorTypeFromTag = (tag: int): option<sparqlErrorType> =>
  switch tag {
  | 0 => Some(ParseError)
  | 1 => Some(QueryTimeout)
  | 2 => Some(ResultsTooLarge)
  | 3 => Some(UnknownGraph)
  | 4 => Some(AccessDenied)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sparqlErrorTypeToTag = (v: sparqlErrorType): int =>
  switch v {
  | ParseError => 0
  | QueryTimeout => 1
  | ResultsTooLarge => 2
  | UnknownGraph => 3
  | AccessDenied => 4
  }

