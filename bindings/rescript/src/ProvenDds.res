// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DDS types for the proven-servers ABI.
//
// Mirrors the Idris2 module DdsABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard DDS discovery port.
let ddsDiscoveryPort = 7400

// ===========================================================================
// ReliabilityKind (tags 0-1)
// ===========================================================================

/// Standard DDS discovery port.
type reliabilityKind =
  | @as(0) BestEffort
  | @as(1) Reliable

/// Decode from the C-ABI tag value.
let reliabilityKindFromTag = (tag: int): option<reliabilityKind> =>
  switch tag {
  | 0 => Some(BestEffort)
  | 1 => Some(Reliable)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let reliabilityKindToTag = (v: reliabilityKind): int =>
  switch v {
  | BestEffort => 0
  | Reliable => 1
  }

// ===========================================================================
// DurabilityKind (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type durabilityKind =
  | @as(1) TransientLocal
  | @as(2) Transient
  | @as(3) Persistent

/// Decode from the C-ABI tag value.
let durabilityKindFromTag = (tag: int): option<durabilityKind> =>
  switch tag {
  | 1 => Some(TransientLocal)
  | 2 => Some(Transient)
  | 3 => Some(Persistent)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let durabilityKindToTag = (v: durabilityKind): int =>
  switch v {
  | TransientLocal => 1
  | Transient => 2
  | Persistent => 3
  }

// ===========================================================================
// HistoryKind (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type historyKind =
  | @as(0) KeepLast
  | @as(1) KeepAll

/// Decode from the C-ABI tag value.
let historyKindFromTag = (tag: int): option<historyKind> =>
  switch tag {
  | 0 => Some(KeepLast)
  | 1 => Some(KeepAll)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let historyKindToTag = (v: historyKind): int =>
  switch v {
  | KeepLast => 0
  | KeepAll => 1
  }

// ===========================================================================
// OwnershipKind (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type ownershipKind =
  | @as(0) Shared
  | @as(1) Exclusive

/// Decode from the C-ABI tag value.
let ownershipKindFromTag = (tag: int): option<ownershipKind> =>
  switch tag {
  | 0 => Some(Shared)
  | 1 => Some(Exclusive)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ownershipKindToTag = (v: ownershipKind): int =>
  switch v {
  | Shared => 0
  | Exclusive => 1
  }

// ===========================================================================
// EntityType (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type entityType =
  | @as(0) Participant
  | @as(1) Publisher
  | @as(2) Subscriber
  | @as(3) Topic
  | @as(4) DataWriter
  | @as(5) DataReader

/// Decode from the C-ABI tag value.
let entityTypeFromTag = (tag: int): option<entityType> =>
  switch tag {
  | 0 => Some(Participant)
  | 1 => Some(Publisher)
  | 2 => Some(Subscriber)
  | 3 => Some(Topic)
  | 4 => Some(DataWriter)
  | 5 => Some(DataReader)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let entityTypeToTag = (v: entityType): int =>
  switch v {
  | Participant => 0
  | Publisher => 1
  | Subscriber => 2
  | Topic => 3
  | DataWriter => 4
  | DataReader => 5
  }

// ===========================================================================
// ParticipantState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type participantState =
  | @as(0) Idle
  | @as(1) Joined
  | @as(2) Publishing
  | @as(3) Subscribing
  | @as(4) Leaving

/// Decode from the C-ABI tag value.
let participantStateFromTag = (tag: int): option<participantState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Joined)
  | 2 => Some(Publishing)
  | 3 => Some(Subscribing)
  | 4 => Some(Leaving)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let participantStateToTag = (v: participantState): int =>
  switch v {
  | Idle => 0
  | Joined => 1
  | Publishing => 2
  | Subscribing => 3
  | Leaving => 4
  }

