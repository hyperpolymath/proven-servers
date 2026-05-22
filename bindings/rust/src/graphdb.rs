// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Graph Database types for the proven-servers ABI.
//!
//! Formally verified graph database types.
//! Mirrors the Idris2 module `GraphdbABI.Types`.
//!
//! - `ElementType` -- Graph element types.
//! - `QueryLanguage` -- Graph query languages.
//! - `TraversalStrategy` -- Graph traversal strategies.
//! - `Consistency` -- Consistency levels.
//! - `ErrorCode` -- Graph database error codes.
//! - `SessionState` -- Graph database session states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Graph Database Constants
// ===========================================================================

/// Standard Bolt protocol port.
pub const GRAPHDB_PORT: u16 = 7687;

// ===========================================================================
// ElementType (tags 0-4)
// ===========================================================================

/// Graph element types.
///
/// Matches `ElementType` in `GraphdbABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ElementType {
    /// Node (tag 0).
    Node = 0,
    /// Edge (tag 1).
    Edge = 1,
    /// Property (tag 2).
    Property = 2,
    /// Label (tag 3).
    Label = 3,
    /// Index (tag 4).
    Index = 4,
}

impl ElementType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Node),
            1 => Some(Self::Edge),
            2 => Some(Self::Property),
            3 => Some(Self::Label),
            4 => Some(Self::Index),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ElementType; 5] = [
        Self::Node, Self::Edge, Self::Property, Self::Label, Self::Index,
    ];
}

impl fmt::Display for ElementType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// QueryLanguage (tags 0-3)
// ===========================================================================

/// Graph query languages.
///
/// Matches `QueryLanguage` in `GraphdbABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum QueryLanguage {
    /// Cypher (tag 0).
    Cypher = 0,
    /// Gremlin (tag 1).
    Gremlin = 1,
    /// SPARQL (tag 2).
    Sparql = 2,
    /// GraphQL (tag 3).
    GraphQl = 3,
}

impl QueryLanguage {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Cypher),
            1 => Some(Self::Gremlin),
            2 => Some(Self::Sparql),
            3 => Some(Self::GraphQl),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [QueryLanguage; 4] = [
        Self::Cypher, Self::Gremlin, Self::Sparql, Self::GraphQl,
    ];
}

impl fmt::Display for QueryLanguage {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TraversalStrategy (tags 0-4)
// ===========================================================================

/// Graph traversal strategies.
///
/// Matches `TraversalStrategy` in `GraphdbABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TraversalStrategy {
    /// Breadth-first search (tag 0).
    Bfs = 0,
    /// Depth-first search (tag 1).
    Dfs = 1,
    /// Dijkstra (tag 2).
    Dijkstra = 2,
    /// A* (tag 3).
    AStar = 3,
    /// Random (tag 4).
    Random = 4,
}

impl TraversalStrategy {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Bfs),
            1 => Some(Self::Dfs),
            2 => Some(Self::Dijkstra),
            3 => Some(Self::AStar),
            4 => Some(Self::Random),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [TraversalStrategy; 5] = [
        Self::Bfs, Self::Dfs, Self::Dijkstra, Self::AStar, Self::Random,
    ];
}

impl fmt::Display for TraversalStrategy {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Consistency (tags 0-3)
// ===========================================================================

/// Consistency levels.
///
/// Matches `Consistency` in `GraphdbABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Consistency {
    /// Strong (tag 0).
    Strong = 0,
    /// Eventual (tag 1).
    Eventual = 1,
    /// Session (tag 2).
    Session = 2,
    /// Causal (tag 3).
    Causal = 3,
}

impl Consistency {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Strong),
            1 => Some(Self::Eventual),
            2 => Some(Self::Session),
            3 => Some(Self::Causal),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Consistency; 4] = [
        Self::Strong, Self::Eventual, Self::Session, Self::Causal,
    ];
}

impl fmt::Display for Consistency {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorCode (tags 0-6)
// ===========================================================================

/// Graph database error codes.
///
/// Matches `ErrorCode` in `GraphdbABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCode {
    /// SyntaxError (tag 0).
    SyntaxError = 0,
    /// NodeNotFound (tag 1).
    NodeNotFound = 1,
    /// EdgeNotFound (tag 2).
    EdgeNotFound = 2,
    /// ConstraintViolation (tag 3).
    ConstraintViolation = 3,
    /// IndexExists (tag 4).
    IndexExists = 4,
    /// TransactionConflict (tag 5).
    TransactionConflict = 5,
    /// OutOfMemory (tag 6).
    OutOfMemory = 6,
}

impl ErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::SyntaxError),
            1 => Some(Self::NodeNotFound),
            2 => Some(Self::EdgeNotFound),
            3 => Some(Self::ConstraintViolation),
            4 => Some(Self::IndexExists),
            5 => Some(Self::TransactionConflict),
            6 => Some(Self::OutOfMemory),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ErrorCode; 7] = [
        Self::SyntaxError, Self::NodeNotFound, Self::EdgeNotFound, Self::ConstraintViolation, Self::IndexExists, Self::TransactionConflict, Self::OutOfMemory,
    ];
}

impl fmt::Display for ErrorCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Graph database session states.
///
/// Matches `SessionState` in `GraphdbABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Idle (tag 0).
    Idle = 0,
    /// Connected (tag 1).
    Connected = 1,
    /// Querying (tag 2).
    Querying = 2,
    /// Traversing (tag 3).
    Traversing = 3,
    /// Disconnecting (tag 4).
    Disconnecting = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Connected),
            2 => Some(Self::Querying),
            3 => Some(Self::Traversing),
            4 => Some(Self::Disconnecting),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionState; 5] = [
        Self::Idle, Self::Connected, Self::Querying, Self::Traversing, Self::Disconnecting,
    ];
}

impl fmt::Display for SessionState {
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
    fn element_type_roundtrip() {
        for v in ElementType::ALL {
            let tag = v.to_tag();
            let decoded = ElementType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ElementType::from_tag(5).is_none());
    }

    #[test]
    fn query_language_roundtrip() {
        for v in QueryLanguage::ALL {
            let tag = v.to_tag();
            let decoded = QueryLanguage::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(QueryLanguage::from_tag(4).is_none());
    }

    #[test]
    fn traversal_strategy_roundtrip() {
        for v in TraversalStrategy::ALL {
            let tag = v.to_tag();
            let decoded = TraversalStrategy::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(TraversalStrategy::from_tag(5).is_none());
    }

    #[test]
    fn consistency_roundtrip() {
        for v in Consistency::ALL {
            let tag = v.to_tag();
            let decoded = Consistency::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Consistency::from_tag(4).is_none());
    }

    #[test]
    fn error_code_roundtrip() {
        for v in ErrorCode::ALL {
            let tag = v.to_tag();
            let decoded = ErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ErrorCode::from_tag(7).is_none());
    }

    #[test]
    fn session_state_roundtrip() {
        for v in SessionState::ALL {
            let tag = v.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionState::from_tag(5).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(GRAPHDB_PORT, 7687);
    }

}
