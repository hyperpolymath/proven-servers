// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Tests for ProvenApiserver protocol bindings.

open ProvenApiserver

let test_authScheme_roundtrip = () => {
  assert(authSchemeFromTag(0) == Some(ApiKey))
  assert(authSchemeFromTag(1) == Some(Bearer))
  assert(authSchemeFromTag(2) == Some(Basic))
  assert(authSchemeFromTag(3) == Some(OAuth2))
  assert(authSchemeFromTag(4) == Some(Hmac))
  assert(authSchemeFromTag(5) == Some(Mtls))
  assert(authSchemeFromTag(6) == None)
}

let test_authScheme_toTag = () => {
  assert(authSchemeToTag(ApiKey) == 0)
  assert(authSchemeToTag(Bearer) == 1)
  assert(authSchemeToTag(Basic) == 2)
  assert(authSchemeToTag(OAuth2) == 3)
  assert(authSchemeToTag(Hmac) == 4)
  assert(authSchemeToTag(Mtls) == 5)
}

let test_rateLimitStrategy_roundtrip = () => {
  assert(rateLimitStrategyFromTag(0) == Some(FixedWindow))
  assert(rateLimitStrategyFromTag(1) == Some(SlidingWindow))
  assert(rateLimitStrategyFromTag(2) == Some(TokenBucket))
  assert(rateLimitStrategyFromTag(3) == Some(LeakyBucket))
  assert(rateLimitStrategyFromTag(4) == None)
}

let test_rateLimitStrategy_toTag = () => {
  assert(rateLimitStrategyToTag(FixedWindow) == 0)
  assert(rateLimitStrategyToTag(SlidingWindow) == 1)
  assert(rateLimitStrategyToTag(TokenBucket) == 2)
  assert(rateLimitStrategyToTag(LeakyBucket) == 3)
}

let test_apiVersion_roundtrip = () => {
  assert(apiVersionFromTag(0) == Some(V1))
  assert(apiVersionFromTag(1) == Some(V2))
  assert(apiVersionFromTag(2) == Some(V3))
  assert(apiVersionFromTag(3) == Some(Latest))
  assert(apiVersionFromTag(4) == Some(Deprecated))
  assert(apiVersionFromTag(5) == None)
}

let test_apiVersion_toTag = () => {
  assert(apiVersionToTag(V1) == 0)
  assert(apiVersionToTag(V2) == 1)
  assert(apiVersionToTag(V3) == 2)
  assert(apiVersionToTag(Latest) == 3)
  assert(apiVersionToTag(Deprecated) == 4)
}

let test_responseFormat_roundtrip = () => {
  assert(responseFormatFromTag(0) == Some(Json))
  assert(responseFormatFromTag(1) == Some(Xml))
  assert(responseFormatFromTag(2) == Some(Protobuf))
  assert(responseFormatFromTag(3) == Some(MessagePack))
  assert(responseFormatFromTag(4) == None)
}

let test_responseFormat_toTag = () => {
  assert(responseFormatToTag(Json) == 0)
  assert(responseFormatToTag(Xml) == 1)
  assert(responseFormatToTag(Protobuf) == 2)
  assert(responseFormatToTag(MessagePack) == 3)
}

let test_gatewayError_roundtrip = () => {
  assert(gatewayErrorFromTag(0) == Some(Unauthorized))
  assert(gatewayErrorFromTag(1) == Some(RateLimited))
  assert(gatewayErrorFromTag(2) == Some(NotFound))
  assert(gatewayErrorFromTag(3) == Some(BadRequest))
  assert(gatewayErrorFromTag(4) == Some(ServiceUnavailable))
  assert(gatewayErrorFromTag(5) == Some(CircuitOpen))
  assert(gatewayErrorFromTag(6) == None)
}

let test_gatewayError_toTag = () => {
  assert(gatewayErrorToTag(Unauthorized) == 0)
  assert(gatewayErrorToTag(RateLimited) == 1)
  assert(gatewayErrorToTag(NotFound) == 2)
  assert(gatewayErrorToTag(BadRequest) == 3)
  assert(gatewayErrorToTag(ServiceUnavailable) == 4)
  assert(gatewayErrorToTag(CircuitOpen) == 5)
}

// Run all tests
test_authScheme_roundtrip()
test_authScheme_toTag()
test_rateLimitStrategy_roundtrip()
test_rateLimitStrategy_toTag()
test_apiVersion_roundtrip()
test_apiVersion_toTag()
test_responseFormat_roundtrip()
test_responseFormat_toTag()
test_gatewayError_roundtrip()
test_gatewayError_toTag()
