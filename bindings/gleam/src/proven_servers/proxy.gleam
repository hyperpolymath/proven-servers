//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Proxy protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `ProxyABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Proxy Constants
// ===========================================================================

/// Proxy Http Port constant.
pub const proxy_http_port = 80

/// Proxy Https Port constant.
pub const proxy_https_port = 443

// ===========================================================================
// ProxyMode
// ===========================================================================

/// Proxy operating modes.
/// 
/// Matches `ProxyMode` in `ProxyABI.Types`.
pub type ProxyMode {
  /// Forward (tag 0).
  Forward
  /// Reverse (tag 1).
  Reverse
}

/// Convert a `ProxyMode` to its C-ABI tag value.
pub fn proxy_mode_to_int(value: ProxyMode) -> Int {
  case value {
    Forward -> 0
    Reverse -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn proxy_mode_from_int(tag: Int) -> Result(ProxyMode, Nil) {
  case tag {
    0 -> Ok(Forward)
    1 -> Ok(Reverse)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HopByHopHeader
// ===========================================================================

/// HTTP hop-by-hop headers (RFC 2616).
/// 
/// Matches `HopByHopHeader` in `ProxyABI.Types`.
pub type HopByHopHeader {
  /// Connection (tag 0).
  Connection
  /// KeepAlive (tag 1).
  KeepAlive
  /// Proxy-Authenticate (tag 2).
  ProxyAuth
  /// Proxy-Authorization (tag 3).
  ProxyAuthz
  /// TE (tag 4).
  Te
  /// Trailers (tag 5).
  Trailers
  /// TransferEncoding (tag 6).
  TransferEncoding
  /// Upgrade (tag 7).
  Upgrade
}

/// Convert a `HopByHopHeader` to its C-ABI tag value.
pub fn hop_by_hop_header_to_int(value: HopByHopHeader) -> Int {
  case value {
    Connection -> 0
    KeepAlive -> 1
    ProxyAuth -> 2
    ProxyAuthz -> 3
    Te -> 4
    Trailers -> 5
    TransferEncoding -> 6
    Upgrade -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn hop_by_hop_header_from_int(tag: Int) -> Result(HopByHopHeader, Nil) {
  case tag {
    0 -> Ok(Connection)
    1 -> Ok(KeepAlive)
    2 -> Ok(ProxyAuth)
    3 -> Ok(ProxyAuthz)
    4 -> Ok(Te)
    5 -> Ok(Trailers)
    6 -> Ok(TransferEncoding)
    7 -> Ok(Upgrade)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CacheDirective
// ===========================================================================

/// HTTP cache directives.
/// 
/// Matches `CacheDirective` in `ProxyABI.Types`.
pub type CacheDirective {
  /// NoCache (tag 0).
  NoCache
  /// NoStore (tag 1).
  NoStore
  /// MaxAge (tag 2).
  MaxAge
  /// Public (tag 3).
  Public
  /// Private (tag 4).
  Private
  /// MustRevalidate (tag 5).
  MustRevalidate
}

/// Convert a `CacheDirective` to its C-ABI tag value.
pub fn cache_directive_to_int(value: CacheDirective) -> Int {
  case value {
    NoCache -> 0
    NoStore -> 1
    MaxAge -> 2
    Public -> 3
    Private -> 4
    MustRevalidate -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn cache_directive_from_int(tag: Int) -> Result(CacheDirective, Nil) {
  case tag {
    0 -> Ok(NoCache)
    1 -> Ok(NoStore)
    2 -> Ok(MaxAge)
    3 -> Ok(Public)
    4 -> Ok(Private)
    5 -> Ok(MustRevalidate)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ProxyError
// ===========================================================================

/// Proxy-specific error codes.
/// 
/// Matches `ProxyError` in `ProxyABI.Types`.
pub type ProxyError {
  /// BadGateway (tag 0).
  BadGateway
  /// GatewayTimeout (tag 1).
  GatewayTimeout
  /// UpstreamRefused (tag 2).
  UpstreamRefused
  /// Upstream TLS error (tag 3).
  UpstreamTls
}

/// Convert a `ProxyError` to its C-ABI tag value.
pub fn proxy_error_to_int(value: ProxyError) -> Int {
  case value {
    BadGateway -> 0
    GatewayTimeout -> 1
    UpstreamRefused -> 2
    UpstreamTls -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn proxy_error_from_int(tag: Int) -> Result(ProxyError, Nil) {
  case tag {
    0 -> Ok(BadGateway)
    1 -> Ok(GatewayTimeout)
    2 -> Ok(UpstreamRefused)
    3 -> Ok(UpstreamTls)
    _ -> Error(Nil)
  }
}

