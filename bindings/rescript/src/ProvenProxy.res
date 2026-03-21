// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Reverse Proxy types for the proven-servers ABI.
//
// Mirrors the Idris2 module ProxyABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard HTTP proxy port.
let proxyHttpPort = 80

/// Standard HTTPS proxy port.
let proxyHttpsPort = 443

// ===========================================================================
// ProxyMode (tags 0-1)
// ===========================================================================

/// Standard HTTP proxy port.
type proxyMode =
  | @as(0) Forward
  | @as(1) Reverse

/// Decode from the C-ABI tag value.
let proxyModeFromTag = (tag: int): option<proxyMode> =>
  switch tag {
  | 0 => Some(Forward)
  | 1 => Some(Reverse)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let proxyModeToTag = (v: proxyMode): int =>
  switch v {
  | Forward => 0
  | Reverse => 1
  }

// ===========================================================================
// HopByHopHeader (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type hopByHopHeader =
  | @as(0) Connection
  | @as(1) KeepAlive
  | @as(2) ProxyAuth
  | @as(3) ProxyAuthz
  | @as(4) Te
  | @as(5) Trailers
  | @as(6) TransferEncoding
  | @as(7) Upgrade

/// Decode from the C-ABI tag value.
let hopByHopHeaderFromTag = (tag: int): option<hopByHopHeader> =>
  switch tag {
  | 0 => Some(Connection)
  | 1 => Some(KeepAlive)
  | 2 => Some(ProxyAuth)
  | 3 => Some(ProxyAuthz)
  | 4 => Some(Te)
  | 5 => Some(Trailers)
  | 6 => Some(TransferEncoding)
  | 7 => Some(Upgrade)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let hopByHopHeaderToTag = (v: hopByHopHeader): int =>
  switch v {
  | Connection => 0
  | KeepAlive => 1
  | ProxyAuth => 2
  | ProxyAuthz => 3
  | Te => 4
  | Trailers => 5
  | TransferEncoding => 6
  | Upgrade => 7
  }

// ===========================================================================
// CacheDirective (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type cacheDirective =
  | @as(0) NoCache
  | @as(1) NoStore
  | @as(2) MaxAge
  | @as(3) Public
  | @as(4) Private
  | @as(5) MustRevalidate

/// Decode from the C-ABI tag value.
let cacheDirectiveFromTag = (tag: int): option<cacheDirective> =>
  switch tag {
  | 0 => Some(NoCache)
  | 1 => Some(NoStore)
  | 2 => Some(MaxAge)
  | 3 => Some(Public)
  | 4 => Some(Private)
  | 5 => Some(MustRevalidate)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let cacheDirectiveToTag = (v: cacheDirective): int =>
  switch v {
  | NoCache => 0
  | NoStore => 1
  | MaxAge => 2
  | Public => 3
  | Private => 4
  | MustRevalidate => 5
  }

// ===========================================================================
// ProxyError (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type proxyError =
  | @as(0) BadGateway
  | @as(1) GatewayTimeout
  | @as(2) UpstreamRefused
  | @as(3) UpstreamTls

/// Decode from the C-ABI tag value.
let proxyErrorFromTag = (tag: int): option<proxyError> =>
  switch tag {
  | 0 => Some(BadGateway)
  | 1 => Some(GatewayTimeout)
  | 2 => Some(UpstreamRefused)
  | 3 => Some(UpstreamTls)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let proxyErrorToTag = (v: proxyError): int =>
  switch v {
  | BadGateway => 0
  | GatewayTimeout => 1
  | UpstreamRefused => 2
  | UpstreamTls => 3
  }

