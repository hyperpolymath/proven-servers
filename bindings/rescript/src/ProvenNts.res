// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Network Time Security types for the proven-servers ABI.
//
// Mirrors the Idris2 module NtsABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard NTS-KE port.
let ntsKePort = 4460

// ===========================================================================
// RecordType (tags 0-8)
// ===========================================================================

/// Standard NTS-KE port.
type recordType =
  | @as(0) EndOfMessage
  | @as(1) NextProtocol
  | @as(2) Error
  | @as(3) Warning
  | @as(4) AeadAlgorithm
  | @as(5) Cookie
  | @as(6) CookiePlaceholder
  | @as(7) NtskeServer
  | @as(8) NtskePort

/// Decode from the C-ABI tag value.
let recordTypeFromTag = (tag: int): option<recordType> =>
  switch tag {
  | 0 => Some(EndOfMessage)
  | 1 => Some(NextProtocol)
  | 2 => Some(Error)
  | 3 => Some(Warning)
  | 4 => Some(AeadAlgorithm)
  | 5 => Some(Cookie)
  | 6 => Some(CookiePlaceholder)
  | 7 => Some(NtskeServer)
  | 8 => Some(NtskePort)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let recordTypeToTag = (v: recordType): int =>
  switch v {
  | EndOfMessage => 0
  | NextProtocol => 1
  | Error => 2
  | Warning => 3
  | AeadAlgorithm => 4
  | Cookie => 5
  | CookiePlaceholder => 6
  | NtskeServer => 7
  | NtskePort => 8
  }

// ===========================================================================
// ErrorCode (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type errorCode =
  | @as(0) UnrecognizedCritical
  | @as(1) BadRequest
  | @as(2) InternalError

/// Decode from the C-ABI tag value.
let errorCodeFromTag = (tag: int): option<errorCode> =>
  switch tag {
  | 0 => Some(UnrecognizedCritical)
  | 1 => Some(BadRequest)
  | 2 => Some(InternalError)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let errorCodeToTag = (v: errorCode): int =>
  switch v {
  | UnrecognizedCritical => 0
  | BadRequest => 1
  | InternalError => 2
  }

// ===========================================================================
// AeadAlgorithm (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type aeadAlgorithm =
  | @as(0) AeadAes128Gcm
  | @as(1) AeadAes256Gcm
  | @as(2) AeadAesSivCmac256

/// Decode from the C-ABI tag value.
let aeadAlgorithmFromTag = (tag: int): option<aeadAlgorithm> =>
  switch tag {
  | 0 => Some(AeadAes128Gcm)
  | 1 => Some(AeadAes256Gcm)
  | 2 => Some(AeadAesSivCmac256)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let aeadAlgorithmToTag = (v: aeadAlgorithm): int =>
  switch v {
  | AeadAes128Gcm => 0
  | AeadAes256Gcm => 1
  | AeadAesSivCmac256 => 2
  }

// ===========================================================================
// HandshakeState (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type handshakeState =
  | @as(0) Initial
  | @as(1) Negotiating
  | @as(2) Established
  | @as(3) Failed

/// Decode from the C-ABI tag value.
let handshakeStateFromTag = (tag: int): option<handshakeState> =>
  switch tag {
  | 0 => Some(Initial)
  | 1 => Some(Negotiating)
  | 2 => Some(Established)
  | 3 => Some(Failed)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let handshakeStateToTag = (v: handshakeState): int =>
  switch v {
  | Initial => 0
  | Negotiating => 1
  | Established => 2
  | Failed => 3
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) Handshaking
  | @as(2) Negotiating
  | @as(3) Established
  | @as(4) Closing

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Handshaking)
  | 2 => Some(Negotiating)
  | 3 => Some(Established)
  | 4 => Some(Closing)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | Handshaking => 1
  | Negotiating => 2
  | Established => 3
  | Closing => 4
  }

