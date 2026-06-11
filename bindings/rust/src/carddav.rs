// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! CardDAV types for the proven-servers ABI.
//!
//! Formally verified CardDAV types (RFC 6352).
//! Mirrors the Idris2 module `CarddavABI.Types`.
//!
//! - `PropertyType` -- vCard property types.
//! - `CardMethod` -- CardDAV methods.
//! - `VCardVersion` -- vCard versions.
//! - `CardError` -- CardDAV error codes.
//! - `ServerState` -- CardDAV server lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// CardDAV Constants
// ===========================================================================

/// Standard CardDAV HTTPS port.
pub const CARDDAV_PORT: u16 = 443;

// ===========================================================================
// PropertyType (tags 0-8)
// ===========================================================================

/// vCard property types.
///
/// Matches `PropertyType` in `CarddavABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PropertyType {
    /// FN (full name) (tag 0).
    FnName = 0,
    /// Structured name (tag 1).
    N = 1,
    /// Email (tag 2).
    Email = 2,
    /// Telephone (tag 3).
    Tel = 3,
    /// Address (tag 4).
    Adr = 4,
    /// Organization (tag 5).
    Org = 5,
    /// Photo (tag 6).
    Photo = 6,
    /// URL (tag 7).
    Url = 7,
    /// Note (tag 8).
    Note = 8,
}

impl PropertyType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::FnName),
            1 => Some(Self::N),
            2 => Some(Self::Email),
            3 => Some(Self::Tel),
            4 => Some(Self::Adr),
            5 => Some(Self::Org),
            6 => Some(Self::Photo),
            7 => Some(Self::Url),
            8 => Some(Self::Note),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [PropertyType; 9] = [
        Self::FnName, Self::N, Self::Email, Self::Tel, Self::Adr, Self::Org, Self::Photo, Self::Url, Self::Note,
    ];
}

impl fmt::Display for PropertyType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CardMethod (tags 0-6)
// ===========================================================================

/// CardDAV methods.
///
/// Matches `CardMethod` in `CarddavABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CardMethod {
    /// Get (tag 0).
    Get = 0,
    /// Put (tag 1).
    Put = 1,
    /// Delete (tag 2).
    Delete = 2,
    /// PROPFIND (tag 3).
    Propfind = 3,
    /// PROPPATCH (tag 4).
    Proppatch = 4,
    /// REPORT (tag 5).
    Report = 5,
    /// MKCOL (tag 6).
    Mkcol = 6,
}

impl CardMethod {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Get),
            1 => Some(Self::Put),
            2 => Some(Self::Delete),
            3 => Some(Self::Propfind),
            4 => Some(Self::Proppatch),
            5 => Some(Self::Report),
            6 => Some(Self::Mkcol),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CardMethod; 7] = [
        Self::Get, Self::Put, Self::Delete, Self::Propfind, Self::Proppatch, Self::Report, Self::Mkcol,
    ];
}

impl fmt::Display for CardMethod {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// VCardVersion (tags 0-1)
// ===========================================================================

/// vCard versions.
///
/// Matches `VCardVersion` in `CarddavABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum VCardVersion {
    /// vCard 3.0 (tag 0).
    Vcard3 = 0,
    /// vCard 4.0 (tag 1).
    Vcard4 = 1,
}

impl VCardVersion {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Vcard3),
            1 => Some(Self::Vcard4),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [VCardVersion; 2] = [
        Self::Vcard3, Self::Vcard4,
    ];
}

impl fmt::Display for VCardVersion {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CardError (tags 0-5)
// ===========================================================================

/// CardDAV error codes.
///
/// Matches `CardError` in `CarddavABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CardError {
    /// ValidAddressData (tag 0).
    ValidAddressData = 0,
    /// NoResourceType (tag 1).
    NoResourceType = 1,
    /// MaxResourceSize (tag 2).
    MaxResourceSize = 2,
    /// UidConflict (tag 3).
    UidConflict = 3,
    /// SupportedAddressData (tag 4).
    SupportedAddressData = 4,
    /// PreconditionFailed (tag 5).
    PreconditionFailed = 5,
}

impl CardError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ValidAddressData),
            1 => Some(Self::NoResourceType),
            2 => Some(Self::MaxResourceSize),
            3 => Some(Self::UidConflict),
            4 => Some(Self::SupportedAddressData),
            5 => Some(Self::PreconditionFailed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CardError; 6] = [
        Self::ValidAddressData, Self::NoResourceType, Self::MaxResourceSize, Self::UidConflict, Self::SupportedAddressData, Self::PreconditionFailed,
    ];
}

impl fmt::Display for CardError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ServerState (tags 0-3)
// ===========================================================================

/// CardDAV server lifecycle states.
///
/// Matches `ServerState` in `CarddavABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ServerState {
    /// Idle (tag 0).
    Idle = 0,
    /// Bound (tag 1).
    Bound = 1,
    /// Serving (tag 2).
    Serving = 2,
    /// Shutdown (tag 3).
    Shutdown = 3,
}

impl ServerState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Bound),
            2 => Some(Self::Serving),
            3 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ServerState; 4] = [
        Self::Idle, Self::Bound, Self::Serving, Self::Shutdown,
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
    fn property_type_roundtrip() {
        for v in PropertyType::ALL {
            let tag = v.to_tag();
            let decoded = PropertyType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PropertyType::from_tag(9).is_none());
    }

    #[test]
    fn card_method_roundtrip() {
        for v in CardMethod::ALL {
            let tag = v.to_tag();
            let decoded = CardMethod::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CardMethod::from_tag(7).is_none());
    }

    #[test]
    fn v_card_version_roundtrip() {
        for v in VCardVersion::ALL {
            let tag = v.to_tag();
            let decoded = VCardVersion::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(VCardVersion::from_tag(2).is_none());
    }

    #[test]
    fn card_error_roundtrip() {
        for v in CardError::ALL {
            let tag = v.to_tag();
            let decoded = CardError::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CardError::from_tag(6).is_none());
    }

    #[test]
    fn server_state_roundtrip() {
        for v in ServerState::ALL {
            let tag = v.to_tag();
            let decoded = ServerState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ServerState::from_tag(4).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(CARDDAV_PORT, 443);
    }

}
