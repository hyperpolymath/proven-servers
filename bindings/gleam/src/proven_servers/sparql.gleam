//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// SPARQL protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `SparqlABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// SparqlQueryType
// ===========================================================================

/// SPARQL query types.
/// 
/// Matches `SparqlQueryType` in `SparqlABI.Types`.
pub type SparqlQueryType {
  /// Select (tag 0).
  Select
  /// Construct (tag 1).
  Construct
  /// Ask (tag 2).
  Ask
  /// Describe (tag 3).
  Describe
}

/// Convert a `SparqlQueryType` to its C-ABI tag value.
pub fn sparql_query_type_to_int(value: SparqlQueryType) -> Int {
  case value {
    Select -> 0
    Construct -> 1
    Ask -> 2
    Describe -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn sparql_query_type_from_int(tag: Int) -> Result(SparqlQueryType, Nil) {
  case tag {
    0 -> Ok(Select)
    1 -> Ok(Construct)
    2 -> Ok(Ask)
    3 -> Ok(Describe)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// UpdateType
// ===========================================================================

/// SPARQL update types.
/// 
/// Matches `UpdateType` in `SparqlABI.Types`.
pub type UpdateType {
  /// Insert (tag 0).
  Insert
  /// Delete (tag 1).
  Delete
  /// Load (tag 2).
  Load
  /// Clear (tag 3).
  Clear
  /// Create (tag 4).
  Create
  /// Drop (tag 5).
  Drop
}

/// Convert a `UpdateType` to its C-ABI tag value.
pub fn update_type_to_int(value: UpdateType) -> Int {
  case value {
    Insert -> 0
    Delete -> 1
    Load -> 2
    Clear -> 3
    Create -> 4
    Drop -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn update_type_from_int(tag: Int) -> Result(UpdateType, Nil) {
  case tag {
    0 -> Ok(Insert)
    1 -> Ok(Delete)
    2 -> Ok(Load)
    3 -> Ok(Clear)
    4 -> Ok(Create)
    5 -> Ok(Drop)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResultFormat
// ===========================================================================

/// SPARQL result formats.
/// 
/// Matches `ResultFormat` in `SparqlABI.Types`.
pub type ResultFormat {
  /// XML (tag 0).
  Xml
  /// JSON (tag 1).
  Json
  /// CSV (tag 2).
  Csv
  /// TSV (tag 3).
  Tsv
}

/// Convert a `ResultFormat` to its C-ABI tag value.
pub fn result_format_to_int(value: ResultFormat) -> Int {
  case value {
    Xml -> 0
    Json -> 1
    Csv -> 2
    Tsv -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn result_format_from_int(tag: Int) -> Result(ResultFormat, Nil) {
  case tag {
    0 -> Ok(Xml)
    1 -> Ok(Json)
    2 -> Ok(Csv)
    3 -> Ok(Tsv)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SparqlErrorType
// ===========================================================================

/// SPARQL error types.
/// 
/// Matches `SparqlErrorType` in `SparqlABI.Types`.
pub type SparqlErrorType {
  /// ParseError (tag 0).
  ParseError
  /// QueryTimeout (tag 1).
  QueryTimeout
  /// ResultsTooLarge (tag 2).
  ResultsTooLarge
  /// UnknownGraph (tag 3).
  UnknownGraph
  /// AccessDenied (tag 4).
  AccessDenied
}

/// Convert a `SparqlErrorType` to its C-ABI tag value.
pub fn sparql_error_type_to_int(value: SparqlErrorType) -> Int {
  case value {
    ParseError -> 0
    QueryTimeout -> 1
    ResultsTooLarge -> 2
    UnknownGraph -> 3
    AccessDenied -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn sparql_error_type_from_int(tag: Int) -> Result(SparqlErrorType, Nil) {
  case tag {
    0 -> Ok(ParseError)
    1 -> Ok(QueryTimeout)
    2 -> Ok(ResultsTooLarge)
    3 -> Ok(UnknownGraph)
    4 -> Ok(AccessDenied)
    _ -> Error(Nil)
  }
}

