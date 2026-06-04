// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! RADIUS protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `RadiusABI.Types` and its type definitions:
//! - `PacketType`    — RADIUS packet types (6 constructors, non-contiguous tags)
//! - `AttributeType` — RADIUS attribute types (9 constructors, non-contiguous tags)
//! - `ServiceType`   — Service type values (6 constructors, tags 1-6)
//! - `AuthMethod`    — Authentication methods (5 constructors, tags 0-4)
//! - `SessionState`  — Session state machine (7 constructors, tags 0-6)
//! - `RadiusResult`  — FFI result codes (5 constructors, tags 0-4)
//!
//! Note: PacketType and AttributeType use non-contiguous tags matching
//! the actual RADIUS wire values from RFC 2865.

use std::fmt;

// ===========================================================================
// RADIUS Constants
// ===========================================================================

/// Standard RADIUS authentication port (RFC 2865).
pub const RADIUS_AUTH_PORT: u16 = 1812;

/// Standard RADIUS accounting port (RFC 2866).
pub const RADIUS_ACCT_PORT: u16 = 1813;

// ===========================================================================
// PacketType (6 constructors, non-contiguous tags matching RFC 2865)
// ===========================================================================

/// RADIUS packet types (RFC 2865).
///
/// Matches `PacketType` in `RadiusABI.Types`.
/// Tag values match the RADIUS Code field from the wire protocol.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PacketType {
    /// Access-Request (Code 1) (tag 1).
    AccessRequest = 1,
    /// Access-Accept (Code 2) (tag 2).
    AccessAccept = 2,
    /// Access-Reject (Code 3) (tag 3).
    AccessReject = 3,
    /// Accounting-Request (Code 4) (tag 4).
    AccountingRequest = 4,
    /// Accounting-Response (Code 5) (tag 5).
    AccountingResponse = 5,
    /// Access-Challenge (Code 11) (tag 11).
    AccessChallenge = 11,
}

impl PacketType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            1 => Some(Self::AccessRequest),
            2 => Some(Self::AccessAccept),
            3 => Some(Self::AccessReject),
            4 => Some(Self::AccountingRequest),
            5 => Some(Self::AccountingResponse),
            11 => Some(Self::AccessChallenge),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this packet is an authentication request/response.
    pub fn is_auth(self) -> bool {
        matches!(
            self,
            Self::AccessRequest | Self::AccessAccept
                | Self::AccessReject | Self::AccessChallenge
        )
    }

    /// Whether this packet is an accounting request/response.
    pub fn is_accounting(self) -> bool {
        matches!(self, Self::AccountingRequest | Self::AccountingResponse)
    }

    /// Whether this packet is a request (client -> server).
    pub fn is_request(self) -> bool {
        matches!(self, Self::AccessRequest | Self::AccountingRequest)
    }

    /// All supported packet types.
    pub const ALL: [PacketType; 6] = [
        Self::AccessRequest, Self::AccessAccept, Self::AccessReject,
        Self::AccountingRequest, Self::AccountingResponse, Self::AccessChallenge,
    ];
}

impl fmt::Display for PacketType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AttributeType (9 constructors, non-contiguous tags matching RFC 2865)
// ===========================================================================

/// RADIUS attribute types (RFC 2865).
///
/// Matches `AttributeType` in `RadiusABI.Types`.
/// Tag values match the actual RADIUS Attribute-Type numbers.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AttributeType {
    /// User-Name (Type 1) (tag 1).
    UserName = 1,
    /// User-Password (Type 2) (tag 2).
    UserPassword = 2,
    /// NAS-IP-Address (Type 4) (tag 4).
    NasIpAddress = 4,
    /// NAS-Port (Type 5) (tag 5).
    NasPort = 5,
    /// Service-Type (Type 6) (tag 6).
    ServiceType = 6,
    /// Framed-Protocol (Type 7) (tag 7).
    FramedProtocol = 7,
    /// Framed-IP-Address (Type 8) (tag 8).
    FramedIpAddress = 8,
    /// Reply-Message (Type 18) (tag 18).
    ReplyMessage = 18,
    /// Session-Timeout (Type 27) (tag 27).
    SessionTimeout = 27,
}

impl AttributeType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            1 => Some(Self::UserName),
            2 => Some(Self::UserPassword),
            4 => Some(Self::NasIpAddress),
            5 => Some(Self::NasPort),
            6 => Some(Self::ServiceType),
            7 => Some(Self::FramedProtocol),
            8 => Some(Self::FramedIpAddress),
            18 => Some(Self::ReplyMessage),
            27 => Some(Self::SessionTimeout),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this attribute contains sensitive data.
    pub fn is_sensitive(self) -> bool {
        matches!(self, Self::UserPassword)
    }

    /// All supported attribute types.
    pub const ALL: [AttributeType; 9] = [
        Self::UserName, Self::UserPassword, Self::NasIpAddress, Self::NasPort,
        Self::ServiceType, Self::FramedProtocol, Self::FramedIpAddress,
        Self::ReplyMessage, Self::SessionTimeout,
    ];
}

impl fmt::Display for AttributeType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServiceType (tags 1-6)
// ===========================================================================

/// RADIUS Service-Type values (RFC 2865).
///
/// Matches `ServiceType` in `RadiusABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServiceType {
    /// Login (tag 1).
    Login = 1,
    /// Framed (tag 2).
    Framed = 2,
    /// Callback Login (tag 3).
    CallbackLogin = 3,
    /// Callback Framed (tag 4).
    CallbackFramed = 4,
    /// Outbound (tag 5).
    Outbound = 5,
    /// Administrative (tag 6).
    Administrative = 6,
}

impl ServiceType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            1 => Some(Self::Login),
            2 => Some(Self::Framed),
            3 => Some(Self::CallbackLogin),
            4 => Some(Self::CallbackFramed),
            5 => Some(Self::Outbound),
            6 => Some(Self::Administrative),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All supported service types.
    pub const ALL: [ServiceType; 6] = [
        Self::Login, Self::Framed, Self::CallbackLogin,
        Self::CallbackFramed, Self::Outbound, Self::Administrative,
    ];
}

impl fmt::Display for ServiceType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AuthMethod (tags 0-4)
// ===========================================================================

/// RADIUS authentication methods.
///
/// Matches `AuthMethod` in `RadiusABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AuthMethod {
    /// PAP — Password Authentication Protocol (tag 0).
    Pap = 0,
    /// CHAP — Challenge Handshake Authentication Protocol (tag 1).
    Chap = 1,
    /// MS-CHAP — Microsoft CHAP v1 (tag 2).
    Mschap = 2,
    /// MS-CHAPv2 — Microsoft CHAP v2 (tag 3).
    Mschapv2 = 3,
    /// EAP — Extensible Authentication Protocol (tag 4).
    Eap = 4,
}

impl AuthMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Pap),
            1 => Some(Self::Chap),
            2 => Some(Self::Mschap),
            3 => Some(Self::Mschapv2),
            4 => Some(Self::Eap),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this method is considered legacy/weak.
    pub fn is_legacy(self) -> bool {
        matches!(self, Self::Pap | Self::Mschap)
    }

    /// All supported authentication methods.
    pub const ALL: [AuthMethod; 5] = [
        Self::Pap, Self::Chap, Self::Mschap, Self::Mschapv2, Self::Eap,
    ];
}

impl fmt::Display for AuthMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-6)
// ===========================================================================

/// RADIUS session state machine.
///
/// Matches `SessionState` in `RadiusABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Idle — no active session (tag 0).
    Idle = 0,
    /// Authenticating — processing auth request (tag 1).
    Authenticating = 1,
    /// Authorized — access granted (tag 2).
    Authorized = 2,
    /// Rejected — access denied (tag 3).
    Rejected = 3,
    /// Challenged — additional auth step required (tag 4).
    Challenged = 4,
    /// Accounting — session accounting in progress (tag 5).
    Accounting = 5,
    /// Complete — session fully processed (tag 6).
    Complete = 6,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Authenticating),
            2 => Some(Self::Authorized),
            3 => Some(Self::Rejected),
            4 => Some(Self::Challenged),
            5 => Some(Self::Accounting),
            6 => Some(Self::Complete),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is a terminal state.
    pub fn is_terminal(self) -> bool {
        matches!(self, Self::Rejected | Self::Complete)
    }

    /// All supported states.
    pub const ALL: [SessionState; 7] = [
        Self::Idle, Self::Authenticating, Self::Authorized, Self::Rejected,
        Self::Challenged, Self::Accounting, Self::Complete,
    ];
}

impl fmt::Display for SessionState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RadiusResult (tags 0-4)
// ===========================================================================

/// RADIUS FFI result codes.
///
/// Matches `RadiusResult` in `RadiusABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RadiusResult {
    /// Success (tag 0).
    Ok = 0,
    /// Generic error (tag 1).
    Err = 1,
    /// Invalid parameter (tag 2).
    InvalidParam = 2,
    /// Address pool exhausted (tag 3).
    PoolExhausted = 3,
    /// Shared secret mismatch (tag 4).
    BadSecret = 4,
}

impl RadiusResult {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ok),
            1 => Some(Self::Err),
            2 => Some(Self::InvalidParam),
            3 => Some(Self::PoolExhausted),
            4 => Some(Self::BadSecret),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this result indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Ok)
    }

    /// All result codes.
    pub const ALL: [RadiusResult; 5] = [
        Self::Ok, Self::Err, Self::InvalidParam, Self::PoolExhausted, Self::BadSecret,
    ];
}

impl fmt::Display for RadiusResult {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for RadiusResult {}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn packet_type_roundtrip() {
        for pt in PacketType::ALL {
            let tag = pt.to_tag();
            let decoded = PacketType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, pt);
        }
        assert!(PacketType::from_tag(0).is_none());
        assert!(PacketType::from_tag(6).is_none());
    }

    #[test]
    fn packet_type_classification() {
        assert!(PacketType::AccessRequest.is_auth());
        assert!(PacketType::AccessChallenge.is_auth());
        assert!(!PacketType::AccountingRequest.is_auth());
        assert!(PacketType::AccountingRequest.is_accounting());
        assert!(PacketType::AccessRequest.is_request());
    }

    #[test]
    fn attribute_type_roundtrip() {
        for at in AttributeType::ALL {
            let tag = at.to_tag();
            let decoded = AttributeType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, at);
        }
        assert!(AttributeType::from_tag(0).is_none());
        assert!(AttributeType::from_tag(3).is_none());
    }

    #[test]
    fn service_type_roundtrip() {
        for st in ServiceType::ALL {
            let tag = st.to_tag();
            let decoded = ServiceType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, st);
        }
        assert!(ServiceType::from_tag(0).is_none());
    }

    #[test]
    fn auth_method_roundtrip() {
        for am in AuthMethod::ALL {
            let tag = am.to_tag();
            let decoded = AuthMethod::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, am);
        }
        assert!(AuthMethod::from_tag(5).is_none());
    }

    #[test]
    fn session_state_roundtrip() {
        for ss in SessionState::ALL {
            let tag = ss.to_tag();
            let decoded = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, ss);
        }
        assert!(SessionState::from_tag(7).is_none());
    }

    #[test]
    fn radius_result_roundtrip() {
        for rr in RadiusResult::ALL {
            let tag = rr.to_tag();
            let decoded = RadiusResult::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, rr);
        }
        assert!(RadiusResult::from_tag(5).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(RADIUS_AUTH_PORT, 1812);
        assert_eq!(RADIUS_ACCT_PORT, 1813);
    }
}
