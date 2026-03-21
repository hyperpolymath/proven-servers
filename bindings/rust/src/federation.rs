// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Federation types for the proven-servers ABI.
//!
//! Formally verified ActivityPub/federation types.
//! Mirrors the Idris2 module `FederationABI.Types`.
//!
//! - `ActivityType` -- ActivityPub activity types.
//! - `ActorType` -- ActivityPub actor types.
//! - `DeliveryStatus` -- Federation delivery statuses.
//! - `TrustLevel` -- Federation trust levels.
//! - `ObjectType` -- ActivityPub object types.
//! - `ServerState` -- Federation server states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// ActivityType (tags 0-10)
// ===========================================================================

/// ActivityPub activity types.
///
/// Matches `ActivityType` in `FederationABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ActivityType {
    /// Create (tag 0).
    Create = 0,
    /// Update (tag 1).
    Update = 1,
    /// Delete (tag 2).
    Delete = 2,
    /// Follow (tag 3).
    Follow = 3,
    /// Accept (tag 4).
    Accept = 4,
    /// Reject (tag 5).
    Reject = 5,
    /// Announce (tag 6).
    Announce = 6,
    /// Like (tag 7).
    Like = 7,
    /// Undo (tag 8).
    Undo = 8,
    /// Block (tag 9).
    Block = 9,
    /// Flag (tag 10).
    Flag = 10,
}

impl ActivityType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Create),
            1 => Some(Self::Update),
            2 => Some(Self::Delete),
            3 => Some(Self::Follow),
            4 => Some(Self::Accept),
            5 => Some(Self::Reject),
            6 => Some(Self::Announce),
            7 => Some(Self::Like),
            8 => Some(Self::Undo),
            9 => Some(Self::Block),
            10 => Some(Self::Flag),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ActivityType; 11] = [
        Self::Create, Self::Update, Self::Delete, Self::Follow, Self::Accept, Self::Reject, Self::Announce, Self::Like, Self::Undo, Self::Block, Self::Flag,
    ];
}

impl fmt::Display for ActivityType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ActorType (tags 0-4)
// ===========================================================================

/// ActivityPub actor types.
///
/// Matches `ActorType` in `FederationABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ActorType {
    /// Person (tag 0).
    Person = 0,
    /// Service (tag 1).
    Service = 1,
    /// Application (tag 2).
    Application = 2,
    /// Group (tag 3).
    Group = 3,
    /// Organization (tag 4).
    Organization = 4,
}

impl ActorType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Person),
            1 => Some(Self::Service),
            2 => Some(Self::Application),
            3 => Some(Self::Group),
            4 => Some(Self::Organization),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ActorType; 5] = [
        Self::Person, Self::Service, Self::Application, Self::Group, Self::Organization,
    ];
}

impl fmt::Display for ActorType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DeliveryStatus (tags 0-4)
// ===========================================================================

/// Federation delivery statuses.
///
/// Matches `DeliveryStatus` in `FederationABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DeliveryStatus {
    /// Pending (tag 0).
    Pending = 0,
    /// Delivered (tag 1).
    Delivered = 1,
    /// Failed (tag 2).
    Failed = 2,
    /// Rejected (tag 3).
    Rejected = 3,
    /// Deferred (tag 4).
    Deferred = 4,
}

impl DeliveryStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Pending),
            1 => Some(Self::Delivered),
            2 => Some(Self::Failed),
            3 => Some(Self::Rejected),
            4 => Some(Self::Deferred),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DeliveryStatus; 5] = [
        Self::Pending, Self::Delivered, Self::Failed, Self::Rejected, Self::Deferred,
    ];
}

impl fmt::Display for DeliveryStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TrustLevel (tags 0-4)
// ===========================================================================

/// Federation trust levels.
///
/// Matches `TrustLevel` in `FederationABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TrustLevel {
    /// SelfSigned (tag 0).
    SelfSigned = 0,
    /// PeerVerified (tag 1).
    PeerVerified = 1,
    /// FederationTrusted (tag 2).
    FederationTrusted = 2,
    /// Revoked (tag 3).
    Revoked = 3,
    /// Unknown (tag 4).
    Unknown = 4,
}

impl TrustLevel {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::SelfSigned),
            1 => Some(Self::PeerVerified),
            2 => Some(Self::FederationTrusted),
            3 => Some(Self::Revoked),
            4 => Some(Self::Unknown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [TrustLevel; 5] = [
        Self::SelfSigned, Self::PeerVerified, Self::FederationTrusted, Self::Revoked, Self::Unknown,
    ];
}

impl fmt::Display for TrustLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ObjectType (tags 0-8)
// ===========================================================================

/// ActivityPub object types.
///
/// Matches `ObjectType` in `FederationABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ObjectType {
    /// Note (tag 0).
    Note = 0,
    /// Article (tag 1).
    Article = 1,
    /// Image (tag 2).
    Image = 2,
    /// Video (tag 3).
    Video = 3,
    /// Audio (tag 4).
    Audio = 4,
    /// Document (tag 5).
    Document = 5,
    /// Event (tag 6).
    Event = 6,
    /// Collection (tag 7).
    Collection = 7,
    /// OrderedCollection (tag 8).
    OrderedCollection = 8,
}

impl ObjectType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Note),
            1 => Some(Self::Article),
            2 => Some(Self::Image),
            3 => Some(Self::Video),
            4 => Some(Self::Audio),
            5 => Some(Self::Document),
            6 => Some(Self::Event),
            7 => Some(Self::Collection),
            8 => Some(Self::OrderedCollection),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ObjectType; 9] = [
        Self::Note, Self::Article, Self::Image, Self::Video, Self::Audio, Self::Document, Self::Event, Self::Collection, Self::OrderedCollection,
    ];
}

impl fmt::Display for ObjectType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Federation server states.
///
/// Matches `ServerState` in `FederationABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Active (tag 1).
    Active = 1,
    /// Processing (tag 2).
    Processing = 2,
    /// Delivering (tag 3).
    Delivering = 3,
    /// Shutdown (tag 4).
    Shutdown = 4,
}

impl ServerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Active),
            2 => Some(Self::Processing),
            3 => Some(Self::Delivering),
            4 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ServerState; 5] = [
        Self::Idle, Self::Active, Self::Processing, Self::Delivering, Self::Shutdown,
    ];
}

impl fmt::Display for ServerState {
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
    fn activity_type_roundtrip() {
        for v in ActivityType::ALL {
            let tag = v.to_tag();
            let decoded = ActivityType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ActivityType::from_tag(11).is_none());
    }

    #[test]
    fn actor_type_roundtrip() {
        for v in ActorType::ALL {
            let tag = v.to_tag();
            let decoded = ActorType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ActorType::from_tag(5).is_none());
    }

    #[test]
    fn delivery_status_roundtrip() {
        for v in DeliveryStatus::ALL {
            let tag = v.to_tag();
            let decoded = DeliveryStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DeliveryStatus::from_tag(5).is_none());
    }

    #[test]
    fn trust_level_roundtrip() {
        for v in TrustLevel::ALL {
            let tag = v.to_tag();
            let decoded = TrustLevel::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(TrustLevel::from_tag(5).is_none());
    }

    #[test]
    fn object_type_roundtrip() {
        for v in ObjectType::ALL {
            let tag = v.to_tag();
            let decoded = ObjectType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ObjectType::from_tag(9).is_none());
    }

    #[test]
    fn server_state_roundtrip() {
        for v in ServerState::ALL {
            let tag = v.to_tag();
            let decoded = ServerState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ServerState::from_tag(5).is_none());
    }

}
