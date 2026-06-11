// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! ODNS types for the proven-servers ABI.
//!
//! Formally verified Oblivious DNS (ODNS) types.
//! Mirrors the Idris2 module `OdnsABI.Types`.
//!
//! - `Role` -- ODNS participant roles.
//! - `OdnsMessageType` -- ODNS message types.
//! - `OdnsErrorReason` -- ODNS error reasons.
//! - `EncapsulationFormat` -- ODNS encapsulation formats.
//! - `SessionState` -- ODNS session states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Role (tags 0-2)
// ===========================================================================

/// ODNS participant roles.
///
/// Matches `Role` in `OdnsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Role {
    /// Client (tag 0).
    Client = 0,
    /// Proxy (tag 1).
    Proxy = 1,
    /// Target (tag 2).
    Target = 2,
}

impl Role {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Client),
            1 => Some(Self::Proxy),
            2 => Some(Self::Target),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Role; 3] = [
        Self::Client, Self::Proxy, Self::Target,
    ];
}

impl fmt::Display for Role {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// OdnsMessageType (tags 0-1)
// ===========================================================================

/// ODNS message types.
///
/// Matches `OdnsMessageType` in `OdnsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum OdnsMessageType {
    /// Query (tag 0).
    Query = 0,
    /// Response (tag 1).
    Response = 1,
}

impl OdnsMessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Query),
            1 => Some(Self::Response),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [OdnsMessageType; 2] = [
        Self::Query, Self::Response,
    ];
}

impl fmt::Display for OdnsMessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// OdnsErrorReason (tags 0-4)
// ===========================================================================

/// ODNS error reasons.
///
/// Matches `OdnsErrorReason` in `OdnsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum OdnsErrorReason {
    /// ProxyError (tag 0).
    ProxyError = 0,
    /// TargetError (tag 1).
    TargetError = 1,
    /// DecryptionFailed (tag 2).
    DecryptionFailed = 2,
    /// InvalidConfig (tag 3).
    InvalidConfig = 3,
    /// PayloadTooLarge (tag 4).
    PayloadTooLarge = 4,
}

impl OdnsErrorReason {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ProxyError),
            1 => Some(Self::TargetError),
            2 => Some(Self::DecryptionFailed),
            3 => Some(Self::InvalidConfig),
            4 => Some(Self::PayloadTooLarge),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [OdnsErrorReason; 5] = [
        Self::ProxyError, Self::TargetError, Self::DecryptionFailed, Self::InvalidConfig, Self::PayloadTooLarge,
    ];
}

impl fmt::Display for OdnsErrorReason {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// EncapsulationFormat (tags 0-0)
// ===========================================================================

/// ODNS encapsulation formats.
///
/// Matches `EncapsulationFormat` in `OdnsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum EncapsulationFormat {
    /// HPKE (tag 0).
    Hpke = 0,
}

impl EncapsulationFormat {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Hpke),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [EncapsulationFormat; 1] = [
        Self::Hpke,
    ];
}

impl fmt::Display for EncapsulationFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// ODNS session states.
///
/// Matches `SessionState` in `OdnsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Idle (tag 0).
    Idle = 0,
    /// KeyExchange (tag 1).
    KeyExchange = 1,
    /// Ready (tag 2).
    Ready = 2,
    /// Processing (tag 3).
    Processing = 3,
    /// Closing (tag 4).
    Closing = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::KeyExchange),
            2 => Some(Self::Ready),
            3 => Some(Self::Processing),
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
        Self::Idle, Self::KeyExchange, Self::Ready, Self::Processing, Self::Closing,
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
    fn role_roundtrip() {
        for v in Role::ALL {
            let tag = v.to_tag();
            let decoded = Role::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Role::from_tag(3).is_none());
    }

    #[test]
    fn odns_message_type_roundtrip() {
        for v in OdnsMessageType::ALL {
            let tag = v.to_tag();
            let decoded = OdnsMessageType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(OdnsMessageType::from_tag(2).is_none());
    }

    #[test]
    fn odns_error_reason_roundtrip() {
        for v in OdnsErrorReason::ALL {
            let tag = v.to_tag();
            let decoded = OdnsErrorReason::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(OdnsErrorReason::from_tag(5).is_none());
    }

    #[test]
    fn encapsulation_format_roundtrip() {
        for v in EncapsulationFormat::ALL {
            let tag = v.to_tag();
            let decoded = EncapsulationFormat::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(EncapsulationFormat::from_tag(1).is_none());
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

}
