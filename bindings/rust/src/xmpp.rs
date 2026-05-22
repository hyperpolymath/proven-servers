// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! XMPP (Extensible Messaging and Presence Protocol) types for the
//! proven-servers ABI.
//!
//! Mirrors the Idris2 module `XMPPABI.Types` and its type definitions:
//! - `StanzaType`   — XMPP stanza types (3 constructors, tags 0-2)
//! - `MessageType`  — XMPP message types (5 constructors, tags 0-4)
//! - `PresenceType` — XMPP presence show values (5 constructors, tags 0-4)
//! - `IqType`       — XMPP IQ stanza types (4 constructors, tags 0-3)
//! - `StreamError`  — XMPP stream-level errors (9 constructors, tags 0-8)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// XMPP Constants
// ===========================================================================

/// Standard XMPP client-to-server port (RFC 6120).
pub const XMPP_CLIENT_PORT: u16 = 5222;

/// Standard XMPP server-to-server port (RFC 6120).
pub const XMPP_SERVER_PORT: u16 = 5269;

/// XMPP over TLS (XMPPS) port for direct TLS connections.
pub const XMPPS_PORT: u16 = 5223;

// ===========================================================================
// StanzaType (tags 0-2)
// ===========================================================================

/// XMPP stanza types (RFC 6120 Section 8).
///
/// Matches `StanzaType` in `XMPPABI.Types`.
/// The three fundamental XML stanza types in the XMPP protocol.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StanzaType {
    /// Message stanza — asynchronous messaging (tag 0).
    Message = 0,
    /// Presence stanza — availability broadcasting (tag 1).
    Presence = 1,
    /// IQ (Info/Query) stanza — request/response (tag 2).
    Iq = 2,
}

impl StanzaType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Message),
            1 => Some(Self::Presence),
            2 => Some(Self::Iq),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The XML element name for this stanza type.
    pub fn element_name(self) -> &'static str {
        match self {
            Self::Message => "message",
            Self::Presence => "presence",
            Self::Iq => "iq",
        }
    }

    /// All supported stanza types.
    pub const ALL: [StanzaType; 3] = [Self::Message, Self::Presence, Self::Iq];
}

impl fmt::Display for StanzaType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.element_name())
    }
}

// ===========================================================================
// MessageType (tags 0-4)
// ===========================================================================

/// XMPP message types (RFC 6121 Section 5.2.2).
///
/// Matches `MessageType` in `XMPPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MessageType {
    /// One-to-one chat message (tag 0).
    Chat = 0,
    /// Error message (tag 1).
    Error = 1,
    /// Multi-user chat / groupchat message (tag 2).
    Groupchat = 2,
    /// Headline / news message (tag 3).
    Headline = 3,
    /// Normal (standalone) message — default type (tag 4).
    Normal = 4,
}

impl MessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Chat),
            1 => Some(Self::Error),
            2 => Some(Self::Groupchat),
            3 => Some(Self::Headline),
            4 => Some(Self::Normal),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this message type expects a reply.
    pub fn expects_reply(self) -> bool {
        matches!(self, Self::Chat | Self::Normal)
    }

    /// Whether this message type is for multi-party communication.
    pub fn is_multi_party(self) -> bool {
        matches!(self, Self::Groupchat)
    }

    /// All supported message types.
    pub const ALL: [MessageType; 5] = [
        Self::Chat, Self::Error, Self::Groupchat, Self::Headline, Self::Normal,
    ];
}

impl fmt::Display for MessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// PresenceType (tags 0-4)
// ===========================================================================

/// XMPP presence show values (RFC 6121 Section 4.7.2.1).
///
/// Matches `PresenceType` in `XMPPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PresenceType {
    /// Available — online and ready to communicate (tag 0).
    Available = 0,
    /// Away — temporarily absent (tag 1).
    Away = 1,
    /// Do Not Disturb — busy, should not be interrupted (tag 2).
    Dnd = 2,
    /// Extended Away — away for a longer period (tag 3).
    Xa = 3,
    /// Unavailable — offline (tag 4).
    Unavailable = 4,
}

impl PresenceType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Available),
            1 => Some(Self::Away),
            2 => Some(Self::Dnd),
            3 => Some(Self::Xa),
            4 => Some(Self::Unavailable),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the entity is online (any form of availability).
    pub fn is_online(self) -> bool {
        !matches!(self, Self::Unavailable)
    }

    /// Whether the entity is actively available for communication.
    pub fn is_available(self) -> bool {
        matches!(self, Self::Available)
    }

    /// The XMPP `<show>` element value, or None for Available/Unavailable.
    pub fn show_value(self) -> Option<&'static str> {
        match self {
            Self::Available => None,
            Self::Away => Some("away"),
            Self::Dnd => Some("dnd"),
            Self::Xa => Some("xa"),
            Self::Unavailable => None,
        }
    }

    /// All supported presence types.
    pub const ALL: [PresenceType; 5] = [
        Self::Available, Self::Away, Self::Dnd, Self::Xa, Self::Unavailable,
    ];
}

impl fmt::Display for PresenceType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// IqType (tags 0-3)
// ===========================================================================

/// XMPP IQ (Info/Query) stanza types (RFC 6120 Section 8.2.3).
///
/// Matches `IQType` in `XMPPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum IqType {
    /// Get — request information (tag 0).
    Get = 0,
    /// Set — provide information or make a request (tag 1).
    Set = 1,
    /// Result — successful response (tag 2).
    Result = 2,
    /// Error — error response (tag 3).
    Error = 3,
}

impl IqType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Get),
            1 => Some(Self::Set),
            2 => Some(Self::Result),
            3 => Some(Self::Error),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this IQ type is a request (requires a response).
    pub fn is_request(self) -> bool {
        matches!(self, Self::Get | Self::Set)
    }

    /// Whether this IQ type is a response.
    pub fn is_response(self) -> bool {
        matches!(self, Self::Result | Self::Error)
    }

    /// All supported IQ types.
    pub const ALL: [IqType; 4] = [Self::Get, Self::Set, Self::Result, Self::Error];
}

impl fmt::Display for IqType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// StreamError (tags 0-8)
// ===========================================================================

/// XMPP stream-level error conditions (RFC 6120 Section 4.9.3).
///
/// Matches `StreamError` in `XMPPABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StreamError {
    /// Malformed XML or protocol violation (tag 0).
    BadFormat = 0,
    /// Resource conflict (tag 1).
    Conflict = 1,
    /// Connection timed out (tag 2).
    ConnectionTimeout = 2,
    /// Remote host is no longer available (tag 3).
    HostGone = 3,
    /// Remote host is unknown (tag 4).
    HostUnknown = 4,
    /// Entity is not authorised (tag 5).
    NotAuthorized = 5,
    /// Policy violation (tag 6).
    PolicyViolation = 6,
    /// Server resource constraint (tag 7).
    ResourceConstraint = 7,
    /// System is shutting down (tag 8).
    SystemShutdown = 8,
}

impl StreamError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::BadFormat),
            1 => Some(Self::Conflict),
            2 => Some(Self::ConnectionTimeout),
            3 => Some(Self::HostGone),
            4 => Some(Self::HostUnknown),
            5 => Some(Self::NotAuthorized),
            6 => Some(Self::PolicyViolation),
            7 => Some(Self::ResourceConstraint),
            8 => Some(Self::SystemShutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this error is related to security/authorisation.
    pub fn is_security_error(self) -> bool {
        matches!(self, Self::NotAuthorized | Self::PolicyViolation)
    }

    /// Whether this error is likely transient and the connection can be retried.
    pub fn is_retryable(self) -> bool {
        matches!(
            self,
            Self::ConnectionTimeout | Self::ResourceConstraint | Self::SystemShutdown
        )
    }

    /// The XMPP defined-condition element name.
    pub fn condition_name(self) -> &'static str {
        match self {
            Self::BadFormat => "bad-format",
            Self::Conflict => "conflict",
            Self::ConnectionTimeout => "connection-timeout",
            Self::HostGone => "host-gone",
            Self::HostUnknown => "host-unknown",
            Self::NotAuthorized => "not-authorized",
            Self::PolicyViolation => "policy-violation",
            Self::ResourceConstraint => "resource-constraint",
            Self::SystemShutdown => "system-shutdown",
        }
    }

    /// All supported stream errors.
    pub const ALL: [StreamError; 9] = [
        Self::BadFormat, Self::Conflict, Self::ConnectionTimeout,
        Self::HostGone, Self::HostUnknown, Self::NotAuthorized,
        Self::PolicyViolation, Self::ResourceConstraint, Self::SystemShutdown,
    ];
}

impl fmt::Display for StreamError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.condition_name())
    }
}

impl std::error::Error for StreamError {}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn stanza_type_roundtrip() {
        for st in StanzaType::ALL {
            let tag = st.to_tag();
            let decoded = StanzaType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, st);
        }
        assert!(StanzaType::from_tag(3).is_none());
    }

    #[test]
    fn message_type_roundtrip() {
        for mt in MessageType::ALL {
            let tag = mt.to_tag();
            let decoded = MessageType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, mt);
        }
        assert!(MessageType::from_tag(5).is_none());
    }

    #[test]
    fn message_type_classification() {
        assert!(MessageType::Chat.expects_reply());
        assert!(MessageType::Normal.expects_reply());
        assert!(!MessageType::Headline.expects_reply());
        assert!(MessageType::Groupchat.is_multi_party());
        assert!(!MessageType::Chat.is_multi_party());
    }

    #[test]
    fn presence_type_roundtrip() {
        for pt in PresenceType::ALL {
            let tag = pt.to_tag();
            let decoded = PresenceType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, pt);
        }
        assert!(PresenceType::from_tag(5).is_none());
    }

    #[test]
    fn presence_type_availability() {
        assert!(PresenceType::Available.is_online());
        assert!(PresenceType::Away.is_online());
        assert!(PresenceType::Dnd.is_online());
        assert!(!PresenceType::Unavailable.is_online());
        assert!(PresenceType::Available.is_available());
        assert!(!PresenceType::Away.is_available());
    }

    #[test]
    fn presence_type_show_values() {
        assert_eq!(PresenceType::Available.show_value(), None);
        assert_eq!(PresenceType::Away.show_value(), Some("away"));
        assert_eq!(PresenceType::Dnd.show_value(), Some("dnd"));
        assert_eq!(PresenceType::Xa.show_value(), Some("xa"));
        assert_eq!(PresenceType::Unavailable.show_value(), None);
    }

    #[test]
    fn iq_type_roundtrip() {
        for iq in IqType::ALL {
            let tag = iq.to_tag();
            let decoded = IqType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, iq);
        }
        assert!(IqType::from_tag(4).is_none());
    }

    #[test]
    fn iq_type_classification() {
        assert!(IqType::Get.is_request());
        assert!(IqType::Set.is_request());
        assert!(!IqType::Result.is_request());
        assert!(IqType::Result.is_response());
        assert!(IqType::Error.is_response());
        assert!(!IqType::Get.is_response());
    }

    #[test]
    fn stream_error_roundtrip() {
        for se in StreamError::ALL {
            let tag = se.to_tag();
            let decoded = StreamError::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, se);
        }
        assert!(StreamError::from_tag(9).is_none());
    }

    #[test]
    fn stream_error_classification() {
        assert!(StreamError::NotAuthorized.is_security_error());
        assert!(StreamError::PolicyViolation.is_security_error());
        assert!(!StreamError::BadFormat.is_security_error());
        assert!(StreamError::ConnectionTimeout.is_retryable());
        assert!(StreamError::SystemShutdown.is_retryable());
        assert!(!StreamError::BadFormat.is_retryable());
    }

    #[test]
    fn stream_error_condition_names() {
        assert_eq!(StreamError::BadFormat.condition_name(), "bad-format");
        assert_eq!(StreamError::SystemShutdown.condition_name(), "system-shutdown");
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(XMPP_CLIENT_PORT, 5222);
        assert_eq!(XMPP_SERVER_PORT, 5269);
    }
}
