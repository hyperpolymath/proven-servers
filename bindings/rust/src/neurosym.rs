// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Neurosymbolic Engine types for the proven-servers ABI.
//!
//! Formally verified neurosymbolic integration types.
//! Mirrors the Idris2 module `NeurosymABI.Types`.
//!
//! - `InferenceMode` -- Neurosymbolic inference modes.
//! - `SymbolicOp` -- Symbolic reasoning operations.
//! - `NeuralOp` -- Neural inference operations.
//! - `FusionStrategy` -- Neural-symbolic fusion strategies.
//! - `ConfidenceLevel` -- Inference confidence levels.
//! - `KnowledgeType` -- Knowledge entry types.
//! - `NeurosymState` -- Neurosymbolic engine states.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// InferenceMode (tags 0-3)
// ===========================================================================

/// Neurosymbolic inference modes.
///
/// Matches `InferenceMode` in `NeurosymABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum InferenceMode {
    /// Neural (tag 0).
    Neural = 0,
    /// Symbolic (tag 1).
    Symbolic = 1,
    /// Hybrid (tag 2).
    Hybrid = 2,
    /// Cascade (tag 3).
    Cascade = 3,
}

impl InferenceMode {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Neural),
            1 => Some(Self::Symbolic),
            2 => Some(Self::Hybrid),
            3 => Some(Self::Cascade),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [InferenceMode; 4] = [
        Self::Neural, Self::Symbolic, Self::Hybrid, Self::Cascade,
    ];
}

impl fmt::Display for InferenceMode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SymbolicOp (tags 0-5)
// ===========================================================================

/// Symbolic reasoning operations.
///
/// Matches `SymbolicOp` in `NeurosymABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SymbolicOp {
    /// Unify (tag 0).
    Unify = 0,
    /// Resolve (tag 1).
    Resolve = 1,
    /// Rewrite (tag 2).
    Rewrite = 2,
    /// Prove (tag 3).
    Prove = 3,
    /// Search (tag 4).
    Search = 4,
    /// Constrain (tag 5).
    Constrain = 5,
}

impl SymbolicOp {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Unify),
            1 => Some(Self::Resolve),
            2 => Some(Self::Rewrite),
            3 => Some(Self::Prove),
            4 => Some(Self::Search),
            5 => Some(Self::Constrain),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SymbolicOp; 6] = [
        Self::Unify, Self::Resolve, Self::Rewrite, Self::Prove, Self::Search, Self::Constrain,
    ];
}

impl fmt::Display for SymbolicOp {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NeuralOp (tags 0-5)
// ===========================================================================

/// Neural inference operations.
///
/// Matches `NeuralOp` in `NeurosymABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NeuralOp {
    /// Embed (tag 0).
    Embed = 0,
    /// Classify (tag 1).
    Classify = 1,
    /// Generate (tag 2).
    Generate = 2,
    /// Attend (tag 3).
    Attend = 3,
    /// Retrieve (tag 4).
    Retrieve = 4,
    /// Finetune (tag 5).
    Finetune = 5,
}

impl NeuralOp {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Embed),
            1 => Some(Self::Classify),
            2 => Some(Self::Generate),
            3 => Some(Self::Attend),
            4 => Some(Self::Retrieve),
            5 => Some(Self::Finetune),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [NeuralOp; 6] = [
        Self::Embed, Self::Classify, Self::Generate, Self::Attend, Self::Retrieve, Self::Finetune,
    ];
}

impl fmt::Display for NeuralOp {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// FusionStrategy (tags 0-4)
// ===========================================================================

/// Neural-symbolic fusion strategies.
///
/// Matches `FusionStrategy` in `NeurosymABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FusionStrategy {
    /// NeuralThenSymbolic (tag 0).
    NeuralThenSymbolic = 0,
    /// SymbolicThenNeural (tag 1).
    SymbolicThenNeural = 1,
    /// Parallel (tag 2).
    Parallel = 2,
    /// Iterative (tag 3).
    Iterative = 3,
    /// Gated (tag 4).
    Gated = 4,
}

impl FusionStrategy {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::NeuralThenSymbolic),
            1 => Some(Self::SymbolicThenNeural),
            2 => Some(Self::Parallel),
            3 => Some(Self::Iterative),
            4 => Some(Self::Gated),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [FusionStrategy; 5] = [
        Self::NeuralThenSymbolic, Self::SymbolicThenNeural, Self::Parallel, Self::Iterative, Self::Gated,
    ];
}

impl fmt::Display for FusionStrategy {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ConfidenceLevel (tags 0-5)
// ===========================================================================

/// Inference confidence levels.
///
/// Matches `ConfidenceLevel` in `NeurosymABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ConfidenceLevel {
    /// Proven (tag 0).
    Proven = 0,
    /// HighConfidence (tag 1).
    HighConfidence = 1,
    /// Moderate (tag 2).
    Moderate = 2,
    /// LowConfidence (tag 3).
    LowConfidence = 3,
    /// Uncertain (tag 4).
    Uncertain = 4,
    /// Contradicted (tag 5).
    Contradicted = 5,
}

impl ConfidenceLevel {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Proven),
            1 => Some(Self::HighConfidence),
            2 => Some(Self::Moderate),
            3 => Some(Self::LowConfidence),
            4 => Some(Self::Uncertain),
            5 => Some(Self::Contradicted),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ConfidenceLevel; 6] = [
        Self::Proven, Self::HighConfidence, Self::Moderate, Self::LowConfidence, Self::Uncertain, Self::Contradicted,
    ];
}

impl fmt::Display for ConfidenceLevel {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// KnowledgeType (tags 0-5)
// ===========================================================================

/// Knowledge entry types.
///
/// Matches `KnowledgeType` in `NeurosymABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum KnowledgeType {
    /// Axiom (tag 0).
    Axiom = 0,
    /// Learned (tag 1).
    Learned = 1,
    /// Inferred (tag 2).
    Inferred = 2,
    /// Grounded (tag 3).
    Grounded = 3,
    /// Hypothetical (tag 4).
    Hypothetical = 4,
    /// Retracted (tag 5).
    Retracted = 5,
}

impl KnowledgeType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Axiom),
            1 => Some(Self::Learned),
            2 => Some(Self::Inferred),
            3 => Some(Self::Grounded),
            4 => Some(Self::Hypothetical),
            5 => Some(Self::Retracted),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [KnowledgeType; 6] = [
        Self::Axiom, Self::Learned, Self::Inferred, Self::Grounded, Self::Hypothetical, Self::Retracted,
    ];
}

impl fmt::Display for KnowledgeType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NeurosymState (tags 0-5)
// ===========================================================================

/// Neurosymbolic engine states.
///
/// Matches `NeurosymState` in `NeurosymABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NeurosymState {
    /// Idle (tag 0).
    Idle = 0,
    /// Ready (tag 1).
    Ready = 1,
    /// Inferring (tag 2).
    Inferring = 2,
    /// Reasoning (tag 3).
    Reasoning = 3,
    /// Fusing (tag 4).
    Fusing = 4,
    /// Shutdown (tag 5).
    Shutdown = 5,
}

impl NeurosymState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Ready),
            2 => Some(Self::Inferring),
            3 => Some(Self::Reasoning),
            4 => Some(Self::Fusing),
            5 => Some(Self::Shutdown),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [NeurosymState; 6] = [
        Self::Idle, Self::Ready, Self::Inferring, Self::Reasoning, Self::Fusing, Self::Shutdown,
    ];
}

impl fmt::Display for NeurosymState {
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
    fn inference_mode_roundtrip() {
        for v in InferenceMode::ALL {
            let tag = v.to_tag();
            let decoded = InferenceMode::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(InferenceMode::from_tag(4).is_none());
    }

    #[test]
    fn symbolic_op_roundtrip() {
        for v in SymbolicOp::ALL {
            let tag = v.to_tag();
            let decoded = SymbolicOp::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SymbolicOp::from_tag(6).is_none());
    }

    #[test]
    fn neural_op_roundtrip() {
        for v in NeuralOp::ALL {
            let tag = v.to_tag();
            let decoded = NeuralOp::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(NeuralOp::from_tag(6).is_none());
    }

    #[test]
    fn fusion_strategy_roundtrip() {
        for v in FusionStrategy::ALL {
            let tag = v.to_tag();
            let decoded = FusionStrategy::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(FusionStrategy::from_tag(5).is_none());
    }

    #[test]
    fn confidence_level_roundtrip() {
        for v in ConfidenceLevel::ALL {
            let tag = v.to_tag();
            let decoded = ConfidenceLevel::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ConfidenceLevel::from_tag(6).is_none());
    }

    #[test]
    fn knowledge_type_roundtrip() {
        for v in KnowledgeType::ALL {
            let tag = v.to_tag();
            let decoded = KnowledgeType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(KnowledgeType::from_tag(6).is_none());
    }

    #[test]
    fn neurosym_state_roundtrip() {
        for v in NeurosymState::ALL {
            let tag = v.to_tag();
            let decoded = NeurosymState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(NeurosymState::from_tag(6).is_none());
    }

}
