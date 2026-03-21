// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ODNS types for the proven-servers ABI.
//
// Mirrors the Idris2 module OdnsABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Role (tags 0-2)
// ===========================================================================

/// ODNS participant roles.
type role =
  | @as(0) Client
  | @as(1) Proxy
  | @as(2) Target

/// Decode from the C-ABI tag value.
let roleFromTag = (tag: int): option<role> =>
  switch tag {
  | 0 => Some(Client)
  | 1 => Some(Proxy)
  | 2 => Some(Target)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let roleToTag = (v: role): int =>
  switch v {
  | Client => 0
  | Proxy => 1
  | Target => 2
  }

// ===========================================================================
// OdnsMessageType (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type odnsMessageType =
  | @as(0) Query
  | @as(1) Response

/// Decode from the C-ABI tag value.
let odnsMessageTypeFromTag = (tag: int): option<odnsMessageType> =>
  switch tag {
  | 0 => Some(Query)
  | 1 => Some(Response)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let odnsMessageTypeToTag = (v: odnsMessageType): int =>
  switch v {
  | Query => 0
  | Response => 1
  }

// ===========================================================================
// OdnsErrorReason (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type odnsErrorReason =
  | @as(0) ProxyError
  | @as(1) TargetError
  | @as(2) DecryptionFailed
  | @as(3) InvalidConfig
  | @as(4) PayloadTooLarge

/// Decode from the C-ABI tag value.
let odnsErrorReasonFromTag = (tag: int): option<odnsErrorReason> =>
  switch tag {
  | 0 => Some(ProxyError)
  | 1 => Some(TargetError)
  | 2 => Some(DecryptionFailed)
  | 3 => Some(InvalidConfig)
  | 4 => Some(PayloadTooLarge)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let odnsErrorReasonToTag = (v: odnsErrorReason): int =>
  switch v {
  | ProxyError => 0
  | TargetError => 1
  | DecryptionFailed => 2
  | InvalidConfig => 3
  | PayloadTooLarge => 4
  }

// ===========================================================================
// EncapsulationFormat (tags 0-0)
// ===========================================================================

/// Decode from an ABI tag value.
type encapsulationFormat =
  | @as(0) Hpke

/// Decode from the C-ABI tag value.
let encapsulationFormatFromTag = (tag: int): option<encapsulationFormat> =>
  switch tag {
  | 0 => Some(Hpke)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let encapsulationFormatToTag = (v: encapsulationFormat): int =>
  switch v {
  | Hpke => 0
  }

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type sessionState =
  | @as(0) Idle
  | @as(1) KeyExchange
  | @as(2) Ready
  | @as(3) Processing
  | @as(4) Closing

/// Decode from the C-ABI tag value.
let sessionStateFromTag = (tag: int): option<sessionState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(KeyExchange)
  | 2 => Some(Ready)
  | 3 => Some(Processing)
  | 4 => Some(Closing)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let sessionStateToTag = (v: sessionState): int =>
  switch v {
  | Idle => 0
  | KeyExchange => 1
  | Ready => 2
  | Processing => 3
  | Closing => 4
  }

