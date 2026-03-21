// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Git Server types for the proven-servers ABI.
//!
//! Formally verified Git smart protocol types.
//! Mirrors the Idris2 module `GitABI.Types`.
//!
//! - `Command` -- Git protocol commands.
//! - `PacketType` -- Git protocol packet types.
//! - `RefType` -- Git reference types.
//! - `Capability` -- Git protocol capabilities.
//! - `HookResult` -- Git hook results.
//! - `ServerState` -- Git server states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Git Server Constants
// ===========================================================================

/// Standard Git daemon port.
pub const GIT_PORT: u16 = 9418;

// ===========================================================================
// Command (tags 0-2)
// ===========================================================================

/// Git protocol commands.
///
/// Matches `Command` in `GitABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Command {
    /// git-upload-pack (tag 0).
    UploadPack = 0,
    /// git-receive-pack (tag 1).
    ReceivePack = 1,
    /// git-upload-archive (tag 2).
    UploadArchive = 2,
}

impl Command {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::UploadPack),
            1 => Some(Self::ReceivePack),
            2 => Some(Self::UploadArchive),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Command; 3] = [
        Self::UploadPack, Self::ReceivePack, Self::UploadArchive,
    ];
}

impl fmt::Display for Command {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PacketType (tags 0-7)
// ===========================================================================

/// Git protocol packet types.
///
/// Matches `PacketType` in `GitABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PacketType {
    /// Flush (tag 0).
    Flush = 0,
    /// Delimiter (tag 1).
    Delimiter = 1,
    /// ResponseEnd (tag 2).
    ResponseEnd = 2,
    /// Data (tag 3).
    Data = 3,
    /// Error packet (tag 4).
    PktError = 4,
    /// SidebandData (tag 5).
    SidebandData = 5,
    /// SidebandProgress (tag 6).
    SidebandProgress = 6,
    /// SidebandError (tag 7).
    SidebandError = 7,
}

impl PacketType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Flush),
            1 => Some(Self::Delimiter),
            2 => Some(Self::ResponseEnd),
            3 => Some(Self::Data),
            4 => Some(Self::PktError),
            5 => Some(Self::SidebandData),
            6 => Some(Self::SidebandProgress),
            7 => Some(Self::SidebandError),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PacketType; 8] = [
        Self::Flush, Self::Delimiter, Self::ResponseEnd, Self::Data, Self::PktError, Self::SidebandData, Self::SidebandProgress, Self::SidebandError,
    ];
}

impl fmt::Display for PacketType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RefType (tags 0-4)
// ===========================================================================

/// Git reference types.
///
/// Matches `RefType` in `GitABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RefType {
    /// Branch (tag 0).
    Branch = 0,
    /// Tag (tag 1).
    Tag = 1,
    /// Head (tag 2).
    Head = 2,
    /// Remote (tag 3).
    Remote = 3,
    /// Note (tag 4).
    GitNote = 4,
}

impl RefType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Branch),
            1 => Some(Self::Tag),
            2 => Some(Self::Head),
            3 => Some(Self::Remote),
            4 => Some(Self::GitNote),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [RefType; 5] = [
        Self::Branch, Self::Tag, Self::Head, Self::Remote, Self::GitNote,
    ];
}

impl fmt::Display for RefType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Capability (tags 0-8)
// ===========================================================================

/// Git protocol capabilities.
///
/// Matches `Capability` in `GitABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Capability {
    /// MultiAck (tag 0).
    MultiAck = 0,
    /// ThinPack (tag 1).
    ThinPack = 1,
    /// SideBand64k (tag 2).
    SideBand64k = 2,
    /// OFS-delta (tag 3).
    OfsDelta = 3,
    /// Shallow (tag 4).
    Shallow = 4,
    /// DeepenSince (tag 5).
    DeepenSince = 5,
    /// DeepenNot (tag 6).
    DeepenNot = 6,
    /// FilterSpec (tag 7).
    FilterSpec = 7,
    /// ObjectFormat (tag 8).
    ObjectFormat = 8,
}

impl Capability {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::MultiAck),
            1 => Some(Self::ThinPack),
            2 => Some(Self::SideBand64k),
            3 => Some(Self::OfsDelta),
            4 => Some(Self::Shallow),
            5 => Some(Self::DeepenSince),
            6 => Some(Self::DeepenNot),
            7 => Some(Self::FilterSpec),
            8 => Some(Self::ObjectFormat),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Capability; 9] = [
        Self::MultiAck, Self::ThinPack, Self::SideBand64k, Self::OfsDelta, Self::Shallow, Self::DeepenSince, Self::DeepenNot, Self::FilterSpec, Self::ObjectFormat,
    ];
}

impl fmt::Display for Capability {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HookResult (tags 0-1)
// ===========================================================================

/// Git hook results.
///
/// Matches `HookResult` in `GitABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HookResult {
    /// Accept (tag 0).
    Accept = 0,
    /// Reject (tag 1).
    Reject = 1,
}

impl HookResult {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Accept),
            1 => Some(Self::Reject),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HookResult; 2] = [
        Self::Accept, Self::Reject,
    ];
}

impl fmt::Display for HookResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Git server states.
///
/// Matches `ServerState` in `GitABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Discovery (tag 1).
    Discovery = 1,
    /// Negotiating (tag 2).
    Negotiating = 2,
    /// Transfer (tag 3).
    Transfer = 3,
    /// Shutdown (tag 4).
    Shutdown = 4,
}

impl ServerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Discovery),
            2 => Some(Self::Negotiating),
            3 => Some(Self::Transfer),
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
        Self::Idle, Self::Discovery, Self::Negotiating, Self::Transfer, Self::Shutdown,
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
    fn command_roundtrip() {
        for v in Command::ALL {
            let tag = v.to_tag();
            let decoded = Command::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Command::from_tag(3).is_none());
    }

    #[test]
    fn packet_type_roundtrip() {
        for v in PacketType::ALL {
            let tag = v.to_tag();
            let decoded = PacketType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PacketType::from_tag(8).is_none());
    }

    #[test]
    fn ref_type_roundtrip() {
        for v in RefType::ALL {
            let tag = v.to_tag();
            let decoded = RefType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RefType::from_tag(5).is_none());
    }

    #[test]
    fn capability_roundtrip() {
        for v in Capability::ALL {
            let tag = v.to_tag();
            let decoded = Capability::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Capability::from_tag(9).is_none());
    }

    #[test]
    fn hook_result_roundtrip() {
        for v in HookResult::ALL {
            let tag = v.to_tag();
            let decoded = HookResult::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HookResult::from_tag(2).is_none());
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

    #[test]
    fn constants_match_idris() {
        assert_eq!(GIT_PORT, 9418);
    }

}
