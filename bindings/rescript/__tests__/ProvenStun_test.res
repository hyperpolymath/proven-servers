// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenStun protocol bindings.

open ProvenStun

let test_messageType_roundtrip = () => {
  assert(messageTypeFromTag(0) == Some(BindingRequest))
  assert(messageTypeFromTag(1) == Some(BindingResponse))
  assert(messageTypeFromTag(2) == Some(BindingError))
  assert(messageTypeFromTag(3) == Some(AllocateRequest))
  assert(messageTypeFromTag(4) == Some(AllocateResponse))
  assert(messageTypeFromTag(5) == Some(AllocateError))
  assert(messageTypeFromTag(6) == Some(RefreshRequest))
  assert(messageTypeFromTag(7) == Some(RefreshResponse))
  assert(messageTypeFromTag(8) == Some(SendIndication))
  assert(messageTypeFromTag(9) == Some(DataIndication))
  assert(messageTypeFromTag(10) == Some(CreatePermission))
  assert(messageTypeFromTag(11) == Some(ChannelBind))
  assert(messageTypeFromTag(12) == None)
}

let test_messageType_toTag = () => {
  assert(messageTypeToTag(BindingRequest) == 0)
  assert(messageTypeToTag(BindingResponse) == 1)
  assert(messageTypeToTag(BindingError) == 2)
  assert(messageTypeToTag(AllocateRequest) == 3)
  assert(messageTypeToTag(AllocateResponse) == 4)
  assert(messageTypeToTag(AllocateError) == 5)
  assert(messageTypeToTag(RefreshRequest) == 6)
  assert(messageTypeToTag(RefreshResponse) == 7)
  assert(messageTypeToTag(SendIndication) == 8)
  assert(messageTypeToTag(DataIndication) == 9)
  assert(messageTypeToTag(CreatePermission) == 10)
  assert(messageTypeToTag(ChannelBind) == 11)
}

let test_transportProtocol_roundtrip = () => {
  assert(transportProtocolFromTag(0) == Some(Udp))
  assert(transportProtocolFromTag(1) == Some(Tcp))
  assert(transportProtocolFromTag(2) == Some(Tls))
  assert(transportProtocolFromTag(3) == Some(Dtls))
  assert(transportProtocolFromTag(4) == None)
}

let test_transportProtocol_toTag = () => {
  assert(transportProtocolToTag(Udp) == 0)
  assert(transportProtocolToTag(Tcp) == 1)
  assert(transportProtocolToTag(Tls) == 2)
  assert(transportProtocolToTag(Dtls) == 3)
}

let test_errorCode_roundtrip = () => {
  assert(errorCodeFromTag(0) == Some(TryAlternate))
  assert(errorCodeFromTag(1) == Some(BadRequest))
  assert(errorCodeFromTag(2) == Some(Unauthorized))
  assert(errorCodeFromTag(3) == Some(Forbidden))
  assert(errorCodeFromTag(4) == Some(MobilityForbidden))
  assert(errorCodeFromTag(5) == Some(StaleNonce))
  assert(errorCodeFromTag(6) == Some(ServerError))
  assert(errorCodeFromTag(7) == Some(InsufficientCapacity))
  assert(errorCodeFromTag(8) == None)
}

let test_errorCode_toTag = () => {
  assert(errorCodeToTag(TryAlternate) == 0)
  assert(errorCodeToTag(BadRequest) == 1)
  assert(errorCodeToTag(Unauthorized) == 2)
  assert(errorCodeToTag(Forbidden) == 3)
  assert(errorCodeToTag(MobilityForbidden) == 4)
  assert(errorCodeToTag(StaleNonce) == 5)
  assert(errorCodeToTag(ServerError) == 6)
  assert(errorCodeToTag(InsufficientCapacity) == 7)
}

// Run all tests
test_messageType_roundtrip()
test_messageType_toTag()
test_transportProtocol_roundtrip()
test_transportProtocol_toTag()
test_errorCode_roundtrip()
test_errorCode_toTag()
