// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! DNS-over-TLS types for the proven-servers ABI.
//!
//! Formally verified DoT types (RFC 7858).
//! Mirrors the Idris2 module `DotABI.Types`.
//!
//! - `SessionState` -- DoT session lifecycle states.
//! - `PaddingStrategy` -- DoT padding strategies (RFC 7830).
//! - `ErrorReason` -- DoT error reasons.
//! - `ServerState` -- DoT server lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// DNS-over-TLS Constants
// ===========================================================================

/// Standard DoT port.
pub const DOT_PORT: u16 = 853;

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// DoT session lifecycle states.
///
/// Matches `SessionState` in `DotABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Connecting (tag 0).
    Connecting = 0,
    /// Handshaking (tag 1).
    Handshaking = 1,
    /// Established (tag 2).
    Established = 2,
    /// Closing (tag 3).
    Closing = 3,
    /// Closed (tag 4).
    Closed = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Connecting),
            1 => Some(Self::Handshaking),
            2 => Some(Self::Established),
            3 => Some(Self::Closing),
            4 => Some(Self::Closed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionState; 5] = [
        Self::Connecting, Self::Handshaking, Self::Established, Self::Closing, Self::Closed,
    ];
}

impl fmt::Display for SessionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PaddingStrategy (tags 0-2)
// ===========================================================================

/// DoT padding strategies (RFC 7830).
///
/// Matches `PaddingStrategy` in `DotABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PaddingStrategy {
    /// NoPadding (tag 0).
    NoPadding = 0,
    /// BlockPadding (tag 1).
    BlockPadding = 1,
    /// RandomPadding (tag 2).
    RandomPadding = 2,
}

impl PaddingStrategy {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NoPadding),
            1 => Some(Self::BlockPadding),
            2 => Some(Self::RandomPadding),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PaddingStrategy; 3] = [
        Self::NoPadding, Self::BlockPadding, Self::RandomPadding,
    ];
}

impl fmt::Display for PaddingStrategy {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorReason (tags 0-3)
// ===========================================================================

/// DoT error reasons.
///
/// Matches `ErrorReason` in `DotABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorReason {
    /// HandshakeFailed (tag 0).
    HandshakeFailed = 0,
    /// CertificateInvalid (tag 1).
    CertificateInvalid = 1,
    /// Timeout (tag 2).
    Timeout = 2,
    /// UpstreamError (tag 3).
    UpstreamError = 3,
}

impl ErrorReason {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::HandshakeFailed),
            1 => Some(Self::CertificateInvalid),
            2 => Some(Self::Timeout),
            3 => Some(Self::UpstreamError),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ErrorReason; 4] = [
        Self::HandshakeFailed, Self::CertificateInvalid, Self::Timeout, Self::UpstreamError,
    ];
}

impl fmt::Display for ErrorReason {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// DoT server lifecycle states.
///
/// Matches `ServerState` in `DotABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Bound (tag 1).
    Bound = 1,
    /// Listening (tag 2).
    Listening = 2,
    /// Processing (tag 3).
    Processing = 3,
    /// Shutdown (tag 4).
    Shutdown = 4,
}

impl ServerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Bound),
            2 => Some(Self::Listening),
            3 => Some(Self::Processing),
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
        Self::Idle, Self::Bound, Self::Listening, Self::Processing, Self::Shutdown,
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
    fn session_state_roundtrip() {
        for v in SessionState::ALL {
            let tag = v.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionState::from_tag(5).is_none());
    }

    #[test]
    fn padding_strategy_roundtrip() {
        for v in PaddingStrategy::ALL {
            let tag = v.to_tag();
            let decoded = PaddingStrategy::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PaddingStrategy::from_tag(3).is_none());
    }

    #[test]
    fn error_reason_roundtrip() {
        for v in ErrorReason::ALL {
            let tag = v.to_tag();
            let decoded = ErrorReason::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ErrorReason::from_tag(4).is_none());
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
        assert_eq!(DOT_PORT, 853);
    }

}
