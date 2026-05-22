// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Key Management Service types for the proven-servers ABI.
//!
//! Formally verified KMS types (KMIP-compatible).
//! Mirrors the Idris2 module `KmsABI.Types`.
//!
//! - `ObjectType` -- Managed cryptographic object types.
//! - `Operation` -- KMS operations.
//! - `KeyState` -- Key lifecycle states (KMIP).
//! - `KmsAlgorithm` -- Cryptographic algorithms.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Key Management Service Constants
// ===========================================================================

/// Standard KMIP port.
pub const KMS_PORT: u16 = 5696;

// ===========================================================================
// ObjectType (tags 0-5)
// ===========================================================================

/// Managed cryptographic object types.
///
/// Matches `ObjectType` in `KmsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ObjectType {
    /// SymmetricKey (tag 0).
    SymmetricKey = 0,
    /// PublicKey (tag 1).
    PublicKey = 1,
    /// PrivateKey (tag 2).
    PrivateKey = 2,
    /// SecretData (tag 3).
    SecretData = 3,
    /// Certificate (tag 4).
    Certificate = 4,
    /// OpaqueData (tag 5).
    OpaqueData = 5,
}

impl ObjectType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::SymmetricKey),
            1 => Some(Self::PublicKey),
            2 => Some(Self::PrivateKey),
            3 => Some(Self::SecretData),
            4 => Some(Self::Certificate),
            5 => Some(Self::OpaqueData),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ObjectType; 6] = [
        Self::SymmetricKey, Self::PublicKey, Self::PrivateKey, Self::SecretData, Self::Certificate, Self::OpaqueData,
    ];
}

impl fmt::Display for ObjectType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Operation (tags 0-14)
// ===========================================================================

/// KMS operations.
///
/// Matches `Operation` in `KmsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Operation {
    /// Create (tag 0).
    Create = 0,
    /// Get (tag 1).
    Get = 1,
    /// Activate (tag 2).
    Activate = 2,
    /// Revoke (tag 3).
    Revoke = 3,
    /// Destroy (tag 4).
    Destroy = 4,
    /// Locate (tag 5).
    Locate = 5,
    /// Register (tag 6).
    Register = 6,
    /// Rekey (tag 7).
    Rekey = 7,
    /// Encrypt (tag 8).
    Encrypt = 8,
    /// Decrypt (tag 9).
    Decrypt = 9,
    /// Sign (tag 10).
    Sign = 10,
    /// Verify (tag 11).
    Verify = 11,
    /// Wrap (tag 12).
    Wrap = 12,
    /// Unwrap (tag 13).
    Unwrap = 13,
    /// MAC (tag 14).
    Mac = 14,
}

impl Operation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Create),
            1 => Some(Self::Get),
            2 => Some(Self::Activate),
            3 => Some(Self::Revoke),
            4 => Some(Self::Destroy),
            5 => Some(Self::Locate),
            6 => Some(Self::Register),
            7 => Some(Self::Rekey),
            8 => Some(Self::Encrypt),
            9 => Some(Self::Decrypt),
            10 => Some(Self::Sign),
            11 => Some(Self::Verify),
            12 => Some(Self::Wrap),
            13 => Some(Self::Unwrap),
            14 => Some(Self::Mac),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is a cryptographic operation.
    pub fn is_crypto_op(self) -> bool {
        matches!(self, Self::Encrypt | Self::Decrypt | Self::Sign | Self::Verify | Self::Wrap | Self::Unwrap | Self::Mac)
    }

    /// Whether this is a key lifecycle operation.
    pub fn is_lifecycle_op(self) -> bool {
        matches!(self, Self::Create | Self::Activate | Self::Revoke | Self::Destroy | Self::Rekey)
    }

    /// All variants of this type.
    pub const ALL: [Operation; 15] = [
        Self::Create, Self::Get, Self::Activate, Self::Revoke, Self::Destroy, Self::Locate, Self::Register, Self::Rekey, Self::Encrypt, Self::Decrypt, Self::Sign, Self::Verify, Self::Wrap, Self::Unwrap, Self::Mac,
    ];
}

impl fmt::Display for Operation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// KeyState (tags 0-5)
// ===========================================================================

/// Key lifecycle states (KMIP).
///
/// Matches `KeyState` in `KmsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum KeyState {
    /// PreActive (tag 0).
    PreActive = 0,
    /// Active (tag 1).
    Active = 1,
    /// Deactivated (tag 2).
    Deactivated = 2,
    /// Compromised (tag 3).
    Compromised = 3,
    /// Destroyed (tag 4).
    Destroyed = 4,
    /// DestroyedCompromised (tag 5).
    DestroyedCompromised = 5,
}

impl KeyState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::PreActive),
            1 => Some(Self::Active),
            2 => Some(Self::Deactivated),
            3 => Some(Self::Compromised),
            4 => Some(Self::Destroyed),
            5 => Some(Self::DestroyedCompromised),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the key can be used for cryptographic operations.
    pub fn is_usable(self) -> bool {
        matches!(self, Self::Active)
    }

    /// All variants of this type.
    pub const ALL: [KeyState; 6] = [
        Self::PreActive, Self::Active, Self::Deactivated, Self::Compromised, Self::Destroyed, Self::DestroyedCompromised,
    ];
}

impl fmt::Display for KeyState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// KmsAlgorithm (tags 0-8)
// ===========================================================================

/// Cryptographic algorithms.
///
/// Matches `KmsAlgorithm` in `KmsABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum KmsAlgorithm {
    /// AES-128 (tag 0).
    Aes128 = 0,
    /// AES-256 (tag 1).
    Aes256 = 1,
    /// RSA-2048 (tag 2).
    Rsa2048 = 2,
    /// RSA-4096 (tag 3).
    Rsa4096 = 3,
    /// ECDSA P-256 (tag 4).
    EcdsaP256 = 4,
    /// ECDSA P-384 (tag 5).
    EcdsaP384 = 5,
    /// Ed25519 (tag 6).
    Ed25519 = 6,
    /// Chacha20Poly1305 (tag 7).
    Chacha20Poly1305 = 7,
    /// HMAC-SHA256 (tag 8).
    HmacSha256 = 8,
}

impl KmsAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Aes128),
            1 => Some(Self::Aes256),
            2 => Some(Self::Rsa2048),
            3 => Some(Self::Rsa4096),
            4 => Some(Self::EcdsaP256),
            5 => Some(Self::EcdsaP384),
            6 => Some(Self::Ed25519),
            7 => Some(Self::Chacha20Poly1305),
            8 => Some(Self::HmacSha256),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [KmsAlgorithm; 9] = [
        Self::Aes128, Self::Aes256, Self::Rsa2048, Self::Rsa4096, Self::EcdsaP256, Self::EcdsaP384, Self::Ed25519, Self::Chacha20Poly1305, Self::HmacSha256,
    ];
}

impl fmt::Display for KmsAlgorithm {
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
    fn object_type_roundtrip() {
        for v in ObjectType::ALL {
            let tag = v.to_tag();
            let decoded = ObjectType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ObjectType::from_tag(6).is_none());
    }

    #[test]
    fn operation_roundtrip() {
        for v in Operation::ALL {
            let tag = v.to_tag();
            let decoded = Operation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Operation::from_tag(15).is_none());
    }

    #[test]
    fn key_state_roundtrip() {
        for v in KeyState::ALL {
            let tag = v.to_tag();
            let decoded = KeyState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(KeyState::from_tag(6).is_none());
    }

    #[test]
    fn kms_algorithm_roundtrip() {
        for v in KmsAlgorithm::ALL {
            let tag = v.to_tag();
            let decoded = KmsAlgorithm::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(KmsAlgorithm::from_tag(9).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(KMS_PORT, 5696);
    }

}
