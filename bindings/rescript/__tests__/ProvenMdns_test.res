// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenMdns protocol bindings.

open ProvenMdns

let test_mdnsRecordType_roundtrip = () => {
  assert(mdnsRecordTypeFromTag(0) == Some(A))
  assert(mdnsRecordTypeFromTag(1) == Some(Aaaa))
  assert(mdnsRecordTypeFromTag(2) == Some(Ptr))
  assert(mdnsRecordTypeFromTag(3) == Some(Srv))
  assert(mdnsRecordTypeFromTag(4) == Some(Txt))
  assert(mdnsRecordTypeFromTag(5) == None)
}

let test_mdnsRecordType_toTag = () => {
  assert(mdnsRecordTypeToTag(A) == 0)
  assert(mdnsRecordTypeToTag(Aaaa) == 1)
  assert(mdnsRecordTypeToTag(Ptr) == 2)
  assert(mdnsRecordTypeToTag(Srv) == 3)
  assert(mdnsRecordTypeToTag(Txt) == 4)
}

let test_queryType_roundtrip = () => {
  assert(queryTypeFromTag(0) == Some(Standard))
  assert(queryTypeFromTag(1) == Some(OneShot))
  assert(queryTypeFromTag(2) == Some(Continuous))
  assert(queryTypeFromTag(3) == None)
}

let test_queryType_toTag = () => {
  assert(queryTypeToTag(Standard) == 0)
  assert(queryTypeToTag(OneShot) == 1)
  assert(queryTypeToTag(Continuous) == 2)
}

let test_conflictAction_roundtrip = () => {
  assert(conflictActionFromTag(0) == Some(Probe))
  assert(conflictActionFromTag(1) == Some(Defend))
  assert(conflictActionFromTag(2) == Some(Withdraw))
  assert(conflictActionFromTag(3) == None)
}

let test_conflictAction_toTag = () => {
  assert(conflictActionToTag(Probe) == 0)
  assert(conflictActionToTag(Defend) == 1)
  assert(conflictActionToTag(Withdraw) == 2)
}

let test_serviceFlag_roundtrip = () => {
  assert(serviceFlagFromTag(0) == Some(Unique))
  assert(serviceFlagFromTag(1) == Some(Shared))
  assert(serviceFlagFromTag(2) == None)
}

let test_serviceFlag_toTag = () => {
  assert(serviceFlagToTag(Unique) == 0)
  assert(serviceFlagToTag(Shared) == 1)
}

let test_responderState_roundtrip = () => {
  assert(responderStateFromTag(0) == Some(Idle))
  assert(responderStateFromTag(1) == Some(Probing))
  assert(responderStateFromTag(2) == Some(Announcing))
  assert(responderStateFromTag(3) == Some(Running))
  assert(responderStateFromTag(4) == Some(ShuttingDown))
  assert(responderStateFromTag(5) == None)
}

let test_responderState_toTag = () => {
  assert(responderStateToTag(Idle) == 0)
  assert(responderStateToTag(Probing) == 1)
  assert(responderStateToTag(Announcing) == 2)
  assert(responderStateToTag(Running) == 3)
  assert(responderStateToTag(ShuttingDown) == 4)
}

// Run all tests
test_mdnsRecordType_roundtrip()
test_mdnsRecordType_toTag()
test_queryType_roundtrip()
test_queryType_toTag()
test_conflictAction_roundtrip()
test_conflictAction_toTag()
test_serviceFlag_roundtrip()
test_serviceFlag_toTag()
test_responderState_roundtrip()
test_responderState_toTag()
