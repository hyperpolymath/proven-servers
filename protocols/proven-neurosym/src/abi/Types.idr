-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NeurosymABI.Types: C-ABI-compatible numeric representations of Neurosym types.
--
-- Maps every constructor of the core Neurosym sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/neurosym.zig) exactly.
--
-- Types covered:
--   InferenceMode    (4 constructors, tags 0-3)
--   SymbolicOp       (6 constructors, tags 0-5)
--   NeuralOp         (6 constructors, tags 0-5)
--   FusionStrategy   (5 constructors, tags 0-4)
--   ConfidenceLevel  (6 constructors, tags 0-5)
--   KnowledgeType    (6 constructors, tags 0-5)

module NeurosymABI.Types

import Neurosym.Types

%default total

---------------------------------------------------------------------------
-- InferenceMode (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
inferenceModeToTag : InferenceMode -> Bits8
inferenceModeToTag Neural   = 0
inferenceModeToTag Symbolic = 1
inferenceModeToTag Hybrid   = 2
inferenceModeToTag Cascade  = 3

public export
tagToInferenceMode : Bits8 -> Maybe InferenceMode
tagToInferenceMode 0 = Just Neural
tagToInferenceMode 1 = Just Symbolic
tagToInferenceMode 2 = Just Hybrid
tagToInferenceMode 3 = Just Cascade
tagToInferenceMode _ = Nothing

public export
inferenceModeRoundtrip : (m : InferenceMode) -> tagToInferenceMode (inferenceModeToTag m) = Just m
inferenceModeRoundtrip Neural   = Refl
inferenceModeRoundtrip Symbolic = Refl
inferenceModeRoundtrip Hybrid   = Refl
inferenceModeRoundtrip Cascade  = Refl

---------------------------------------------------------------------------
-- SymbolicOp (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
symbolicOpToTag : SymbolicOp -> Bits8
symbolicOpToTag Unify     = 0
symbolicOpToTag Resolve   = 1
symbolicOpToTag Rewrite   = 2
symbolicOpToTag Prove     = 3
symbolicOpToTag Search    = 4
symbolicOpToTag Constrain = 5

public export
tagToSymbolicOp : Bits8 -> Maybe SymbolicOp
tagToSymbolicOp 0 = Just Unify
tagToSymbolicOp 1 = Just Resolve
tagToSymbolicOp 2 = Just Rewrite
tagToSymbolicOp 3 = Just Prove
tagToSymbolicOp 4 = Just Search
tagToSymbolicOp 5 = Just Constrain
tagToSymbolicOp _ = Nothing

public export
symbolicOpRoundtrip : (s : SymbolicOp) -> tagToSymbolicOp (symbolicOpToTag s) = Just s
symbolicOpRoundtrip Unify     = Refl
symbolicOpRoundtrip Resolve   = Refl
symbolicOpRoundtrip Rewrite   = Refl
symbolicOpRoundtrip Prove     = Refl
symbolicOpRoundtrip Search    = Refl
symbolicOpRoundtrip Constrain = Refl

---------------------------------------------------------------------------
-- NeuralOp (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
neuralOpToTag : NeuralOp -> Bits8
neuralOpToTag Embed    = 0
neuralOpToTag Classify = 1
neuralOpToTag Generate = 2
neuralOpToTag Attend   = 3
neuralOpToTag Retrieve = 4
neuralOpToTag Finetune = 5

public export
tagToNeuralOp : Bits8 -> Maybe NeuralOp
tagToNeuralOp 0 = Just Embed
tagToNeuralOp 1 = Just Classify
tagToNeuralOp 2 = Just Generate
tagToNeuralOp 3 = Just Attend
tagToNeuralOp 4 = Just Retrieve
tagToNeuralOp 5 = Just Finetune
tagToNeuralOp _ = Nothing

public export
neuralOpRoundtrip : (n : NeuralOp) -> tagToNeuralOp (neuralOpToTag n) = Just n
neuralOpRoundtrip Embed    = Refl
neuralOpRoundtrip Classify = Refl
neuralOpRoundtrip Generate = Refl
neuralOpRoundtrip Attend   = Refl
neuralOpRoundtrip Retrieve = Refl
neuralOpRoundtrip Finetune = Refl

---------------------------------------------------------------------------
-- FusionStrategy (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
fusionStrategyToTag : FusionStrategy -> Bits8
fusionStrategyToTag NeuralThenSymbolic = 0
fusionStrategyToTag SymbolicThenNeural = 1
fusionStrategyToTag Parallel           = 2
fusionStrategyToTag Iterative          = 3
fusionStrategyToTag Gated              = 4

public export
tagToFusionStrategy : Bits8 -> Maybe FusionStrategy
tagToFusionStrategy 0 = Just NeuralThenSymbolic
tagToFusionStrategy 1 = Just SymbolicThenNeural
tagToFusionStrategy 2 = Just Parallel
tagToFusionStrategy 3 = Just Iterative
tagToFusionStrategy 4 = Just Gated
tagToFusionStrategy _ = Nothing

public export
fusionStrategyRoundtrip : (f : FusionStrategy) -> tagToFusionStrategy (fusionStrategyToTag f) = Just f
fusionStrategyRoundtrip NeuralThenSymbolic = Refl
fusionStrategyRoundtrip SymbolicThenNeural = Refl
fusionStrategyRoundtrip Parallel           = Refl
fusionStrategyRoundtrip Iterative          = Refl
fusionStrategyRoundtrip Gated              = Refl

---------------------------------------------------------------------------
-- ConfidenceLevel (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
confidenceLevelToTag : ConfidenceLevel -> Bits8
confidenceLevelToTag Proven         = 0
confidenceLevelToTag HighConfidence = 1
confidenceLevelToTag Moderate       = 2
confidenceLevelToTag LowConfidence  = 3
confidenceLevelToTag Uncertain      = 4
confidenceLevelToTag Contradicted   = 5

public export
tagToConfidenceLevel : Bits8 -> Maybe ConfidenceLevel
tagToConfidenceLevel 0 = Just Proven
tagToConfidenceLevel 1 = Just HighConfidence
tagToConfidenceLevel 2 = Just Moderate
tagToConfidenceLevel 3 = Just LowConfidence
tagToConfidenceLevel 4 = Just Uncertain
tagToConfidenceLevel 5 = Just Contradicted
tagToConfidenceLevel _ = Nothing

public export
confidenceLevelRoundtrip : (c : ConfidenceLevel) -> tagToConfidenceLevel (confidenceLevelToTag c) = Just c
confidenceLevelRoundtrip Proven         = Refl
confidenceLevelRoundtrip HighConfidence = Refl
confidenceLevelRoundtrip Moderate       = Refl
confidenceLevelRoundtrip LowConfidence  = Refl
confidenceLevelRoundtrip Uncertain      = Refl
confidenceLevelRoundtrip Contradicted   = Refl

---------------------------------------------------------------------------
-- KnowledgeType (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
knowledgeTypeToTag : KnowledgeType -> Bits8
knowledgeTypeToTag Axiom        = 0
knowledgeTypeToTag Learned      = 1
knowledgeTypeToTag Inferred     = 2
knowledgeTypeToTag Grounded     = 3
knowledgeTypeToTag Hypothetical = 4
knowledgeTypeToTag Retracted    = 5

public export
tagToKnowledgeType : Bits8 -> Maybe KnowledgeType
tagToKnowledgeType 0 = Just Axiom
tagToKnowledgeType 1 = Just Learned
tagToKnowledgeType 2 = Just Inferred
tagToKnowledgeType 3 = Just Grounded
tagToKnowledgeType 4 = Just Hypothetical
tagToKnowledgeType 5 = Just Retracted
tagToKnowledgeType _ = Nothing

public export
knowledgeTypeRoundtrip : (k : KnowledgeType) -> tagToKnowledgeType (knowledgeTypeToTag k) = Just k
knowledgeTypeRoundtrip Axiom        = Refl
knowledgeTypeRoundtrip Learned      = Refl
knowledgeTypeRoundtrip Inferred     = Refl
knowledgeTypeRoundtrip Grounded     = Refl
knowledgeTypeRoundtrip Hypothetical = Refl
knowledgeTypeRoundtrip Retracted    = Refl

---------------------------------------------------------------------------
-- NeurosymState: Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| Neurosym server lifecycle states used by the FFI layer.
public export
data NeurosymState : Type where
  ||| Not initialised.
  NSMIdle       : NeurosymState
  ||| Subsystems loaded, ready for inference.
  NSMReady      : NeurosymState
  ||| Neural subsystem processing.
  NSMInferring  : NeurosymState
  ||| Symbolic subsystem processing.
  NSMReasoning  : NeurosymState
  ||| Fusion of neural + symbolic results in progress.
  NSMFusing     : NeurosymState
  ||| Shutting down.
  NSMShutdown   : NeurosymState

public export
Eq NeurosymState where
  NSMIdle      == NSMIdle      = True
  NSMReady     == NSMReady     = True
  NSMInferring == NSMInferring = True
  NSMReasoning == NSMReasoning = True
  NSMFusing    == NSMFusing    = True
  NSMShutdown  == NSMShutdown  = True
  _            == _            = False

public export
Show NeurosymState where
  show NSMIdle      = "Idle"
  show NSMReady     = "Ready"
  show NSMInferring = "Inferring"
  show NSMReasoning = "Reasoning"
  show NSMFusing    = "Fusing"
  show NSMShutdown  = "Shutdown"

public export
neurosymStateToTag : NeurosymState -> Bits8
neurosymStateToTag NSMIdle      = 0
neurosymStateToTag NSMReady     = 1
neurosymStateToTag NSMInferring = 2
neurosymStateToTag NSMReasoning = 3
neurosymStateToTag NSMFusing    = 4
neurosymStateToTag NSMShutdown  = 5

public export
tagToNeurosymState : Bits8 -> Maybe NeurosymState
tagToNeurosymState 0 = Just NSMIdle
tagToNeurosymState 1 = Just NSMReady
tagToNeurosymState 2 = Just NSMInferring
tagToNeurosymState 3 = Just NSMReasoning
tagToNeurosymState 4 = Just NSMFusing
tagToNeurosymState 5 = Just NSMShutdown
tagToNeurosymState _ = Nothing

public export
neurosymStateRoundtrip : (s : NeurosymState) -> tagToNeurosymState (neurosymStateToTag s) = Just s
neurosymStateRoundtrip NSMIdle      = Refl
neurosymStateRoundtrip NSMReady     = Refl
neurosymStateRoundtrip NSMInferring = Refl
neurosymStateRoundtrip NSMReasoning = Refl
neurosymStateRoundtrip NSMFusing    = Refl
neurosymStateRoundtrip NSMShutdown  = Refl
