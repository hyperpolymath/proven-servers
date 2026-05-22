//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// DDS protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `DdsABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// DDS Constants
// ===========================================================================

/// Dds Discovery Port constant.
pub const dds_discovery_port = 7400

// ===========================================================================
// ReliabilityKind
// ===========================================================================

/// DDS reliability QoS.
/// 
/// Matches `ReliabilityKind` in `DdsABI.Types`.
pub type ReliabilityKind {
  /// BestEffort (tag 0).
  BestEffort
  /// Reliable (tag 1).
  Reliable
}

/// Convert a `ReliabilityKind` to its C-ABI tag value.
pub fn reliability_kind_to_int(value: ReliabilityKind) -> Int {
  case value {
    BestEffort -> 0
    Reliable -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn reliability_kind_from_int(tag: Int) -> Result(ReliabilityKind, Nil) {
  case tag {
    0 -> Ok(BestEffort)
    1 -> Ok(Reliable)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DurabilityKind
// ===========================================================================

/// DDS durability QoS.
/// 
/// Matches `DurabilityKind` in `DdsABI.Types`.
pub type DurabilityKind {
  /// Transient-local durability (tag 1).
  TransientLocal
  /// Transient durability (tag 2).
  Transient
  /// Persistent durability (tag 3).
  Persistent
}

/// Convert a `DurabilityKind` to its C-ABI tag value.
pub fn durability_kind_to_int(value: DurabilityKind) -> Int {
  case value {
    TransientLocal -> 1
    Transient -> 2
    Persistent -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn durability_kind_from_int(tag: Int) -> Result(DurabilityKind, Nil) {
  case tag {
    1 -> Ok(TransientLocal)
    2 -> Ok(Transient)
    3 -> Ok(Persistent)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HistoryKind
// ===========================================================================

/// DDS history QoS.
/// 
/// Matches `HistoryKind` in `DdsABI.Types`.
pub type HistoryKind {
  /// KeepLast (tag 0).
  KeepLast
  /// KeepAll (tag 1).
  KeepAll
}

/// Convert a `HistoryKind` to its C-ABI tag value.
pub fn history_kind_to_int(value: HistoryKind) -> Int {
  case value {
    KeepLast -> 0
    KeepAll -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn history_kind_from_int(tag: Int) -> Result(HistoryKind, Nil) {
  case tag {
    0 -> Ok(KeepLast)
    1 -> Ok(KeepAll)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// OwnershipKind
// ===========================================================================

/// DDS ownership QoS.
/// 
/// Matches `OwnershipKind` in `DdsABI.Types`.
pub type OwnershipKind {
  /// Shared (tag 0).
  Shared
  /// Exclusive (tag 1).
  Exclusive
}

/// Convert a `OwnershipKind` to its C-ABI tag value.
pub fn ownership_kind_to_int(value: OwnershipKind) -> Int {
  case value {
    Shared -> 0
    Exclusive -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn ownership_kind_from_int(tag: Int) -> Result(OwnershipKind, Nil) {
  case tag {
    0 -> Ok(Shared)
    1 -> Ok(Exclusive)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// EntityType
// ===========================================================================

/// DDS entity types.
/// 
/// Matches `EntityType` in `DdsABI.Types`.
pub type EntityType {
  /// Participant (tag 0).
  Participant
  /// Publisher (tag 1).
  Publisher
  /// Subscriber (tag 2).
  Subscriber
  /// Topic (tag 3).
  Topic
  /// DataWriter (tag 4).
  DataWriter
  /// DataReader (tag 5).
  DataReader
}

/// Convert a `EntityType` to its C-ABI tag value.
pub fn entity_type_to_int(value: EntityType) -> Int {
  case value {
    Participant -> 0
    Publisher -> 1
    Subscriber -> 2
    Topic -> 3
    DataWriter -> 4
    DataReader -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn entity_type_from_int(tag: Int) -> Result(EntityType, Nil) {
  case tag {
    0 -> Ok(Participant)
    1 -> Ok(Publisher)
    2 -> Ok(Subscriber)
    3 -> Ok(Topic)
    4 -> Ok(DataWriter)
    5 -> Ok(DataReader)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ParticipantState
// ===========================================================================

/// DDS participant states.
/// 
/// Matches `ParticipantState` in `DdsABI.Types`.
pub type ParticipantState {
  /// Idle (tag 0).
  Idle
  /// Joined (tag 1).
  Joined
  /// Publishing (tag 2).
  Publishing
  /// Subscribing (tag 3).
  Subscribing
  /// Leaving (tag 4).
  Leaving
}

/// Convert a `ParticipantState` to its C-ABI tag value.
pub fn participant_state_to_int(value: ParticipantState) -> Int {
  case value {
    Idle -> 0
    Joined -> 1
    Publishing -> 2
    Subscribing -> 3
    Leaving -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn participant_state_from_int(tag: Int) -> Result(ParticipantState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Joined)
    2 -> Ok(Publishing)
    3 -> Ok(Subscribing)
    4 -> Ok(Leaving)
    _ -> Error(Nil)
  }
}

