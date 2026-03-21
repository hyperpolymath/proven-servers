// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DNS-over-TLS types for the proven-servers ABI.
//
// Mirrors the Idris2 module DotABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard DoT port.
let dotPort = 853

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Standard DoT port.
type sessionState =
  | @as(0) Connecting
  | @as(1) Handshaking
  | @as(2) Established
  | @as(3) Closing
  | @as(4) Closed

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Connecting)
  | 1 => Some(Handshaking)
  | 2 => Some(Established)
  | 3 => Some(Closing)
  | 4 => Some(Closed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Connecting => 0
  | Handshaking => 1
  | Established => 2
  | Closing => 3
  | Closed => 4
  }

// ===========================================================================
// PaddingStrategy (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type paddingStrategy =
  | @as(0) NoPadding
  | @as(1) BlockPadding
  | @as(2) RandomPadding

/// Decode from the C-ABI tag value.
let paddingStrategyFromTag = (tag: int): option<paddingStrategy> =>
  switch tag {
  | 0 => Some(NoPadding)
  | 1 => Some(BlockPadding)
  | 2 => Some(RandomPadding)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let paddingStrategyToTag = (v: paddingStrategy): int =>
  switch v {
  | NoPadding => 0
  | BlockPadding => 1
  | RandomPadding => 2
  }

// ===========================================================================
// ErrorReason (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type errorReason =
  | @as(0) HandshakeFailed
  | @as(1) CertificateInvalid
  | @as(2) Timeout
  | @as(3) UpstreamError

/// Decode from the C-ABI tag value.
let errorReasonFromTag = (tag: int): option<errorReason> =>
  switch tag {
  | 0 => Some(HandshakeFailed)
  | 1 => Some(CertificateInvalid)
  | 2 => Some(Timeout)
  | 3 => Some(UpstreamError)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorReasonToTag = (v: errorReason): int =>
  switch v {
  | HandshakeFailed => 0
  | CertificateInvalid => 1
  | Timeout => 2
  | UpstreamError => 3
  }

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type serverState =
  | @as(0) Idle
  | @as(1) Bound
  | @as(2) Listening
  | @as(3) Processing
  | @as(4) Shutdown

/// Decode from the C-ABI tag value.
let serverStateFromTag = (tag: int): option<serverState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Bound)
  | 2 => Some(Listening)
  | 3 => Some(Processing)
  | 4 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serverStateToTag = (v: serverState): int =>
  switch v {
  | Idle => 0
  | Bound => 1
  | Listening => 2
  | Processing => 3
  | Shutdown => 4
  }

