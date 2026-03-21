// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Neurosymbolic Engine types for the proven-servers ABI.
//
// Mirrors the Idris2 module NeurosymABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// InferenceMode (tags 0-3)
// ===========================================================================

/// Neurosymbolic inference modes.
type inferenceMode =
  | @as(0) Neural
  | @as(1) Symbolic
  | @as(2) Hybrid
  | @as(3) Cascade

/// Decode from the C-ABI tag value.
let inferenceModeFromTag = (tag: int): option<inferenceMode> =>
  switch tag {
  | 0 => Some(Neural)
  | 1 => Some(Symbolic)
  | 2 => Some(Hybrid)
  | 3 => Some(Cascade)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let inferenceModeToTag = (v: inferenceMode): int =>
  switch v {
  | Neural => 0
  | Symbolic => 1
  | Hybrid => 2
  | Cascade => 3
  }

// ===========================================================================
// SymbolicOp (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type symbolicOp =
  | @as(0) Unify
  | @as(1) Resolve
  | @as(2) Rewrite
  | @as(3) Prove
  | @as(4) Search
  | @as(5) Constrain

/// Decode from the C-ABI tag value.
let symbolicOpFromTag = (tag: int): option<symbolicOp> =>
  switch tag {
  | 0 => Some(Unify)
  | 1 => Some(Resolve)
  | 2 => Some(Rewrite)
  | 3 => Some(Prove)
  | 4 => Some(Search)
  | 5 => Some(Constrain)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let symbolicOpToTag = (v: symbolicOp): int =>
  switch v {
  | Unify => 0
  | Resolve => 1
  | Rewrite => 2
  | Prove => 3
  | Search => 4
  | Constrain => 5
  }

// ===========================================================================
// NeuralOp (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type neuralOp =
  | @as(0) Embed
  | @as(1) Classify
  | @as(2) Generate
  | @as(3) Attend
  | @as(4) Retrieve
  | @as(5) Finetune

/// Decode from the C-ABI tag value.
let neuralOpFromTag = (tag: int): option<neuralOp> =>
  switch tag {
  | 0 => Some(Embed)
  | 1 => Some(Classify)
  | 2 => Some(Generate)
  | 3 => Some(Attend)
  | 4 => Some(Retrieve)
  | 5 => Some(Finetune)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let neuralOpToTag = (v: neuralOp): int =>
  switch v {
  | Embed => 0
  | Classify => 1
  | Generate => 2
  | Attend => 3
  | Retrieve => 4
  | Finetune => 5
  }

// ===========================================================================
// FusionStrategy (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type fusionStrategy =
  | @as(0) NeuralThenSymbolic
  | @as(1) SymbolicThenNeural
  | @as(2) Parallel
  | @as(3) Iterative
  | @as(4) Gated

/// Decode from the C-ABI tag value.
let fusionStrategyFromTag = (tag: int): option<fusionStrategy> =>
  switch tag {
  | 0 => Some(NeuralThenSymbolic)
  | 1 => Some(SymbolicThenNeural)
  | 2 => Some(Parallel)
  | 3 => Some(Iterative)
  | 4 => Some(Gated)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let fusionStrategyToTag = (v: fusionStrategy): int =>
  switch v {
  | NeuralThenSymbolic => 0
  | SymbolicThenNeural => 1
  | Parallel => 2
  | Iterative => 3
  | Gated => 4
  }

// ===========================================================================
// ConfidenceLevel (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type confidenceLevel =
  | @as(0) Proven
  | @as(1) HighConfidence
  | @as(2) Moderate
  | @as(3) LowConfidence
  | @as(4) Uncertain
  | @as(5) Contradicted

/// Decode from the C-ABI tag value.
let confidenceLevelFromTag = (tag: int): option<confidenceLevel> =>
  switch tag {
  | 0 => Some(Proven)
  | 1 => Some(HighConfidence)
  | 2 => Some(Moderate)
  | 3 => Some(LowConfidence)
  | 4 => Some(Uncertain)
  | 5 => Some(Contradicted)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let confidenceLevelToTag = (v: confidenceLevel): int =>
  switch v {
  | Proven => 0
  | HighConfidence => 1
  | Moderate => 2
  | LowConfidence => 3
  | Uncertain => 4
  | Contradicted => 5
  }

// ===========================================================================
// KnowledgeType (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type knowledgeType =
  | @as(0) Axiom
  | @as(1) Learned
  | @as(2) Inferred
  | @as(3) Grounded
  | @as(4) Hypothetical
  | @as(5) Retracted

/// Decode from the C-ABI tag value.
let knowledgeTypeFromTag = (tag: int): option<knowledgeType> =>
  switch tag {
  | 0 => Some(Axiom)
  | 1 => Some(Learned)
  | 2 => Some(Inferred)
  | 3 => Some(Grounded)
  | 4 => Some(Hypothetical)
  | 5 => Some(Retracted)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let knowledgeTypeToTag = (v: knowledgeType): int =>
  switch v {
  | Axiom => 0
  | Learned => 1
  | Inferred => 2
  | Grounded => 3
  | Hypothetical => 4
  | Retracted => 5
  }

// ===========================================================================
// NeurosymState (tags 0-5)
// ===========================================================================

/// Decode from an ABI tag value.
type neurosymState =
  | @as(0) Idle
  | @as(1) Ready
  | @as(2) Inferring
  | @as(3) Reasoning
  | @as(4) Fusing
  | @as(5) Shutdown

/// Decode from the C-ABI tag value.
let neurosymStateFromTag = (tag: int): option<neurosymState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Ready)
  | 2 => Some(Inferring)
  | 3 => Some(Reasoning)
  | 4 => Some(Fusing)
  | 5 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let neurosymStateToTag = (v: neurosymState): int =>
  switch v {
  | Idle => 0
  | Ready => 1
  | Inferring => 2
  | Reasoning => 3
  | Fusing => 4
  | Shutdown => 5
  }

