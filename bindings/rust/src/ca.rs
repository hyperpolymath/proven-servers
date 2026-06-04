// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! Certificate Authority types for the proven-servers ABI.
//!
//! Formally verified PKI/CA types.
//! Mirrors the Idris2 module `CaABI.Types`.
//!
//! - `CertType` -- X.509 certificate types.
//! - `KeyAlgorithm` -- Cryptographic key algorithms.
//! - `SignatureAlgorithm` -- Cryptographic signature algorithms.
//! - `CertState` -- Certificate lifecycle states.
//! - `RevocationReason` -- Certificate revocation reasons (RFC 5280).
//! - `CrlStatus` -- CRL status.
//! - `OcspStatus` -- OCSP response status.
//! - `Extension` -- X.509 extension types.
//! - `KeyUsageBit` -- Key usage bit flags (RFC 5280).
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Certificate Authority Constants
// ===========================================================================

/// Standard CA API port.
pub const CA_PORT: u16 = 8443;

// ===========================================================================
// CertType (tags 0-6)
// ===========================================================================

/// X.509 certificate types.
///
/// Matches `CertType` in `CaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CertType {
    /// Root (tag 0).
    Root = 0,
    /// Intermediate (tag 1).
    Intermediate = 1,
    /// EndEntity (tag 2).
    EndEntity = 2,
    /// CrossSigned (tag 3).
    CrossSigned = 3,
    /// CodeSigning (tag 4).
    CodeSigning = 4,
    /// EmailProtection (tag 5).
    EmailProtection = 5,
    /// OCSP signing (tag 6).
    OcspSigning = 6,
}

impl CertType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Root),
            1 => Some(Self::Intermediate),
            2 => Some(Self::EndEntity),
            3 => Some(Self::CrossSigned),
            4 => Some(Self::CodeSigning),
            5 => Some(Self::EmailProtection),
            6 => Some(Self::OcspSigning),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this certificate type is a CA certificate.
    pub fn is_ca(self) -> bool {
        matches!(self, Self::Root | Self::Intermediate | Self::CrossSigned)
    }

    /// All variants of this type.
    pub const ALL: [CertType; 7] = [
        Self::Root, Self::Intermediate, Self::EndEntity, Self::CrossSigned, Self::CodeSigning, Self::EmailProtection, Self::OcspSigning,
    ];
}

impl fmt::Display for CertType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// KeyAlgorithm (tags 0-5)
// ===========================================================================

/// Cryptographic key algorithms.
///
/// Matches `KeyAlgorithm` in `CaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum KeyAlgorithm {
    /// Rsa2048 (tag 0).
    Rsa2048 = 0,
    /// Rsa4096 (tag 1).
    Rsa4096 = 1,
    /// ECDSA P-256 (tag 2).
    EcdsaP256 = 2,
    /// ECDSA P-384 (tag 3).
    EcdsaP384 = 3,
    /// Ed25519 (tag 4).
    Ed25519 = 4,
    /// Ed448 (tag 5).
    Ed448 = 5,
}

impl KeyAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Rsa2048),
            1 => Some(Self::Rsa4096),
            2 => Some(Self::EcdsaP256),
            3 => Some(Self::EcdsaP384),
            4 => Some(Self::Ed25519),
            5 => Some(Self::Ed448),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is an RSA algorithm.
    pub fn is_rsa(self) -> bool {
        matches!(self, Self::Rsa2048 | Self::Rsa4096)
    }

    /// Whether this is an elliptic curve algorithm.
    pub fn is_elliptic_curve(self) -> bool {
        matches!(self, Self::EcdsaP256 | Self::EcdsaP384 | Self::Ed25519 | Self::Ed448)
    }

    /// All variants of this type.
    pub const ALL: [KeyAlgorithm; 6] = [
        Self::Rsa2048, Self::Rsa4096, Self::EcdsaP256, Self::EcdsaP384, Self::Ed25519, Self::Ed448,
    ];
}

impl fmt::Display for KeyAlgorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SignatureAlgorithm (tags 0-6)
// ===========================================================================

/// Cryptographic signature algorithms.
///
/// Matches `SignatureAlgorithm` in `CaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SignatureAlgorithm {
    /// Sha256WithRsa (tag 0).
    Sha256WithRsa = 0,
    /// Sha384WithRsa (tag 1).
    Sha384WithRsa = 1,
    /// Sha512WithRsa (tag 2).
    Sha512WithRsa = 2,
    /// Sha256WithEcdsa (tag 3).
    Sha256WithEcdsa = 3,
    /// Sha384WithEcdsa (tag 4).
    Sha384WithEcdsa = 4,
    /// PureEd25519 (tag 5).
    PureEd25519 = 5,
    /// PureEd448 (tag 6).
    PureEd448 = 6,
}

impl SignatureAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Sha256WithRsa),
            1 => Some(Self::Sha384WithRsa),
            2 => Some(Self::Sha512WithRsa),
            3 => Some(Self::Sha256WithEcdsa),
            4 => Some(Self::Sha384WithEcdsa),
            5 => Some(Self::PureEd25519),
            6 => Some(Self::PureEd448),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SignatureAlgorithm; 7] = [
        Self::Sha256WithRsa, Self::Sha384WithRsa, Self::Sha512WithRsa, Self::Sha256WithEcdsa, Self::Sha384WithEcdsa, Self::PureEd25519, Self::PureEd448,
    ];
}

impl fmt::Display for SignatureAlgorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CertState (tags 0-4)
// ===========================================================================

/// Certificate lifecycle states.
///
/// Matches `CertState` in `CaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CertState {
    /// Pending (tag 0).
    Pending = 0,
    /// Active (tag 1).
    Active = 1,
    /// Revoked (tag 2).
    Revoked = 2,
    /// Expired (tag 3).
    Expired = 3,
    /// Suspended (tag 4).
    Suspended = 4,
}

impl CertState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Pending),
            1 => Some(Self::Active),
            2 => Some(Self::Revoked),
            3 => Some(Self::Expired),
            4 => Some(Self::Suspended),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the certificate can be used.
    pub fn is_usable(self) -> bool {
        matches!(self, Self::Active)
    }

    /// All variants of this type.
    pub const ALL: [CertState; 5] = [
        Self::Pending, Self::Active, Self::Revoked, Self::Expired, Self::Suspended,
    ];
}

impl fmt::Display for CertState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// RevocationReason (tags 0-6)
// ===========================================================================

/// Certificate revocation reasons (RFC 5280).
///
/// Matches `RevocationReason` in `CaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RevocationReason {
    /// Unspecified (tag 0).
    Unspecified = 0,
    /// KeyCompromise (tag 1).
    KeyCompromise = 1,
    /// CaCompromise (tag 2).
    CaCompromise = 2,
    /// AffiliationChanged (tag 3).
    AffiliationChanged = 3,
    /// Superseded (tag 4).
    Superseded = 4,
    /// CessationOfOperation (tag 5).
    CessationOfOperation = 5,
    /// CertificateHold (tag 6).
    CertificateHold = 6,
}

impl RevocationReason {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Unspecified),
            1 => Some(Self::KeyCompromise),
            2 => Some(Self::CaCompromise),
            3 => Some(Self::AffiliationChanged),
            4 => Some(Self::Superseded),
            5 => Some(Self::CessationOfOperation),
            6 => Some(Self::CertificateHold),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this revocation indicates a security incident.
    pub fn is_security_incident(self) -> bool {
        matches!(self, Self::KeyCompromise | Self::CaCompromise)
    }

    /// All variants of this type.
    pub const ALL: [RevocationReason; 7] = [
        Self::Unspecified, Self::KeyCompromise, Self::CaCompromise, Self::AffiliationChanged, Self::Superseded, Self::CessationOfOperation, Self::CertificateHold,
    ];
}

impl fmt::Display for RevocationReason {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// CrlStatus (tags 0-3)
// ===========================================================================

/// CRL status.
///
/// Matches `CrlStatus` in `CaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum CrlStatus {
    /// Current (tag 0).
    Current = 0,
    /// CrlExpired (tag 1).
    CrlExpired = 1,
    /// CrlPending (tag 2).
    CrlPending = 2,
    /// CrlError (tag 3).
    CrlError = 3,
}

impl CrlStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Current),
            1 => Some(Self::CrlExpired),
            2 => Some(Self::CrlPending),
            3 => Some(Self::CrlError),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [CrlStatus; 4] = [
        Self::Current, Self::CrlExpired, Self::CrlPending, Self::CrlError,
    ];
}

impl fmt::Display for CrlStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// OcspStatus (tags 0-3)
// ===========================================================================

/// OCSP response status.
///
/// Matches `OcspStatus` in `CaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum OcspStatus {
    /// Good (tag 0).
    Good = 0,
    /// OcspRevoked (tag 1).
    OcspRevoked = 1,
    /// Unknown (tag 2).
    Unknown = 2,
    /// Unavailable (tag 3).
    Unavailable = 3,
}

impl OcspStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Good),
            1 => Some(Self::OcspRevoked),
            2 => Some(Self::Unknown),
            3 => Some(Self::Unavailable),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [OcspStatus; 4] = [
        Self::Good, Self::OcspRevoked, Self::Unknown, Self::Unavailable,
    ];
}

impl fmt::Display for OcspStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Extension (tags 0-5)
// ===========================================================================

/// X.509 extension types.
///
/// Matches `Extension` in `CaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Extension {
    /// BasicConstraints (tag 0).
    BasicConstraints = 0,
    /// KeyUsage (tag 1).
    KeyUsage = 1,
    /// ExtKeyUsage (tag 2).
    ExtKeyUsage = 2,
    /// SubjectAltName (tag 3).
    SubjectAltName = 3,
    /// AuthorityInfoAccess (tag 4).
    AuthorityInfoAccess = 4,
    /// CrlDistributionPoints (tag 5).
    CrlDistributionPoints = 5,
}

impl Extension {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::BasicConstraints),
            1 => Some(Self::KeyUsage),
            2 => Some(Self::ExtKeyUsage),
            3 => Some(Self::SubjectAltName),
            4 => Some(Self::AuthorityInfoAccess),
            5 => Some(Self::CrlDistributionPoints),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Extension; 6] = [
        Self::BasicConstraints, Self::KeyUsage, Self::ExtKeyUsage, Self::SubjectAltName, Self::AuthorityInfoAccess, Self::CrlDistributionPoints,
    ];
}

impl fmt::Display for Extension {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// KeyUsageBit (tags 0-8)
// ===========================================================================

/// Key usage bit flags (RFC 5280).
///
/// Matches `KeyUsageBit` in `CaABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum KeyUsageBit {
    /// DigitalSignature (tag 0).
    DigitalSignature = 0,
    /// NonRepudiation (tag 1).
    NonRepudiation = 1,
    /// KeyEncipherment (tag 2).
    KeyEncipherment = 2,
    /// DataEncipherment (tag 3).
    DataEncipherment = 3,
    /// KeyAgreement (tag 4).
    KeyAgreement = 4,
    /// KeyCertSign (tag 5).
    KeyCertSign = 5,
    /// CrlSign (tag 6).
    CrlSign = 6,
    /// EncipherOnly (tag 7).
    EncipherOnly = 7,
    /// DecipherOnly (tag 8).
    DecipherOnly = 8,
}

impl KeyUsageBit {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::DigitalSignature),
            1 => Some(Self::NonRepudiation),
            2 => Some(Self::KeyEncipherment),
            3 => Some(Self::DataEncipherment),
            4 => Some(Self::KeyAgreement),
            5 => Some(Self::KeyCertSign),
            6 => Some(Self::CrlSign),
            7 => Some(Self::EncipherOnly),
            8 => Some(Self::DecipherOnly),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [KeyUsageBit; 9] = [
        Self::DigitalSignature, Self::NonRepudiation, Self::KeyEncipherment, Self::DataEncipherment, Self::KeyAgreement, Self::KeyCertSign, Self::CrlSign, Self::EncipherOnly, Self::DecipherOnly,
    ];
}

impl fmt::Display for KeyUsageBit {
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
    fn cert_type_roundtrip() {
        for v in CertType::ALL {
            let tag = v.to_tag();
            let decoded = CertType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CertType::from_tag(7).is_none());
    }

    #[test]
    fn key_algorithm_roundtrip() {
        for v in KeyAlgorithm::ALL {
            let tag = v.to_tag();
            let decoded = KeyAlgorithm::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(KeyAlgorithm::from_tag(6).is_none());
    }

    #[test]
    fn signature_algorithm_roundtrip() {
        for v in SignatureAlgorithm::ALL {
            let tag = v.to_tag();
            let decoded = SignatureAlgorithm::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SignatureAlgorithm::from_tag(7).is_none());
    }

    #[test]
    fn cert_state_roundtrip() {
        for v in CertState::ALL {
            let tag = v.to_tag();
            let decoded = CertState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CertState::from_tag(5).is_none());
    }

    #[test]
    fn revocation_reason_roundtrip() {
        for v in RevocationReason::ALL {
            let tag = v.to_tag();
            let decoded = RevocationReason::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RevocationReason::from_tag(7).is_none());
    }

    #[test]
    fn crl_status_roundtrip() {
        for v in CrlStatus::ALL {
            let tag = v.to_tag();
            let decoded = CrlStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(CrlStatus::from_tag(4).is_none());
    }

    #[test]
    fn ocsp_status_roundtrip() {
        for v in OcspStatus::ALL {
            let tag = v.to_tag();
            let decoded = OcspStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(OcspStatus::from_tag(4).is_none());
    }

    #[test]
    fn extension_roundtrip() {
        for v in Extension::ALL {
            let tag = v.to_tag();
            let decoded = Extension::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Extension::from_tag(6).is_none());
    }

    #[test]
    fn key_usage_bit_roundtrip() {
        for v in KeyUsageBit::ALL {
            let tag = v.to_tag();
            let decoded = KeyUsageBit::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(KeyUsageBit::from_tag(9).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(CA_PORT, 8443);
    }

}
