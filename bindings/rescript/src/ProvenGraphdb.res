// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Graph Database types for the proven-servers ABI.
//
// Mirrors the Idris2 module GraphdbABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard Bolt protocol port.
let graphdbPort = 7687

// ===========================================================================
// ElementType (tags 0-4)
// ===========================================================================

/// Standard Bolt protocol port.
type elementType =
  | @as(0) Node
  | @as(1) Edge
  | @as(2) Property
  | @as(3) Label
  | @as(4) Index

/// Decode from the C-ABI tag value.
let elementTypeFromTag = (tag: int): option<elementType> =>
  switch tag {
  | 0 => Some(Node)
  | 1 => Some(Edge)
  | 2 => Some(Property)
  | 3 => Some(Label)
  | 4 => Some(Index)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let elementTypeToTag = (v: elementType): int =>
  switch v {
  | Node => 0
  | Edge => 1
  | Property => 2
  | Label => 3
  | Index => 4
  }

// ===========================================================================
// QueryLanguage (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type queryLanguage =
  | @as(0) Cypher
  | @as(1) Gremlin
  | @as(2) Sparql
  | @as(3) GraphQl

/// Decode from the C-ABI tag value.
let queryLanguageFromTag = (tag: int): option<queryLanguage> =>
  switch tag {
  | 0 => Some(Cypher)
  | 1 => Some(Gremlin)
  | 2 => Some(Sparql)
  | 3 => Some(GraphQl)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let queryLanguageToTag = (v: queryLanguage): int =>
  switch v {
  | Cypher => 0
  | Gremlin => 1
  | Sparql => 2
  | GraphQl => 3
  }

// ===========================================================================
// TraversalStrategy (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type traversalStrategy =
  | @as(0) Bfs
  | @as(1) Dfs
  | @as(2) Dijkstra
  | @as(3) AStar
  | @as(4) Random

/// Decode from the C-ABI tag value.
let traversalStrategyFromTag = (tag: int): option<traversalStrategy> =>
  switch tag {
  | 0 => Some(Bfs)
  | 1 => Some(Dfs)
  | 2 => Some(Dijkstra)
  | 3 => Some(AStar)
  | 4 => Some(Random)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let traversalStrategyToTag = (v: traversalStrategy): int =>
  switch v {
  | Bfs => 0
  | Dfs => 1
  | Dijkstra => 2
  | AStar => 3
  | Random => 4
  }

// ===========================================================================
// Consistency (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type consistency =
  | @as(0) Strong
  | @as(1) Eventual
  | @as(2) Session
  | @as(3) Causal

/// Decode from the C-ABI tag value.
let consistencyFromTag = (tag: int): option<consistency> =>
  switch tag {
  | 0 => Some(Strong)
  | 1 => Some(Eventual)
  | 2 => Some(Session)
  | 3 => Some(Causal)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let consistencyToTag = (v: consistency): int =>
  switch v {
  | Strong => 0
  | Eventual => 1
  | Session => 2
  | Causal => 3
  }

// ===========================================================================
// ErrorCode (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type errorCode =
  | @as(0) SyntaxError
  | @as(1) NodeNotFound
  | @as(2) EdgeNotFound
  | @as(3) ConstraintViolation
  | @as(4) IndexExists
  | @as(5) TransactionConflict
  | @as(6) OutOfMemory

/// Decode from the C-ABI tag value.
let errorCodeFromTag = (tag: int): option<errorCode> =>
  switch tag {
  | 0 => Some(SyntaxError)
  | 1 => Some(NodeNotFound)
  | 2 => Some(EdgeNotFound)
  | 3 => Some(ConstraintViolation)
  | 4 => Some(IndexExists)
  | 5 => Some(TransactionConflict)
  | 6 => Some(OutOfMemory)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorCodeToTag = (v: errorCode): int =>
  switch v {
  | SyntaxError => 0
  | NodeNotFound => 1
  | EdgeNotFound => 2
  | ConstraintViolation => 3
  | IndexExists => 4
  | TransactionConflict => 5
  | OutOfMemory => 6
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Connected
  | @as(2) Querying
  | @as(3) Traversing
  | @as(4) Disconnecting

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Connected)
  | 2 => Some(Querying)
  | 3 => Some(Traversing)
  | 4 => Some(Disconnecting)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Connected => 1
  | Querying => 2
  | Traversing => 3
  | Disconnecting => 4
  }

