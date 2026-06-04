// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! Database server types for the proven-servers ABI.
//!
//! Formally verified database protocol types.
//! Mirrors the Idris2 module `DbserverABI.Types`.
//!
//! - `QueryType` -- Database query types (SQL DML/DDL).
//! - `DataType` -- Database column/value data types.
//! - `IsolationLevel` -- Transaction isolation levels (ANSI SQL).
//! - `ErrorCode` -- Database error codes.
//! - `JoinType` -- SQL JOIN types.
//! - `SessionState` -- Database session lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Database server Constants
// ===========================================================================

/// Standard PostgreSQL port.
pub const DBSERVER_PORT: u16 = 5432;

// ===========================================================================
// QueryType (tags 0-11)
// ===========================================================================

/// Database query types (SQL DML/DDL).
///
/// Matches `QueryType` in `DbserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum QueryType {
    /// SELECT query (tag 0).
    Select = 0,
    /// INSERT query (tag 1).
    Insert = 1,
    /// UPDATE query (tag 2).
    Update = 2,
    /// DELETE query (tag 3).
    Delete = 3,
    /// CREATE TABLE DDL (tag 4).
    CreateTable = 4,
    /// DROP TABLE DDL (tag 5).
    DropTable = 5,
    /// ALTER TABLE DDL (tag 6).
    AlterTable = 6,
    /// CREATE INDEX DDL (tag 7).
    CreateIndex = 7,
    /// DROP INDEX DDL (tag 8).
    DropIndex = 8,
    /// BEGIN TRANSACTION (tag 9).
    Begin = 9,
    /// COMMIT TRANSACTION (tag 10).
    Commit = 10,
    /// ROLLBACK TRANSACTION (tag 11).
    Rollback = 11,
}

impl QueryType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Select),
            1 => Some(Self::Insert),
            2 => Some(Self::Update),
            3 => Some(Self::Delete),
            4 => Some(Self::CreateTable),
            5 => Some(Self::DropTable),
            6 => Some(Self::AlterTable),
            7 => Some(Self::CreateIndex),
            8 => Some(Self::DropIndex),
            9 => Some(Self::Begin),
            10 => Some(Self::Commit),
            11 => Some(Self::Rollback),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is a DDL (schema modification) query.
    pub fn is_ddl(self) -> bool {
        matches!(self, Self::CreateTable | Self::DropTable | Self::AlterTable | Self::CreateIndex | Self::DropIndex)
    }

    /// Whether this is a transaction control statement.
    pub fn is_transaction_control(self) -> bool {
        matches!(self, Self::Begin | Self::Commit | Self::Rollback)
    }

    /// All variants of this type.
    pub const ALL: [QueryType; 12] = [
        Self::Select, Self::Insert, Self::Update, Self::Delete, Self::CreateTable, Self::DropTable, Self::AlterTable, Self::CreateIndex, Self::DropIndex, Self::Begin, Self::Commit, Self::Rollback,
    ];
}

impl fmt::Display for QueryType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DataType (tags 0-8)
// ===========================================================================

/// Database column/value data types.
///
/// Matches `DataType` in `DbserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DataType {
    /// Integer (tag 0).
    Integer = 0,
    /// Float (tag 1).
    Float = 1,
    /// Text (tag 2).
    Text = 2,
    /// Blob (tag 3).
    Blob = 3,
    /// Boolean (tag 4).
    Boolean = 4,
    /// Timestamp (tag 5).
    Timestamp = 5,
    /// UUID type (tag 6).
    Uuid = 6,
    /// JSON type (tag 7).
    Json = 7,
    /// Null (tag 8).
    Null = 8,
}

impl DataType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Integer),
            1 => Some(Self::Float),
            2 => Some(Self::Text),
            3 => Some(Self::Blob),
            4 => Some(Self::Boolean),
            5 => Some(Self::Timestamp),
            6 => Some(Self::Uuid),
            7 => Some(Self::Json),
            8 => Some(Self::Null),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DataType; 9] = [
        Self::Integer, Self::Float, Self::Text, Self::Blob, Self::Boolean, Self::Timestamp, Self::Uuid, Self::Json, Self::Null,
    ];
}

impl fmt::Display for DataType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// IsolationLevel (tags 0-3)
// ===========================================================================

/// Transaction isolation levels (ANSI SQL).
///
/// Matches `IsolationLevel` in `DbserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum IsolationLevel {
    /// ReadUncommitted (tag 0).
    ReadUncommitted = 0,
    /// ReadCommitted (tag 1).
    ReadCommitted = 1,
    /// RepeatableRead (tag 2).
    RepeatableRead = 2,
    /// Serializable (tag 3).
    Serializable = 3,
}

impl IsolationLevel {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ReadUncommitted),
            1 => Some(Self::ReadCommitted),
            2 => Some(Self::RepeatableRead),
            3 => Some(Self::Serializable),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [IsolationLevel; 4] = [
        Self::ReadUncommitted, Self::ReadCommitted, Self::RepeatableRead, Self::Serializable,
    ];
}

impl fmt::Display for IsolationLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorCode (tags 0-9)
// ===========================================================================

/// Database error codes.
///
/// Matches `ErrorCode` in `DbserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCode {
    /// SyntaxError (tag 0).
    SyntaxError = 0,
    /// TableNotFound (tag 1).
    TableNotFound = 1,
    /// ColumnNotFound (tag 2).
    ColumnNotFound = 2,
    /// DuplicateKey (tag 3).
    DuplicateKey = 3,
    /// ConstraintViolation (tag 4).
    ConstraintViolation = 4,
    /// TypeMismatch (tag 5).
    TypeMismatch = 5,
    /// DeadlockDetected (tag 6).
    DeadlockDetected = 6,
    /// TransactionAborted (tag 7).
    TransactionAborted = 7,
    /// DiskFull (tag 8).
    DiskFull = 8,
    /// ConnectionLost (tag 9).
    ConnectionLost = 9,
}

impl ErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::SyntaxError),
            1 => Some(Self::TableNotFound),
            2 => Some(Self::ColumnNotFound),
            3 => Some(Self::DuplicateKey),
            4 => Some(Self::ConstraintViolation),
            5 => Some(Self::TypeMismatch),
            6 => Some(Self::DeadlockDetected),
            7 => Some(Self::TransactionAborted),
            8 => Some(Self::DiskFull),
            9 => Some(Self::ConnectionLost),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this error is potentially recoverable.
    pub fn is_recoverable(self) -> bool {
        matches!(self, Self::DeadlockDetected | Self::TransactionAborted | Self::ConnectionLost)
    }

    /// All variants of this type.
    pub const ALL: [ErrorCode; 10] = [
        Self::SyntaxError, Self::TableNotFound, Self::ColumnNotFound, Self::DuplicateKey, Self::ConstraintViolation, Self::TypeMismatch, Self::DeadlockDetected, Self::TransactionAborted, Self::DiskFull, Self::ConnectionLost,
    ];
}

impl fmt::Display for ErrorCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// JoinType (tags 0-4)
// ===========================================================================

/// SQL JOIN types.
///
/// Matches `JoinType` in `DbserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum JoinType {
    /// Inner (tag 0).
    Inner = 0,
    /// LeftOuter (tag 1).
    LeftOuter = 1,
    /// RightOuter (tag 2).
    RightOuter = 2,
    /// FullOuter (tag 3).
    FullOuter = 3,
    /// Cross (tag 4).
    Cross = 4,
}

impl JoinType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Inner),
            1 => Some(Self::LeftOuter),
            2 => Some(Self::RightOuter),
            3 => Some(Self::FullOuter),
            4 => Some(Self::Cross),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [JoinType; 5] = [
        Self::Inner, Self::LeftOuter, Self::RightOuter, Self::FullOuter, Self::Cross,
    ];
}

impl fmt::Display for JoinType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-5)
// ===========================================================================

/// Database session lifecycle states.
///
/// Matches `SessionState` in `DbserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Idle (tag 0).
    Idle = 0,
    /// Connected (tag 1).
    Connected = 1,
    /// Transaction (tag 2).
    Transaction = 2,
    /// Executing (tag 3).
    Executing = 3,
    /// Finalising (tag 4).
    Finalising = 4,
    /// Disconnecting (tag 5).
    Disconnecting = 5,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Connected),
            2 => Some(Self::Transaction),
            3 => Some(Self::Executing),
            4 => Some(Self::Finalising),
            5 => Some(Self::Disconnecting),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether queries can be executed in this state.
    pub fn can_query(self) -> bool {
        matches!(self, Self::Connected | Self::Transaction)
    }

    /// All variants of this type.
    pub const ALL: [SessionState; 6] = [
        Self::Idle, Self::Connected, Self::Transaction, Self::Executing, Self::Finalising, Self::Disconnecting,
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
    fn query_type_roundtrip() {
        for v in QueryType::ALL {
            let tag = v.to_tag();
            let decoded = QueryType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(QueryType::from_tag(12).is_none());
    }

    #[test]
    fn data_type_roundtrip() {
        for v in DataType::ALL {
            let tag = v.to_tag();
            let decoded = DataType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DataType::from_tag(9).is_none());
    }

    #[test]
    fn isolation_level_roundtrip() {
        for v in IsolationLevel::ALL {
            let tag = v.to_tag();
            let decoded = IsolationLevel::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(IsolationLevel::from_tag(4).is_none());
    }

    #[test]
    fn error_code_roundtrip() {
        for v in ErrorCode::ALL {
            let tag = v.to_tag();
            let decoded = ErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ErrorCode::from_tag(10).is_none());
    }

    #[test]
    fn join_type_roundtrip() {
        for v in JoinType::ALL {
            let tag = v.to_tag();
            let decoded = JoinType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(JoinType::from_tag(5).is_none());
    }

    #[test]
    fn session_state_roundtrip() {
        for v in SessionState::ALL {
            let tag = v.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionState::from_tag(6).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(DBSERVER_PORT, 5432);
    }

}
