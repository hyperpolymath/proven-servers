// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! CoAP (Constrained Application Protocol) types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `CoapABI.Types` and its type definitions:
//! - `Method`        — CoAP request methods (4 constructors, tags 0-3)
//! - `MessageType`   — CoAP message types (4 constructors, tags 0-3)
//! - `ContentFormat` — CoAP content formats (7 constructors, tags 0-6)
//! - `ResponseClass` — CoAP response class codes (5 constructors, tags 0-4)
//! - `SessionState`  — CoAP server lifecycle (5 constructors, tags 0-4)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// CoAP Constants
// ===========================================================================

/// Standard CoAP port (RFC 7252).
pub const COAP_PORT: u16 = 5683;

/// Standard CoAPS (CoAP over DTLS) port (RFC 7252).
pub const COAPS_PORT: u16 = 5684;

/// Default CoAP block size (RFC 7959).
pub const COAP_DEFAULT_BLOCK_SIZE: u16 = 1024;

// ===========================================================================
// Method (tags 0-3)
// ===========================================================================

/// CoAP request methods (RFC 7252 Section 5.8).
///
/// Matches `Method` in `CoapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Method {
    /// GET — retrieve a resource representation (tag 0).
    Get = 0,
    /// POST — process a resource representation (tag 1).
    Post = 1,
    /// PUT — update or create a resource (tag 2).
    Put = 2,
    /// DELETE — remove a resource (tag 3).
    Delete = 3,
}

impl Method {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Get),
            1 => Some(Self::Post),
            2 => Some(Self::Put),
            3 => Some(Self::Delete),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this method is safe (does not alter server state).
    pub fn is_safe(self) -> bool {
        matches!(self, Self::Get)
    }

    /// Whether this method is idempotent.
    pub fn is_idempotent(self) -> bool {
        matches!(self, Self::Get | Self::Put | Self::Delete)
    }

    /// All supported methods.
    pub const ALL: [Method; 4] = [Self::Get, Self::Post, Self::Put, Self::Delete];
}

impl fmt::Display for Method {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// MessageType (tags 0-3)
// ===========================================================================

/// CoAP message types (RFC 7252 Section 4.1).
///
/// Matches `MessageType` in `CoapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MessageType {
    /// Confirmable — requires acknowledgement (tag 0).
    Confirmable = 0,
    /// Non-confirmable — fire-and-forget (tag 1).
    NonConfirmable = 1,
    /// Acknowledgement — reply to a confirmable (tag 2).
    Acknowledgement = 2,
    /// Reset — reject a message (tag 3).
    Reset = 3,
}

impl MessageType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Confirmable),
            1 => Some(Self::NonConfirmable),
            2 => Some(Self::Acknowledgement),
            3 => Some(Self::Reset),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this message type requires a response.
    pub fn requires_response(self) -> bool {
        matches!(self, Self::Confirmable)
    }

    /// Whether this message type is a response.
    pub fn is_response(self) -> bool {
        matches!(self, Self::Acknowledgement | Self::Reset)
    }

    /// All supported message types.
    pub const ALL: [MessageType; 4] = [
        Self::Confirmable, Self::NonConfirmable,
        Self::Acknowledgement, Self::Reset,
    ];
}

impl fmt::Display for MessageType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ContentFormat (tags 0-6)
// ===========================================================================

/// CoAP content formats (RFC 7252 Section 12.3).
///
/// Matches `ContentFormat` in `CoapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ContentFormat {
    /// text/plain; charset=utf-8 (tag 0).
    TextPlain = 0,
    /// application/link-format (tag 1).
    LinkFormat = 1,
    /// application/xml (tag 2).
    Xml = 2,
    /// application/octet-stream (tag 3).
    OctetStream = 3,
    /// application/exi (tag 4).
    Exi = 4,
    /// application/json (tag 5).
    Json = 5,
    /// application/cbor (tag 6).
    Cbor = 6,
}

impl ContentFormat {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::TextPlain),
            1 => Some(Self::LinkFormat),
            2 => Some(Self::Xml),
            3 => Some(Self::OctetStream),
            4 => Some(Self::Exi),
            5 => Some(Self::Json),
            6 => Some(Self::Cbor),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// The IANA media type string for this content format.
    pub fn media_type(self) -> &'static str {
        match self {
            Self::TextPlain => "text/plain; charset=utf-8",
            Self::LinkFormat => "application/link-format",
            Self::Xml => "application/xml",
            Self::OctetStream => "application/octet-stream",
            Self::Exi => "application/exi",
            Self::Json => "application/json",
            Self::Cbor => "application/cbor",
        }
    }

    /// Whether this format is text-based (human-readable).
    pub fn is_text_based(self) -> bool {
        matches!(self, Self::TextPlain | Self::LinkFormat | Self::Xml | Self::Json)
    }

    /// All supported content formats.
    pub const ALL: [ContentFormat; 7] = [
        Self::TextPlain, Self::LinkFormat, Self::Xml, Self::OctetStream,
        Self::Exi, Self::Json, Self::Cbor,
    ];
}

impl fmt::Display for ContentFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.media_type())
    }
}

// ===========================================================================
// ResponseClass (tags 0-4)
// ===========================================================================

/// CoAP response class codes (RFC 7252 Section 5.9).
///
/// Matches `ResponseClass` in `CoapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResponseClass {
    /// 2.xx Success (tag 0).
    Success = 0,
    /// 4.xx Client Error (tag 1).
    ClientError = 1,
    /// 5.xx Server Error (tag 2).
    ServerError = 2,
    /// Signaling codes — CSM, Ping, Pong, Release, Abort (tag 3).
    Signaling = 3,
    /// Empty message (tag 4).
    Empty = 4,
}

impl ResponseClass {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Success),
            1 => Some(Self::ClientError),
            2 => Some(Self::ServerError),
            3 => Some(Self::Signaling),
            4 => Some(Self::Empty),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this response class indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Success)
    }

    /// Whether this response class indicates an error.
    pub fn is_error(self) -> bool {
        matches!(self, Self::ClientError | Self::ServerError)
    }

    /// All supported response classes.
    pub const ALL: [ResponseClass; 5] = [
        Self::Success, Self::ClientError, Self::ServerError,
        Self::Signaling, Self::Empty,
    ];
}

impl fmt::Display for ResponseClass {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// CoAP server lifecycle states for the FFI layer.
///
/// Matches `SessionState` in `CoapABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// No server active (tag 0).
    Idle = 0,
    /// Socket bound to a port (tag 1).
    Bound = 1,
    /// Actively serving CoAP requests (tag 2).
    Serving = 2,
    /// Observing resources (RFC 7641) (tag 3).
    Observing = 3,
    /// Server shutting down (tag 4).
    Shutdown = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Bound),
            2 => Some(Self::Serving),
            3 => Some(Self::Observing),
            4 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the server is ready to handle requests.
    pub fn is_active(self) -> bool {
        matches!(self, Self::Serving | Self::Observing)
    }
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
    fn method_roundtrip() {
        for m in Method::ALL {
            let tag = m.to_tag();
            let decoded = Method::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, m);
        }
        assert!(Method::from_tag(4).is_none());
    }

    #[test]
    fn method_safety() {
        assert!(Method::Get.is_safe());
        assert!(!Method::Post.is_safe());
        assert!(Method::Get.is_idempotent());
        assert!(Method::Put.is_idempotent());
        assert!(!Method::Post.is_idempotent());
    }

    #[test]
    fn message_type_roundtrip() {
        for mt in MessageType::ALL {
            let tag = mt.to_tag();
            let decoded = MessageType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, mt);
        }
        assert!(MessageType::from_tag(4).is_none());
    }

    #[test]
    fn message_type_classification() {
        assert!(MessageType::Confirmable.requires_response());
        assert!(!MessageType::NonConfirmable.requires_response());
        assert!(MessageType::Acknowledgement.is_response());
        assert!(MessageType::Reset.is_response());
        assert!(!MessageType::Confirmable.is_response());
    }

    #[test]
    fn content_format_roundtrip() {
        for cf in ContentFormat::ALL {
            let tag = cf.to_tag();
            let decoded = ContentFormat::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, cf);
        }
        assert!(ContentFormat::from_tag(7).is_none());
    }

    #[test]
    fn content_format_text_based() {
        assert!(ContentFormat::TextPlain.is_text_based());
        assert!(ContentFormat::Json.is_text_based());
        assert!(!ContentFormat::OctetStream.is_text_based());
        assert!(!ContentFormat::Cbor.is_text_based());
    }

    #[test]
    fn response_class_roundtrip() {
        for rc in ResponseClass::ALL {
            let tag = rc.to_tag();
            let decoded = ResponseClass::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, rc);
        }
        assert!(ResponseClass::from_tag(5).is_none());
    }

    #[test]
    fn response_class_classification() {
        assert!(ResponseClass::Success.is_success());
        assert!(!ResponseClass::ClientError.is_success());
        assert!(ResponseClass::ClientError.is_error());
        assert!(ResponseClass::ServerError.is_error());
        assert!(!ResponseClass::Success.is_error());
    }

    #[test]
    fn session_state_roundtrip() {
        for tag in 0u8..=4 {
            let ss = SessionState::from_tag(tag).expect("valid tag");
            assert_eq!(ss.to_tag(), tag);
        }
        assert!(SessionState::from_tag(5).is_none());
    }

    #[test]
    fn session_state_active() {
        assert!(!SessionState::Idle.is_active());
        assert!(!SessionState::Bound.is_active());
        assert!(SessionState::Serving.is_active());
        assert!(SessionState::Observing.is_active());
        assert!(!SessionState::Shutdown.is_active());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(COAP_PORT, 5683);
        assert_eq!(COAPS_PORT, 5684);
    }
}
