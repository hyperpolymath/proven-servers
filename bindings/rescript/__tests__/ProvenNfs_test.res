// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenNfs protocol bindings.

open ProvenNfs

let test_operation_roundtrip = () => {
  assert(operationFromTag(0) == Some(Access))
  assert(operationFromTag(1) == Some(Close))
  assert(operationFromTag(2) == Some(Commit))
  assert(operationFromTag(3) == Some(Create))
  assert(operationFromTag(4) == Some(GetAttr))
  assert(operationFromTag(5) == Some(Link))
  assert(operationFromTag(6) == Some(Lock))
  assert(operationFromTag(7) == Some(Lookup))
  assert(operationFromTag(8) == Some(Open))
  assert(operationFromTag(9) == Some(Read))
  assert(operationFromTag(10) == Some(ReadDir))
  assert(operationFromTag(11) == Some(Remove))
  assert(operationFromTag(12) == Some(Rename))
  assert(operationFromTag(13) == Some(SetAttr))
  assert(operationFromTag(14) == Some(Write))
  assert(operationFromTag(15) == None)
}

let test_operation_toTag = () => {
  assert(operationToTag(Access) == 0)
  assert(operationToTag(Close) == 1)
  assert(operationToTag(Commit) == 2)
  assert(operationToTag(Create) == 3)
  assert(operationToTag(GetAttr) == 4)
  assert(operationToTag(Link) == 5)
  assert(operationToTag(Lock) == 6)
  assert(operationToTag(Lookup) == 7)
  assert(operationToTag(Open) == 8)
  assert(operationToTag(Read) == 9)
  assert(operationToTag(ReadDir) == 10)
  assert(operationToTag(Remove) == 11)
  assert(operationToTag(Rename) == 12)
  assert(operationToTag(SetAttr) == 13)
  assert(operationToTag(Write) == 14)
}

let test_fileType_roundtrip = () => {
  assert(fileTypeFromTag(0) == Some(Regular))
  assert(fileTypeFromTag(1) == Some(Directory))
  assert(fileTypeFromTag(2) == Some(BlockDevice))
  assert(fileTypeFromTag(3) == Some(CharDevice))
  assert(fileTypeFromTag(4) == Some(Link))
  assert(fileTypeFromTag(5) == Some(Socket))
  assert(fileTypeFromTag(6) == Some(Fifo))
  assert(fileTypeFromTag(7) == None)
}

let test_fileType_toTag = () => {
  assert(fileTypeToTag(Regular) == 0)
  assert(fileTypeToTag(Directory) == 1)
  assert(fileTypeToTag(BlockDevice) == 2)
  assert(fileTypeToTag(CharDevice) == 3)
  assert(fileTypeToTag(Link) == 4)
  assert(fileTypeToTag(Socket) == 5)
  assert(fileTypeToTag(Fifo) == 6)
}

let test_status_roundtrip = () => {
  assert(statusFromTag(0) == Some(Ok))
  assert(statusFromTag(1) == Some(Perm))
  assert(statusFromTag(2) == Some(NoEnt))
  assert(statusFromTag(3) == Some(Io))
  assert(statusFromTag(4) == Some(NxIo))
  assert(statusFromTag(5) == Some(Access))
  assert(statusFromTag(6) == Some(Exist))
  assert(statusFromTag(7) == Some(NotDir))
  assert(statusFromTag(8) == Some(IsDir))
  assert(statusFromTag(9) == Some(FBig))
  assert(statusFromTag(10) == Some(NoSpc))
  assert(statusFromTag(11) == Some(ROfs))
  assert(statusFromTag(12) == Some(NotEmpty))
  assert(statusFromTag(13) == Some(Stale))
  assert(statusFromTag(14) == None)
}

let test_status_toTag = () => {
  assert(statusToTag(Ok) == 0)
  assert(statusToTag(Perm) == 1)
  assert(statusToTag(NoEnt) == 2)
  assert(statusToTag(Io) == 3)
  assert(statusToTag(NxIo) == 4)
  assert(statusToTag(Access) == 5)
  assert(statusToTag(Exist) == 6)
  assert(statusToTag(NotDir) == 7)
  assert(statusToTag(IsDir) == 8)
  assert(statusToTag(FBig) == 9)
  assert(statusToTag(NoSpc) == 10)
  assert(statusToTag(ROfs) == 11)
  assert(statusToTag(NotEmpty) == 12)
  assert(statusToTag(Stale) == 13)
}

let test_nfsState_roundtrip = () => {
  assert(nfsStateFromTag(0) == Some(Idle))
  assert(nfsStateFromTag(1) == Some(Mounted))
  assert(nfsStateFromTag(2) == Some(FileOpen))
  assert(nfsStateFromTag(3) == Some(Locked))
  assert(nfsStateFromTag(4) == Some(Busy))
  assert(nfsStateFromTag(5) == Some(Unmounting))
  assert(nfsStateFromTag(6) == None)
}

let test_nfsState_toTag = () => {
  assert(nfsStateToTag(Idle) == 0)
  assert(nfsStateToTag(Mounted) == 1)
  assert(nfsStateToTag(FileOpen) == 2)
  assert(nfsStateToTag(Locked) == 3)
  assert(nfsStateToTag(Busy) == 4)
  assert(nfsStateToTag(Unmounting) == 5)
}

// Run all tests
test_operation_roundtrip()
test_operation_toTag()
test_fileType_roundtrip()
test_fileType_toTag()
test_status_roundtrip()
test_status_toTag()
test_nfsState_roundtrip()
test_nfsState_toTag()
