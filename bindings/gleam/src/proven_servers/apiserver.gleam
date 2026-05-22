//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// API Server protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `ApiserverABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// API Server Constants
// ===========================================================================

/// Api Port constant.
pub const api_port = 8080

// ===========================================================================
// AuthScheme
// ===========================================================================

/// API authentication schemes.
/// 
/// Matches `AuthScheme` in `ApiserverABI.Types`.
pub type AuthScheme {
  /// API Key (tag 0).
  ApiKey
  /// Bearer (tag 1).
  Bearer
  /// Basic (tag 2).
  Basic
  /// OAuth2 (tag 3).
  OAuth2
  /// HMAC (tag 4).
  Hmac
  /// mTLS (tag 5).
  Mtls
}

/// Convert a `AuthScheme` to its C-ABI tag value.
pub fn auth_scheme_to_int(value: AuthScheme) -> Int {
  case value {
    ApiKey -> 0
    Bearer -> 1
    Basic -> 2
    OAuth2 -> 3
    Hmac -> 4
    Mtls -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn auth_scheme_from_int(tag: Int) -> Result(AuthScheme, Nil) {
  case tag {
    0 -> Ok(ApiKey)
    1 -> Ok(Bearer)
    2 -> Ok(Basic)
    3 -> Ok(OAuth2)
    4 -> Ok(Hmac)
    5 -> Ok(Mtls)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// RateLimitStrategy
// ===========================================================================

/// API rate limiting strategies.
/// 
/// Matches `RateLimitStrategy` in `ApiserverABI.Types`.
pub type RateLimitStrategy {
  /// FixedWindow (tag 0).
  FixedWindow
  /// SlidingWindow (tag 1).
  SlidingWindow
  /// TokenBucket (tag 2).
  TokenBucket
  /// LeakyBucket (tag 3).
  LeakyBucket
}

/// Convert a `RateLimitStrategy` to its C-ABI tag value.
pub fn rate_limit_strategy_to_int(value: RateLimitStrategy) -> Int {
  case value {
    FixedWindow -> 0
    SlidingWindow -> 1
    TokenBucket -> 2
    LeakyBucket -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn rate_limit_strategy_from_int(tag: Int) -> Result(RateLimitStrategy, Nil) {
  case tag {
    0 -> Ok(FixedWindow)
    1 -> Ok(SlidingWindow)
    2 -> Ok(TokenBucket)
    3 -> Ok(LeakyBucket)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ApiVersion
// ===========================================================================

/// API version identifiers.
/// 
/// Matches `ApiVersion` in `ApiserverABI.Types`.
pub type ApiVersion {
  /// V1 (tag 0).
  V1
  /// V2 (tag 1).
  V2
  /// V3 (tag 2).
  V3
  /// Latest (tag 3).
  Latest
  /// Deprecated (tag 4).
  Deprecated
}

/// Convert a `ApiVersion` to its C-ABI tag value.
pub fn api_version_to_int(value: ApiVersion) -> Int {
  case value {
    V1 -> 0
    V2 -> 1
    V3 -> 2
    Latest -> 3
    Deprecated -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn api_version_from_int(tag: Int) -> Result(ApiVersion, Nil) {
  case tag {
    0 -> Ok(V1)
    1 -> Ok(V2)
    2 -> Ok(V3)
    3 -> Ok(Latest)
    4 -> Ok(Deprecated)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ResponseFormat
// ===========================================================================

/// API response formats.
/// 
/// Matches `ResponseFormat` in `ApiserverABI.Types`.
pub type ResponseFormat {
  /// JSON (tag 0).
  Json
  /// XML (tag 1).
  Xml
  /// Protobuf (tag 2).
  Protobuf
  /// MessagePack (tag 3).
  MessagePack
}

/// Convert a `ResponseFormat` to its C-ABI tag value.
pub fn response_format_to_int(value: ResponseFormat) -> Int {
  case value {
    Json -> 0
    Xml -> 1
    Protobuf -> 2
    MessagePack -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn response_format_from_int(tag: Int) -> Result(ResponseFormat, Nil) {
  case tag {
    0 -> Ok(Json)
    1 -> Ok(Xml)
    2 -> Ok(Protobuf)
    3 -> Ok(MessagePack)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// GatewayError
// ===========================================================================

/// API gateway error codes.
/// 
/// Matches `GatewayError` in `ApiserverABI.Types`.
pub type GatewayError {
  /// Unauthorized (tag 0).
  Unauthorized
  /// RateLimited (tag 1).
  RateLimited
  /// NotFound (tag 2).
  NotFound
  /// BadRequest (tag 3).
  BadRequest
  /// ServiceUnavailable (tag 4).
  ServiceUnavailable
  /// CircuitOpen (tag 5).
  CircuitOpen
}

/// Convert a `GatewayError` to its C-ABI tag value.
pub fn gateway_error_to_int(value: GatewayError) -> Int {
  case value {
    Unauthorized -> 0
    RateLimited -> 1
    NotFound -> 2
    BadRequest -> 3
    ServiceUnavailable -> 4
    CircuitOpen -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn gateway_error_from_int(tag: Int) -> Result(GatewayError, Nil) {
  case tag {
    0 -> Ok(Unauthorized)
    1 -> Ok(RateLimited)
    2 -> Ok(NotFound)
    3 -> Ok(BadRequest)
    4 -> Ok(ServiceUnavailable)
    5 -> Ok(CircuitOpen)
    _ -> Error(Nil)
  }
}

