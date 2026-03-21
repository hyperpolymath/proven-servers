//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Neurosymbolic Integration protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `NeurosymABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// InferenceMode
// ===========================================================================

/// Neurosymbolic inference modes.
/// 
/// Matches `InferenceMode` in `NeurosymABI.Types`.
pub type InferenceMode {
  /// Neural (tag 0).
  Neural
  /// Symbolic (tag 1).
  Symbolic
  /// Hybrid (tag 2).
  Hybrid
  /// Cascade (tag 3).
  Cascade
}

/// Convert a `InferenceMode` to its C-ABI tag value.
pub fn inference_mode_to_int(value: InferenceMode) -> Int {
  case value {
    Neural -> 0
    Symbolic -> 1
    Hybrid -> 2
    Cascade -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn inference_mode_from_int(tag: Int) -> Result(InferenceMode, Nil) {
  case tag {
    0 -> Ok(Neural)
    1 -> Ok(Symbolic)
    2 -> Ok(Hybrid)
    3 -> Ok(Cascade)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// SymbolicOp
// ===========================================================================

/// Symbolic reasoning operations.
/// 
/// Matches `SymbolicOp` in `NeurosymABI.Types`.
pub type SymbolicOp {
  /// Unify (tag 0).
  Unify
  /// Resolve (tag 1).
  Resolve
  /// Rewrite (tag 2).
  Rewrite
  /// Prove (tag 3).
  Prove
  /// Search (tag 4).
  Search
  /// Constrain (tag 5).
  Constrain
}

/// Convert a `SymbolicOp` to its C-ABI tag value.
pub fn symbolic_op_to_int(value: SymbolicOp) -> Int {
  case value {
    Unify -> 0
    Resolve -> 1
    Rewrite -> 2
    Prove -> 3
    Search -> 4
    Constrain -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn symbolic_op_from_int(tag: Int) -> Result(SymbolicOp, Nil) {
  case tag {
    0 -> Ok(Unify)
    1 -> Ok(Resolve)
    2 -> Ok(Rewrite)
    3 -> Ok(Prove)
    4 -> Ok(Search)
    5 -> Ok(Constrain)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NeuralOp
// ===========================================================================

/// Neural inference operations.
/// 
/// Matches `NeuralOp` in `NeurosymABI.Types`.
pub type NeuralOp {
  /// Embed (tag 0).
  Embed
  /// Classify (tag 1).
  Classify
  /// Generate (tag 2).
  Generate
  /// Attend (tag 3).
  Attend
  /// Retrieve (tag 4).
  Retrieve
  /// Finetune (tag 5).
  Finetune
}

/// Convert a `NeuralOp` to its C-ABI tag value.
pub fn neural_op_to_int(value: NeuralOp) -> Int {
  case value {
    Embed -> 0
    Classify -> 1
    Generate -> 2
    Attend -> 3
    Retrieve -> 4
    Finetune -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn neural_op_from_int(tag: Int) -> Result(NeuralOp, Nil) {
  case tag {
    0 -> Ok(Embed)
    1 -> Ok(Classify)
    2 -> Ok(Generate)
    3 -> Ok(Attend)
    4 -> Ok(Retrieve)
    5 -> Ok(Finetune)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// FusionStrategy
// ===========================================================================

/// Neural-symbolic fusion strategies.
/// 
/// Matches `FusionStrategy` in `NeurosymABI.Types`.
pub type FusionStrategy {
  /// NeuralThenSymbolic (tag 0).
  NeuralThenSymbolic
  /// SymbolicThenNeural (tag 1).
  SymbolicThenNeural
  /// Parallel (tag 2).
  Parallel
  /// Iterative (tag 3).
  Iterative
  /// Gated (tag 4).
  Gated
}

/// Convert a `FusionStrategy` to its C-ABI tag value.
pub fn fusion_strategy_to_int(value: FusionStrategy) -> Int {
  case value {
    NeuralThenSymbolic -> 0
    SymbolicThenNeural -> 1
    Parallel -> 2
    Iterative -> 3
    Gated -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn fusion_strategy_from_int(tag: Int) -> Result(FusionStrategy, Nil) {
  case tag {
    0 -> Ok(NeuralThenSymbolic)
    1 -> Ok(SymbolicThenNeural)
    2 -> Ok(Parallel)
    3 -> Ok(Iterative)
    4 -> Ok(Gated)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ConfidenceLevel
// ===========================================================================

/// Inference confidence levels.
/// 
/// Matches `ConfidenceLevel` in `NeurosymABI.Types`.
pub type ConfidenceLevel {
  /// Proven (tag 0).
  Proven
  /// HighConfidence (tag 1).
  HighConfidence
  /// Moderate (tag 2).
  Moderate
  /// LowConfidence (tag 3).
  LowConfidence
  /// Uncertain (tag 4).
  Uncertain
  /// Contradicted (tag 5).
  Contradicted
}

/// Convert a `ConfidenceLevel` to its C-ABI tag value.
pub fn confidence_level_to_int(value: ConfidenceLevel) -> Int {
  case value {
    Proven -> 0
    HighConfidence -> 1
    Moderate -> 2
    LowConfidence -> 3
    Uncertain -> 4
    Contradicted -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn confidence_level_from_int(tag: Int) -> Result(ConfidenceLevel, Nil) {
  case tag {
    0 -> Ok(Proven)
    1 -> Ok(HighConfidence)
    2 -> Ok(Moderate)
    3 -> Ok(LowConfidence)
    4 -> Ok(Uncertain)
    5 -> Ok(Contradicted)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// KnowledgeType
// ===========================================================================

/// Knowledge entry types.
/// 
/// Matches `KnowledgeType` in `NeurosymABI.Types`.
pub type KnowledgeType {
  /// Axiom (tag 0).
  Axiom
  /// Learned (tag 1).
  Learned
  /// Inferred (tag 2).
  Inferred
  /// Grounded (tag 3).
  Grounded
  /// Hypothetical (tag 4).
  Hypothetical
  /// Retracted (tag 5).
  Retracted
}

/// Convert a `KnowledgeType` to its C-ABI tag value.
pub fn knowledge_type_to_int(value: KnowledgeType) -> Int {
  case value {
    Axiom -> 0
    Learned -> 1
    Inferred -> 2
    Grounded -> 3
    Hypothetical -> 4
    Retracted -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn knowledge_type_from_int(tag: Int) -> Result(KnowledgeType, Nil) {
  case tag {
    0 -> Ok(Axiom)
    1 -> Ok(Learned)
    2 -> Ok(Inferred)
    3 -> Ok(Grounded)
    4 -> Ok(Hypothetical)
    5 -> Ok(Retracted)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NeurosymState
// ===========================================================================

/// Neurosymbolic engine states.
/// 
/// Matches `NeurosymState` in `NeurosymABI.Types`.
pub type NeurosymState {
  /// Idle (tag 0).
  Idle
  /// Ready (tag 1).
  Ready
  /// Inferring (tag 2).
  Inferring
  /// Reasoning (tag 3).
  Reasoning
  /// Fusing (tag 4).
  Fusing
  /// Shutdown (tag 5).
  Shutdown
}

/// Convert a `NeurosymState` to its C-ABI tag value.
pub fn neurosym_state_to_int(value: NeurosymState) -> Int {
  case value {
    Idle -> 0
    Ready -> 1
    Inferring -> 2
    Reasoning -> 3
    Fusing -> 4
    Shutdown -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn neurosym_state_from_int(tag: Int) -> Result(NeurosymState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Ready)
    2 -> Ok(Inferring)
    3 -> Ok(Reasoning)
    4 -> Ok(Fusing)
    5 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

