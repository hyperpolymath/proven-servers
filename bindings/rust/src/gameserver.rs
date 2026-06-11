// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! Game Server types for the proven-servers ABI.
//!
//! Formally verified game server types.
//! Mirrors the Idris2 module `GameserverABI.Types`.
//!
//! - `SessionType` -- Game session types.
//! - `PlayerState` -- Game player states.
//! - `MatchState` -- Game match states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// SessionType (tags 0-4)
// ===========================================================================

/// Game session types.
///
/// Matches `SessionType` in `GameserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionType {
    /// Lobby (tag 0).
    Lobby = 0,
    /// Match (tag 1).
    Match = 1,
    /// Practice (tag 2).
    Practice = 2,
    /// Spectator (tag 3).
    Spectator = 3,
    /// Tournament (tag 4).
    Tournament = 4,
}

impl SessionType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Lobby),
            1 => Some(Self::Match),
            2 => Some(Self::Practice),
            3 => Some(Self::Spectator),
            4 => Some(Self::Tournament),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionType; 5] = [
        Self::Lobby, Self::Match, Self::Practice, Self::Spectator, Self::Tournament,
    ];
}

impl fmt::Display for SessionType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PlayerState (tags 0-5)
// ===========================================================================

/// Game player states.
///
/// Matches `PlayerState` in `GameserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PlayerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Queuing (tag 1).
    Queuing = 1,
    /// Loading (tag 2).
    Loading = 2,
    /// Playing (tag 3).
    Playing = 3,
    /// Spectating (tag 4).
    Spectating = 4,
    /// Disconnected (tag 5).
    Disconnected = 5,
}

impl PlayerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Queuing),
            2 => Some(Self::Loading),
            3 => Some(Self::Playing),
            4 => Some(Self::Spectating),
            5 => Some(Self::Disconnected),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PlayerState; 6] = [
        Self::Idle, Self::Queuing, Self::Loading, Self::Playing, Self::Spectating, Self::Disconnected,
    ];
}

impl fmt::Display for PlayerState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// MatchState (tags 0-5)
// ===========================================================================

/// Game match states.
///
/// Matches `MatchState` in `GameserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MatchState {
    /// Waiting (tag 0).
    Waiting = 0,
    /// Starting (tag 1).
    Starting = 1,
    /// InProgress (tag 2).
    InProgress = 2,
    /// Paused (tag 3).
    Paused = 3,
    /// Ending (tag 4).
    Ending = 4,
    /// Complete (tag 5).
    Complete = 5,
}

impl MatchState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Waiting),
            1 => Some(Self::Starting),
            2 => Some(Self::InProgress),
            3 => Some(Self::Paused),
            4 => Some(Self::Ending),
            5 => Some(Self::Complete),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [MatchState; 6] = [
        Self::Waiting, Self::Starting, Self::InProgress, Self::Paused, Self::Ending, Self::Complete,
    ];
}

impl fmt::Display for MatchState {
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
    fn session_type_roundtrip() {
        for v in SessionType::ALL {
            let tag = v.to_tag();
            let decoded = SessionType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionType::from_tag(5).is_none());
    }

    #[test]
    fn player_state_roundtrip() {
        for v in PlayerState::ALL {
            let tag = v.to_tag();
            let decoded = PlayerState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PlayerState::from_tag(6).is_none());
    }

    #[test]
    fn match_state_roundtrip() {
        for v in MatchState::ALL {
            let tag = v.to_tag();
            let decoded = MatchState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(MatchState::from_tag(6).is_none());
    }

}
