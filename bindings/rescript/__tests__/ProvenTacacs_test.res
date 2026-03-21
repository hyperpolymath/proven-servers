// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenTacacs protocol bindings.

open ProvenTacacs

let test_packetType_roundtrip = () => {
  assert(packetTypeFromTag(0) == Some(Authentication))
  assert(packetTypeFromTag(1) == Some(Authorization))
  assert(packetTypeFromTag(2) == Some(Accounting))
  assert(packetTypeFromTag(3) == None)
}

let test_packetType_toTag = () => {
  assert(packetTypeToTag(Authentication) == 0)
  assert(packetTypeToTag(Authorization) == 1)
  assert(packetTypeToTag(Accounting) == 2)
}

let test_authenType_roundtrip = () => {
  assert(authenTypeFromTag(0) == Some(Ascii))
  assert(authenTypeFromTag(1) == Some(Pap))
  assert(authenTypeFromTag(2) == Some(Chap))
  assert(authenTypeFromTag(3) == Some(MsChapV1))
  assert(authenTypeFromTag(4) == Some(MsChapV2))
  assert(authenTypeFromTag(5) == None)
}

let test_authenType_toTag = () => {
  assert(authenTypeToTag(Ascii) == 0)
  assert(authenTypeToTag(Pap) == 1)
  assert(authenTypeToTag(Chap) == 2)
  assert(authenTypeToTag(MsChapV1) == 3)
  assert(authenTypeToTag(MsChapV2) == 4)
}

let test_authenAction_roundtrip = () => {
  assert(authenActionFromTag(0) == Some(Login))
  assert(authenActionFromTag(1) == Some(ChangePass))
  assert(authenActionFromTag(2) == Some(SendAuth))
  assert(authenActionFromTag(3) == None)
}

let test_authenAction_toTag = () => {
  assert(authenActionToTag(Login) == 0)
  assert(authenActionToTag(ChangePass) == 1)
  assert(authenActionToTag(SendAuth) == 2)
}

let test_authenStatus_roundtrip = () => {
  assert(authenStatusFromTag(0) == Some(Pass))
  assert(authenStatusFromTag(1) == Some(Fail))
  assert(authenStatusFromTag(2) == Some(GetData))
  assert(authenStatusFromTag(3) == Some(GetUser))
  assert(authenStatusFromTag(4) == Some(GetPass))
  assert(authenStatusFromTag(5) == Some(Restart))
  assert(authenStatusFromTag(6) == Some(Error))
  assert(authenStatusFromTag(7) == Some(Follow))
  assert(authenStatusFromTag(8) == None)
}

let test_authenStatus_toTag = () => {
  assert(authenStatusToTag(Pass) == 0)
  assert(authenStatusToTag(Fail) == 1)
  assert(authenStatusToTag(GetData) == 2)
  assert(authenStatusToTag(GetUser) == 3)
  assert(authenStatusToTag(GetPass) == 4)
  assert(authenStatusToTag(Restart) == 5)
  assert(authenStatusToTag(Error) == 6)
  assert(authenStatusToTag(Follow) == 7)
}

let test_authorStatus_roundtrip = () => {
  assert(authorStatusFromTag(0) == Some(PassAdd))
  assert(authorStatusFromTag(1) == Some(PassRepl))
  assert(authorStatusFromTag(2) == Some(Fail))
  assert(authorStatusFromTag(3) == Some(Error))
  assert(authorStatusFromTag(4) == Some(Follow))
  assert(authorStatusFromTag(5) == None)
}

let test_authorStatus_toTag = () => {
  assert(authorStatusToTag(PassAdd) == 0)
  assert(authorStatusToTag(PassRepl) == 1)
  assert(authorStatusToTag(Fail) == 2)
  assert(authorStatusToTag(Error) == 3)
  assert(authorStatusToTag(Follow) == 4)
}

let test_acctStatus_roundtrip = () => {
  assert(acctStatusFromTag(0) == Some(Success))
  assert(acctStatusFromTag(1) == Some(Error))
  assert(acctStatusFromTag(2) == Some(Follow))
  assert(acctStatusFromTag(3) == None)
}

let test_acctStatus_toTag = () => {
  assert(acctStatusToTag(Success) == 0)
  assert(acctStatusToTag(Error) == 1)
  assert(acctStatusToTag(Follow) == 2)
}

let test_acctFlag_roundtrip = () => {
  assert(acctFlagFromTag(0) == Some(Start))
  assert(acctFlagFromTag(1) == Some(Stop))
  assert(acctFlagFromTag(2) == Some(Watchdog))
  assert(acctFlagFromTag(3) == None)
}

let test_acctFlag_toTag = () => {
  assert(acctFlagToTag(Start) == 0)
  assert(acctFlagToTag(Stop) == 1)
  assert(acctFlagToTag(Watchdog) == 2)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Authenticating))
  assert(sessionStateFromTag(2) == Some(Authorizing))
  assert(sessionStateFromTag(3) == Some(Active))
  assert(sessionStateFromTag(4) == Some(Closing))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Authenticating) == 1)
  assert(sessionStateToTag(Authorizing) == 2)
  assert(sessionStateToTag(Active) == 3)
  assert(sessionStateToTag(Closing) == 4)
}

// Run all tests
test_packetType_roundtrip()
test_packetType_toTag()
test_authenType_roundtrip()
test_authenType_toTag()
test_authenAction_roundtrip()
test_authenAction_toTag()
test_authenStatus_roundtrip()
test_authenStatus_toTag()
test_authorStatus_roundtrip()
test_authorStatus_toTag()
test_acctStatus_roundtrip()
test_acctStatus_toTag()
test_acctFlag_roundtrip()
test_acctFlag_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
