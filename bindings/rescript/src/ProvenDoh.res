// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DNS-over-HTTPS types for the proven-servers ABI.
//
// Mirrors the Idris2 module DohABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard HTTPS port for DoH.
let dohPort = 443

// ===========================================================================
// ContentType (tags 0-1)
// ===========================================================================

/// Standard HTTPS port for DoH.
type contentType =
  | @as(0) DnsMessage
  | @as(1) DnsJson

/// Decode from the C-ABI tag value.
let contentTypeFromTag = (tag: int): option<contentType> =>
  switch tag {
  | 0 => Some(DnsMessage)
  | 1 => Some(DnsJson)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let contentTypeToTag = (v: contentType): int =>
  switch v {
  | DnsMessage => 0
  | DnsJson => 1
  }

// ===========================================================================
// RequestMethod (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type requestMethod =
  | @as(0) Get
  | @as(1) Post

/// Decode from the C-ABI tag value.
let requestMethodFromTag = (tag: int): option<requestMethod> =>
  switch tag {
  | 0 => Some(Get)
  | 1 => Some(Post)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let requestMethodToTag = (v: requestMethod): int =>
  switch v {
  | Get => 0
  | Post => 1
  }

// ===========================================================================
// WireFormat (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type wireFormat =
  | @as(0) Binary
  | @as(1) Json

/// Decode from the C-ABI tag value.
let wireFormatFromTag = (tag: int): option<wireFormat> =>
  switch tag {
  | 0 => Some(Binary)
  | 1 => Some(Json)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let wireFormatToTag = (v: wireFormat): int =>
  switch v {
  | Binary => 0
  | Json => 1
  }

// ===========================================================================
// ErrorReason (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type errorReason =
  | @as(0) BadContentType
  | @as(1) BadMethod
  | @as(2) PayloadTooLarge
  | @as(3) UpstreamTimeout
  | @as(4) UpstreamError

/// Decode from the C-ABI tag value.
let errorReasonFromTag = (tag: int): option<errorReason> =>
  switch tag {
  | 0 => Some(BadContentType)
  | 1 => Some(BadMethod)
  | 2 => Some(PayloadTooLarge)
  | 3 => Some(UpstreamTimeout)
  | 4 => Some(UpstreamError)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorReasonToTag = (v: errorReason): int =>
  switch v {
  | BadContentType => 0
  | BadMethod => 1
  | PayloadTooLarge => 2
  | UpstreamTimeout => 3
  | UpstreamError => 4
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Bound
  | @as(2) Serving
  | @as(3) Resolving
  | @as(4) Shutdown

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Bound)
  | 2 => Some(Serving)
  | 3 => Some(Resolving)
  | 4 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Bound => 1
  | Serving => 2
  | Resolving => 3
  | Shutdown => 4
  }

