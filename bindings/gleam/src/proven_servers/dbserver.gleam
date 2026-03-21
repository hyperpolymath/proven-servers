//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Database Server protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `DbserverABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Database Server Constants
// ===========================================================================

/// Dbserver Port constant.
pub const dbserver_port = 5432

// ===========================================================================
// QueryType
// ===========================================================================

/// Database query types (SQL DML/DDL).
/// 
/// Matches `QueryType` in `DbserverABI.Types`.
pub type QueryType {
  /// SELECT query (tag 0).
  Select
  /// INSERT query (tag 1).
  Insert
  /// UPDATE query (tag 2).
  Update
  /// DELETE query (tag 3).
  Delete
  /// CREATE TABLE DDL (tag 4).
  CreateTable
  /// DROP TABLE DDL (tag 5).
  DropTable
  /// ALTER TABLE DDL (tag 6).
  AlterTable
  /// CREATE INDEX DDL (tag 7).
  CreateIndex
  /// DROP INDEX DDL (tag 8).
  DropIndex
  /// BEGIN TRANSACTION (tag 9).
  Begin
  /// COMMIT TRANSACTION (tag 10).
  Commit
  /// ROLLBACK TRANSACTION (tag 11).
  Rollback
}

/// Convert a `QueryType` to its C-ABI tag value.
pub fn query_type_to_int(value: QueryType) -> Int {
  case value {
    Select -> 0
    Insert -> 1
    Update -> 2
    Delete -> 3
    CreateTable -> 4
    DropTable -> 5
    AlterTable -> 6
    CreateIndex -> 7
    DropIndex -> 8
    Begin -> 9
    Commit -> 10
    Rollback -> 11
  }
}

/// Decode from a C-ABI tag value.
pub fn query_type_from_int(tag: Int) -> Result(QueryType, Nil) {
  case tag {
    0 -> Ok(Select)
    1 -> Ok(Insert)
    2 -> Ok(Update)
    3 -> Ok(Delete)
    4 -> Ok(CreateTable)
    5 -> Ok(DropTable)
    6 -> Ok(AlterTable)
    7 -> Ok(CreateIndex)
    8 -> Ok(DropIndex)
    9 -> Ok(Begin)
    10 -> Ok(Commit)
    11 -> Ok(Rollback)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DataType
// ===========================================================================

/// Database column/value data types.
/// 
/// Matches `DataType` in `DbserverABI.Types`.
pub type DataType {
  /// Integer (tag 0).
  Integer
  /// Float (tag 1).
  Float
  /// Text (tag 2).
  Text
  /// Blob (tag 3).
  Blob
  /// Boolean (tag 4).
  Boolean
  /// Timestamp (tag 5).
  Timestamp
  /// UUID type (tag 6).
  Uuid
  /// JSON type (tag 7).
  Json
  /// Null (tag 8).
  Null
}

/// Convert a `DataType` to its C-ABI tag value.
pub fn data_type_to_int(value: DataType) -> Int {
  case value {
    Integer -> 0
    Float -> 1
    Text -> 2
    Blob -> 3
    Boolean -> 4
    Timestamp -> 5
    Uuid -> 6
    Json -> 7
    Null -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn data_type_from_int(tag: Int) -> Result(DataType, Nil) {
  case tag {
    0 -> Ok(Integer)
    1 -> Ok(Float)
    2 -> Ok(Text)
    3 -> Ok(Blob)
    4 -> Ok(Boolean)
    5 -> Ok(Timestamp)
    6 -> Ok(Uuid)
    7 -> Ok(Json)
    8 -> Ok(Null)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// IsolationLevel
// ===========================================================================

/// Transaction isolation levels (ANSI SQL).
/// 
/// Matches `IsolationLevel` in `DbserverABI.Types`.
pub type IsolationLevel {
  /// ReadUncommitted (tag 0).
  ReadUncommitted
  /// ReadCommitted (tag 1).
  ReadCommitted
  /// RepeatableRead (tag 2).
  RepeatableRead
  /// Serializable (tag 3).
  Serializable
}

/// Convert a `IsolationLevel` to its C-ABI tag value.
pub fn isolation_level_to_int(value: IsolationLevel) -> Int {
  case value {
    ReadUncommitted -> 0
    ReadCommitted -> 1
    RepeatableRead -> 2
    Serializable -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn isolation_level_from_int(tag: Int) -> Result(IsolationLevel, Nil) {
  case tag {
    0 -> Ok(ReadUncommitted)
    1 -> Ok(ReadCommitted)
    2 -> Ok(RepeatableRead)
    3 -> Ok(Serializable)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ErrorCode
// ===========================================================================

/// Database error codes.
/// 
/// Matches `ErrorCode` in `DbserverABI.Types`.
pub type ErrorCode {
  /// SyntaxError (tag 0).
  SyntaxError
  /// TableNotFound (tag 1).
  TableNotFound
  /// ColumnNotFound (tag 2).
  ColumnNotFound
  /// DuplicateKey (tag 3).
  DuplicateKey
  /// ConstraintViolation (tag 4).
  ConstraintViolation
  /// TypeMismatch (tag 5).
  TypeMismatch
  /// DeadlockDetected (tag 6).
  DeadlockDetected
  /// TransactionAborted (tag 7).
  TransactionAborted
  /// DiskFull (tag 8).
  DiskFull
  /// ConnectionLost (tag 9).
  ConnectionLost
}

/// Convert a `ErrorCode` to its C-ABI tag value.
pub fn error_code_to_int(value: ErrorCode) -> Int {
  case value {
    SyntaxError -> 0
    TableNotFound -> 1
    ColumnNotFound -> 2
    DuplicateKey -> 3
    ConstraintViolation -> 4
    TypeMismatch -> 5
    DeadlockDetected -> 6
    TransactionAborted -> 7
    DiskFull -> 8
    ConnectionLost -> 9
  }
}

/// Decode from a C-ABI tag value.
pub fn error_code_from_int(tag: Int) -> Result(ErrorCode, Nil) {
  case tag {
    0 -> Ok(SyntaxError)
    1 -> Ok(TableNotFound)
    2 -> Ok(ColumnNotFound)
    3 -> Ok(DuplicateKey)
    4 -> Ok(ConstraintViolation)
    5 -> Ok(TypeMismatch)
    6 -> Ok(DeadlockDetected)
    7 -> Ok(TransactionAborted)
    8 -> Ok(DiskFull)
    9 -> Ok(ConnectionLost)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// JoinType
// ===========================================================================

/// SQL JOIN types.
/// 
/// Matches `JoinType` in `DbserverABI.Types`.
pub type JoinType {
  /// Inner (tag 0).
  Inner
  /// LeftOuter (tag 1).
  LeftOuter
  /// RightOuter (tag 2).
  RightOuter
  /// FullOuter (tag 3).
  FullOuter
  /// Cross (tag 4).
  Cross
}

/// Convert a `JoinType` to its C-ABI tag value.
pub fn join_type_to_int(value: JoinType) -> Int {
  case value {
    Inner -> 0
    LeftOuter -> 1
    RightOuter -> 2
    FullOuter -> 3
    Cross -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn join_type_from_int(tag: Int) -> Result(JoinType, Nil) {
  case tag {
    0 -> Ok(Inner)
    1 -> Ok(LeftOuter)
    2 -> Ok(RightOuter)
    3 -> Ok(FullOuter)
    4 -> Ok(Cross)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SessionState
// ===========================================================================

/// Database session lifecycle states.
/// 
/// Matches `SessionState` in `DbserverABI.Types`.
pub type SessionState {
  /// Idle (tag 0).
  Idle
  /// Connected (tag 1).
  Connected
  /// Transaction (tag 2).
  Transaction
  /// Executing (tag 3).
  Executing
  /// Finalising (tag 4).
  Finalising
  /// Disconnecting (tag 5).
  Disconnecting
}

/// Convert a `SessionState` to its C-ABI tag value.
pub fn session_state_to_int(value: SessionState) -> Int {
  case value {
    Idle -> 0
    Connected -> 1
    Transaction -> 2
    Executing -> 3
    Finalising -> 4
    Disconnecting -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn session_state_from_int(tag: Int) -> Result(SessionState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Connected)
    2 -> Ok(Transaction)
    3 -> Ok(Executing)
    4 -> Ok(Finalising)
    5 -> Ok(Disconnecting)
    _ -> Error(Nil)
  }
}

