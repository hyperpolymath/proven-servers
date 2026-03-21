// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! DNS-over-QUIC types for the proven-servers ABI.
//!
//! Formally verified DoQ types (RFC 9250).
//! Mirrors the Idris2 module `DoqABI.Types`.
//!
//! - `StreamType` -- QUIC stream types.
//! - `ErrorCode` -- DoQ error codes.
//! - `SessionState` -- DoQ session lifecycle states.
//! - `ServerState` -- DoQ server lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// DNS-over-QUIC Constants
// ===========================================================================

/// Standard DoQ port.
pub const DOQ_PORT: u16 = 853;

// ===========================================================================
// StreamType (tags 0-1)
// ===========================================================================

/// QUIC stream types.
///
/// Matches `StreamType` in `DoqABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StreamType {
    /// Unidirectional (tag 0).
    Unidirectional = 0,
    /// Bidirectional (tag 1).
    Bidirectional = 1,
}

impl StreamType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Unidirectional),
            1 => Some(Self::Bidirectional),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [StreamType; 2] = [
        Self::Unidirectional, Self::Bidirectional,
    ];
}

impl fmt::Display for StreamType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorCode (tags 0-3)
// ===========================================================================

/// DoQ error codes.
///
/// Matches `ErrorCode` in `DoqABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCode {
    /// NoError (tag 0).
    NoError = 0,
    /// InternalError (tag 1).
    InternalError = 1,
    /// ExcessiveLoad (tag 2).
    ExcessiveLoad = 2,
    /// ProtocolError (tag 3).
    ProtocolError = 3,
}

impl ErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NoError),
            1 => Some(Self::InternalError),
            2 => Some(Self::ExcessiveLoad),
            3 => Some(Self::ProtocolError),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ErrorCode; 4] = [
        Self::NoError, Self::InternalError, Self::ExcessiveLoad, Self::ProtocolError,
    ];
}

impl fmt::Display for ErrorCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// DoQ session lifecycle states.
///
/// Matches `SessionState` in `DoqABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Initial (tag 0).
    Initial = 0,
    /// Handshaking (tag 1).
    Handshaking = 1,
    /// Ready (tag 2).
    Ready = 2,
    /// Draining (tag 3).
    Draining = 3,
    /// Closed (tag 4).
    Closed = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Initial),
            1 => Some(Self::Handshaking),
            2 => Some(Self::Ready),
            3 => Some(Self::Draining),
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
        Self::Initial, Self::Handshaking, Self::Ready, Self::Draining, Self::Closed,
    ];
}

impl fmt::Display for SessionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// DoQ server lifecycle states.
///
/// Matches `ServerState` in `DoqABI.Types`.
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
    fn stream_type_roundtrip() {
        for v in StreamType::ALL {
            let tag = v.to_tag();
            let decoded = StreamType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(StreamType::from_tag(2).is_none());
    }

    #[test]
    fn error_code_roundtrip() {
        for v in ErrorCode::ALL {
            let tag = v.to_tag();
            let decoded = ErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ErrorCode::from_tag(4).is_none());
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
        assert_eq!(DOQ_PORT, 853);
    }

}
