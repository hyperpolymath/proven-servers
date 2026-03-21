// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! OCSP types for the proven-servers ABI.
//!
//! Formally verified OCSP (Online Certificate Status Protocol, RFC 6960) types.
//! Mirrors the Idris2 module `OcspABI.Types`.
//!
//! - `CertStatus` -- Certificate status in OCSP response.
//! - `ResponseStatus` -- OCSP response status.
//! - `HashAlgorithm` -- OCSP hash algorithms.
//! - `ResponderState` -- OCSP responder states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// OCSP Constants
// ===========================================================================

/// Standard OCSP HTTP port.
pub const OCSP_PORT: u16 = 80;

// ===========================================================================
// CertStatus (tags 0-2)
// ===========================================================================

/// Certificate status in OCSP response.
///
/// Matches `CertStatus` in `OcspABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CertStatus {
    /// Good (tag 0).
    Good = 0,
    /// Revoked (tag 1).
    Revoked = 1,
    /// Unknown (tag 2).
    Unknown = 2,
}

impl CertStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Good),
            1 => Some(Self::Revoked),
            2 => Some(Self::Unknown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CertStatus; 3] = [
        Self::Good, Self::Revoked, Self::Unknown,
    ];
}

impl fmt::Display for CertStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ResponseStatus (tags 0-5)
// ===========================================================================

/// OCSP response status.
///
/// Matches `ResponseStatus` in `OcspABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResponseStatus {
    /// Successful (tag 0).
    Successful = 0,
    /// MalformedRequest (tag 1).
    MalformedRequest = 1,
    /// InternalError (tag 2).
    InternalError = 2,
    /// TryLater (tag 3).
    TryLater = 3,
    /// SigRequired (tag 4).
    SigRequired = 4,
    /// Unauthorized (tag 5).
    Unauthorized = 5,
}

impl ResponseStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Successful),
            1 => Some(Self::MalformedRequest),
            2 => Some(Self::InternalError),
            3 => Some(Self::TryLater),
            4 => Some(Self::SigRequired),
            5 => Some(Self::Unauthorized),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ResponseStatus; 6] = [
        Self::Successful, Self::MalformedRequest, Self::InternalError, Self::TryLater, Self::SigRequired, Self::Unauthorized,
    ];
}

impl fmt::Display for ResponseStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HashAlgorithm (tags 0-3)
// ===========================================================================

/// OCSP hash algorithms.
///
/// Matches `HashAlgorithm` in `OcspABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HashAlgorithm {
    /// SHA-1 (legacy) (tag 0).
    Sha1 = 0,
    /// SHA-256 (tag 1).
    Sha256 = 1,
    /// SHA-384 (tag 2).
    Sha384 = 2,
    /// SHA-512 (tag 3).
    Sha512 = 3,
}

impl HashAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Sha1),
            1 => Some(Self::Sha256),
            2 => Some(Self::Sha384),
            3 => Some(Self::Sha512),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HashAlgorithm; 4] = [
        Self::Sha1, Self::Sha256, Self::Sha384, Self::Sha512,
    ];
}

impl fmt::Display for HashAlgorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ResponderState (tags 0-4)
// ===========================================================================

/// OCSP responder states.
///
/// Matches `ResponderState` in `OcspABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ResponderState {
    /// Idle (tag 0).
    Idle = 0,
    /// Ready (tag 1).
    Ready = 1,
    /// Processing (tag 2).
    Processing = 2,
    /// Signing (tag 3).
    Signing = 3,
    /// Closing (tag 4).
    Closing = 4,
}

impl ResponderState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Ready),
            2 => Some(Self::Processing),
            3 => Some(Self::Signing),
            4 => Some(Self::Closing),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ResponderState; 5] = [
        Self::Idle, Self::Ready, Self::Processing, Self::Signing, Self::Closing,
    ];
}

impl fmt::Display for ResponderState {
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
    fn cert_status_roundtrip() {
        for v in CertStatus::ALL {
            let tag = v.to_tag();
            let decoded = CertStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CertStatus::from_tag(3).is_none());
    }

    #[test]
    fn response_status_roundtrip() {
        for v in ResponseStatus::ALL {
            let tag = v.to_tag();
            let decoded = ResponseStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ResponseStatus::from_tag(6).is_none());
    }

    #[test]
    fn hash_algorithm_roundtrip() {
        for v in HashAlgorithm::ALL {
            let tag = v.to_tag();
            let decoded = HashAlgorithm::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HashAlgorithm::from_tag(4).is_none());
    }

    #[test]
    fn responder_state_roundtrip() {
        for v in ResponderState::ALL {
            let tag = v.to_tag();
            let decoded = ResponderState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ResponderState::from_tag(5).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(OCSP_PORT, 80);
    }

}
