// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenWebdav protocol bindings.

open ProvenWebdav

let test_method_roundtrip = () => {
  assert(methodFromTag(0) == Some(Propfind))
  assert(methodFromTag(1) == Some(Proppatch))
  assert(methodFromTag(2) == Some(Mkcol))
  assert(methodFromTag(3) == Some(Copy))
  assert(methodFromTag(4) == Some(Move))
  assert(methodFromTag(5) == Some(Lock))
  assert(methodFromTag(6) == Some(Unlock))
  assert(methodFromTag(7) == None)
}

let test_method_toTag = () => {
  assert(methodToTag(Propfind) == 0)
  assert(methodToTag(Proppatch) == 1)
  assert(methodToTag(Mkcol) == 2)
  assert(methodToTag(Copy) == 3)
  assert(methodToTag(Move) == 4)
  assert(methodToTag(Lock) == 5)
  assert(methodToTag(Unlock) == 6)
}

let test_statusCode_roundtrip = () => {
  assert(statusCodeFromTag(0) == Some(MultiStatus))
  assert(statusCodeFromTag(1) == Some(UnprocessableEntity))
  assert(statusCodeFromTag(2) == Some(Locked))
  assert(statusCodeFromTag(3) == Some(FailedDependency))
  assert(statusCodeFromTag(4) == Some(InsufficientStorage))
  assert(statusCodeFromTag(5) == None)
}

let test_statusCode_toTag = () => {
  assert(statusCodeToTag(MultiStatus) == 0)
  assert(statusCodeToTag(UnprocessableEntity) == 1)
  assert(statusCodeToTag(Locked) == 2)
  assert(statusCodeToTag(FailedDependency) == 3)
  assert(statusCodeToTag(InsufficientStorage) == 4)
}

let test_lockScope_roundtrip = () => {
  assert(lockScopeFromTag(0) == Some(Exclusive))
  assert(lockScopeFromTag(1) == Some(Shared))
  assert(lockScopeFromTag(2) == None)
}

let test_lockScope_toTag = () => {
  assert(lockScopeToTag(Exclusive) == 0)
  assert(lockScopeToTag(Shared) == 1)
}

let test_lockType_roundtrip = () => {
  assert(lockTypeFromTag(0) == Some(Write))
  assert(lockTypeFromTag(1) == None)
}

let test_lockType_toTag = () => {
  assert(lockTypeToTag(Write) == 0)
}

let test_depth_roundtrip = () => {
  assert(depthFromTag(0) == Some(Zero))
  assert(depthFromTag(1) == Some(One))
  assert(depthFromTag(2) == Some(Infinity))
  assert(depthFromTag(3) == None)
}

let test_depth_toTag = () => {
  assert(depthToTag(Zero) == 0)
  assert(depthToTag(One) == 1)
  assert(depthToTag(Infinity) == 2)
}

let test_propertyOp_roundtrip = () => {
  assert(propertyOpFromTag(0) == Some(Set))
  assert(propertyOpFromTag(1) == Some(Remove))
  assert(propertyOpFromTag(2) == None)
}

let test_propertyOp_toTag = () => {
  assert(propertyOpToTag(Set) == 0)
  assert(propertyOpToTag(Remove) == 1)
}

// Run all tests
test_method_roundtrip()
test_method_toTag()
test_statusCode_roundtrip()
test_statusCode_toTag()
test_lockScope_roundtrip()
test_lockScope_toTag()
test_lockType_roundtrip()
test_lockType_toTag()
test_depth_roundtrip()
test_depth_toTag()
test_propertyOp_roundtrip()
test_propertyOp_toTag()
