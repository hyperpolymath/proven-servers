// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// API Server types for the proven-servers ABI.
//
// Mirrors the Idris2 module ApiserverABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard API server port.
let apiPort = 8080

// ===========================================================================
// AuthScheme (tags 0-5)
// ===========================================================================

/// Standard API server port.
type authScheme =
  | @as(0) ApiKey
  | @as(1) Bearer
  | @as(2) Basic
  | @as(3) OAuth2
  | @as(4) Hmac
  | @as(5) Mtls

/// Decode from the C-ABI tag value.
let authSchemeFromTag = (tag: int): option<authScheme> =>
  switch tag {
  | 0 => Some(ApiKey)
  | 1 => Some(Bearer)
  | 2 => Some(Basic)
  | 3 => Some(OAuth2)
  | 4 => Some(Hmac)
  | 5 => Some(Mtls)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let authSchemeToTag = (v: authScheme): int =>
  switch v {
  | ApiKey => 0
  | Bearer => 1
  | Basic => 2
  | OAuth2 => 3
  | Hmac => 4
  | Mtls => 5
  }

// ===========================================================================
// RateLimitStrategy (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type rateLimitStrategy =
  | @as(0) FixedWindow
  | @as(1) SlidingWindow
  | @as(2) TokenBucket
  | @as(3) LeakyBucket

/// Decode from the C-ABI tag value.
let rateLimitStrategyFromTag = (tag: int): option<rateLimitStrategy> =>
  switch tag {
  | 0 => Some(FixedWindow)
  | 1 => Some(SlidingWindow)
  | 2 => Some(TokenBucket)
  | 3 => Some(LeakyBucket)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let rateLimitStrategyToTag = (v: rateLimitStrategy): int =>
  switch v {
  | FixedWindow => 0
  | SlidingWindow => 1
  | TokenBucket => 2
  | LeakyBucket => 3
  }

// ===========================================================================
// ApiVersion (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type apiVersion =
  | @as(0) V1
  | @as(1) V2
  | @as(2) V3
  | @as(3) Latest
  | @as(4) Deprecated

/// Decode from the C-ABI tag value.
let apiVersionFromTag = (tag: int): option<apiVersion> =>
  switch tag {
  | 0 => Some(V1)
  | 1 => Some(V2)
  | 2 => Some(V3)
  | 3 => Some(Latest)
  | 4 => Some(Deprecated)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let apiVersionToTag = (v: apiVersion): int =>
  switch v {
  | V1 => 0
  | V2 => 1
  | V3 => 2
  | Latest => 3
  | Deprecated => 4
  }

// ===========================================================================
// ResponseFormat (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type responseFormat =
  | @as(0) Json
  | @as(1) Xml
  | @as(2) Protobuf
  | @as(3) MessagePack

/// Decode from the C-ABI tag value.
let responseFormatFromTag = (tag: int): option<responseFormat> =>
  switch tag {
  | 0 => Some(Json)
  | 1 => Some(Xml)
  | 2 => Some(Protobuf)
  | 3 => Some(MessagePack)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let responseFormatToTag = (v: responseFormat): int =>
  switch v {
  | Json => 0
  | Xml => 1
  | Protobuf => 2
  | MessagePack => 3
  }

// ===========================================================================
// GatewayError (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type gatewayError =
  | @as(0) Unauthorized
  | @as(1) RateLimited
  | @as(2) NotFound
  | @as(3) BadRequest
  | @as(4) ServiceUnavailable
  | @as(5) CircuitOpen

/// Decode from the C-ABI tag value.
let gatewayErrorFromTag = (tag: int): option<gatewayError> =>
  switch tag {
  | 0 => Some(Unauthorized)
  | 1 => Some(RateLimited)
  | 2 => Some(NotFound)
  | 3 => Some(BadRequest)
  | 4 => Some(ServiceUnavailable)
  | 5 => Some(CircuitOpen)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let gatewayErrorToTag = (v: gatewayError): int =>
  switch v {
  | Unauthorized => 0
  | RateLimited => 1
  | NotFound => 2
  | BadRequest => 3
  | ServiceUnavailable => 4
  | CircuitOpen => 5
  }

