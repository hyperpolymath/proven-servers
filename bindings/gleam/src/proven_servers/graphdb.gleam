//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Graph Database protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `GraphdbABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Graph Database Constants
// ===========================================================================

/// Graphdb Port constant.
pub const graphdb_port = 7687

// ===========================================================================
// ElementType
// ===========================================================================

/// Graph element types.
/// 
/// Matches `ElementType` in `GraphdbABI.Types`.
pub type ElementType {
  /// Node (tag 0).
  Node
  /// Edge (tag 1).
  Edge
  /// Property (tag 2).
  Property
  /// Label (tag 3).
  Label
  /// Index (tag 4).
  Index
}

/// Convert a `ElementType` to its C-ABI tag value.
pub fn element_type_to_int(value: ElementType) -> Int {
  case value {
    Node -> 0
    Edge -> 1
    Property -> 2
    Label -> 3
    Index -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn element_type_from_int(tag: Int) -> Result(ElementType, Nil) {
  case tag {
    0 -> Ok(Node)
    1 -> Ok(Edge)
    2 -> Ok(Property)
    3 -> Ok(Label)
    4 -> Ok(Index)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// QueryLanguage
// ===========================================================================

/// Graph query languages.
/// 
/// Matches `QueryLanguage` in `GraphdbABI.Types`.
pub type QueryLanguage {
  /// Cypher (tag 0).
  Cypher
  /// Gremlin (tag 1).
  Gremlin
  /// SPARQL (tag 2).
  Sparql
  /// GraphQL (tag 3).
  GraphQl
}

/// Convert a `QueryLanguage` to its C-ABI tag value.
pub fn query_language_to_int(value: QueryLanguage) -> Int {
  case value {
    Cypher -> 0
    Gremlin -> 1
    Sparql -> 2
    GraphQl -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn query_language_from_int(tag: Int) -> Result(QueryLanguage, Nil) {
  case tag {
    0 -> Ok(Cypher)
    1 -> Ok(Gremlin)
    2 -> Ok(Sparql)
    3 -> Ok(GraphQl)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TraversalStrategy
// ===========================================================================

/// Graph traversal strategies.
/// 
/// Matches `TraversalStrategy` in `GraphdbABI.Types`.
pub type TraversalStrategy {
  /// Breadth-first search (tag 0).
  Bfs
  /// Depth-first search (tag 1).
  Dfs
  /// Dijkstra (tag 2).
  Dijkstra
  /// A* (tag 3).
  AStar
  /// Random (tag 4).
  Random
}

/// Convert a `TraversalStrategy` to its C-ABI tag value.
pub fn traversal_strategy_to_int(value: TraversalStrategy) -> Int {
  case value {
    Bfs -> 0
    Dfs -> 1
    Dijkstra -> 2
    AStar -> 3
    Random -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn traversal_strategy_from_int(tag: Int) -> Result(TraversalStrategy, Nil) {
  case tag {
    0 -> Ok(Bfs)
    1 -> Ok(Dfs)
    2 -> Ok(Dijkstra)
    3 -> Ok(AStar)
    4 -> Ok(Random)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Consistency
// ===========================================================================

/// Consistency levels.
/// 
/// Matches `Consistency` in `GraphdbABI.Types`.
pub type Consistency {
  /// Strong (tag 0).
  Strong
  /// Eventual (tag 1).
  Eventual
  /// Session (tag 2).
  Session
  /// Causal (tag 3).
  Causal
}

/// Convert a `Consistency` to its C-ABI tag value.
pub fn consistency_to_int(value: Consistency) -> Int {
  case value {
    Strong -> 0
    Eventual -> 1
    Session -> 2
    Causal -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn consistency_from_int(tag: Int) -> Result(Consistency, Nil) {
  case tag {
    0 -> Ok(Strong)
    1 -> Ok(Eventual)
    2 -> Ok(Session)
    3 -> Ok(Causal)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorCode
// ===========================================================================

/// Graph database error codes.
/// 
/// Matches `ErrorCode` in `GraphdbABI.Types`.
pub type ErrorCode {
  /// SyntaxError (tag 0).
  SyntaxError
  /// NodeNotFound (tag 1).
  NodeNotFound
  /// EdgeNotFound (tag 2).
  EdgeNotFound
  /// ConstraintViolation (tag 3).
  ConstraintViolation
  /// IndexExists (tag 4).
  IndexExists
  /// TransactionConflict (tag 5).
  TransactionConflict
  /// OutOfMemory (tag 6).
  OutOfMemory
}

/// Convert a `ErrorCode` to its C-ABI tag value.
pub fn error_code_to_int(value: ErrorCode) -> Int {
  case value {
    SyntaxError -> 0
    NodeNotFound -> 1
    EdgeNotFound -> 2
    ConstraintViolation -> 3
    IndexExists -> 4
    TransactionConflict -> 5
    OutOfMemory -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn error_code_from_int(tag: Int) -> Result(ErrorCode, Nil) {
  case tag {
    0 -> Ok(SyntaxError)
    1 -> Ok(NodeNotFound)
    2 -> Ok(EdgeNotFound)
    3 -> Ok(ConstraintViolation)
    4 -> Ok(IndexExists)
    5 -> Ok(TransactionConflict)
    6 -> Ok(OutOfMemory)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// Graph database session states.
/// 
/// Matches `SessionState` in `GraphdbABI.Types`.
pub type SessionState {
  /// Idle (tag 0).
  Idle
  /// Connected (tag 1).
  Connected
  /// Querying (tag 2).
  Querying
  /// Traversing (tag 3).
  Traversing
  /// Disconnecting (tag 4).
  Disconnecting
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Connected -> 1
    Querying -> 2
    Traversing -> 3
    Disconnecting -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Connected)
    2 -> Ok(Querying)
    3 -> Ok(Traversing)
    4 -> Ok(Disconnecting)
    _ -> Error(Nil)
  }
}

