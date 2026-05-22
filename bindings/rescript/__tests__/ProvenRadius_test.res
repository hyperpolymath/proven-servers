// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenRadius protocol bindings.

open ProvenRadius

let test_packetType_roundtrip = () => {
  assert(packetTypeFromTag(1) == Some(AccessRequest))
  assert(packetTypeFromTag(2) == Some(AccessAccept))
  assert(packetTypeFromTag(3) == Some(AccessReject))
  assert(packetTypeFromTag(4) == Some(AccountingRequest))
  assert(packetTypeFromTag(5) == Some(AccountingResponse))
  assert(packetTypeFromTag(11) == Some(AccessChallenge))
  assert(packetTypeFromTag(12) == None)
}

let test_packetType_toTag = () => {
  assert(packetTypeToTag(AccessRequest) == 1)
  assert(packetTypeToTag(AccessAccept) == 2)
  assert(packetTypeToTag(AccessReject) == 3)
  assert(packetTypeToTag(AccountingRequest) == 4)
  assert(packetTypeToTag(AccountingResponse) == 5)
  assert(packetTypeToTag(AccessChallenge) == 11)
}

let test_attributeType_roundtrip = () => {
  assert(attributeTypeFromTag(1) == Some(UserName))
  assert(attributeTypeFromTag(2) == Some(UserPassword))
  assert(attributeTypeFromTag(4) == Some(NasIpAddress))
  assert(attributeTypeFromTag(5) == Some(NasPort))
  assert(attributeTypeFromTag(6) == Some(ServiceType))
  assert(attributeTypeFromTag(7) == Some(FramedProtocol))
  assert(attributeTypeFromTag(8) == Some(FramedIpAddress))
  assert(attributeTypeFromTag(18) == Some(ReplyMessage))
  assert(attributeTypeFromTag(27) == Some(SessionTimeout))
  assert(attributeTypeFromTag(28) == None)
}

let test_attributeType_toTag = () => {
  assert(attributeTypeToTag(UserName) == 1)
  assert(attributeTypeToTag(UserPassword) == 2)
  assert(attributeTypeToTag(NasIpAddress) == 4)
  assert(attributeTypeToTag(NasPort) == 5)
  assert(attributeTypeToTag(ServiceType) == 6)
  assert(attributeTypeToTag(FramedProtocol) == 7)
  assert(attributeTypeToTag(FramedIpAddress) == 8)
  assert(attributeTypeToTag(ReplyMessage) == 18)
  assert(attributeTypeToTag(SessionTimeout) == 27)
}

let test_serviceType_roundtrip = () => {
  assert(serviceTypeFromTag(1) == Some(Login))
  assert(serviceTypeFromTag(2) == Some(Framed))
  assert(serviceTypeFromTag(3) == Some(CallbackLogin))
  assert(serviceTypeFromTag(4) == Some(CallbackFramed))
  assert(serviceTypeFromTag(5) == Some(Outbound))
  assert(serviceTypeFromTag(6) == Some(Administrative))
  assert(serviceTypeFromTag(7) == None)
}

let test_serviceType_toTag = () => {
  assert(serviceTypeToTag(Login) == 1)
  assert(serviceTypeToTag(Framed) == 2)
  assert(serviceTypeToTag(CallbackLogin) == 3)
  assert(serviceTypeToTag(CallbackFramed) == 4)
  assert(serviceTypeToTag(Outbound) == 5)
  assert(serviceTypeToTag(Administrative) == 6)
}

let test_authMethod_roundtrip = () => {
  assert(authMethodFromTag(0) == Some(Pap))
  assert(authMethodFromTag(1) == Some(Chap))
  assert(authMethodFromTag(2) == Some(Mschap))
  assert(authMethodFromTag(3) == Some(Mschapv2))
  assert(authMethodFromTag(4) == Some(Eap))
  assert(authMethodFromTag(5) == None)
}

let test_authMethod_toTag = () => {
  assert(authMethodToTag(Pap) == 0)
  assert(authMethodToTag(Chap) == 1)
  assert(authMethodToTag(Mschap) == 2)
  assert(authMethodToTag(Mschapv2) == 3)
  assert(authMethodToTag(Eap) == 4)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Authenticating))
  assert(sessionStateFromTag(2) == Some(Authorized))
  assert(sessionStateFromTag(3) == Some(Rejected))
  assert(sessionStateFromTag(4) == Some(Challenged))
  assert(sessionStateFromTag(5) == Some(Accounting))
  assert(sessionStateFromTag(6) == Some(Complete))
  assert(sessionStateFromTag(7) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Authenticating) == 1)
  assert(sessionStateToTag(Authorized) == 2)
  assert(sessionStateToTag(Rejected) == 3)
  assert(sessionStateToTag(Challenged) == 4)
  assert(sessionStateToTag(Accounting) == 5)
  assert(sessionStateToTag(Complete) == 6)
}

let test_radiusResult_roundtrip = () => {
  assert(radiusResultFromTag(0) == Some(Ok))
  assert(radiusResultFromTag(1) == Some(Err))
  assert(radiusResultFromTag(2) == Some(InvalidParam))
  assert(radiusResultFromTag(3) == Some(PoolExhausted))
  assert(radiusResultFromTag(4) == Some(BadSecret))
  assert(radiusResultFromTag(5) == None)
}

let test_radiusResult_toTag = () => {
  assert(radiusResultToTag(Ok) == 0)
  assert(radiusResultToTag(Err) == 1)
  assert(radiusResultToTag(InvalidParam) == 2)
  assert(radiusResultToTag(PoolExhausted) == 3)
  assert(radiusResultToTag(BadSecret) == 4)
}

// Run all tests
test_packetType_roundtrip()
test_packetType_toTag()
test_attributeType_roundtrip()
test_attributeType_toTag()
test_serviceType_roundtrip()
test_serviceType_toTag()
test_authMethod_roundtrip()
test_authMethod_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
test_radiusResult_roundtrip()
test_radiusResult_toTag()
