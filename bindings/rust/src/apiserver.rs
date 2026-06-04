// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! API Server types for the proven-servers ABI.
//!
//! Formally verified API gateway/server types.
//! Mirrors the Idris2 module `ApiserverABI.Types`.
//!
//! - `AuthScheme` -- API authentication schemes.
//! - `RateLimitStrategy` -- API rate limiting strategies.
//! - `ApiVersion` -- API version identifiers.
//! - `ResponseFormat` -- API response formats.
//! - `GatewayError` -- API gateway error codes.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// API Server Constants
// ===========================================================================

/// Standard API server port.
pub const API_PORT: u16 = 8080;

// ===========================================================================
// AuthScheme (tags 0-5)
// ===========================================================================

/// API authentication schemes.
///
/// Matches `AuthScheme` in `ApiserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthScheme {
    /// API Key (tag 0).
    ApiKey = 0,
    /// Bearer (tag 1).
    Bearer = 1,
    /// Basic (tag 2).
    Basic = 2,
    /// OAuth2 (tag 3).
    OAuth2 = 3,
    /// HMAC (tag 4).
    Hmac = 4,
    /// mTLS (tag 5).
    Mtls = 5,
}

impl AuthScheme {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ApiKey),
            1 => Some(Self::Bearer),
            2 => Some(Self::Basic),
            3 => Some(Self::OAuth2),
            4 => Some(Self::Hmac),
            5 => Some(Self::Mtls),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AuthScheme; 6] = [
        Self::ApiKey, Self::Bearer, Self::Basic, Self::OAuth2, Self::Hmac, Self::Mtls,
    ];
}

impl fmt::Display for AuthScheme {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RateLimitStrategy (tags 0-3)
// ===========================================================================

/// API rate limiting strategies.
///
/// Matches `RateLimitStrategy` in `ApiserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RateLimitStrategy {
    /// FixedWindow (tag 0).
    FixedWindow = 0,
    /// SlidingWindow (tag 1).
    SlidingWindow = 1,
    /// TokenBucket (tag 2).
    TokenBucket = 2,
    /// LeakyBucket (tag 3).
    LeakyBucket = 3,
}

impl RateLimitStrategy {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::FixedWindow),
            1 => Some(Self::SlidingWindow),
            2 => Some(Self::TokenBucket),
            3 => Some(Self::LeakyBucket),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [RateLimitStrategy; 4] = [
        Self::FixedWindow, Self::SlidingWindow, Self::TokenBucket, Self::LeakyBucket,
    ];
}

impl fmt::Display for RateLimitStrategy {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ApiVersion (tags 0-4)
// ===========================================================================

/// API version identifiers.
///
/// Matches `ApiVersion` in `ApiserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ApiVersion {
    /// V1 (tag 0).
    V1 = 0,
    /// V2 (tag 1).
    V2 = 1,
    /// V3 (tag 2).
    V3 = 2,
    /// Latest (tag 3).
    Latest = 3,
    /// Deprecated (tag 4).
    Deprecated = 4,
}

impl ApiVersion {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::V1),
            1 => Some(Self::V2),
            2 => Some(Self::V3),
            3 => Some(Self::Latest),
            4 => Some(Self::Deprecated),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ApiVersion; 5] = [
        Self::V1, Self::V2, Self::V3, Self::Latest, Self::Deprecated,
    ];
}

impl fmt::Display for ApiVersion {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ResponseFormat (tags 0-3)
// ===========================================================================

/// API response formats.
///
/// Matches `ResponseFormat` in `ApiserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResponseFormat {
    /// JSON (tag 0).
    Json = 0,
    /// XML (tag 1).
    Xml = 1,
    /// Protobuf (tag 2).
    Protobuf = 2,
    /// MessagePack (tag 3).
    MessagePack = 3,
}

impl ResponseFormat {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Json),
            1 => Some(Self::Xml),
            2 => Some(Self::Protobuf),
            3 => Some(Self::MessagePack),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ResponseFormat; 4] = [
        Self::Json, Self::Xml, Self::Protobuf, Self::MessagePack,
    ];
}

impl fmt::Display for ResponseFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// GatewayError (tags 0-5)
// ===========================================================================

/// API gateway error codes.
///
/// Matches `GatewayError` in `ApiserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum GatewayError {
    /// Unauthorized (tag 0).
    Unauthorized = 0,
    /// RateLimited (tag 1).
    RateLimited = 1,
    /// NotFound (tag 2).
    NotFound = 2,
    /// BadRequest (tag 3).
    BadRequest = 3,
    /// ServiceUnavailable (tag 4).
    ServiceUnavailable = 4,
    /// CircuitOpen (tag 5).
    CircuitOpen = 5,
}

impl GatewayError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Unauthorized),
            1 => Some(Self::RateLimited),
            2 => Some(Self::NotFound),
            3 => Some(Self::BadRequest),
            4 => Some(Self::ServiceUnavailable),
            5 => Some(Self::CircuitOpen),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [GatewayError; 6] = [
        Self::Unauthorized, Self::RateLimited, Self::NotFound, Self::BadRequest, Self::ServiceUnavailable, Self::CircuitOpen,
    ];
}

impl fmt::Display for GatewayError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn auth_scheme_roundtrip() {
        for v in AuthScheme::ALL {
            let tag = v.to_tag();
            let decoded = AuthScheme::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AuthScheme::from_tag(6).is_none());
    }

    #[test]
    fn rate_limit_strategy_roundtrip() {
        for v in RateLimitStrategy::ALL {
            let tag = v.to_tag();
            let decoded = RateLimitStrategy::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RateLimitStrategy::from_tag(4).is_none());
    }

    #[test]
    fn api_version_roundtrip() {
        for v in ApiVersion::ALL {
            let tag = v.to_tag();
            let decoded = ApiVersion::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ApiVersion::from_tag(5).is_none());
    }

    #[test]
    fn response_format_roundtrip() {
        for v in ResponseFormat::ALL {
            let tag = v.to_tag();
            let decoded = ResponseFormat::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ResponseFormat::from_tag(4).is_none());
    }

    #[test]
    fn gateway_error_roundtrip() {
        for v in GatewayError::ALL {
            let tag = v.to_tag();
            let decoded = GatewayError::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(GatewayError::from_tag(6).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(API_PORT, 8080);
    }

}
