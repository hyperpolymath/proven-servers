-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NeSyABI.Types: C-ABI-compatible numeric representations of NeSy types.
--
-- Maps every constructor of the core NeSy sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/nesy.zig) exactly.
--
-- Types covered:
--   ReasoningMode  (6 constructors, tags 0-5)
--   ProofStatus    (6 constructors, tags 0-5)
--   ConstraintKind (8 constructors, tags 0-7)
--   NeuralBackend  (6 constructors, tags 0-5)
--   Confidence     (6 constructors, tags 0-5)
--   DriftKind      (6 constructors, tags 0-5)

module NeSyABI.Types

import NeSy.Types

%default total

---------------------------------------------------------------------------
-- ReasoningMode (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
reasoningModeToTag : ReasoningMode -> Bits8
reasoningModeToTag Symbolic    = 0
reasoningModeToTag Neural      = 1
reasoningModeToTag SymToNeural = 2
reasoningModeToTag NeuralToSym = 3
reasoningModeToTag Ensemble    = 4
reasoningModeToTag Cascade     = 5

public export
tagToReasoningMode : Bits8 -> Maybe ReasoningMode
tagToReasoningMode 0 = Just Symbolic
tagToReasoningMode 1 = Just Neural
tagToReasoningMode 2 = Just SymToNeural
tagToReasoningMode 3 = Just NeuralToSym
tagToReasoningMode 4 = Just Ensemble
tagToReasoningMode 5 = Just Cascade
tagToReasoningMode _ = Nothing

public export
reasoningModeRoundtrip : (r : ReasoningMode) -> tagToReasoningMode (reasoningModeToTag r) = Just r
reasoningModeRoundtrip Symbolic    = Refl
reasoningModeRoundtrip Neural      = Refl
reasoningModeRoundtrip SymToNeural = Refl
reasoningModeRoundtrip NeuralToSym = Refl
reasoningModeRoundtrip Ensemble    = Refl
reasoningModeRoundtrip Cascade     = Refl

---------------------------------------------------------------------------
-- ProofStatus (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
proofStatusToTag : ProofStatus -> Bits8
proofStatusToTag Pending    = 0
proofStatusToTag Attempting = 1
proofStatusToTag Proved     = 2
proofStatusToTag Failed     = 3
proofStatusToTag Assumed    = 4
proofStatusToTag Vacuous    = 5

public export
tagToProofStatus : Bits8 -> Maybe ProofStatus
tagToProofStatus 0 = Just Pending
tagToProofStatus 1 = Just Attempting
tagToProofStatus 2 = Just Proved
tagToProofStatus 3 = Just Failed
tagToProofStatus 4 = Just Assumed
tagToProofStatus 5 = Just Vacuous
tagToProofStatus _ = Nothing

public export
proofStatusRoundtrip : (p : ProofStatus) -> tagToProofStatus (proofStatusToTag p) = Just p
proofStatusRoundtrip Pending    = Refl
proofStatusRoundtrip Attempting = Refl
proofStatusRoundtrip Proved     = Refl
proofStatusRoundtrip Failed     = Refl
proofStatusRoundtrip Assumed    = Refl
proofStatusRoundtrip Vacuous    = Refl

---------------------------------------------------------------------------
-- ConstraintKind (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
constraintKindToTag : ConstraintKind -> Bits8
constraintKindToTag TypeEquality   = 0
constraintKindToTag Subtype        = 1
constraintKindToTag Linearity      = 2
constraintKindToTag Termination    = 3
constraintKindToTag Totality       = 4
constraintKindToTag Invariant      = 5
constraintKindToTag Refinement     = 6
constraintKindToTag DependentIndex = 7

public export
tagToConstraintKind : Bits8 -> Maybe ConstraintKind
tagToConstraintKind 0 = Just TypeEquality
tagToConstraintKind 1 = Just Subtype
tagToConstraintKind 2 = Just Linearity
tagToConstraintKind 3 = Just Termination
tagToConstraintKind 4 = Just Totality
tagToConstraintKind 5 = Just Invariant
tagToConstraintKind 6 = Just Refinement
tagToConstraintKind 7 = Just DependentIndex
tagToConstraintKind _ = Nothing

public export
constraintKindRoundtrip : (c : ConstraintKind) -> tagToConstraintKind (constraintKindToTag c) = Just c
constraintKindRoundtrip TypeEquality   = Refl
constraintKindRoundtrip Subtype        = Refl
constraintKindRoundtrip Linearity      = Refl
constraintKindRoundtrip Termination    = Refl
constraintKindRoundtrip Totality       = Refl
constraintKindRoundtrip Invariant      = Refl
constraintKindRoundtrip Refinement     = Refl
constraintKindRoundtrip DependentIndex = Refl

---------------------------------------------------------------------------
-- NeuralBackend (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
neuralBackendToTag : NeuralBackend -> Bits8
neuralBackendToTag LocalModel   = 0
neuralBackendToTag Claude       = 1
neuralBackendToTag Gemini       = 2
neuralBackendToTag Mistral      = 3
neuralBackendToTag GPT          = 4
neuralBackendToTag CustomNeural = 5

public export
tagToNeuralBackend : Bits8 -> Maybe NeuralBackend
tagToNeuralBackend 0 = Just LocalModel
tagToNeuralBackend 1 = Just Claude
tagToNeuralBackend 2 = Just Gemini
tagToNeuralBackend 3 = Just Mistral
tagToNeuralBackend 4 = Just GPT
tagToNeuralBackend 5 = Just CustomNeural
tagToNeuralBackend _ = Nothing

public export
neuralBackendRoundtrip : (n : NeuralBackend) -> tagToNeuralBackend (neuralBackendToTag n) = Just n
neuralBackendRoundtrip LocalModel   = Refl
neuralBackendRoundtrip Claude       = Refl
neuralBackendRoundtrip Gemini       = Refl
neuralBackendRoundtrip Mistral      = Refl
neuralBackendRoundtrip GPT          = Refl
neuralBackendRoundtrip CustomNeural = Refl

---------------------------------------------------------------------------
-- Confidence (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
confidenceToTag : Confidence -> Bits8
confidenceToTag Verified     = 0
confidenceToTag HighNeural   = 1
confidenceToTag MediumNeural = 2
confidenceToTag LowNeural    = 3
confidenceToTag Unknown      = 4
confidenceToTag Contradicted = 5

public export
tagToConfidence : Bits8 -> Maybe Confidence
tagToConfidence 0 = Just Verified
tagToConfidence 1 = Just HighNeural
tagToConfidence 2 = Just MediumNeural
tagToConfidence 3 = Just LowNeural
tagToConfidence 4 = Just Unknown
tagToConfidence 5 = Just Contradicted
tagToConfidence _ = Nothing

public export
confidenceRoundtrip : (c : Confidence) -> tagToConfidence (confidenceToTag c) = Just c
confidenceRoundtrip Verified     = Refl
confidenceRoundtrip HighNeural   = Refl
confidenceRoundtrip MediumNeural = Refl
confidenceRoundtrip LowNeural    = Refl
confidenceRoundtrip Unknown      = Refl
confidenceRoundtrip Contradicted = Refl

---------------------------------------------------------------------------
-- DriftKind (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
driftKindToTag : DriftKind -> Bits8
driftKindToTag NoDrift           = 0
driftKindToTag SemanticDrift     = 1
driftKindToTag ConfidenceDrift   = 2
driftKindToTag FactualDrift      = 3
driftKindToTag TemporalDrift     = 4
driftKindToTag CatastrophicDrift = 5

public export
tagToDriftKind : Bits8 -> Maybe DriftKind
tagToDriftKind 0 = Just NoDrift
tagToDriftKind 1 = Just SemanticDrift
tagToDriftKind 2 = Just ConfidenceDrift
tagToDriftKind 3 = Just FactualDrift
tagToDriftKind 4 = Just TemporalDrift
tagToDriftKind 5 = Just CatastrophicDrift
tagToDriftKind _ = Nothing

public export
driftKindRoundtrip : (d : DriftKind) -> tagToDriftKind (driftKindToTag d) = Just d
driftKindRoundtrip NoDrift           = Refl
driftKindRoundtrip SemanticDrift     = Refl
driftKindRoundtrip ConfidenceDrift   = Refl
driftKindRoundtrip FactualDrift      = Refl
driftKindRoundtrip TemporalDrift     = Refl
driftKindRoundtrip CatastrophicDrift = Refl

---------------------------------------------------------------------------
-- NeSyState: Composite lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| NeSy server lifecycle states used by the FFI layer.
public export
data NeSyState : Type where
  ||| Not initialised.
  NSIdle       : NeSyState
  ||| Backend configured, ready to accept queries.
  NSReady      : NeSyState
  ||| Processing a reasoning query.
  NSReasoning  : NeSyState
  ||| Verifying a proof obligation.
  NSVerifying  : NeSyState
  ||| Drift detected between neural and symbolic layers.
  NSDrift      : NeSyState
  ||| Shutting down.
  NSShutdown   : NeSyState

public export
Eq NeSyState where
  NSIdle      == NSIdle      = True
  NSReady     == NSReady     = True
  NSReasoning == NSReasoning = True
  NSVerifying == NSVerifying = True
  NSDrift     == NSDrift     = True
  NSShutdown  == NSShutdown  = True
  _           == _           = False

public export
Show NeSyState where
  show NSIdle      = "Idle"
  show NSReady     = "Ready"
  show NSReasoning = "Reasoning"
  show NSVerifying = "Verifying"
  show NSDrift     = "Drift"
  show NSShutdown  = "Shutdown"

public export
nesyStateToTag : NeSyState -> Bits8
nesyStateToTag NSIdle      = 0
nesyStateToTag NSReady     = 1
nesyStateToTag NSReasoning = 2
nesyStateToTag NSVerifying = 3
nesyStateToTag NSDrift     = 4
nesyStateToTag NSShutdown  = 5

public export
tagToNeSyState : Bits8 -> Maybe NeSyState
tagToNeSyState 0 = Just NSIdle
tagToNeSyState 1 = Just NSReady
tagToNeSyState 2 = Just NSReasoning
tagToNeSyState 3 = Just NSVerifying
tagToNeSyState 4 = Just NSDrift
tagToNeSyState 5 = Just NSShutdown
tagToNeSyState _ = Nothing

public export
nesyStateRoundtrip : (s : NeSyState) -> tagToNeSyState (nesyStateToTag s) = Just s
nesyStateRoundtrip NSIdle      = Refl
nesyStateRoundtrip NSReady     = Refl
nesyStateRoundtrip NSReasoning = Refl
nesyStateRoundtrip NSVerifying = Refl
nesyStateRoundtrip NSDrift     = Refl
nesyStateRoundtrip NSShutdown  = Refl
