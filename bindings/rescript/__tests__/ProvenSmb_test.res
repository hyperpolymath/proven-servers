// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenSmb protocol bindings.

open ProvenSmb

let test_command_roundtrip = () => {
  assert(commandFromTag(0) == Some(Negotiate))
  assert(commandFromTag(1) == Some(SessionSetup))
  assert(commandFromTag(2) == Some(Logoff))
  assert(commandFromTag(3) == Some(TreeConnect))
  assert(commandFromTag(4) == Some(TreeDisconnect))
  assert(commandFromTag(5) == Some(Create))
  assert(commandFromTag(6) == Some(Close))
  assert(commandFromTag(7) == Some(Read))
  assert(commandFromTag(8) == Some(Write))
  assert(commandFromTag(9) == Some(Lock))
  assert(commandFromTag(10) == Some(Ioctl))
  assert(commandFromTag(11) == Some(Cancel))
  assert(commandFromTag(12) == Some(QueryDirectory))
  assert(commandFromTag(13) == Some(ChangeNotify))
  assert(commandFromTag(14) == Some(QueryInfo))
  assert(commandFromTag(15) == Some(SetInfo))
  assert(commandFromTag(16) == None)
}

let test_command_toTag = () => {
  assert(commandToTag(Negotiate) == 0)
  assert(commandToTag(SessionSetup) == 1)
  assert(commandToTag(Logoff) == 2)
  assert(commandToTag(TreeConnect) == 3)
  assert(commandToTag(TreeDisconnect) == 4)
  assert(commandToTag(Create) == 5)
  assert(commandToTag(Close) == 6)
  assert(commandToTag(Read) == 7)
  assert(commandToTag(Write) == 8)
  assert(commandToTag(Lock) == 9)
  assert(commandToTag(Ioctl) == 10)
  assert(commandToTag(Cancel) == 11)
  assert(commandToTag(QueryDirectory) == 12)
  assert(commandToTag(ChangeNotify) == 13)
  assert(commandToTag(QueryInfo) == 14)
  assert(commandToTag(SetInfo) == 15)
}

let test_dialect_roundtrip = () => {
  assert(dialectFromTag(0) == Some(Smb2_0_2))
  assert(dialectFromTag(1) == Some(Smb2_1))
  assert(dialectFromTag(2) == Some(Smb3_0))
  assert(dialectFromTag(3) == Some(Smb3_0_2))
  assert(dialectFromTag(4) == Some(Smb3_1_1))
  assert(dialectFromTag(5) == None)
}

let test_dialect_toTag = () => {
  assert(dialectToTag(Smb2_0_2) == 0)
  assert(dialectToTag(Smb2_1) == 1)
  assert(dialectToTag(Smb3_0) == 2)
  assert(dialectToTag(Smb3_0_2) == 3)
  assert(dialectToTag(Smb3_1_1) == 4)
}

let test_shareType_roundtrip = () => {
  assert(shareTypeFromTag(0) == Some(Disk))
  assert(shareTypeFromTag(1) == Some(Pipe))
  assert(shareTypeFromTag(2) == Some(Print))
  assert(shareTypeFromTag(3) == None)
}

let test_shareType_toTag = () => {
  assert(shareTypeToTag(Disk) == 0)
  assert(shareTypeToTag(Pipe) == 1)
  assert(shareTypeToTag(Print) == 2)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Negotiated))
  assert(sessionStateFromTag(2) == Some(Authenticated))
  assert(sessionStateFromTag(3) == Some(TreeConnected))
  assert(sessionStateFromTag(4) == Some(FileOpen))
  assert(sessionStateFromTag(5) == Some(Disconnecting))
  assert(sessionStateFromTag(6) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Negotiated) == 1)
  assert(sessionStateToTag(Authenticated) == 2)
  assert(sessionStateToTag(TreeConnected) == 3)
  assert(sessionStateToTag(FileOpen) == 4)
  assert(sessionStateToTag(Disconnecting) == 5)
}

// Run all tests
test_command_roundtrip()
test_command_toTag()
test_dialect_roundtrip()
test_dialect_toTag()
test_shareType_roundtrip()
test_shareType_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
