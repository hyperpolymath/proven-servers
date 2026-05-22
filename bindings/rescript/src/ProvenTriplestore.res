// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Triple Store types for the proven-servers ABI.
//
// Mirrors the Idris2 module TriplestoreABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Statement (tags 0-1)
// ===========================================================================

/// RDF statement types.
type statement =
  | @as(0) Triple
  | @as(1) Quad

/// Decode from the C-ABI tag value.
let statementFromTag = (tag: int): option<statement> =>
  switch tag {
  | 0 => Some(Triple)
  | 1 => Some(Quad)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let statementToTag = (v: statement): int =>
  switch v {
  | Triple => 0
  | Quad => 1
  }

// ===========================================================================
// IndexOrder (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type indexOrder =
  | @as(0) Spo
  | @as(1) Pos
  | @as(2) Osp
  | @as(3) Gspo
  | @as(4) Gpos
  | @as(5) Gosp

/// Decode from the C-ABI tag value.
let indexOrderFromTag = (tag: int): option<indexOrder> =>
  switch tag {
  | 0 => Some(Spo)
  | 1 => Some(Pos)
  | 2 => Some(Osp)
  | 3 => Some(Gspo)
  | 4 => Some(Gpos)
  | 5 => Some(Gosp)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let indexOrderToTag = (v: indexOrder): int =>
  switch v {
  | Spo => 0
  | Pos => 1
  | Osp => 2
  | Gspo => 3
  | Gpos => 4
  | Gosp => 5
  }

// ===========================================================================
// StorageBackend (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type storageBackend =
  | @as(0) InMemory
  | @as(1) BTree
  | @as(2) Lsm
  | @as(3) Persistent

/// Decode from the C-ABI tag value.
let storageBackendFromTag = (tag: int): option<storageBackend> =>
  switch tag {
  | 0 => Some(InMemory)
  | 1 => Some(BTree)
  | 2 => Some(Lsm)
  | 3 => Some(Persistent)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let storageBackendToTag = (v: storageBackend): int =>
  switch v {
  | InMemory => 0
  | BTree => 1
  | Lsm => 2
  | Persistent => 3
  }

// ===========================================================================
// ImportFormat (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type importFormat =
  | @as(0) NTriples
  | @as(1) Turtle
  | @as(2) RdfXml
  | @as(3) JsonLd
  | @as(4) NQuads
  | @as(5) Trig

/// Decode from the C-ABI tag value.
let importFormatFromTag = (tag: int): option<importFormat> =>
  switch tag {
  | 0 => Some(NTriples)
  | 1 => Some(Turtle)
  | 2 => Some(RdfXml)
  | 3 => Some(JsonLd)
  | 4 => Some(NQuads)
  | 5 => Some(Trig)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let importFormatToTag = (v: importFormat): int =>
  switch v {
  | NTriples => 0
  | Turtle => 1
  | RdfXml => 2
  | JsonLd => 3
  | NQuads => 4
  | Trig => 5
  }

// ===========================================================================
// TransactionIsolation (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type transactionIsolation =
  | @as(0) ReadCommitted
  | @as(1) Serializable
  | @as(2) Snapshot

/// Decode from the C-ABI tag value.
let transactionIsolationFromTag = (tag: int): option<transactionIsolation> =>
  switch tag {
  | 0 => Some(ReadCommitted)
  | 1 => Some(Serializable)
  | 2 => Some(Snapshot)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let transactionIsolationToTag = (v: transactionIsolation): int =>
  switch v {
  | ReadCommitted => 0
  | Serializable => 1
  | Snapshot => 2
  }

// ===========================================================================
// StoreState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type storeState =
  | @as(0) Idle
  | @as(1) Ready
  | @as(2) InTransaction
  | @as(3) Importing
  | @as(4) Closing

/// Decode from the C-ABI tag value.
let storeStateFromTag = (tag: int): option<storeState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Ready)
  | 2 => Some(InTransaction)
  | 3 => Some(Importing)
  | 4 => Some(Closing)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let storeStateToTag = (v: storeState): int =>
  switch v {
  | Idle => 0
  | Ready => 1
  | InTransaction => 2
  | Importing => 3
  | Closing => 4
  }

