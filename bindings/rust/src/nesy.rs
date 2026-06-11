// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! NeSy types for the proven-servers ABI.
//!
//! Formally verified neurosymbolic AI types.
//! Mirrors the Idris2 module `NesyABI.Types`.
//!
//! - `ReasoningMode` -- Neurosymbolic reasoning modes.
//! - `ProofStatus` -- Proof verification status.
//! - `ConstraintKind` -- Type constraint kinds.
//! - `NeuralBackend` -- Neural inference backend providers.
//! - `Confidence` -- Inference confidence levels.
//! - `DriftKind` -- Knowledge drift types.
//! - `NeSyState` -- NeSy engine states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// ReasoningMode (tags 0-5)
// ===========================================================================

/// Neurosymbolic reasoning modes.
///
/// Matches `ReasoningMode` in `NesyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ReasoningMode {
    /// Symbolic (tag 0).
    Symbolic = 0,
    /// Neural (tag 1).
    Neural = 1,
    /// SymToNeural (tag 2).
    SymToNeural = 2,
    /// NeuralToSym (tag 3).
    NeuralToSym = 3,
    /// Ensemble (tag 4).
    Ensemble = 4,
    /// Cascade (tag 5).
    Cascade = 5,
}

impl ReasoningMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Symbolic),
            1 => Some(Self::Neural),
            2 => Some(Self::SymToNeural),
            3 => Some(Self::NeuralToSym),
            4 => Some(Self::Ensemble),
            5 => Some(Self::Cascade),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ReasoningMode; 6] = [
        Self::Symbolic, Self::Neural, Self::SymToNeural, Self::NeuralToSym, Self::Ensemble, Self::Cascade,
    ];
}

impl fmt::Display for ReasoningMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ProofStatus (tags 0-5)
// ===========================================================================

/// Proof verification status.
///
/// Matches `ProofStatus` in `NesyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ProofStatus {
    /// Pending (tag 0).
    Pending = 0,
    /// Attempting (tag 1).
    Attempting = 1,
    /// Proved (tag 2).
    Proved = 2,
    /// Failed (tag 3).
    Failed = 3,
    /// Assumed (tag 4).
    Assumed = 4,
    /// Vacuous (tag 5).
    Vacuous = 5,
}

impl ProofStatus {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Pending),
            1 => Some(Self::Attempting),
            2 => Some(Self::Proved),
            3 => Some(Self::Failed),
            4 => Some(Self::Assumed),
            5 => Some(Self::Vacuous),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ProofStatus; 6] = [
        Self::Pending, Self::Attempting, Self::Proved, Self::Failed, Self::Assumed, Self::Vacuous,
    ];
}

impl fmt::Display for ProofStatus {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ConstraintKind (tags 0-7)
// ===========================================================================

/// Type constraint kinds.
///
/// Matches `ConstraintKind` in `NesyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ConstraintKind {
    /// TypeEquality (tag 0).
    TypeEquality = 0,
    /// Subtype (tag 1).
    Subtype = 1,
    /// Linearity (tag 2).
    Linearity = 2,
    /// Termination (tag 3).
    Termination = 3,
    /// Totality (tag 4).
    Totality = 4,
    /// Invariant (tag 5).
    Invariant = 5,
    /// Refinement (tag 6).
    Refinement = 6,
    /// DependentIndex (tag 7).
    DependentIndex = 7,
}

impl ConstraintKind {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::TypeEquality),
            1 => Some(Self::Subtype),
            2 => Some(Self::Linearity),
            3 => Some(Self::Termination),
            4 => Some(Self::Totality),
            5 => Some(Self::Invariant),
            6 => Some(Self::Refinement),
            7 => Some(Self::DependentIndex),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ConstraintKind; 8] = [
        Self::TypeEquality, Self::Subtype, Self::Linearity, Self::Termination, Self::Totality, Self::Invariant, Self::Refinement, Self::DependentIndex,
    ];
}

impl fmt::Display for ConstraintKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NeuralBackend (tags 0-5)
// ===========================================================================

/// Neural inference backend providers.
///
/// Matches `NeuralBackend` in `NesyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NeuralBackend {
    /// LocalModel (tag 0).
    LocalModel = 0,
    /// Claude (tag 1).
    Claude = 1,
    /// Gemini (tag 2).
    Gemini = 2,
    /// Mistral (tag 3).
    Mistral = 3,
    /// GPT (tag 4).
    Gpt = 4,
    /// CustomNeural (tag 5).
    CustomNeural = 5,
}

impl NeuralBackend {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::LocalModel),
            1 => Some(Self::Claude),
            2 => Some(Self::Gemini),
            3 => Some(Self::Mistral),
            4 => Some(Self::Gpt),
            5 => Some(Self::CustomNeural),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [NeuralBackend; 6] = [
        Self::LocalModel, Self::Claude, Self::Gemini, Self::Mistral, Self::Gpt, Self::CustomNeural,
    ];
}

impl fmt::Display for NeuralBackend {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Confidence (tags 0-5)
// ===========================================================================

/// Inference confidence levels.
///
/// Matches `Confidence` in `NesyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Confidence {
    /// Verified (tag 0).
    Verified = 0,
    /// HighNeural (tag 1).
    HighNeural = 1,
    /// MediumNeural (tag 2).
    MediumNeural = 2,
    /// LowNeural (tag 3).
    LowNeural = 3,
    /// Unknown (tag 4).
    Unknown = 4,
    /// Contradicted (tag 5).
    Contradicted = 5,
}

impl Confidence {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Verified),
            1 => Some(Self::HighNeural),
            2 => Some(Self::MediumNeural),
            3 => Some(Self::LowNeural),
            4 => Some(Self::Unknown),
            5 => Some(Self::Contradicted),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Confidence; 6] = [
        Self::Verified, Self::HighNeural, Self::MediumNeural, Self::LowNeural, Self::Unknown, Self::Contradicted,
    ];
}

impl fmt::Display for Confidence {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DriftKind (tags 0-5)
// ===========================================================================

/// Knowledge drift types.
///
/// Matches `DriftKind` in `NesyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DriftKind {
    /// NoDrift (tag 0).
    NoDrift = 0,
    /// SemanticDrift (tag 1).
    SemanticDrift = 1,
    /// ConfidenceDrift (tag 2).
    ConfidenceDrift = 2,
    /// FactualDrift (tag 3).
    FactualDrift = 3,
    /// TemporalDrift (tag 4).
    TemporalDrift = 4,
    /// CatastrophicDrift (tag 5).
    CatastrophicDrift = 5,
}

impl DriftKind {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NoDrift),
            1 => Some(Self::SemanticDrift),
            2 => Some(Self::ConfidenceDrift),
            3 => Some(Self::FactualDrift),
            4 => Some(Self::TemporalDrift),
            5 => Some(Self::CatastrophicDrift),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DriftKind; 6] = [
        Self::NoDrift, Self::SemanticDrift, Self::ConfidenceDrift, Self::FactualDrift, Self::TemporalDrift, Self::CatastrophicDrift,
    ];
}

impl fmt::Display for DriftKind {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NeSyState (tags 0-5)
// ===========================================================================

/// NeSy engine states.
///
/// Matches `NeSyState` in `NesyABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NeSyState {
    /// Idle (tag 0).
    Idle = 0,
    /// Ready (tag 1).
    Ready = 1,
    /// Reasoning (tag 2).
    Reasoning = 2,
    /// Verifying (tag 3).
    Verifying = 3,
    /// Drift (tag 4).
    Drift = 4,
    /// Shutdown (tag 5).
    Shutdown = 5,
}

impl NeSyState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Ready),
            2 => Some(Self::Reasoning),
            3 => Some(Self::Verifying),
            4 => Some(Self::Drift),
            5 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [NeSyState; 6] = [
        Self::Idle, Self::Ready, Self::Reasoning, Self::Verifying, Self::Drift, Self::Shutdown,
    ];
}

impl fmt::Display for NeSyState {
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
    fn reasoning_mode_roundtrip() {
        for v in ReasoningMode::ALL {
            let tag = v.to_tag();
            let decoded = ReasoningMode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ReasoningMode::from_tag(6).is_none());
    }

    #[test]
    fn proof_status_roundtrip() {
        for v in ProofStatus::ALL {
            let tag = v.to_tag();
            let decoded = ProofStatus::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ProofStatus::from_tag(6).is_none());
    }

    #[test]
    fn constraint_kind_roundtrip() {
        for v in ConstraintKind::ALL {
            let tag = v.to_tag();
            let decoded = ConstraintKind::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ConstraintKind::from_tag(8).is_none());
    }

    #[test]
    fn neural_backend_roundtrip() {
        for v in NeuralBackend::ALL {
            let tag = v.to_tag();
            let decoded = NeuralBackend::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(NeuralBackend::from_tag(6).is_none());
    }

    #[test]
    fn confidence_roundtrip() {
        for v in Confidence::ALL {
            let tag = v.to_tag();
            let decoded = Confidence::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Confidence::from_tag(6).is_none());
    }

    #[test]
    fn drift_kind_roundtrip() {
        for v in DriftKind::ALL {
            let tag = v.to_tag();
            let decoded = DriftKind::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DriftKind::from_tag(6).is_none());
    }

    #[test]
    fn ne_sy_state_roundtrip() {
        for v in NeSyState::ALL {
            let tag = v.to_tag();
            let decoded = NeSyState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(NeSyState::from_tag(6).is_none());
    }

}
