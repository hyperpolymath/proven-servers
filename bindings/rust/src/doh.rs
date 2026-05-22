// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! DNS-over-HTTPS types for the proven-servers ABI.
//!
//! Formally verified DoH types (RFC 8484).
//! Mirrors the Idris2 module `DohABI.Types`.
//!
//! - `ContentType` -- DoH content types.
//! - `RequestMethod` -- DoH HTTP request methods.
//! - `WireFormat` -- DNS wire format.
//! - `ErrorReason` -- DoH-specific error reasons.
//! - `SessionState` -- DoH session lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// DNS-over-HTTPS Constants
// ===========================================================================

/// Standard HTTPS port for DoH.
pub const DOH_PORT: u16 = 443;

// ===========================================================================
// ContentType (tags 0-1)
// ===========================================================================

/// DoH content types.
///
/// Matches `ContentType` in `DohABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ContentType {
    /// application/dns-message (tag 0).
    DnsMessage = 0,
    /// application/dns-json (tag 1).
    DnsJson = 1,
}

impl ContentType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::DnsMessage),
            1 => Some(Self::DnsJson),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ContentType; 2] = [
        Self::DnsMessage, Self::DnsJson,
    ];
}

impl fmt::Display for ContentType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RequestMethod (tags 0-1)
// ===========================================================================

/// DoH HTTP request methods.
///
/// Matches `RequestMethod` in `DohABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RequestMethod {
    /// Get (tag 0).
    Get = 0,
    /// Post (tag 1).
    Post = 1,
}

impl RequestMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Get),
            1 => Some(Self::Post),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [RequestMethod; 2] = [
        Self::Get, Self::Post,
    ];
}

impl fmt::Display for RequestMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// WireFormat (tags 0-1)
// ===========================================================================

/// DNS wire format.
///
/// Matches `WireFormat` in `DohABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum WireFormat {
    /// Binary (tag 0).
    Binary = 0,
    /// Json (tag 1).
    Json = 1,
}

impl WireFormat {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Binary),
            1 => Some(Self::Json),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [WireFormat; 2] = [
        Self::Binary, Self::Json,
    ];
}

impl fmt::Display for WireFormat {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorReason (tags 0-4)
// ===========================================================================

/// DoH-specific error reasons.
///
/// Matches `ErrorReason` in `DohABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorReason {
    /// BadContentType (tag 0).
    BadContentType = 0,
    /// BadMethod (tag 1).
    BadMethod = 1,
    /// PayloadTooLarge (tag 2).
    PayloadTooLarge = 2,
    /// UpstreamTimeout (tag 3).
    UpstreamTimeout = 3,
    /// UpstreamError (tag 4).
    UpstreamError = 4,
}

impl ErrorReason {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::BadContentType),
            1 => Some(Self::BadMethod),
            2 => Some(Self::PayloadTooLarge),
            3 => Some(Self::UpstreamTimeout),
            4 => Some(Self::UpstreamError),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ErrorReason; 5] = [
        Self::BadContentType, Self::BadMethod, Self::PayloadTooLarge, Self::UpstreamTimeout, Self::UpstreamError,
    ];
}

impl fmt::Display for ErrorReason {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionState (tags 0-4)
// ===========================================================================

/// DoH session lifecycle states.
///
/// Matches `SessionState` in `DohABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionState {
    /// Idle (tag 0).
    Idle = 0,
    /// Bound (tag 1).
    Bound = 1,
    /// Serving (tag 2).
    Serving = 2,
    /// Resolving (tag 3).
    Resolving = 3,
    /// Shutdown (tag 4).
    Shutdown = 4,
}

impl SessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Bound),
            2 => Some(Self::Serving),
            3 => Some(Self::Resolving),
            4 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionState; 5] = [
        Self::Idle, Self::Bound, Self::Serving, Self::Resolving, Self::Shutdown,
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
    fn content_type_roundtrip() {
        for v in ContentType::ALL {
            let tag = v.to_tag();
            let decoded = ContentType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ContentType::from_tag(2).is_none());
    }

    #[test]
    fn request_method_roundtrip() {
        for v in RequestMethod::ALL {
            let tag = v.to_tag();
            let decoded = RequestMethod::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RequestMethod::from_tag(2).is_none());
    }

    #[test]
    fn wire_format_roundtrip() {
        for v in WireFormat::ALL {
            let tag = v.to_tag();
            let decoded = WireFormat::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(WireFormat::from_tag(2).is_none());
    }

    #[test]
    fn error_reason_roundtrip() {
        for v in ErrorReason::ALL {
            let tag = v.to_tag();
            let decoded = ErrorReason::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ErrorReason::from_tag(5).is_none());
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
        assert_eq!(DOH_PORT, 443);
    }

}
