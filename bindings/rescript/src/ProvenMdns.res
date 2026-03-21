// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mDNS types for the proven-servers ABI.
//
// Mirrors the Idris2 module MdnsABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard mDNS port.
let mdnsPort = 5353

// ===========================================================================
// MdnsRecordType (tags 0-4)
// ===========================================================================

/// Standard mDNS port.
type mdnsRecordType =
  | @as(0) A
  | @as(1) Aaaa
  | @as(2) Ptr
  | @as(3) Srv
  | @as(4) Txt

/// Decode from the C-ABI tag value.
let mdnsRecordTypeFromTag = (tag: int): option<mdnsRecordType> =>
  switch tag {
  | 0 => Some(A)
  | 1 => Some(Aaaa)
  | 2 => Some(Ptr)
  | 3 => Some(Srv)
  | 4 => Some(Txt)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let mdnsRecordTypeToTag = (v: mdnsRecordType): int =>
  switch v {
  | A => 0
  | Aaaa => 1
  | Ptr => 2
  | Srv => 3
  | Txt => 4
  }

// ===========================================================================
// QueryType (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type queryType =
  | @as(0) Standard
  | @as(1) OneShot
  | @as(2) Continuous

/// Decode from the C-ABI tag value.
let queryTypeFromTag = (tag: int): option<queryType> =>
  switch tag {
  | 0 => Some(Standard)
  | 1 => Some(OneShot)
  | 2 => Some(Continuous)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let queryTypeToTag = (v: queryType): int =>
  switch v {
  | Standard => 0
  | OneShot => 1
  | Continuous => 2
  }

// ===========================================================================
// ConflictAction (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type conflictAction =
  | @as(0) Probe
  | @as(1) Defend
  | @as(2) Withdraw

/// Decode from the C-ABI tag value.
let conflictActionFromTag = (tag: int): option<conflictAction> =>
  switch tag {
  | 0 => Some(Probe)
  | 1 => Some(Defend)
  | 2 => Some(Withdraw)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let conflictActionToTag = (v: conflictAction): int =>
  switch v {
  | Probe => 0
  | Defend => 1
  | Withdraw => 2
  }

// ===========================================================================
// ServiceFlag (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type serviceFlag =
  | @as(0) Unique
  | @as(1) Shared

/// Decode from the C-ABI tag value.
let serviceFlagFromTag = (tag: int): option<serviceFlag> =>
  switch tag {
  | 0 => Some(Unique)
  | 1 => Some(Shared)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serviceFlagToTag = (v: serviceFlag): int =>
  switch v {
  | Unique => 0
  | Shared => 1
  }

// ===========================================================================
// ResponderState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type responderState =
  | @as(0) Idle
  | @as(1) Probing
  | @as(2) Announcing
  | @as(3) Running
  | @as(4) ShuttingDown

/// Decode from the C-ABI tag value.
let responderStateFromTag = (tag: int): option<responderState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Probing)
  | 2 => Some(Announcing)
  | 3 => Some(Running)
  | 4 => Some(ShuttingDown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let responderStateToTag = (v: responderState): int =>
  switch v {
  | Idle => 0
  | Probing => 1
  | Announcing => 2
  | Running => 3
  | ShuttingDown => 4
  }

