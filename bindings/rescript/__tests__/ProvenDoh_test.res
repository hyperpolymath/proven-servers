// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenDoh protocol bindings.

open ProvenDoh

let test_contentType_roundtrip = () => {
  assert(contentTypeFromTag(0) == Some(DnsMessage))
  assert(contentTypeFromTag(1) == Some(DnsJson))
  assert(contentTypeFromTag(2) == None)
}

let test_contentType_toTag = () => {
  assert(contentTypeToTag(DnsMessage) == 0)
  assert(contentTypeToTag(DnsJson) == 1)
}

let test_requestMethod_roundtrip = () => {
  assert(requestMethodFromTag(0) == Some(Get))
  assert(requestMethodFromTag(1) == Some(Post))
  assert(requestMethodFromTag(2) == None)
}

let test_requestMethod_toTag = () => {
  assert(requestMethodToTag(Get) == 0)
  assert(requestMethodToTag(Post) == 1)
}

let test_wireFormat_roundtrip = () => {
  assert(wireFormatFromTag(0) == Some(Binary))
  assert(wireFormatFromTag(1) == Some(Json))
  assert(wireFormatFromTag(2) == None)
}

let test_wireFormat_toTag = () => {
  assert(wireFormatToTag(Binary) == 0)
  assert(wireFormatToTag(Json) == 1)
}

let test_errorReason_roundtrip = () => {
  assert(errorReasonFromTag(0) == Some(BadContentType))
  assert(errorReasonFromTag(1) == Some(BadMethod))
  assert(errorReasonFromTag(2) == Some(PayloadTooLarge))
  assert(errorReasonFromTag(3) == Some(UpstreamTimeout))
  assert(errorReasonFromTag(4) == Some(UpstreamError))
  assert(errorReasonFromTag(5) == None)
}

let test_errorReason_toTag = () => {
  assert(errorReasonToTag(BadContentType) == 0)
  assert(errorReasonToTag(BadMethod) == 1)
  assert(errorReasonToTag(PayloadTooLarge) == 2)
  assert(errorReasonToTag(UpstreamTimeout) == 3)
  assert(errorReasonToTag(UpstreamError) == 4)
}

let test_sessionState_roundtrip = () => {
  assert(sessionStateFromTag(0) == Some(Idle))
  assert(sessionStateFromTag(1) == Some(Bound))
  assert(sessionStateFromTag(2) == Some(Serving))
  assert(sessionStateFromTag(3) == Some(Resolving))
  assert(sessionStateFromTag(4) == Some(Shutdown))
  assert(sessionStateFromTag(5) == None)
}

let test_sessionState_toTag = () => {
  assert(sessionStateToTag(Idle) == 0)
  assert(sessionStateToTag(Bound) == 1)
  assert(sessionStateToTag(Serving) == 2)
  assert(sessionStateToTag(Resolving) == 3)
  assert(sessionStateToTag(Shutdown) == 4)
}

// Run all tests
test_contentType_roundtrip()
test_contentType_toTag()
test_requestMethod_roundtrip()
test_requestMethod_toTag()
test_wireFormat_roundtrip()
test_wireFormat_toTag()
test_errorReason_roundtrip()
test_errorReason_toTag()
test_sessionState_roundtrip()
test_sessionState_toTag()
