// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Reverse Proxy types for the proven-servers ABI.
//!
//! Formally verified HTTP proxy types.
//! Mirrors the Idris2 module `ProxyABI.Types`.
//!
//! - `ProxyMode` -- Proxy operating modes.
//! - `HopByHopHeader` -- HTTP hop-by-hop headers (RFC 2616).
//! - `CacheDirective` -- HTTP cache directives.
//! - `ProxyError` -- Proxy-specific error codes.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Reverse Proxy Constants
// ===========================================================================

/// Standard HTTP proxy port.
pub const PROXY_HTTP_PORT: u16 = 80;

/// Standard HTTPS proxy port.
pub const PROXY_HTTPS_PORT: u16 = 443;

// ===========================================================================
// ProxyMode (tags 0-1)
// ===========================================================================

/// Proxy operating modes.
///
/// Matches `ProxyMode` in `ProxyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ProxyMode {
    /// Forward (tag 0).
    Forward = 0,
    /// Reverse (tag 1).
    Reverse = 1,
}

impl ProxyMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Forward),
            1 => Some(Self::Reverse),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ProxyMode; 2] = [
        Self::Forward, Self::Reverse,
    ];
}

impl fmt::Display for ProxyMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HopByHopHeader (tags 0-7)
// ===========================================================================

/// HTTP hop-by-hop headers (RFC 2616).
///
/// Matches `HopByHopHeader` in `ProxyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HopByHopHeader {
    /// Connection (tag 0).
    Connection = 0,
    /// KeepAlive (tag 1).
    KeepAlive = 1,
    /// Proxy-Authenticate (tag 2).
    ProxyAuth = 2,
    /// Proxy-Authorization (tag 3).
    ProxyAuthz = 3,
    /// TE (tag 4).
    Te = 4,
    /// Trailers (tag 5).
    Trailers = 5,
    /// TransferEncoding (tag 6).
    TransferEncoding = 6,
    /// Upgrade (tag 7).
    Upgrade = 7,
}

impl HopByHopHeader {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Connection),
            1 => Some(Self::KeepAlive),
            2 => Some(Self::ProxyAuth),
            3 => Some(Self::ProxyAuthz),
            4 => Some(Self::Te),
            5 => Some(Self::Trailers),
            6 => Some(Self::TransferEncoding),
            7 => Some(Self::Upgrade),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HopByHopHeader; 8] = [
        Self::Connection, Self::KeepAlive, Self::ProxyAuth, Self::ProxyAuthz, Self::Te, Self::Trailers, Self::TransferEncoding, Self::Upgrade,
    ];
}

impl fmt::Display for HopByHopHeader {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CacheDirective (tags 0-5)
// ===========================================================================

/// HTTP cache directives.
///
/// Matches `CacheDirective` in `ProxyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CacheDirective {
    /// NoCache (tag 0).
    NoCache = 0,
    /// NoStore (tag 1).
    NoStore = 1,
    /// MaxAge (tag 2).
    MaxAge = 2,
    /// Public (tag 3).
    Public = 3,
    /// Private (tag 4).
    Private = 4,
    /// MustRevalidate (tag 5).
    MustRevalidate = 5,
}

impl CacheDirective {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NoCache),
            1 => Some(Self::NoStore),
            2 => Some(Self::MaxAge),
            3 => Some(Self::Public),
            4 => Some(Self::Private),
            5 => Some(Self::MustRevalidate),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CacheDirective; 6] = [
        Self::NoCache, Self::NoStore, Self::MaxAge, Self::Public, Self::Private, Self::MustRevalidate,
    ];
}

impl fmt::Display for CacheDirective {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ProxyError (tags 0-3)
// ===========================================================================

/// Proxy-specific error codes.
///
/// Matches `ProxyError` in `ProxyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ProxyError {
    /// BadGateway (tag 0).
    BadGateway = 0,
    /// GatewayTimeout (tag 1).
    GatewayTimeout = 1,
    /// UpstreamRefused (tag 2).
    UpstreamRefused = 2,
    /// Upstream TLS error (tag 3).
    UpstreamTls = 3,
}

impl ProxyError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::BadGateway),
            1 => Some(Self::GatewayTimeout),
            2 => Some(Self::UpstreamRefused),
            3 => Some(Self::UpstreamTls),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ProxyError; 4] = [
        Self::BadGateway, Self::GatewayTimeout, Self::UpstreamRefused, Self::UpstreamTls,
    ];
}

impl fmt::Display for ProxyError {
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
    fn proxy_mode_roundtrip() {
        for v in ProxyMode::ALL {
            let tag = v.to_tag();
            let decoded = ProxyMode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ProxyMode::from_tag(2).is_none());
    }

    #[test]
    fn hop_by_hop_header_roundtrip() {
        for v in HopByHopHeader::ALL {
            let tag = v.to_tag();
            let decoded = HopByHopHeader::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HopByHopHeader::from_tag(8).is_none());
    }

    #[test]
    fn cache_directive_roundtrip() {
        for v in CacheDirective::ALL {
            let tag = v.to_tag();
            let decoded = CacheDirective::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CacheDirective::from_tag(6).is_none());
    }

    #[test]
    fn proxy_error_roundtrip() {
        for v in ProxyError::ALL {
            let tag = v.to_tag();
            let decoded = ProxyError::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ProxyError::from_tag(4).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(PROXY_HTTP_PORT, 80);
        assert_eq!(PROXY_HTTPS_PORT, 443);
    }

}
