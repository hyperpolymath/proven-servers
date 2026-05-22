// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Database server types for the proven-servers ABI.
//
// Mirrors the Idris2 module DbserverABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard PostgreSQL port.
let dbserverPort = 5432

// ===========================================================================
// QueryType (tags 0-11)
// ===========================================================================

/// Standard PostgreSQL port.
type queryType =
  | @as(0) Select
  | @as(1) Insert
  | @as(2) Update
  | @as(3) Delete
  | @as(4) CreateTable
  | @as(5) DropTable
  | @as(6) AlterTable
  | @as(7) CreateIndex
  | @as(8) DropIndex
  | @as(9) Begin
  | @as(10) Commit
  | @as(11) Rollback

/// Decode from the C-ABI tag value.
let queryTypeFromTag = (tag: int): option<queryType> =>
  switch tag {
  | 0 => Some(Select)
  | 1 => Some(Insert)
  | 2 => Some(Update)
  | 3 => Some(Delete)
  | 4 => Some(CreateTable)
  | 5 => Some(DropTable)
  | 6 => Some(AlterTable)
  | 7 => Some(CreateIndex)
  | 8 => Some(DropIndex)
  | 9 => Some(Begin)
  | 10 => Some(Commit)
  | 11 => Some(Rollback)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let queryTypeToTag = (v: queryType): int =>
  switch v {
  | Select => 0
  | Insert => 1
  | Update => 2
  | Delete => 3
  | CreateTable => 4
  | DropTable => 5
  | AlterTable => 6
  | CreateIndex => 7
  | DropIndex => 8
  | Begin => 9
  | Commit => 10
  | Rollback => 11
  }

/// Whether this is a DDL (schema modification) query.
let queryTypeIsDdl = (v: queryType): bool =>
  switch v {
  | CreateTable | DropTable | AlterTable | CreateIndex | DropIndex => true
  | _ => false
  }

/// Whether this is a transaction control statement.
let queryTypeIsTransactionControl = (v: queryType): bool =>
  switch v {
  | Begin | Commit | Rollback => true
  | _ => false
  }

// ===========================================================================
// DataType (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type dataType =
  | @as(0) Integer
  | @as(1) Float
  | @as(2) Text
  | @as(3) Blob
  | @as(4) Boolean
  | @as(5) Timestamp
  | @as(6) Uuid
  | @as(7) Json
  | @as(8) Null

/// Decode from the C-ABI tag value.
let dataTypeFromTag = (tag: int): option<dataType> =>
  switch tag {
  | 0 => Some(Integer)
  | 1 => Some(Float)
  | 2 => Some(Text)
  | 3 => Some(Blob)
  | 4 => Some(Boolean)
  | 5 => Some(Timestamp)
  | 6 => Some(Uuid)
  | 7 => Some(Json)
  | 8 => Some(Null)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let dataTypeToTag = (v: dataType): int =>
  switch v {
  | Integer => 0
  | Float => 1
  | Text => 2
  | Blob => 3
  | Boolean => 4
  | Timestamp => 5
  | Uuid => 6
  | Json => 7
  | Null => 8
  }

// ===========================================================================
// IsolationLevel (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type isolationLevel =
  | @as(0) ReadUncommitted
  | @as(1) ReadCommitted
  | @as(2) RepeatableRead
  | @as(3) Serializable

/// Decode from the C-ABI tag value.
let isolationLevelFromTag = (tag: int): option<isolationLevel> =>
  switch tag {
  | 0 => Some(ReadUncommitted)
  | 1 => Some(ReadCommitted)
  | 2 => Some(RepeatableRead)
  | 3 => Some(Serializable)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let isolationLevelToTag = (v: isolationLevel): int =>
  switch v {
  | ReadUncommitted => 0
  | ReadCommitted => 1
  | RepeatableRead => 2
  | Serializable => 3
  }

// ===========================================================================
// ErrorCode (tags 0-9)
// ===========================================================================

/// Decode from an ABI tag value.
type errorCode =
  | @as(0) SyntaxError
  | @as(1) TableNotFound
  | @as(2) ColumnNotFound
  | @as(3) DuplicateKey
  | @as(4) ConstraintViolation
  | @as(5) TypeMismatch
  | @as(6) DeadlockDetected
  | @as(7) TransactionAborted
  | @as(8) DiskFull
  | @as(9) ConnectionLost

/// Decode from the C-ABI tag value.
let errorCodeFromTag = (tag: int): option<errorCode> =>
  switch tag {
  | 0 => Some(SyntaxError)
  | 1 => Some(TableNotFound)
  | 2 => Some(ColumnNotFound)
  | 3 => Some(DuplicateKey)
  | 4 => Some(ConstraintViolation)
  | 5 => Some(TypeMismatch)
  | 6 => Some(DeadlockDetected)
  | 7 => Some(TransactionAborted)
  | 8 => Some(DiskFull)
  | 9 => Some(ConnectionLost)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorCodeToTag = (v: errorCode): int =>
  switch v {
  | SyntaxError => 0
  | TableNotFound => 1
  | ColumnNotFound => 2
  | DuplicateKey => 3
  | ConstraintViolation => 4
  | TypeMismatch => 5
  | DeadlockDetected => 6
  | TransactionAborted => 7
  | DiskFull => 8
  | ConnectionLost => 9
  }

/// Whether this error is potentially recoverable.
let errorCodeIsRecoverable = (v: errorCode): bool =>
  switch v {
  | DeadlockDetected | TransactionAborted | ConnectionLost => true
  | _ => false
  }

// ===========================================================================
// JoinType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type joinType =
  | @as(0) Inner
  | @as(1) LeftOuter
  | @as(2) RightOuter
  | @as(3) FullOuter
  | @as(4) Cross

/// Decode from the C-ABI tag value.
let joinTypeFromTag = (tag: int): option<joinType> =>
  switch tag {
  | 0 => Some(Inner)
  | 1 => Some(LeftOuter)
  | 2 => Some(RightOuter)
  | 3 => Some(FullOuter)
  | 4 => Some(Cross)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let joinTypeToTag = (v: joinType): int =>
  switch v {
  | Inner => 0
  | LeftOuter => 1
  | RightOuter => 2
  | FullOuter => 3
  | Cross => 4
  }

// ===========================================================================
// SessionState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Connected
  | @as(2) Transaction
  | @as(3) Executing
  | @as(4) Finalising
  | @as(5) Disconnecting

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Connected)
  | 2 => Some(Transaction)
  | 3 => Some(Executing)
  | 4 => Some(Finalising)
  | 5 => Some(Disconnecting)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Connected => 1
  | Transaction => 2
  | Executing => 3
  | Finalising => 4
  | Disconnecting => 5
  }

/// Whether queries can be executed in this state.
let sessionStateCanQuery = (v: sessionState): bool =>
  switch v {
  | Connected | Transaction => true
  | _ => false
  }

