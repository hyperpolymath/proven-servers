// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Post-Quantum Cryptography types for the proven-servers ABI.
//!
//! Formally verified PQC types.
//! Mirrors the Idris2 module `PqcABI.Types`.
//!
//! - `PqcAlgorithm` -- Post-quantum cryptographic algorithms.
//! - `NistLevel` -- NIST security levels (1-5).
//! - `Operation` -- PQC cryptographic operations.
//! - `HybridMode` -- Classical/PQC hybrid modes.
//! - `AlgorithmCategory` -- PQC algorithm categories.
//! - `KeyState` -- PQC key lifecycle states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// PqcAlgorithm (tags 0-7)
// ===========================================================================

/// Post-quantum cryptographic algorithms.
///
/// Matches `PqcAlgorithm` in `PqcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PqcAlgorithm {
    /// CRYSTALS-Kyber KEM (tag 0).
    CrystalsKyber = 0,
    /// CRYSTALS-Dilithium signature (tag 1).
    CrystalsDilithium = 1,
    /// FALCON signature (tag 2).
    Falcon = 2,
    /// SPHINCS+ signature (tag 3).
    SphincsPlus = 3,
    /// Classic McEliece KEM (tag 4).
    ClassicMceliece = 4,
    /// BIKE KEM (tag 5).
    Bike = 5,
    /// HQC KEM (tag 6).
    Hqc = 6,
    /// FrodoKEM (tag 7).
    Frodokem = 7,
}

impl PqcAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::CrystalsKyber),
            1 => Some(Self::CrystalsDilithium),
            2 => Some(Self::Falcon),
            3 => Some(Self::SphincsPlus),
            4 => Some(Self::ClassicMceliece),
            5 => Some(Self::Bike),
            6 => Some(Self::Hqc),
            7 => Some(Self::Frodokem),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this is a KEM (key encapsulation) algorithm.
    pub fn is_kem(self) -> bool {
        matches!(self, Self::CrystalsKyber | Self::ClassicMceliece | Self::Bike | Self::Hqc | Self::Frodokem)
    }

    /// Whether this is a signature algorithm.
    pub fn is_signature(self) -> bool {
        matches!(self, Self::CrystalsDilithium | Self::Falcon | Self::SphincsPlus)
    }

    /// All variants of this type.
    pub const ALL: [PqcAlgorithm; 8] = [
        Self::CrystalsKyber, Self::CrystalsDilithium, Self::Falcon, Self::SphincsPlus, Self::ClassicMceliece, Self::Bike, Self::Hqc, Self::Frodokem,
    ];
}

impl fmt::Display for PqcAlgorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NistLevel (tags 0-4)
// ===========================================================================

/// NIST security levels (1-5).
///
/// Matches `NistLevel` in `PqcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NistLevel {
    /// Nist1 (tag 0).
    Nist1 = 0,
    /// Nist2 (tag 1).
    Nist2 = 1,
    /// Nist3 (tag 2).
    Nist3 = 2,
    /// Nist4 (tag 3).
    Nist4 = 3,
    /// Nist5 (tag 4).
    Nist5 = 4,
}

impl NistLevel {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Nist1),
            1 => Some(Self::Nist2),
            2 => Some(Self::Nist3),
            3 => Some(Self::Nist4),
            4 => Some(Self::Nist5),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [NistLevel; 5] = [
        Self::Nist1, Self::Nist2, Self::Nist3, Self::Nist4, Self::Nist5,
    ];
}

impl fmt::Display for NistLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Operation (tags 0-4)
// ===========================================================================

/// PQC cryptographic operations.
///
/// Matches `Operation` in `PqcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Operation {
    /// Keygen (tag 0).
    Keygen = 0,
    /// Encapsulate (tag 1).
    Encapsulate = 1,
    /// Decapsulate (tag 2).
    Decapsulate = 2,
    /// Sign (tag 3).
    Sign = 3,
    /// Verify (tag 4).
    Verify = 4,
}

impl Operation {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Keygen),
            1 => Some(Self::Encapsulate),
            2 => Some(Self::Decapsulate),
            3 => Some(Self::Sign),
            4 => Some(Self::Verify),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Operation; 5] = [
        Self::Keygen, Self::Encapsulate, Self::Decapsulate, Self::Sign, Self::Verify,
    ];
}

impl fmt::Display for Operation {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HybridMode (tags 0-2)
// ===========================================================================

/// Classical/PQC hybrid modes.
///
/// Matches `HybridMode` in `PqcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HybridMode {
    /// ClassicalOnly (tag 0).
    ClassicalOnly = 0,
    /// PqcOnly (tag 1).
    PqcOnly = 1,
    /// Hybrid (tag 2).
    Hybrid = 2,
}

impl HybridMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ClassicalOnly),
            1 => Some(Self::PqcOnly),
            2 => Some(Self::Hybrid),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HybridMode; 3] = [
        Self::ClassicalOnly, Self::PqcOnly, Self::Hybrid,
    ];
}

impl fmt::Display for HybridMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AlgorithmCategory (tags 0-1)
// ===========================================================================

/// PQC algorithm categories.
///
/// Matches `AlgorithmCategory` in `PqcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AlgorithmCategory {
    /// Key encapsulation (tag 0).
    Kem = 0,
    /// Signature (tag 1).
    Signature = 1,
}

impl AlgorithmCategory {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Kem),
            1 => Some(Self::Signature),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [AlgorithmCategory; 2] = [
        Self::Kem, Self::Signature,
    ];
}

impl fmt::Display for AlgorithmCategory {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// KeyState (tags 0-5)
// ===========================================================================

/// PQC key lifecycle states.
///
/// Matches `KeyState` in `PqcABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum KeyState {
    /// Empty (tag 0).
    Empty = 0,
    /// Generating (tag 1).
    Generating = 1,
    /// Generated (tag 2).
    Generated = 2,
    /// Active (tag 3).
    Active = 3,
    /// Expired (tag 4).
    Expired = 4,
    /// Compromised (tag 5).
    Compromised = 5,
}

impl KeyState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Empty),
            1 => Some(Self::Generating),
            2 => Some(Self::Generated),
            3 => Some(Self::Active),
            4 => Some(Self::Expired),
            5 => Some(Self::Compromised),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the key can be used.
    pub fn is_usable(self) -> bool {
        matches!(self, Self::Active)
    }

    /// All variants of this type.
    pub const ALL: [KeyState; 6] = [
        Self::Empty, Self::Generating, Self::Generated, Self::Active, Self::Expired, Self::Compromised,
    ];
}

impl fmt::Display for KeyState {
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
    fn pqc_algorithm_roundtrip() {
        for v in PqcAlgorithm::ALL {
            let tag = v.to_tag();
            let decoded = PqcAlgorithm::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(PqcAlgorithm::from_tag(8).is_none());
    }

    #[test]
    fn nist_level_roundtrip() {
        for v in NistLevel::ALL {
            let tag = v.to_tag();
            let decoded = NistLevel::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(NistLevel::from_tag(5).is_none());
    }

    #[test]
    fn operation_roundtrip() {
        for v in Operation::ALL {
            let tag = v.to_tag();
            let decoded = Operation::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Operation::from_tag(5).is_none());
    }

    #[test]
    fn hybrid_mode_roundtrip() {
        for v in HybridMode::ALL {
            let tag = v.to_tag();
            let decoded = HybridMode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HybridMode::from_tag(3).is_none());
    }

    #[test]
    fn algorithm_category_roundtrip() {
        for v in AlgorithmCategory::ALL {
            let tag = v.to_tag();
            let decoded = AlgorithmCategory::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(AlgorithmCategory::from_tag(2).is_none());
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

}
