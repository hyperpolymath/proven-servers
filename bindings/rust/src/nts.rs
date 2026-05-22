// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Network Time Security types for the proven-servers ABI.
//!
//! Formally verified NTS types (RFC 8915).
//! Mirrors the Idris2 module `NtsABI.Types`.
//!
//! - `RecordType` -- NTS-KE record types.
//! - `ErrorCode` -- NTS error codes.
//! - `AeadAlgorithm` -- AEAD algorithms for NTS.
//! - `HandshakeState` -- NTS handshake states.
//! - `SessionState` -- NTS session lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Network Time Security Constants
// ===========================================================================

/// Standard NTS-KE port.
pub const NTS_KE_PORT: u16 = 4460;

// ===========================================================================
// RecordType (tags 0-8)
// ===========================================================================

/// NTS-KE record types.
///
/// Matches `RecordType` in `NtsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RecordType {
    /// EndOfMessage (tag 0).
    EndOfMessage = 0,
    /// NextProtocol (tag 1).
    NextProtocol = 1,
    /// Error (tag 2).
    Error = 2,
    /// Warning (tag 3).
    Warning = 3,
    /// AEAD algorithm negotiation (tag 4).
    AeadAlgorithm = 4,
    /// Cookie (tag 5).
    Cookie = 5,
    /// CookiePlaceholder (tag 6).
    CookiePlaceholder = 6,
    /// NTS-KE server (tag 7).
    NtskeServer = 7,
    /// NTS-KE port (tag 8).
    NtskePort = 8,
}

impl RecordType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::EndOfMessage),
            1 => Some(Self::NextProtocol),
            2 => Some(Self::Error),
            3 => Some(Self::Warning),
            4 => Some(Self::AeadAlgorithm),
            5 => Some(Self::Cookie),
            6 => Some(Self::CookiePlaceholder),
            7 => Some(Self::NtskeServer),
            8 => Some(Self::NtskePort),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [RecordType; 9] = [
        Self::EndOfMessage, Self::NextProtocol, Self::Error, Self::Warning, Self::AeadAlgorithm, Self::Cookie, Self::CookiePlaceholder, Self::NtskeServer, Self::NtskePort,
    ];
}

impl fmt::Display for RecordType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorCode (tags 0-2)
// ===========================================================================

/// NTS error codes.
///
/// Matches `ErrorCode` in `NtsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCode {
    /// UnrecognizedCritical (tag 0).
    UnrecognizedCritical = 0,
    /// BadRequest (tag 1).
    BadRequest = 1,
    /// InternalError (tag 2).
    InternalError = 2,
}

impl ErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::UnrecognizedCritical),
            1 => Some(Self::BadRequest),
            2 => Some(Self::InternalError),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ErrorCode; 3] = [
        Self::UnrecognizedCritical, Self::BadRequest, Self::InternalError,
    ];
}

impl fmt::Display for ErrorCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AeadAlgorithm (tags 0-2)
// ===========================================================================

/// AEAD algorithms for NTS.
///
/// Matches `AeadAlgorithm` in `NtsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AeadAlgorithm {
    /// AEAD-AES-128-GCM (tag 0).
    AeadAes128Gcm = 0,
    /// AEAD-AES-256-GCM (tag 1).
    AeadAes256Gcm = 1,
    /// AEAD-AES-SIV-CMAC-256 (tag 2).
    AeadAesSivCmac256 = 2,
}

impl AeadAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::AeadAes128Gcm),
            1 => Some(Self::AeadAes256Gcm),
            2 => Some(Self::AeadAesSivCmac256),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AeadAlgorithm; 3] = [
        Self::AeadAes128Gcm, Self::AeadAes256Gcm, Self::AeadAesSivCmac256,
    ];
}

impl fmt::Display for AeadAlgorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HandshakeState (tags 0-3)
// ===========================================================================

/// NTS handshake states.
///
/// Matches `HandshakeState` in `NtsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HandshakeState {
    /// Initial (tag 0).
    Initial = 0,
    /// Negotiating (tag 1).
    Negotiating = 1,
    /// Established (tag 2).
    Established = 2,
    /// Failed (tag 3).
    Failed = 3,
}

impl HandshakeState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Initial),
            1 => Some(Self::Negotiating),
            2 => Some(Self::Established),
            3 => Some(Self::Failed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HandshakeState; 4] = [
        Self::Initial, Self::Negotiating, Self::Established, Self::Failed,
    ];
}

impl fmt::Display for HandshakeState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// NTS session lifecycle states.
///
/// Matches `SessionState` in `NtsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Idle (tag 0).
    Idle = 0,
    /// Handshaking (tag 1).
    Handshaking = 1,
    /// Negotiating (tag 2).
    Negotiating = 2,
    /// Established (tag 3).
    Established = 3,
    /// Closing (tag 4).
    Closing = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Handshaking),
            2 => Some(Self::Negotiating),
            3 => Some(Self::Established),
            4 => Some(Self::Closing),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionState; 5] = [
        Self::Idle, Self::Handshaking, Self::Negotiating, Self::Established, Self::Closing,
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
    fn record_type_roundtrip() {
        for v in RecordType::ALL {
            let tag = v.to_tag();
            let decoded = RecordType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RecordType::from_tag(9).is_none());
    }

    #[test]
    fn error_code_roundtrip() {
        for v in ErrorCode::ALL {
            let tag = v.to_tag();
            let decoded = ErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ErrorCode::from_tag(3).is_none());
    }

    #[test]
    fn aead_algorithm_roundtrip() {
        for v in AeadAlgorithm::ALL {
            let tag = v.to_tag();
            let decoded = AeadAlgorithm::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AeadAlgorithm::from_tag(3).is_none());
    }

    #[test]
    fn handshake_state_roundtrip() {
        for v in HandshakeState::ALL {
            let tag = v.to_tag();
            let decoded = HandshakeState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HandshakeState::from_tag(4).is_none());
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
        assert_eq!(NTS_KE_PORT, 4460);
    }

}
