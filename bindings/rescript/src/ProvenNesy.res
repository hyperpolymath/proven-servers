// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NeSy types for the proven-servers ABI.
//
// Mirrors the Idris2 module NesyABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// ReasoningMode (tags 0-5)
// ===========================================================================

/// Neurosymbolic reasoning modes.
type reasoningMode =
  | @as(0) Symbolic
  | @as(1) Neural
  | @as(2) SymToNeural
  | @as(3) NeuralToSym
  | @as(4) Ensemble
  | @as(5) Cascade

/// Decode from the C-ABI tag value.
let reasoningModeFromTag = (tag: int): option<reasoningMode> =>
  switch tag {
  | 0 => Some(Symbolic)
  | 1 => Some(Neural)
  | 2 => Some(SymToNeural)
  | 3 => Some(NeuralToSym)
  | 4 => Some(Ensemble)
  | 5 => Some(Cascade)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let reasoningModeToTag = (v: reasoningMode): int =>
  switch v {
  | Symbolic => 0
  | Neural => 1
  | SymToNeural => 2
  | NeuralToSym => 3
  | Ensemble => 4
  | Cascade => 5
  }

// ===========================================================================
// ProofStatus (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type proofStatus =
  | @as(0) Pending
  | @as(1) Attempting
  | @as(2) Proved
  | @as(3) Failed
  | @as(4) Assumed
  | @as(5) Vacuous

/// Decode from the C-ABI tag value.
let proofStatusFromTag = (tag: int): option<proofStatus> =>
  switch tag {
  | 0 => Some(Pending)
  | 1 => Some(Attempting)
  | 2 => Some(Proved)
  | 3 => Some(Failed)
  | 4 => Some(Assumed)
  | 5 => Some(Vacuous)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let proofStatusToTag = (v: proofStatus): int =>
  switch v {
  | Pending => 0
  | Attempting => 1
  | Proved => 2
  | Failed => 3
  | Assumed => 4
  | Vacuous => 5
  }

// ===========================================================================
// ConstraintKind (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type constraintKind =
  | @as(0) TypeEquality
  | @as(1) Subtype
  | @as(2) Linearity
  | @as(3) Termination
  | @as(4) Totality
  | @as(5) Invariant
  | @as(6) Refinement
  | @as(7) DependentIndex

/// Decode from the C-ABI tag value.
let constraintKindFromTag = (tag: int): option<constraintKind> =>
  switch tag {
  | 0 => Some(TypeEquality)
  | 1 => Some(Subtype)
  | 2 => Some(Linearity)
  | 3 => Some(Termination)
  | 4 => Some(Totality)
  | 5 => Some(Invariant)
  | 6 => Some(Refinement)
  | 7 => Some(DependentIndex)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let constraintKindToTag = (v: constraintKind): int =>
  switch v {
  | TypeEquality => 0
  | Subtype => 1
  | Linearity => 2
  | Termination => 3
  | Totality => 4
  | Invariant => 5
  | Refinement => 6
  | DependentIndex => 7
  }

// ===========================================================================
// NeuralBackend (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type neuralBackend =
  | @as(0) LocalModel
  | @as(1) Claude
  | @as(2) Gemini
  | @as(3) Mistral
  | @as(4) Gpt
  | @as(5) CustomNeural

/// Decode from the C-ABI tag value.
let neuralBackendFromTag = (tag: int): option<neuralBackend> =>
  switch tag {
  | 0 => Some(LocalModel)
  | 1 => Some(Claude)
  | 2 => Some(Gemini)
  | 3 => Some(Mistral)
  | 4 => Some(Gpt)
  | 5 => Some(CustomNeural)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let neuralBackendToTag = (v: neuralBackend): int =>
  switch v {
  | LocalModel => 0
  | Claude => 1
  | Gemini => 2
  | Mistral => 3
  | Gpt => 4
  | CustomNeural => 5
  }

// ===========================================================================
// Confidence (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type confidence =
  | @as(0) Verified
  | @as(1) HighNeural
  | @as(2) MediumNeural
  | @as(3) LowNeural
  | @as(4) Unknown
  | @as(5) Contradicted

/// Decode from the C-ABI tag value.
let confidenceFromTag = (tag: int): option<confidence> =>
  switch tag {
  | 0 => Some(Verified)
  | 1 => Some(HighNeural)
  | 2 => Some(MediumNeural)
  | 3 => Some(LowNeural)
  | 4 => Some(Unknown)
  | 5 => Some(Contradicted)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let confidenceToTag = (v: confidence): int =>
  switch v {
  | Verified => 0
  | HighNeural => 1
  | MediumNeural => 2
  | LowNeural => 3
  | Unknown => 4
  | Contradicted => 5
  }

// ===========================================================================
// DriftKind (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type driftKind =
  | @as(0) NoDrift
  | @as(1) SemanticDrift
  | @as(2) ConfidenceDrift
  | @as(3) FactualDrift
  | @as(4) TemporalDrift
  | @as(5) CatastrophicDrift

/// Decode from the C-ABI tag value.
let driftKindFromTag = (tag: int): option<driftKind> =>
  switch tag {
  | 0 => Some(NoDrift)
  | 1 => Some(SemanticDrift)
  | 2 => Some(ConfidenceDrift)
  | 3 => Some(FactualDrift)
  | 4 => Some(TemporalDrift)
  | 5 => Some(CatastrophicDrift)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let driftKindToTag = (v: driftKind): int =>
  switch v {
  | NoDrift => 0
  | SemanticDrift => 1
  | ConfidenceDrift => 2
  | FactualDrift => 3
  | TemporalDrift => 4
  | CatastrophicDrift => 5
  }

// ===========================================================================
// NeSyState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type neSyState =
  | @as(0) Idle
  | @as(1) Ready
  | @as(2) Reasoning
  | @as(3) Verifying
  | @as(4) Drift
  | @as(5) Shutdown

/// Decode from the C-ABI tag value.
let neSyStateFromTag = (tag: int): option<neSyState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Ready)
  | 2 => Some(Reasoning)
  | 3 => Some(Verifying)
  | 4 => Some(Drift)
  | 5 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let neSyStateToTag = (v: neSyState): int =>
  switch v {
  | Idle => 0
  | Ready => 1
  | Reasoning => 2
  | Verifying => 3
  | Drift => 4
  | Shutdown => 5
  }

