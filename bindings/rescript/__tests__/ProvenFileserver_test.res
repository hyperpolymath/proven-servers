// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenFileserver protocol bindings.

open ProvenFileserver

let test_fileOperation_roundtrip = () => {
  assert(fileOperationFromTag(0) == Some(Read))
  assert(fileOperationFromTag(1) == Some(Write))
  assert(fileOperationFromTag(2) == Some(Create))
  assert(fileOperationFromTag(3) == Some(Delete))
  assert(fileOperationFromTag(4) == Some(Rename))
  assert(fileOperationFromTag(5) == Some(List))
  assert(fileOperationFromTag(6) == Some(Stat))
  assert(fileOperationFromTag(7) == Some(Lock))
  assert(fileOperationFromTag(8) == Some(Unlock))
  assert(fileOperationFromTag(9) == Some(Watch))
  assert(fileOperationFromTag(10) == None)
}

let test_fileOperation_toTag = () => {
  assert(fileOperationToTag(Read) == 0)
  assert(fileOperationToTag(Write) == 1)
  assert(fileOperationToTag(Create) == 2)
  assert(fileOperationToTag(Delete) == 3)
  assert(fileOperationToTag(Rename) == 4)
  assert(fileOperationToTag(List) == 5)
  assert(fileOperationToTag(Stat) == 6)
  assert(fileOperationToTag(Lock) == 7)
  assert(fileOperationToTag(Unlock) == 8)
  assert(fileOperationToTag(Watch) == 9)
}

let test_fileType_roundtrip = () => {
  assert(fileTypeFromTag(0) == Some(Regular))
  assert(fileTypeFromTag(1) == Some(Directory))
  assert(fileTypeFromTag(2) == Some(Symlink))
  assert(fileTypeFromTag(3) == Some(BlockDevice))
  assert(fileTypeFromTag(4) == Some(CharDevice))
  assert(fileTypeFromTag(5) == Some(Fifo))
  assert(fileTypeFromTag(6) == Some(Socket))
  assert(fileTypeFromTag(7) == None)
}

let test_fileType_toTag = () => {
  assert(fileTypeToTag(Regular) == 0)
  assert(fileTypeToTag(Directory) == 1)
  assert(fileTypeToTag(Symlink) == 2)
  assert(fileTypeToTag(BlockDevice) == 3)
  assert(fileTypeToTag(CharDevice) == 4)
  assert(fileTypeToTag(Fifo) == 5)
  assert(fileTypeToTag(Socket) == 6)
}

let test_filePermission_roundtrip = () => {
  assert(filePermissionFromTag(0) == Some(OwnerRead))
  assert(filePermissionFromTag(1) == Some(OwnerWrite))
  assert(filePermissionFromTag(2) == Some(OwnerExecute))
  assert(filePermissionFromTag(3) == Some(GroupRead))
  assert(filePermissionFromTag(4) == Some(GroupWrite))
  assert(filePermissionFromTag(5) == Some(GroupExecute))
  assert(filePermissionFromTag(6) == Some(OtherRead))
  assert(filePermissionFromTag(7) == Some(OtherWrite))
  assert(filePermissionFromTag(8) == Some(OtherExecute))
  assert(filePermissionFromTag(9) == None)
}

let test_filePermission_toTag = () => {
  assert(filePermissionToTag(OwnerRead) == 0)
  assert(filePermissionToTag(OwnerWrite) == 1)
  assert(filePermissionToTag(OwnerExecute) == 2)
  assert(filePermissionToTag(GroupRead) == 3)
  assert(filePermissionToTag(GroupWrite) == 4)
  assert(filePermissionToTag(GroupExecute) == 5)
  assert(filePermissionToTag(OtherRead) == 6)
  assert(filePermissionToTag(OtherWrite) == 7)
  assert(filePermissionToTag(OtherExecute) == 8)
}

let test_lockType_roundtrip = () => {
  assert(lockTypeFromTag(0) == Some(Shared))
  assert(lockTypeFromTag(1) == Some(Exclusive))
  assert(lockTypeFromTag(2) == Some(Advisory))
  assert(lockTypeFromTag(3) == Some(Mandatory))
  assert(lockTypeFromTag(4) == None)
}

let test_lockType_toTag = () => {
  assert(lockTypeToTag(Shared) == 0)
  assert(lockTypeToTag(Exclusive) == 1)
  assert(lockTypeToTag(Advisory) == 2)
  assert(lockTypeToTag(Mandatory) == 3)
}

let test_fileErrorCode_roundtrip = () => {
  assert(fileErrorCodeFromTag(0) == Some(NotFound))
  assert(fileErrorCodeFromTag(1) == Some(PermissionDenied))
  assert(fileErrorCodeFromTag(2) == Some(AlreadyExists))
  assert(fileErrorCodeFromTag(3) == Some(NotEmpty))
  assert(fileErrorCodeFromTag(4) == Some(IsDirectory))
  assert(fileErrorCodeFromTag(5) == Some(NotDirectory))
  assert(fileErrorCodeFromTag(6) == Some(NoSpace))
  assert(fileErrorCodeFromTag(7) == Some(ReadOnly))
  assert(fileErrorCodeFromTag(8) == Some(Locked))
  assert(fileErrorCodeFromTag(9) == Some(IoError))
  assert(fileErrorCodeFromTag(10) == None)
}

let test_fileErrorCode_toTag = () => {
  assert(fileErrorCodeToTag(NotFound) == 0)
  assert(fileErrorCodeToTag(PermissionDenied) == 1)
  assert(fileErrorCodeToTag(AlreadyExists) == 2)
  assert(fileErrorCodeToTag(NotEmpty) == 3)
  assert(fileErrorCodeToTag(IsDirectory) == 4)
  assert(fileErrorCodeToTag(NotDirectory) == 5)
  assert(fileErrorCodeToTag(NoSpace) == 6)
  assert(fileErrorCodeToTag(ReadOnly) == 7)
  assert(fileErrorCodeToTag(Locked) == 8)
  assert(fileErrorCodeToTag(IoError) == 9)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Connected))
  assert(sessionStateFromTag(2) == Some(Operating))
  assert(sessionStateFromTag(3) == Some(FsLocked))
  assert(sessionStateFromTag(4) == Some(Disconnecting))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Connected) == 1)
  assert(sessionStateToTag(Operating) == 2)
  assert(sessionStateToTag(FsLocked) == 3)
  assert(sessionStateToTag(Disconnecting) == 4)
}

// Run all tests
test_fileOperation_roundtrip()
test_fileOperation_toTag()
test_fileType_roundtrip()
test_fileType_toTag()
test_filePermission_roundtrip()
test_filePermission_toTag()
test_lockType_roundtrip()
test_lockType_toTag()
test_fileErrorCode_roundtrip()
test_fileErrorCode_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
