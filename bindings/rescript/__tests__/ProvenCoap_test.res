// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenCoap protocol bindings.

open ProvenCoap

let test_method_roundtrip = () => {
  assert(methodFromTag(0) == Some(Get))
  assert(methodFromTag(1) == Some(Post))
  assert(methodFromTag(2) == Some(Put))
  assert(methodFromTag(3) == Some(Delete))
  assert(methodFromTag(4) == None)
}

let test_method_toTag = () => {
  assert(methodToTag(Get) == 0)
  assert(methodToTag(Post) == 1)
  assert(methodToTag(Put) == 2)
  assert(methodToTag(Delete) == 3)
}

let test_messageType_roundtrip = () => {
  assert(messageTypeFromTag(0) == Some(Confirmable))
  assert(messageTypeFromTag(1) == Some(NonConfirmable))
  assert(messageTypeFromTag(2) == Some(Acknowledgement))
  assert(messageTypeFromTag(3) == Some(Reset))
  assert(messageTypeFromTag(4) == None)
}

let test_messageType_toTag = () => {
  assert(messageTypeToTag(Confirmable) == 0)
  assert(messageTypeToTag(NonConfirmable) == 1)
  assert(messageTypeToTag(Acknowledgement) == 2)
  assert(messageTypeToTag(Reset) == 3)
}

let test_contentFormat_roundtrip = () => {
  assert(contentFormatFromTag(0) == Some(TextPlain))
  assert(contentFormatFromTag(1) == Some(LinkFormat))
  assert(contentFormatFromTag(2) == Some(Xml))
  assert(contentFormatFromTag(3) == Some(OctetStream))
  assert(contentFormatFromTag(4) == Some(Exi))
  assert(contentFormatFromTag(5) == Some(Json))
  assert(contentFormatFromTag(6) == Some(Cbor))
  assert(contentFormatFromTag(7) == None)
}

let test_contentFormat_toTag = () => {
  assert(contentFormatToTag(TextPlain) == 0)
  assert(contentFormatToTag(LinkFormat) == 1)
  assert(contentFormatToTag(Xml) == 2)
  assert(contentFormatToTag(OctetStream) == 3)
  assert(contentFormatToTag(Exi) == 4)
  assert(contentFormatToTag(Json) == 5)
  assert(contentFormatToTag(Cbor) == 6)
}

let test_responseClass_roundtrip = () => {
  assert(responseClassFromTag(0) == Some(Success))
  assert(responseClassFromTag(1) == Some(ClientError))
  assert(responseClassFromTag(2) == Some(ServerError))
  assert(responseClassFromTag(3) == Some(Signaling))
  assert(responseClassFromTag(4) == Some(Empty))
  assert(responseClassFromTag(5) == None)
}

let test_responseClass_toTag = () => {
  assert(responseClassToTag(Success) == 0)
  assert(responseClassToTag(ClientError) == 1)
  assert(responseClassToTag(ServerError) == 2)
  assert(responseClassToTag(Signaling) == 3)
  assert(responseClassToTag(Empty) == 4)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Bound))
  assert(sessionStateFromTag(2) == Some(Serving))
  assert(sessionStateFromTag(3) == Some(Observing))
  assert(sessionStateFromTag(4) == Some(Shutdown))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Bound) == 1)
  assert(sessionStateToTag(Serving) == 2)
  assert(sessionStateToTag(Observing) == 3)
  assert(sessionStateToTag(Shutdown) == 4)
}

// Run all tests
test_method_roundtrip()
test_method_toTag()
test_messageType_roundtrip()
test_messageType_toTag()
test_contentFormat_roundtrip()
test_contentFormat_toTag()
test_responseClass_roundtrip()
test_responseClass_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
