// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenLdap protocol bindings.

open ProvenLdap

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Anonymous))
  assert(sessionStateFromTag(1) == Some(Bound))
  assert(sessionStateFromTag(2) == Some(Closed))
  assert(sessionStateFromTag(3) == Some(Binding))
  assert(sessionStateFromTag(4) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Anonymous) == 0)
  assert(sessionStateToTag(Bound) == 1)
  assert(sessionStateToTag(Closed) == 2)
  assert(sessionStateToTag(Binding) == 3)
}

let test_operation_roundtrip = () => {
  assert(operationFromTag(0) == Some(Bind))
  assert(operationFromTag(1) == Some(Unbind))
  assert(operationFromTag(2) == Some(Search))
  assert(operationFromTag(3) == Some(Modify))
  assert(operationFromTag(4) == Some(Add))
  assert(operationFromTag(5) == Some(Delete))
  assert(operationFromTag(6) == Some(ModDn))
  assert(operationFromTag(7) == Some(Compare))
  assert(operationFromTag(8) == Some(Abandon))
  assert(operationFromTag(9) == Some(Extended))
  assert(operationFromTag(10) == None)
}

let test_operation_toTag = () => {
  assert(operationToTag(Bind) == 0)
  assert(operationToTag(Unbind) == 1)
  assert(operationToTag(Search) == 2)
  assert(operationToTag(Modify) == 3)
  assert(operationToTag(Add) == 4)
  assert(operationToTag(Delete) == 5)
  assert(operationToTag(ModDn) == 6)
  assert(operationToTag(Compare) == 7)
  assert(operationToTag(Abandon) == 8)
  assert(operationToTag(Extended) == 9)
}

let test_searchScope_roundtrip = () => {
  assert(searchScopeFromTag(0) == Some(BaseObject))
  assert(searchScopeFromTag(1) == Some(SingleLevel))
  assert(searchScopeFromTag(2) == Some(WholeSubtree))
  assert(searchScopeFromTag(3) == None)
}

let test_searchScope_toTag = () => {
  assert(searchScopeToTag(BaseObject) == 0)
  assert(searchScopeToTag(SingleLevel) == 1)
  assert(searchScopeToTag(WholeSubtree) == 2)
}

let test_resultCode_roundtrip = () => {
  assert(resultCodeFromTag(0) == Some(Success))
  assert(resultCodeFromTag(1) == Some(OperationsError))
  assert(resultCodeFromTag(2) == Some(ProtocolError))
  assert(resultCodeFromTag(3) == Some(TimeLimitExceeded))
  assert(resultCodeFromTag(4) == Some(SizeLimitExceeded))
  assert(resultCodeFromTag(5) == Some(AuthMethodNotSupported))
  assert(resultCodeFromTag(6) == Some(NoSuchObject))
  assert(resultCodeFromTag(7) == Some(InvalidCredentials))
  assert(resultCodeFromTag(8) == Some(InsufficientAccessRights))
  assert(resultCodeFromTag(9) == Some(Busy))
  assert(resultCodeFromTag(10) == Some(Unavailable))
  assert(resultCodeFromTag(11) == None)
}

let test_resultCode_toTag = () => {
  assert(resultCodeToTag(Success) == 0)
  assert(resultCodeToTag(OperationsError) == 1)
  assert(resultCodeToTag(ProtocolError) == 2)
  assert(resultCodeToTag(TimeLimitExceeded) == 3)
  assert(resultCodeToTag(SizeLimitExceeded) == 4)
  assert(resultCodeToTag(AuthMethodNotSupported) == 5)
  assert(resultCodeToTag(NoSuchObject) == 6)
  assert(resultCodeToTag(InvalidCredentials) == 7)
  assert(resultCodeToTag(InsufficientAccessRights) == 8)
  assert(resultCodeToTag(Busy) == 9)
  assert(resultCodeToTag(Unavailable) == 10)
}

// Run all tests
test_sessionState_roundtrip()
test_sessionState_toTag()
test_operation_roundtrip()
test_operation_toTag()
test_searchScope_roundtrip()
test_searchScope_toTag()
test_resultCode_roundtrip()
test_resultCode_toTag()
