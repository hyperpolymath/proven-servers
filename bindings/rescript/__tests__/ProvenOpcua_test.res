// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenOpcua protocol bindings.

open ProvenOpcua

let test_serviceType_roundtrip = () => {
  assert(serviceTypeFromTag(0) == Some(Read))
  assert(serviceTypeFromTag(1) == Some(Write))
  assert(serviceTypeFromTag(2) == Some(Browse))
  assert(serviceTypeFromTag(3) == Some(Subscribe))
  assert(serviceTypeFromTag(4) == Some(Publish))
  assert(serviceTypeFromTag(5) == Some(Call))
  assert(serviceTypeFromTag(6) == Some(CreateSession))
  assert(serviceTypeFromTag(7) == Some(ActivateSession))
  assert(serviceTypeFromTag(8) == Some(CloseSession))
  assert(serviceTypeFromTag(9) == Some(CreateSubscription))
  assert(serviceTypeFromTag(10) == Some(DeleteSubscription))
  assert(serviceTypeFromTag(11) == None)
}

let test_serviceType_toTag = () => {
  assert(serviceTypeToTag(Read) == 0)
  assert(serviceTypeToTag(Write) == 1)
  assert(serviceTypeToTag(Browse) == 2)
  assert(serviceTypeToTag(Subscribe) == 3)
  assert(serviceTypeToTag(Publish) == 4)
  assert(serviceTypeToTag(Call) == 5)
  assert(serviceTypeToTag(CreateSession) == 6)
  assert(serviceTypeToTag(ActivateSession) == 7)
  assert(serviceTypeToTag(CloseSession) == 8)
  assert(serviceTypeToTag(CreateSubscription) == 9)
  assert(serviceTypeToTag(DeleteSubscription) == 10)
}

let test_nodeClass_roundtrip = () => {
  assert(nodeClassFromTag(0) == Some(Object))
  assert(nodeClassFromTag(1) == Some(Variable))
  assert(nodeClassFromTag(2) == Some(Method))
  assert(nodeClassFromTag(3) == Some(ObjectType))
  assert(nodeClassFromTag(4) == Some(VariableType))
  assert(nodeClassFromTag(5) == Some(ReferenceType))
  assert(nodeClassFromTag(6) == Some(DataType))
  assert(nodeClassFromTag(7) == Some(View))
  assert(nodeClassFromTag(8) == None)
}

let test_nodeClass_toTag = () => {
  assert(nodeClassToTag(Object) == 0)
  assert(nodeClassToTag(Variable) == 1)
  assert(nodeClassToTag(Method) == 2)
  assert(nodeClassToTag(ObjectType) == 3)
  assert(nodeClassToTag(VariableType) == 4)
  assert(nodeClassToTag(ReferenceType) == 5)
  assert(nodeClassToTag(DataType) == 6)
  assert(nodeClassToTag(View) == 7)
}

let test_statusCode_roundtrip = () => {
  assert(statusCodeFromTag(0) == Some(Good))
  assert(statusCodeFromTag(1) == Some(Uncertain))
  assert(statusCodeFromTag(2) == Some(Bad))
  assert(statusCodeFromTag(3) == Some(BadNodeIdUnknown))
  assert(statusCodeFromTag(4) == Some(BadAttributeIdInvalid))
  assert(statusCodeFromTag(5) == Some(BadNotReadable))
  assert(statusCodeFromTag(6) == Some(BadNotWritable))
  assert(statusCodeFromTag(7) == Some(BadOutOfRange))
  assert(statusCodeFromTag(8) == Some(BadTypeMismatch))
  assert(statusCodeFromTag(9) == Some(BadSessionIdInvalid))
  assert(statusCodeFromTag(10) == Some(BadSubscriptionIdInvalid))
  assert(statusCodeFromTag(11) == Some(BadTimeout))
  assert(statusCodeFromTag(12) == None)
}

let test_statusCode_toTag = () => {
  assert(statusCodeToTag(Good) == 0)
  assert(statusCodeToTag(Uncertain) == 1)
  assert(statusCodeToTag(Bad) == 2)
  assert(statusCodeToTag(BadNodeIdUnknown) == 3)
  assert(statusCodeToTag(BadAttributeIdInvalid) == 4)
  assert(statusCodeToTag(BadNotReadable) == 5)
  assert(statusCodeToTag(BadNotWritable) == 6)
  assert(statusCodeToTag(BadOutOfRange) == 7)
  assert(statusCodeToTag(BadTypeMismatch) == 8)
  assert(statusCodeToTag(BadSessionIdInvalid) == 9)
  assert(statusCodeToTag(BadSubscriptionIdInvalid) == 10)
  assert(statusCodeToTag(BadTimeout) == 11)
}

let test_securityMode_roundtrip = () => {
  assert(securityModeFromTag(0) == Some(None))
  assert(securityModeFromTag(1) == Some(Sign))
  assert(securityModeFromTag(2) == Some(SignAndEncrypt))
  assert(securityModeFromTag(3) == None)
}

let test_securityMode_toTag = () => {
  assert(securityModeToTag(None) == 0)
  assert(securityModeToTag(Sign) == 1)
  assert(securityModeToTag(SignAndEncrypt) == 2)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Connected))
  assert(sessionStateFromTag(2) == Some(Created))
  assert(sessionStateFromTag(3) == Some(Activated))
  assert(sessionStateFromTag(4) == Some(Monitoring))
  assert(sessionStateFromTag(5) == Some(Closing))
  assert(sessionStateFromTag(6) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Connected) == 1)
  assert(sessionStateToTag(Created) == 2)
  assert(sessionStateToTag(Activated) == 3)
  assert(sessionStateToTag(Monitoring) == 4)
  assert(sessionStateToTag(Closing) == 5)
}

// Run all tests
test_serviceType_roundtrip()
test_serviceType_toTag()
test_nodeClass_roundtrip()
test_nodeClass_toTag()
test_statusCode_roundtrip()
test_statusCode_toTag()
test_securityMode_roundtrip()
test_securityMode_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
