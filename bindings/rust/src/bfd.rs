// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! BFD types for the proven-servers ABI.
//!
//! Formally verified BFD (Bidirectional Forwarding Detection, RFC 5880) types.
//! Mirrors the Idris2 module `BfdABI.Types`.
//!
//! - `BfdState` -- BFD session states (RFC 5880 Section 4.1).
//! - `Diagnostic` -- BFD diagnostic codes (RFC 5880 Section 4.1).
//! - `SessionMode` -- BFD session modes.
//! - `SessionState` -- BFD session lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// BFD Constants
// ===========================================================================

/// Standard BFD port.
pub const BFD_PORT: u16 = 3784;

// ===========================================================================
// BfdState (tags 0-3)
// ===========================================================================

/// BFD session states (RFC 5880 Section 4.1).
///
/// Matches `BfdState` in `BfdABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum BfdState {
    /// AdminDown (tag 0).
    AdminDown = 0,
    /// Down (tag 1).
    Down = 1,
    /// Init (tag 2).
    Init = 2,
    /// Up (tag 3).
    Up = 3,
}

impl BfdState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::AdminDown),
            1 => Some(Self::Down),
            2 => Some(Self::Init),
            3 => Some(Self::Up),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [BfdState; 4] = [
        Self::AdminDown, Self::Down, Self::Init, Self::Up,
    ];
}

impl fmt::Display for BfdState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Diagnostic (tags 0-8)
// ===========================================================================

/// BFD diagnostic codes (RFC 5880 Section 4.1).
///
/// Matches `Diagnostic` in `BfdABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Diagnostic {
    /// NoDiagnostic (tag 0).
    NoDiagnostic = 0,
    /// ControlDetectionTimeExpired (tag 1).
    ControlDetectionTimeExpired = 1,
    /// EchoFunctionFailed (tag 2).
    EchoFunctionFailed = 2,
    /// NeighborSignaledSessionDown (tag 3).
    NeighborSignaledSessionDown = 3,
    /// ForwardingPlaneReset (tag 4).
    ForwardingPlaneReset = 4,
    /// PathDown (tag 5).
    PathDown = 5,
    /// ConcatenatedPathDown (tag 6).
    ConcatenatedPathDown = 6,
    /// AdministrativelyDown (tag 7).
    AdministrativelyDown = 7,
    /// ReverseConcatenatedPathDown (tag 8).
    ReverseConcatenatedPathDown = 8,
}

impl Diagnostic {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NoDiagnostic),
            1 => Some(Self::ControlDetectionTimeExpired),
            2 => Some(Self::EchoFunctionFailed),
            3 => Some(Self::NeighborSignaledSessionDown),
            4 => Some(Self::ForwardingPlaneReset),
            5 => Some(Self::PathDown),
            6 => Some(Self::ConcatenatedPathDown),
            7 => Some(Self::AdministrativelyDown),
            8 => Some(Self::ReverseConcatenatedPathDown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Diagnostic; 9] = [
        Self::NoDiagnostic, Self::ControlDetectionTimeExpired, Self::EchoFunctionFailed, Self::NeighborSignaledSessionDown, Self::ForwardingPlaneReset, Self::PathDown, Self::ConcatenatedPathDown, Self::AdministrativelyDown, Self::ReverseConcatenatedPathDown,
    ];
}

impl fmt::Display for Diagnostic {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionMode (tags 0-1)
// ===========================================================================

/// BFD session modes.
///
/// Matches `SessionMode` in `BfdABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionMode {
    /// AsyncMode (tag 0).
    AsyncMode = 0,
    /// DemandMode (tag 1).
    DemandMode = 1,
}

impl SessionMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::AsyncMode),
            1 => Some(Self::DemandMode),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionMode; 2] = [
        Self::AsyncMode, Self::DemandMode,
    ];
}

impl fmt::Display for SessionMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// BFD session lifecycle states.
///
/// Matches `SessionState` in `BfdABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Idle (tag 0).
    Idle = 0,
    /// Down (tag 1).
    SsDown = 1,
    /// Negotiating (tag 2).
    Negotiating = 2,
    /// Established (tag 3).
    Established = 3,
    /// Teardown (tag 4).
    Teardown = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::SsDown),
            2 => Some(Self::Negotiating),
            3 => Some(Self::Established),
            4 => Some(Self::Teardown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionState; 5] = [
        Self::Idle, Self::SsDown, Self::Negotiating, Self::Established, Self::Teardown,
    ];
}

impl fmt::Display for SessionState {
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
    fn bfd_state_roundtrip() {
        for v in BfdState::ALL {
            let tag = v.to_tag();
            let decoded = BfdState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(BfdState::from_tag(4).is_none());
    }

    #[test]
    fn diagnostic_roundtrip() {
        for v in Diagnostic::ALL {
            let tag = v.to_tag();
            let decoded = Diagnostic::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Diagnostic::from_tag(9).is_none());
    }

    #[test]
    fn session_mode_roundtrip() {
        for v in SessionMode::ALL {
            let tag = v.to_tag();
            let decoded = SessionMode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionMode::from_tag(2).is_none());
    }

    #[test]
    fn session_state_roundtrip() {
        for v in SessionState::ALL {
            let tag = v.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionState::from_tag(5).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(BFD_PORT, 3784);
    }

}
