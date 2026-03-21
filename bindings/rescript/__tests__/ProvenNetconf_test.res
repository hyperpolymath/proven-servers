// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenNetconf protocol bindings.

open ProvenNetconf

let test_netconfOperation_roundtrip = () => {
  assert(netconfOperationFromTag(0) == Some(Get))
  assert(netconfOperationFromTag(1) == Some(GetConfig))
  assert(netconfOperationFromTag(2) == Some(EditConfig))
  assert(netconfOperationFromTag(3) == Some(CopyConfig))
  assert(netconfOperationFromTag(4) == Some(DeleteConfig))
  assert(netconfOperationFromTag(5) == Some(Lock))
  assert(netconfOperationFromTag(6) == Some(Unlock))
  assert(netconfOperationFromTag(7) == Some(CloseSession))
  assert(netconfOperationFromTag(8) == Some(KillSession))
  assert(netconfOperationFromTag(9) == Some(Commit))
  assert(netconfOperationFromTag(10) == Some(Validate))
  assert(netconfOperationFromTag(11) == Some(DiscardChanges))
  assert(netconfOperationFromTag(12) == None)
}

let test_netconfOperation_toTag = () => {
  assert(netconfOperationToTag(Get) == 0)
  assert(netconfOperationToTag(GetConfig) == 1)
  assert(netconfOperationToTag(EditConfig) == 2)
  assert(netconfOperationToTag(CopyConfig) == 3)
  assert(netconfOperationToTag(DeleteConfig) == 4)
  assert(netconfOperationToTag(Lock) == 5)
  assert(netconfOperationToTag(Unlock) == 6)
  assert(netconfOperationToTag(CloseSession) == 7)
  assert(netconfOperationToTag(KillSession) == 8)
  assert(netconfOperationToTag(Commit) == 9)
  assert(netconfOperationToTag(Validate) == 10)
  assert(netconfOperationToTag(DiscardChanges) == 11)
}

let test_datastore_roundtrip = () => {
  assert(datastoreFromTag(0) == Some(Running))
  assert(datastoreFromTag(1) == Some(Startup))
  assert(datastoreFromTag(2) == Some(Candidate))
  assert(datastoreFromTag(3) == None)
}

let test_datastore_toTag = () => {
  assert(datastoreToTag(Running) == 0)
  assert(datastoreToTag(Startup) == 1)
  assert(datastoreToTag(Candidate) == 2)
}

let test_editOperation_roundtrip = () => {
  assert(editOperationFromTag(0) == Some(Merge))
  assert(editOperationFromTag(1) == Some(Replace))
  assert(editOperationFromTag(2) == Some(Create))
  assert(editOperationFromTag(3) == Some(Delete))
  assert(editOperationFromTag(4) == Some(Remove))
  assert(editOperationFromTag(5) == None)
}

let test_editOperation_toTag = () => {
  assert(editOperationToTag(Merge) == 0)
  assert(editOperationToTag(Replace) == 1)
  assert(editOperationToTag(Create) == 2)
  assert(editOperationToTag(Delete) == 3)
  assert(editOperationToTag(Remove) == 4)
}

let test_netconfErrorType_roundtrip = () => {
  assert(netconfErrorTypeFromTag(0) == Some(Transport))
  assert(netconfErrorTypeFromTag(1) == Some(Rpc))
  assert(netconfErrorTypeFromTag(2) == Some(Protocol))
  assert(netconfErrorTypeFromTag(3) == Some(Application))
  assert(netconfErrorTypeFromTag(4) == None)
}

let test_netconfErrorType_toTag = () => {
  assert(netconfErrorTypeToTag(Transport) == 0)
  assert(netconfErrorTypeToTag(Rpc) == 1)
  assert(netconfErrorTypeToTag(Protocol) == 2)
  assert(netconfErrorTypeToTag(Application) == 3)
}

let test_errorSeverity_roundtrip = () => {
  assert(errorSeverityFromTag(0) == Some(Error))
  assert(errorSeverityFromTag(1) == Some(Warning))
  assert(errorSeverityFromTag(2) == None)
}

let test_errorSeverity_toTag = () => {
  assert(errorSeverityToTag(Error) == 0)
  assert(errorSeverityToTag(Warning) == 1)
}

let test_netconfState_roundtrip = () => {
  assert(netconfStateFromTag(0) == Some(Idle))
  assert(netconfStateFromTag(1) == Some(Connected))
  assert(netconfStateFromTag(2) == Some(Locked))
  assert(netconfStateFromTag(3) == Some(Editing))
  assert(netconfStateFromTag(4) == Some(Closing))
  assert(netconfStateFromTag(5) == Some(Terminated))
  assert(netconfStateFromTag(6) == None)
}

let test_netconfState_toTag = () => {
  assert(netconfStateToTag(Idle) == 0)
  assert(netconfStateToTag(Connected) == 1)
  assert(netconfStateToTag(Locked) == 2)
  assert(netconfStateToTag(Editing) == 3)
  assert(netconfStateToTag(Closing) == 4)
  assert(netconfStateToTag(Terminated) == 5)
}

// Run all tests
test_netconfOperation_roundtrip()
test_netconfOperation_toTag()
test_datastore_roundtrip()
test_datastore_toTag()
test_editOperation_roundtrip()
test_editOperation_toTag()
test_netconfErrorType_roundtrip()
test_netconfErrorType_toTag()
test_errorSeverity_roundtrip()
test_errorSeverity_toTag()
test_netconfState_roundtrip()
test_netconfState_toTag()
