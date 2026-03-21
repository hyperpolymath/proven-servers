// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Chat Server types for the proven-servers ABI.
//!
//! Formally verified real-time chat types.
//! Mirrors the Idris2 module `ChatABI.Types`.
//!
//! - `MessageType` -- Chat message types.
//! - `PresenceStatus` -- User presence statuses.
//! - `RoomType` -- Chat room types.
//! - `Permission` -- Chat permissions.
//! - `Event` -- Chat events.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// MessageType (tags 0-8)
// ===========================================================================

/// Chat message types.
///
/// Matches `MessageType` in `ChatABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MessageType {
    /// Text (tag 0).
    Text = 0,
    /// Image (tag 1).
    Image = 1,
    /// File (tag 2).
    File = 2,
    /// System (tag 3).
    System = 3,
    /// Reaction (tag 4).
    Reaction = 4,
    /// Edit (tag 5).
    Edit = 5,
    /// Delete (tag 6).
    Delete = 6,
    /// Reply (tag 7).
    Reply = 7,
    /// Thread (tag 8).
    Thread = 8,
}

impl MessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Text),
            1 => Some(Self::Image),
            2 => Some(Self::File),
            3 => Some(Self::System),
            4 => Some(Self::Reaction),
            5 => Some(Self::Edit),
            6 => Some(Self::Delete),
            7 => Some(Self::Reply),
            8 => Some(Self::Thread),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [MessageType; 9] = [
        Self::Text, Self::Image, Self::File, Self::System, Self::Reaction, Self::Edit, Self::Delete, Self::Reply, Self::Thread,
    ];
}

impl fmt::Display for MessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PresenceStatus (tags 0-4)
// ===========================================================================

/// User presence statuses.
///
/// Matches `PresenceStatus` in `ChatABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PresenceStatus {
    /// Online (tag 0).
    Online = 0,
    /// Away (tag 1).
    Away = 1,
    /// Do Not Disturb (tag 2).
    Dnd = 2,
    /// Invisible (tag 3).
    Invisible = 3,
    /// Offline (tag 4).
    Offline = 4,
}

impl PresenceStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Online),
            1 => Some(Self::Away),
            2 => Some(Self::Dnd),
            3 => Some(Self::Invisible),
            4 => Some(Self::Offline),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PresenceStatus; 5] = [
        Self::Online, Self::Away, Self::Dnd, Self::Invisible, Self::Offline,
    ];
}

impl fmt::Display for PresenceStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RoomType (tags 0-3)
// ===========================================================================

/// Chat room types.
///
/// Matches `RoomType` in `ChatABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RoomType {
    /// Direct (tag 0).
    Direct = 0,
    /// Group (tag 1).
    Group = 1,
    /// Channel (tag 2).
    Channel = 2,
    /// Broadcast (tag 3).
    Broadcast = 3,
}

impl RoomType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Direct),
            1 => Some(Self::Group),
            2 => Some(Self::Channel),
            3 => Some(Self::Broadcast),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [RoomType; 4] = [
        Self::Direct, Self::Group, Self::Channel, Self::Broadcast,
    ];
}

impl fmt::Display for RoomType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Permission (tags 0-7)
// ===========================================================================

/// Chat permissions.
///
/// Matches `Permission` in `ChatABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Permission {
    /// Read (tag 0).
    Read = 0,
    /// Write (tag 1).
    Write = 1,
    /// Admin (tag 2).
    Admin = 2,
    /// Invite (tag 3).
    Invite = 3,
    /// Kick (tag 4).
    Kick = 4,
    /// Ban (tag 5).
    Ban = 5,
    /// Pin (tag 6).
    Pin = 6,
    /// DeleteOthers (tag 7).
    DeleteOthers = 7,
}

impl Permission {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Read),
            1 => Some(Self::Write),
            2 => Some(Self::Admin),
            3 => Some(Self::Invite),
            4 => Some(Self::Kick),
            5 => Some(Self::Ban),
            6 => Some(Self::Pin),
            7 => Some(Self::DeleteOthers),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Permission; 8] = [
        Self::Read, Self::Write, Self::Admin, Self::Invite, Self::Kick, Self::Ban, Self::Pin, Self::DeleteOthers,
    ];
}

impl fmt::Display for Permission {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Event (tags 0-6)
// ===========================================================================

/// Chat events.
///
/// Matches `Event` in `ChatABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Event {
    /// MessageSent (tag 0).
    MessageSent = 0,
    /// MessageDelivered (tag 1).
    MessageDelivered = 1,
    /// MessageRead (tag 2).
    MessageRead = 2,
    /// UserJoined (tag 3).
    UserJoined = 3,
    /// UserLeft (tag 4).
    UserLeft = 4,
    /// Typing (tag 5).
    Typing = 5,
    /// RoomCreated (tag 6).
    RoomCreated = 6,
}

impl Event {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::MessageSent),
            1 => Some(Self::MessageDelivered),
            2 => Some(Self::MessageRead),
            3 => Some(Self::UserJoined),
            4 => Some(Self::UserLeft),
            5 => Some(Self::Typing),
            6 => Some(Self::RoomCreated),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Event; 7] = [
        Self::MessageSent, Self::MessageDelivered, Self::MessageRead, Self::UserJoined, Self::UserLeft, Self::Typing, Self::RoomCreated,
    ];
}

impl fmt::Display for Event {
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
    fn message_type_roundtrip() {
        for v in MessageType::ALL {
            let tag = v.to_tag();
            let decoded = MessageType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(MessageType::from_tag(9).is_none());
    }

    #[test]
    fn presence_status_roundtrip() {
        for v in PresenceStatus::ALL {
            let tag = v.to_tag();
            let decoded = PresenceStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PresenceStatus::from_tag(5).is_none());
    }

    #[test]
    fn room_type_roundtrip() {
        for v in RoomType::ALL {
            let tag = v.to_tag();
            let decoded = RoomType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RoomType::from_tag(4).is_none());
    }

    #[test]
    fn permission_roundtrip() {
        for v in Permission::ALL {
            let tag = v.to_tag();
            let decoded = Permission::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Permission::from_tag(8).is_none());
    }

    #[test]
    fn event_roundtrip() {
        for v in Event::ALL {
            let tag = v.to_tag();
            let decoded = Event::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Event::from_tag(7).is_none());
    }

}
