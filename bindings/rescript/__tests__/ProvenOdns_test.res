// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenOdns protocol bindings.

open ProvenOdns

let test_role_roundtrip = () => {
  assert(roleFromTag(0) == Some(Client))
  assert(roleFromTag(1) == Some(Proxy))
  assert(roleFromTag(2) == Some(Target))
  assert(roleFromTag(3) == None)
}

let test_role_toTag = () => {
  assert(roleToTag(Client) == 0)
  assert(roleToTag(Proxy) == 1)
  assert(roleToTag(Target) == 2)
}

let test_odnsMessageType_roundtrip = () => {
  assert(odnsMessageTypeFromTag(0) == Some(Query))
  assert(odnsMessageTypeFromTag(1) == Some(Response))
  assert(odnsMessageTypeFromTag(2) == None)
}

let test_odnsMessageType_toTag = () => {
  assert(odnsMessageTypeToTag(Query) == 0)
  assert(odnsMessageTypeToTag(Response) == 1)
}

let test_odnsErrorReason_roundtrip = () => {
  assert(odnsErrorReasonFromTag(0) == Some(ProxyError))
  assert(odnsErrorReasonFromTag(1) == Some(TargetError))
  assert(odnsErrorReasonFromTag(2) == Some(DecryptionFailed))
  assert(odnsErrorReasonFromTag(3) == Some(InvalidConfig))
  assert(odnsErrorReasonFromTag(4) == Some(PayloadTooLarge))
  assert(odnsErrorReasonFromTag(5) == None)
}

let test_odnsErrorReason_toTag = () => {
  assert(odnsErrorReasonToTag(ProxyError) == 0)
  assert(odnsErrorReasonToTag(TargetError) == 1)
  assert(odnsErrorReasonToTag(DecryptionFailed) == 2)
  assert(odnsErrorReasonToTag(InvalidConfig) == 3)
  assert(odnsErrorReasonToTag(PayloadTooLarge) == 4)
}

let test_encapsulationFormat_roundtrip = () => {
  assert(encapsulationFormatFromTag(0) == Some(Hpke))
  assert(encapsulationFormatFromTag(1) == None)
}

let test_encapsulationFormat_toTag = () => {
  assert(encapsulationFormatToTag(Hpke) == 0)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(KeyExchange))
  assert(sessionStateFromTag(2) == Some(Ready))
  assert(sessionStateFromTag(3) == Some(Processing))
  assert(sessionStateFromTag(4) == Some(Closing))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(KeyExchange) == 1)
  assert(sessionStateToTag(Ready) == 2)
  assert(sessionStateToTag(Processing) == 3)
  assert(sessionStateToTag(Closing) == 4)
}

// Run all tests
test_role_roundtrip()
test_role_toTag()
test_odnsMessageType_roundtrip()
test_odnsMessageType_toTag()
test_odnsErrorReason_roundtrip()
test_odnsErrorReason_toTag()
test_encapsulationFormat_roundtrip()
test_encapsulationFormat_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
