//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Neurosymbolic protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `NeSyABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// ReasoningMode
// ===========================================================================

/// Neurosymbolic reasoning modes.
/// 
/// Matches `ReasoningMode` in `NesyABI.Types`.
pub type ReasoningMode {
  /// Symbolic (tag 0).
  Symbolic
  /// Neural (tag 1).
  Neural
  /// SymToNeural (tag 2).
  SymToNeural
  /// NeuralToSym (tag 3).
  NeuralToSym
  /// Ensemble (tag 4).
  Ensemble
  /// Cascade (tag 5).
  Cascade
}

/// Convert a `ReasoningMode` to its C-ABI tag value.
pub fn reasoning_mode_to_int(value: ReasoningMode) -> Int {
  case value {
    Symbolic -> 0
    Neural -> 1
    SymToNeural -> 2
    NeuralToSym -> 3
    Ensemble -> 4
    Cascade -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn reasoning_mode_from_int(tag: Int) -> Result(ReasoningMode, Nil) {
  case tag {
    0 -> Ok(Symbolic)
    1 -> Ok(Neural)
    2 -> Ok(SymToNeural)
    3 -> Ok(NeuralToSym)
    4 -> Ok(Ensemble)
    5 -> Ok(Cascade)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ProofStatus
// ===========================================================================

/// Proof verification status.
/// 
/// Matches `ProofStatus` in `NesyABI.Types`.
pub type ProofStatus {
  /// Pending (tag 0).
  Pending
  /// Attempting (tag 1).
  Attempting
  /// Proved (tag 2).
  Proved
  /// Failed (tag 3).
  Failed
  /// Assumed (tag 4).
  Assumed
  /// Vacuous (tag 5).
  Vacuous
}

/// Convert a `ProofStatus` to its C-ABI tag value.
pub fn proof_status_to_int(value: ProofStatus) -> Int {
  case value {
    Pending -> 0
    Attempting -> 1
    Proved -> 2
    Failed -> 3
    Assumed -> 4
    Vacuous -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn proof_status_from_int(tag: Int) -> Result(ProofStatus, Nil) {
  case tag {
    0 -> Ok(Pending)
    1 -> Ok(Attempting)
    2 -> Ok(Proved)
    3 -> Ok(Failed)
    4 -> Ok(Assumed)
    5 -> Ok(Vacuous)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ConstraintKind
// ===========================================================================

/// Type constraint kinds.
/// 
/// Matches `ConstraintKind` in `NesyABI.Types`.
pub type ConstraintKind {
  /// TypeEquality (tag 0).
  TypeEquality
  /// Subtype (tag 1).
  Subtype
  /// Linearity (tag 2).
  Linearity
  /// Termination (tag 3).
  Termination
  /// Totality (tag 4).
  Totality
  /// Invariant (tag 5).
  Invariant
  /// Refinement (tag 6).
  Refinement
  /// DependentIndex (tag 7).
  DependentIndex
}

/// Convert a `ConstraintKind` to its C-ABI tag value.
pub fn constraint_kind_to_int(value: ConstraintKind) -> Int {
  case value {
    TypeEquality -> 0
    Subtype -> 1
    Linearity -> 2
    Termination -> 3
    Totality -> 4
    Invariant -> 5
    Refinement -> 6
    DependentIndex -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn constraint_kind_from_int(tag: Int) -> Result(ConstraintKind, Nil) {
  case tag {
    0 -> Ok(TypeEquality)
    1 -> Ok(Subtype)
    2 -> Ok(Linearity)
    3 -> Ok(Termination)
    4 -> Ok(Totality)
    5 -> Ok(Invariant)
    6 -> Ok(Refinement)
    7 -> Ok(DependentIndex)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NeuralBackend
// ===========================================================================

/// Neural inference backend providers.
/// 
/// Matches `NeuralBackend` in `NesyABI.Types`.
pub type NeuralBackend {
  /// LocalModel (tag 0).
  LocalModel
  /// Claude (tag 1).
  Claude
  /// Gemini (tag 2).
  Gemini
  /// Mistral (tag 3).
  Mistral
  /// GPT (tag 4).
  Gpt
  /// CustomNeural (tag 5).
  CustomNeural
}

/// Convert a `NeuralBackend` to its C-ABI tag value.
pub fn neural_backend_to_int(value: NeuralBackend) -> Int {
  case value {
    LocalModel -> 0
    Claude -> 1
    Gemini -> 2
    Mistral -> 3
    Gpt -> 4
    CustomNeural -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn neural_backend_from_int(tag: Int) -> Result(NeuralBackend, Nil) {
  case tag {
    0 -> Ok(LocalModel)
    1 -> Ok(Claude)
    2 -> Ok(Gemini)
    3 -> Ok(Mistral)
    4 -> Ok(Gpt)
    5 -> Ok(CustomNeural)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Confidence
// ===========================================================================

/// Inference confidence levels.
/// 
/// Matches `Confidence` in `NesyABI.Types`.
pub type Confidence {
  /// Verified (tag 0).
  Verified
  /// HighNeural (tag 1).
  HighNeural
  /// MediumNeural (tag 2).
  MediumNeural
  /// LowNeural (tag 3).
  LowNeural
  /// Unknown (tag 4).
  Unknown
  /// Contradicted (tag 5).
  Contradicted
}

/// Convert a `Confidence` to its C-ABI tag value.
pub fn confidence_to_int(value: Confidence) -> Int {
  case value {
    Verified -> 0
    HighNeural -> 1
    MediumNeural -> 2
    LowNeural -> 3
    Unknown -> 4
    Contradicted -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn confidence_from_int(tag: Int) -> Result(Confidence, Nil) {
  case tag {
    0 -> Ok(Verified)
    1 -> Ok(HighNeural)
    2 -> Ok(MediumNeural)
    3 -> Ok(LowNeural)
    4 -> Ok(Unknown)
    5 -> Ok(Contradicted)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DriftKind
// ===========================================================================

/// Knowledge drift types.
/// 
/// Matches `DriftKind` in `NesyABI.Types`.
pub type DriftKind {
  /// NoDrift (tag 0).
  NoDrift
  /// SemanticDrift (tag 1).
  SemanticDrift
  /// ConfidenceDrift (tag 2).
  ConfidenceDrift
  /// FactualDrift (tag 3).
  FactualDrift
  /// TemporalDrift (tag 4).
  TemporalDrift
  /// CatastrophicDrift (tag 5).
  CatastrophicDrift
}

/// Convert a `DriftKind` to its C-ABI tag value.
pub fn drift_kind_to_int(value: DriftKind) -> Int {
  case value {
    NoDrift -> 0
    SemanticDrift -> 1
    ConfidenceDrift -> 2
    FactualDrift -> 3
    TemporalDrift -> 4
    CatastrophicDrift -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn drift_kind_from_int(tag: Int) -> Result(DriftKind, Nil) {
  case tag {
    0 -> Ok(NoDrift)
    1 -> Ok(SemanticDrift)
    2 -> Ok(ConfidenceDrift)
    3 -> Ok(FactualDrift)
    4 -> Ok(TemporalDrift)
    5 -> Ok(CatastrophicDrift)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NeSyState
// ===========================================================================

/// NeSy engine states.
/// 
/// Matches `NeSyState` in `NesyABI.Types`.
pub type NeSyState {
  /// Idle (tag 0).
  Idle
  /// Ready (tag 1).
  Ready
  /// Reasoning (tag 2).
  Reasoning
  /// Verifying (tag 3).
  Verifying
  /// Drift (tag 4).
  Drift
  /// Shutdown (tag 5).
  Shutdown
}

/// Convert a `NeSyState` to its C-ABI tag value.
pub fn ne_sy_state_to_int(value: NeSyState) -> Int {
  case value {
    Idle -> 0
    Ready -> 1
    Reasoning -> 2
    Verifying -> 3
    Drift -> 4
    Shutdown -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn ne_sy_state_from_int(tag: Int) -> Result(NeSyState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Ready)
    2 -> Ok(Reasoning)
    3 -> Ok(Verifying)
    4 -> Ok(Drift)
    5 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

