// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenDbserver protocol bindings.

open ProvenDbserver

let test_queryType_roundtrip = () => {
  assert(queryTypeFromTag(0) == Some(Select))
  assert(queryTypeFromTag(1) == Some(Insert))
  assert(queryTypeFromTag(2) == Some(Update))
  assert(queryTypeFromTag(3) == Some(Delete))
  assert(queryTypeFromTag(4) == Some(CreateTable))
  assert(queryTypeFromTag(5) == Some(DropTable))
  assert(queryTypeFromTag(6) == Some(AlterTable))
  assert(queryTypeFromTag(7) == Some(CreateIndex))
  assert(queryTypeFromTag(8) == Some(DropIndex))
  assert(queryTypeFromTag(9) == Some(Begin))
  assert(queryTypeFromTag(10) == Some(Commit))
  assert(queryTypeFromTag(11) == Some(Rollback))
  assert(queryTypeFromTag(12) == None)
}

let test_queryType_toTag = () => {
  assert(queryTypeToTag(Select) == 0)
  assert(queryTypeToTag(Insert) == 1)
  assert(queryTypeToTag(Update) == 2)
  assert(queryTypeToTag(Delete) == 3)
  assert(queryTypeToTag(CreateTable) == 4)
  assert(queryTypeToTag(DropTable) == 5)
  assert(queryTypeToTag(AlterTable) == 6)
  assert(queryTypeToTag(CreateIndex) == 7)
  assert(queryTypeToTag(DropIndex) == 8)
  assert(queryTypeToTag(Begin) == 9)
  assert(queryTypeToTag(Commit) == 10)
  assert(queryTypeToTag(Rollback) == 11)
}

let test_dataType_roundtrip = () => {
  assert(dataTypeFromTag(0) == Some(Integer))
  assert(dataTypeFromTag(1) == Some(Float))
  assert(dataTypeFromTag(2) == Some(Text))
  assert(dataTypeFromTag(3) == Some(Blob))
  assert(dataTypeFromTag(4) == Some(Boolean))
  assert(dataTypeFromTag(5) == Some(Timestamp))
  assert(dataTypeFromTag(6) == Some(Uuid))
  assert(dataTypeFromTag(7) == Some(Json))
  assert(dataTypeFromTag(8) == Some(Null))
  assert(dataTypeFromTag(9) == None)
}

let test_dataType_toTag = () => {
  assert(dataTypeToTag(Integer) == 0)
  assert(dataTypeToTag(Float) == 1)
  assert(dataTypeToTag(Text) == 2)
  assert(dataTypeToTag(Blob) == 3)
  assert(dataTypeToTag(Boolean) == 4)
  assert(dataTypeToTag(Timestamp) == 5)
  assert(dataTypeToTag(Uuid) == 6)
  assert(dataTypeToTag(Json) == 7)
  assert(dataTypeToTag(Null) == 8)
}

let test_isolationLevel_roundtrip = () => {
  assert(isolationLevelFromTag(0) == Some(ReadUncommitted))
  assert(isolationLevelFromTag(1) == Some(ReadCommitted))
  assert(isolationLevelFromTag(2) == Some(RepeatableRead))
  assert(isolationLevelFromTag(3) == Some(Serializable))
  assert(isolationLevelFromTag(4) == None)
}

let test_isolationLevel_toTag = () => {
  assert(isolationLevelToTag(ReadUncommitted) == 0)
  assert(isolationLevelToTag(ReadCommitted) == 1)
  assert(isolationLevelToTag(RepeatableRead) == 2)
  assert(isolationLevelToTag(Serializable) == 3)
}

let test_errorCode_roundtrip = () => {
  assert(errorCodeFromTag(0) == Some(SyntaxError))
  assert(errorCodeFromTag(1) == Some(TableNotFound))
  assert(errorCodeFromTag(2) == Some(ColumnNotFound))
  assert(errorCodeFromTag(3) == Some(DuplicateKey))
  assert(errorCodeFromTag(4) == Some(ConstraintViolation))
  assert(errorCodeFromTag(5) == Some(TypeMismatch))
  assert(errorCodeFromTag(6) == Some(DeadlockDetected))
  assert(errorCodeFromTag(7) == Some(TransactionAborted))
  assert(errorCodeFromTag(8) == Some(DiskFull))
  assert(errorCodeFromTag(9) == Some(ConnectionLost))
  assert(errorCodeFromTag(10) == None)
}

let test_errorCode_toTag = () => {
  assert(errorCodeToTag(SyntaxError) == 0)
  assert(errorCodeToTag(TableNotFound) == 1)
  assert(errorCodeToTag(ColumnNotFound) == 2)
  assert(errorCodeToTag(DuplicateKey) == 3)
  assert(errorCodeToTag(ConstraintViolation) == 4)
  assert(errorCodeToTag(TypeMismatch) == 5)
  assert(errorCodeToTag(DeadlockDetected) == 6)
  assert(errorCodeToTag(TransactionAborted) == 7)
  assert(errorCodeToTag(DiskFull) == 8)
  assert(errorCodeToTag(ConnectionLost) == 9)
}

let test_joinType_roundtrip = () => {
  assert(joinTypeFromTag(0) == Some(Inner))
  assert(joinTypeFromTag(1) == Some(LeftOuter))
  assert(joinTypeFromTag(2) == Some(RightOuter))
  assert(joinTypeFromTag(3) == Some(FullOuter))
  assert(joinTypeFromTag(4) == Some(Cross))
  assert(joinTypeFromTag(5) == None)
}

let test_joinType_toTag = () => {
  assert(joinTypeToTag(Inner) == 0)
  assert(joinTypeToTag(LeftOuter) == 1)
  assert(joinTypeToTag(RightOuter) == 2)
  assert(joinTypeToTag(FullOuter) == 3)
  assert(joinTypeToTag(Cross) == 4)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Connected))
  assert(sessionStateFromTag(2) == Some(Transaction))
  assert(sessionStateFromTag(3) == Some(Executing))
  assert(sessionStateFromTag(4) == Some(Finalising))
  assert(sessionStateFromTag(5) == Some(Disconnecting))
  assert(sessionStateFromTag(6) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Connected) == 1)
  assert(sessionStateToTag(Transaction) == 2)
  assert(sessionStateToTag(Executing) == 3)
  assert(sessionStateToTag(Finalising) == 4)
  assert(sessionStateToTag(Disconnecting) == 5)
}

// Run all tests
test_queryType_roundtrip()
test_queryType_toTag()
test_dataType_roundtrip()
test_dataType_toTag()
test_isolationLevel_roundtrip()
test_isolationLevel_toTag()
test_errorCode_roundtrip()
test_errorCode_toTag()
test_joinType_roundtrip()
test_joinType_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
