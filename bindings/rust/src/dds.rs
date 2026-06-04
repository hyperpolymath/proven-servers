// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! DDS types for the proven-servers ABI.
//!
//! Formally verified DDS (Data Distribution Service) types.
//! Mirrors the Idris2 module `DdsABI.Types`.
//!
//! - `ReliabilityKind` -- DDS reliability QoS.
//! - `DurabilityKind` -- DDS durability QoS.
//! - `HistoryKind` -- DDS history QoS.
//! - `OwnershipKind` -- DDS ownership QoS.
//! - `EntityType` -- DDS entity types.
//! - `ParticipantState` -- DDS participant states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// DDS Constants
// ===========================================================================

/// Standard DDS discovery port.
pub const DDS_DISCOVERY_PORT: u16 = 7400;

// ===========================================================================
// ReliabilityKind (tags 0-1)
// ===========================================================================

/// DDS reliability QoS.
///
/// Matches `ReliabilityKind` in `DdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ReliabilityKind {
    /// BestEffort (tag 0).
    BestEffort = 0,
    /// Reliable (tag 1).
    Reliable = 1,
}

impl ReliabilityKind {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::BestEffort),
            1 => Some(Self::Reliable),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ReliabilityKind; 2] = [
        Self::BestEffort, Self::Reliable,
    ];
}

impl fmt::Display for ReliabilityKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DurabilityKind (tags 0-3)
// ===========================================================================

/// DDS durability QoS.
///
/// Matches `DurabilityKind` in `DdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DurabilityKind {
    /// Transient-local durability (tag 1).
    TransientLocal = 1,
    /// Transient durability (tag 2).
    Transient = 2,
    /// Persistent durability (tag 3).
    Persistent = 3,
}

impl DurabilityKind {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            1 => Some(Self::TransientLocal),
            2 => Some(Self::Transient),
            3 => Some(Self::Persistent),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DurabilityKind; 3] = [
        Self::TransientLocal, Self::Transient, Self::Persistent,
    ];
}

impl fmt::Display for DurabilityKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HistoryKind (tags 0-1)
// ===========================================================================

/// DDS history QoS.
///
/// Matches `HistoryKind` in `DdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HistoryKind {
    /// KeepLast (tag 0).
    KeepLast = 0,
    /// KeepAll (tag 1).
    KeepAll = 1,
}

impl HistoryKind {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::KeepLast),
            1 => Some(Self::KeepAll),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HistoryKind; 2] = [
        Self::KeepLast, Self::KeepAll,
    ];
}

impl fmt::Display for HistoryKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// OwnershipKind (tags 0-1)
// ===========================================================================

/// DDS ownership QoS.
///
/// Matches `OwnershipKind` in `DdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum OwnershipKind {
    /// Shared (tag 0).
    Shared = 0,
    /// Exclusive (tag 1).
    Exclusive = 1,
}

impl OwnershipKind {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Shared),
            1 => Some(Self::Exclusive),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [OwnershipKind; 2] = [
        Self::Shared, Self::Exclusive,
    ];
}

impl fmt::Display for OwnershipKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// EntityType (tags 0-5)
// ===========================================================================

/// DDS entity types.
///
/// Matches `EntityType` in `DdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum EntityType {
    /// Participant (tag 0).
    Participant = 0,
    /// Publisher (tag 1).
    Publisher = 1,
    /// Subscriber (tag 2).
    Subscriber = 2,
    /// Topic (tag 3).
    Topic = 3,
    /// DataWriter (tag 4).
    DataWriter = 4,
    /// DataReader (tag 5).
    DataReader = 5,
}

impl EntityType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Participant),
            1 => Some(Self::Publisher),
            2 => Some(Self::Subscriber),
            3 => Some(Self::Topic),
            4 => Some(Self::DataWriter),
            5 => Some(Self::DataReader),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [EntityType; 6] = [
        Self::Participant, Self::Publisher, Self::Subscriber, Self::Topic, Self::DataWriter, Self::DataReader,
    ];
}

impl fmt::Display for EntityType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ParticipantState (tags 0-4)
// ===========================================================================

/// DDS participant states.
///
/// Matches `ParticipantState` in `DdsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ParticipantState {
    /// Idle (tag 0).
    Idle = 0,
    /// Joined (tag 1).
    Joined = 1,
    /// Publishing (tag 2).
    Publishing = 2,
    /// Subscribing (tag 3).
    Subscribing = 3,
    /// Leaving (tag 4).
    Leaving = 4,
}

impl ParticipantState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Joined),
            2 => Some(Self::Publishing),
            3 => Some(Self::Subscribing),
            4 => Some(Self::Leaving),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ParticipantState; 5] = [
        Self::Idle, Self::Joined, Self::Publishing, Self::Subscribing, Self::Leaving,
    ];
}

impl fmt::Display for ParticipantState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn reliability_kind_roundtrip() {
        for v in ReliabilityKind::ALL {
            let tag = v.to_tag();
            let decoded = ReliabilityKind::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ReliabilityKind::from_tag(2).is_none());
    }

    #[test]
    fn durability_kind_roundtrip() {
        for v in DurabilityKind::ALL {
            let tag = v.to_tag();
            let decoded = DurabilityKind::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DurabilityKind::from_tag(4).is_none());
    }

    #[test]
    fn history_kind_roundtrip() {
        for v in HistoryKind::ALL {
            let tag = v.to_tag();
            let decoded = HistoryKind::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HistoryKind::from_tag(2).is_none());
    }

    #[test]
    fn ownership_kind_roundtrip() {
        for v in OwnershipKind::ALL {
            let tag = v.to_tag();
            let decoded = OwnershipKind::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(OwnershipKind::from_tag(2).is_none());
    }

    #[test]
    fn entity_type_roundtrip() {
        for v in EntityType::ALL {
            let tag = v.to_tag();
            let decoded = EntityType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(EntityType::from_tag(6).is_none());
    }

    #[test]
    fn participant_state_roundtrip() {
        for v in ParticipantState::ALL {
            let tag = v.to_tag();
            let decoded = ParticipantState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ParticipantState::from_tag(5).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(DDS_DISCOVERY_PORT, 7400);
    }

}
