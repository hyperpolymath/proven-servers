// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! STUN/TURN types for the proven-servers ABI.
//!
//! Formally verified STUN/TURN types (RFC 8489, RFC 8656).
//! Mirrors the Idris2 module `StunABI.Types`.
//!
//! - `MessageType` -- STUN/TURN message types.
//! - `TransportProtocol` -- STUN transport protocols.
//! - `ErrorCode` -- STUN error codes.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// STUN/TURN Constants
// ===========================================================================

/// Standard STUN port.
pub const STUN_PORT: u16 = 3478;

/// Standard STUN TLS port.
pub const STUN_TLS_PORT: u16 = 5349;

// ===========================================================================
// MessageType (tags 0-11)
// ===========================================================================

/// STUN/TURN message types.
///
/// Matches `MessageType` in `StunABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MessageType {
    /// BindingRequest (tag 0).
    BindingRequest = 0,
    /// BindingResponse (tag 1).
    BindingResponse = 1,
    /// BindingError (tag 2).
    BindingError = 2,
    /// AllocateRequest (tag 3).
    AllocateRequest = 3,
    /// AllocateResponse (tag 4).
    AllocateResponse = 4,
    /// AllocateError (tag 5).
    AllocateError = 5,
    /// RefreshRequest (tag 6).
    RefreshRequest = 6,
    /// RefreshResponse (tag 7).
    RefreshResponse = 7,
    /// SendIndication (tag 8).
    SendIndication = 8,
    /// DataIndication (tag 9).
    DataIndication = 9,
    /// CreatePermission (tag 10).
    CreatePermission = 10,
    /// ChannelBind (tag 11).
    ChannelBind = 11,
}

impl MessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::BindingRequest),
            1 => Some(Self::BindingResponse),
            2 => Some(Self::BindingError),
            3 => Some(Self::AllocateRequest),
            4 => Some(Self::AllocateResponse),
            5 => Some(Self::AllocateError),
            6 => Some(Self::RefreshRequest),
            7 => Some(Self::RefreshResponse),
            8 => Some(Self::SendIndication),
            9 => Some(Self::DataIndication),
            10 => Some(Self::CreatePermission),
            11 => Some(Self::ChannelBind),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is a request message.
    pub fn is_request(self) -> bool {
        matches!(self, Self::BindingRequest | Self::AllocateRequest | Self::RefreshRequest | Self::CreatePermission | Self::ChannelBind)
    }

    /// Whether this is a TURN-specific message.
    pub fn is_turn(self) -> bool {
        matches!(self, Self::AllocateRequest | Self::AllocateResponse | Self::AllocateError | Self::RefreshRequest | Self::RefreshResponse | Self::SendIndication | Self::DataIndication | Self::CreatePermission | Self::ChannelBind)
    }

    /// All variants of this type.
    pub const ALL: [MessageType; 12] = [
        Self::BindingRequest, Self::BindingResponse, Self::BindingError, Self::AllocateRequest, Self::AllocateResponse, Self::AllocateError, Self::RefreshRequest, Self::RefreshResponse, Self::SendIndication, Self::DataIndication, Self::CreatePermission, Self::ChannelBind,
    ];
}

impl fmt::Display for MessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// TransportProtocol (tags 0-3)
// ===========================================================================

/// STUN transport protocols.
///
/// Matches `TransportProtocol` in `StunABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransportProtocol {
    /// UDP (tag 0).
    Udp = 0,
    /// TCP (tag 1).
    Tcp = 1,
    /// TLS (tag 2).
    Tls = 2,
    /// DTLS (tag 3).
    Dtls = 3,
}

impl TransportProtocol {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Udp),
            1 => Some(Self::Tcp),
            2 => Some(Self::Tls),
            3 => Some(Self::Dtls),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [TransportProtocol; 4] = [
        Self::Udp, Self::Tcp, Self::Tls, Self::Dtls,
    ];
}

impl fmt::Display for TransportProtocol {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorCode (tags 0-7)
// ===========================================================================

/// STUN error codes.
///
/// Matches `ErrorCode` in `StunABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCode {
    /// TryAlternate (tag 0).
    TryAlternate = 0,
    /// BadRequest (tag 1).
    BadRequest = 1,
    /// Unauthorized (tag 2).
    Unauthorized = 2,
    /// Forbidden (tag 3).
    Forbidden = 3,
    /// MobilityForbidden (tag 4).
    MobilityForbidden = 4,
    /// StaleNonce (tag 5).
    StaleNonce = 5,
    /// ServerError (tag 6).
    ServerError = 6,
    /// InsufficientCapacity (tag 7).
    InsufficientCapacity = 7,
}

impl ErrorCode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::TryAlternate),
            1 => Some(Self::BadRequest),
            2 => Some(Self::Unauthorized),
            3 => Some(Self::Forbidden),
            4 => Some(Self::MobilityForbidden),
            5 => Some(Self::StaleNonce),
            6 => Some(Self::ServerError),
            7 => Some(Self::InsufficientCapacity),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ErrorCode; 8] = [
        Self::TryAlternate, Self::BadRequest, Self::Unauthorized, Self::Forbidden, Self::MobilityForbidden, Self::StaleNonce, Self::ServerError, Self::InsufficientCapacity,
    ];
}

impl fmt::Display for ErrorCode {
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
        assert!(MessageType::from_tag(12).is_none());
    }

    #[test]
    fn transport_protocol_roundtrip() {
        for v in TransportProtocol::ALL {
            let tag = v.to_tag();
            let decoded = TransportProtocol::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(TransportProtocol::from_tag(4).is_none());
    }

    #[test]
    fn error_code_roundtrip() {
        for v in ErrorCode::ALL {
            let tag = v.to_tag();
            let decoded = ErrorCode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ErrorCode::from_tag(8).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(STUN_PORT, 3478);
        assert_eq!(STUN_TLS_PORT, 5349);
    }

}
