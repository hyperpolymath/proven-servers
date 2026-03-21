// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DNS-over-QUIC types for the proven-servers ABI.
//
// Mirrors the Idris2 module DoqABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard DoQ port.
let doqPort = 853

// ===========================================================================
// StreamType (tags 0-1)
// ===========================================================================

/// Standard DoQ port.
type streamType =
  | @as(0) Unidirectional
  | @as(1) Bidirectional

/// Decode from the C-ABI tag value.
let streamTypeFromTag = (tag: int): option<streamType> =>
  switch tag {
  | 0 => Some(Unidirectional)
  | 1 => Some(Bidirectional)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let streamTypeToTag = (v: streamType): int =>
  switch v {
  | Unidirectional => 0
  | Bidirectional => 1
  }

// ===========================================================================
// ErrorCode (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type errorCode =
  | @as(0) NoError
  | @as(1) InternalError
  | @as(2) ExcessiveLoad
  | @as(3) ProtocolError

/// Decode from the C-ABI tag value.
let errorCodeFromTag = (tag: int): option<errorCode> =>
  switch tag {
  | 0 => Some(NoError)
  | 1 => Some(InternalError)
  | 2 => Some(ExcessiveLoad)
  | 3 => Some(ProtocolError)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorCodeToTag = (v: errorCode): int =>
  switch v {
  | NoError => 0
  | InternalError => 1
  | ExcessiveLoad => 2
  | ProtocolError => 3
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Initial
  | @as(1) Handshaking
  | @as(2) Ready
  | @as(3) Draining
  | @as(4) Closed

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Initial)
  | 1 => Some(Handshaking)
  | 2 => Some(Ready)
  | 3 => Some(Draining)
  | 4 => Some(Closed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Initial => 0
  | Handshaking => 1
  | Ready => 2
  | Draining => 3
  | Closed => 4
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

