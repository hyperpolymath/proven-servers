//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Triplestore protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `TriplestoreABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Statement
// ===========================================================================

/// RDF statement types.
/// 
/// Matches `Statement` in `TriplestoreABI.Types`.
pub type Statement {
  /// Triple (tag 0).
  Triple
  /// Quad (tag 1).
  Quad
}

/// Convert a `Statement` to its C-ABI tag value.
pub fn statement_to_int(value: Statement) -> Int {
  case value {
    Triple -> 0
    Quad -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn statement_from_int(tag: Int) -> Result(Statement, Nil) {
  case tag {
    0 -> Ok(Triple)
    1 -> Ok(Quad)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// IndexOrder
// ===========================================================================

/// Triple index orderings.
/// 
/// Matches `IndexOrder` in `TriplestoreABI.Types`.
pub type IndexOrder {
  /// SPO (tag 0).
  Spo
  /// POS (tag 1).
  Pos
  /// OSP (tag 2).
  Osp
  /// GSPO (tag 3).
  Gspo
  /// GPOS (tag 4).
  Gpos
  /// GOSP (tag 5).
  Gosp
}

/// Convert a `IndexOrder` to its C-ABI tag value.
pub fn index_order_to_int(value: IndexOrder) -> Int {
  case value {
    Spo -> 0
    Pos -> 1
    Osp -> 2
    Gspo -> 3
    Gpos -> 4
    Gosp -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn index_order_from_int(tag: Int) -> Result(IndexOrder, Nil) {
  case tag {
    0 -> Ok(Spo)
    1 -> Ok(Pos)
    2 -> Ok(Osp)
    3 -> Ok(Gspo)
    4 -> Ok(Gpos)
    5 -> Ok(Gosp)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// StorageBackend
// ===========================================================================

/// Triple store storage backends.
/// 
/// Matches `StorageBackend` in `TriplestoreABI.Types`.
pub type StorageBackend {
  /// InMemory (tag 0).
  InMemory
  /// BTree (tag 1).
  BTree
  /// LSM (tag 2).
  Lsm
  /// Persistent (tag 3).
  Persistent
}

/// Convert a `StorageBackend` to its C-ABI tag value.
pub fn storage_backend_to_int(value: StorageBackend) -> Int {
  case value {
    InMemory -> 0
    BTree -> 1
    Lsm -> 2
    Persistent -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn storage_backend_from_int(tag: Int) -> Result(StorageBackend, Nil) {
  case tag {
    0 -> Ok(InMemory)
    1 -> Ok(BTree)
    2 -> Ok(Lsm)
    3 -> Ok(Persistent)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ImportFormat
// ===========================================================================

/// RDF import formats.
/// 
/// Matches `ImportFormat` in `TriplestoreABI.Types`.
pub type ImportFormat {
  /// NTriples (tag 0).
  NTriples
  /// Turtle (tag 1).
  Turtle
  /// RDF/XML (tag 2).
  RdfXml
  /// JSON-LD (tag 3).
  JsonLd
  /// NQuads (tag 4).
  NQuads
  /// Trig (tag 5).
  Trig
}

/// Convert a `ImportFormat` to its C-ABI tag value.
pub fn import_format_to_int(value: ImportFormat) -> Int {
  case value {
    NTriples -> 0
    Turtle -> 1
    RdfXml -> 2
    JsonLd -> 3
    NQuads -> 4
    Trig -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn import_format_from_int(tag: Int) -> Result(ImportFormat, Nil) {
  case tag {
    0 -> Ok(NTriples)
    1 -> Ok(Turtle)
    2 -> Ok(RdfXml)
    3 -> Ok(JsonLd)
    4 -> Ok(NQuads)
    5 -> Ok(Trig)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TransactionIsolation
// ===========================================================================

/// Triple store transaction isolation.
/// 
/// Matches `TransactionIsolation` in `TriplestoreABI.Types`.
pub type TransactionIsolation {
  /// ReadCommitted (tag 0).
  ReadCommitted
  /// Serializable (tag 1).
  Serializable
  /// Snapshot (tag 2).
  Snapshot
}

/// Convert a `TransactionIsolation` to its C-ABI tag value.
pub fn transaction_isolation_to_int(value: TransactionIsolation) -> Int {
  case value {
    ReadCommitted -> 0
    Serializable -> 1
    Snapshot -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn transaction_isolation_from_int(tag: Int) -> Result(TransactionIsolation, Nil) {
  case tag {
    0 -> Ok(ReadCommitted)
    1 -> Ok(Serializable)
    2 -> Ok(Snapshot)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// StoreState
// ===========================================================================

/// Triple store states.
/// 
/// Matches `StoreState` in `TriplestoreABI.Types`.
pub type StoreState {
  /// Idle (tag 0).
  Idle
  /// Ready (tag 1).
  Ready
  /// In transaction (tag 2).
  InTransaction
  /// Importing (tag 3).
  Importing
  /// Closing (tag 4).
  Closing
}

/// Convert a `StoreState` to its C-ABI tag value.
pub fn store_state_to_int(value: StoreState) -> Int {
  case value {
    Idle -> 0
    Ready -> 1
    InTransaction -> 2
    Importing -> 3
    Closing -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn store_state_from_int(tag: Int) -> Result(StoreState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Ready)
    2 -> Ok(InTransaction)
    3 -> Ok(Importing)
    4 -> Ok(Closing)
    _ -> Error(Nil)
  }
}

