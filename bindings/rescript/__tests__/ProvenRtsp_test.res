// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenRtsp protocol bindings.

open ProvenRtsp

let test_method_roundtrip = () => {
  assert(methodFromTag(0) == Some(Describe))
  assert(methodFromTag(1) == Some(Setup))
  assert(methodFromTag(2) == Some(Play))
  assert(methodFromTag(3) == Some(Pause))
  assert(methodFromTag(4) == Some(Teardown))
  assert(methodFromTag(5) == Some(GetParameter))
  assert(methodFromTag(6) == Some(SetParameter))
  assert(methodFromTag(7) == Some(Options))
  assert(methodFromTag(8) == Some(Announce))
  assert(methodFromTag(9) == Some(Record))
  assert(methodFromTag(10) == Some(Redirect))
  assert(methodFromTag(11) == None)
}

let test_method_toTag = () => {
  assert(methodToTag(Describe) == 0)
  assert(methodToTag(Setup) == 1)
  assert(methodToTag(Play) == 2)
  assert(methodToTag(Pause) == 3)
  assert(methodToTag(Teardown) == 4)
  assert(methodToTag(GetParameter) == 5)
  assert(methodToTag(SetParameter) == 6)
  assert(methodToTag(Options) == 7)
  assert(methodToTag(Announce) == 8)
  assert(methodToTag(Record) == 9)
  assert(methodToTag(Redirect) == 10)
}

let test_transportProtocol_roundtrip = () => {
  assert(transportProtocolFromTag(0) == Some(RtpAvpUdp))
  assert(transportProtocolFromTag(1) == Some(RtpAvpTcp))
  assert(transportProtocolFromTag(2) == Some(RtpAvpUdpMulticast))
  assert(transportProtocolFromTag(3) == None)
}

let test_transportProtocol_toTag = () => {
  assert(transportProtocolToTag(RtpAvpUdp) == 0)
  assert(transportProtocolToTag(RtpAvpTcp) == 1)
  assert(transportProtocolToTag(RtpAvpUdpMulticast) == 2)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Init))
  assert(sessionStateFromTag(1) == Some(Ready))
  assert(sessionStateFromTag(2) == Some(Playing))
  assert(sessionStateFromTag(3) == Some(Recording))
  assert(sessionStateFromTag(4) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Init) == 0)
  assert(sessionStateToTag(Ready) == 1)
  assert(sessionStateToTag(Playing) == 2)
  assert(sessionStateToTag(Recording) == 3)
}

let test_statusCode_roundtrip = () => {
  assert(statusCodeFromTag(0) == Some(Ok))
  assert(statusCodeFromTag(1) == Some(MovedPermanently))
  assert(statusCodeFromTag(2) == Some(MovedTemporarily))
  assert(statusCodeFromTag(3) == Some(BadRequest))
  assert(statusCodeFromTag(4) == Some(Unauthorized))
  assert(statusCodeFromTag(5) == Some(NotFound))
  assert(statusCodeFromTag(6) == Some(MethodNotAllowed))
  assert(statusCodeFromTag(7) == Some(NotAcceptable))
  assert(statusCodeFromTag(8) == Some(SessionNotFound))
  assert(statusCodeFromTag(9) == Some(InternalServerError))
  assert(statusCodeFromTag(10) == Some(NotImplemented))
  assert(statusCodeFromTag(11) == Some(ServiceUnavailable))
  assert(statusCodeFromTag(12) == None)
}

let test_statusCode_toTag = () => {
  assert(statusCodeToTag(Ok) == 0)
  assert(statusCodeToTag(MovedPermanently) == 1)
  assert(statusCodeToTag(MovedTemporarily) == 2)
  assert(statusCodeToTag(BadRequest) == 3)
  assert(statusCodeToTag(Unauthorized) == 4)
  assert(statusCodeToTag(NotFound) == 5)
  assert(statusCodeToTag(MethodNotAllowed) == 6)
  assert(statusCodeToTag(NotAcceptable) == 7)
  assert(statusCodeToTag(SessionNotFound) == 8)
  assert(statusCodeToTag(InternalServerError) == 9)
  assert(statusCodeToTag(NotImplemented) == 10)
  assert(statusCodeToTag(ServiceUnavailable) == 11)
}

let test_rtspError_roundtrip = () => {
  assert(rtspErrorFromTag(0) == Some(Ok))
  assert(rtspErrorFromTag(1) == Some(InvalidSlot))
  assert(rtspErrorFromTag(2) == Some(NotActive))
  assert(rtspErrorFromTag(3) == Some(InvalidTransition))
  assert(rtspErrorFromTag(4) == Some(MethodNotAllowed))
  assert(rtspErrorFromTag(5) == Some(TransportError))
  assert(rtspErrorFromTag(6) == Some(SessionExpired))
  assert(rtspErrorFromTag(7) == None)
}

let test_rtspError_toTag = () => {
  assert(rtspErrorToTag(Ok) == 0)
  assert(rtspErrorToTag(InvalidSlot) == 1)
  assert(rtspErrorToTag(NotActive) == 2)
  assert(rtspErrorToTag(InvalidTransition) == 3)
  assert(rtspErrorToTag(MethodNotAllowed) == 4)
  assert(rtspErrorToTag(TransportError) == 5)
  assert(rtspErrorToTag(SessionExpired) == 6)
}

// Run all tests
test_method_roundtrip()
test_method_toTag()
test_transportProtocol_roundtrip()
test_transportProtocol_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
test_statusCode_roundtrip()
test_statusCode_toTag()
test_rtspError_roundtrip()
test_rtspError_toTag()
