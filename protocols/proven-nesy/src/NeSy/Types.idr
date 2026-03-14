-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NeSy.Types: Core protocol types for the neurosymbolic integration server.
-- All types are closed sum types with total Show instances.
--
-- The neurosymbolic paradigm combines two reasoning traditions:
--   Symbolic: logic, proofs, type systems, constraint solving, formal verification
--   Neural:   embeddings, gradient descent, generation, pattern recognition
--
-- This server mediates between them, providing a verified protocol for
-- requesting reasoning, combining results, and maintaining proof obligations.

module NeSy.Types

%default total

------------------------------------------------------------------------
-- ReasoningMode
-- Which reasoning paradigm to use for a given query.
------------------------------------------------------------------------

||| The reasoning paradigm to apply. Neurosymbolic systems blend these
||| at query time, choosing the best approach for each sub-problem.
public export
data ReasoningMode : Type where
  ||| Pure symbolic reasoning — theorem proving, SAT/SMT, constraint solving.
  Symbolic   : ReasoningMode
  ||| Pure neural reasoning — embedding lookup, generation, classification.
  Neural     : ReasoningMode
  ||| Hybrid: symbolic decomposes the problem, neural handles sub-goals.
  SymToNeural : ReasoningMode
  ||| Hybrid: neural proposes candidates, symbolic verifies them.
  NeuralToSym : ReasoningMode
  ||| Ensemble: both run in parallel, results merged by confidence.
  Ensemble   : ReasoningMode
  ||| Cascade: try symbolic first, fall back to neural on timeout.
  Cascade    : ReasoningMode

export
Show ReasoningMode where
  show Symbolic    = "Symbolic"
  show Neural      = "Neural"
  show SymToNeural = "SymToNeural"
  show NeuralToSym = "NeuralToSym"
  show Ensemble    = "Ensemble"
  show Cascade     = "Cascade"

------------------------------------------------------------------------
-- ProofStatus
-- The state of a proof obligation in the symbolic layer.
------------------------------------------------------------------------

||| Lifecycle state of a proof obligation. Proof obligations arise when
||| a symbolic constraint must be discharged before a result is trusted.
public export
data ProofStatus : Type where
  ||| Obligation has been stated but not yet attempted.
  Pending    : ProofStatus
  ||| A proof attempt is in progress (e.g. SMT solver running).
  Attempting : ProofStatus
  ||| Proof has been found and verified.
  Proved     : ProofStatus
  ||| Proof attempt failed — the obligation is unresolved.
  Failed     : ProofStatus
  ||| Proof was discharged by assumption (trusted but not verified).
  ||| This is the neurosymbolic equivalent of believe_me — track carefully.
  Assumed    : ProofStatus
  ||| Obligation was determined to be vacuously true.
  Vacuous    : ProofStatus

export
Show ProofStatus where
  show Pending    = "Pending"
  show Attempting = "Attempting"
  show Proved     = "Proved"
  show Failed     = "Failed"
  show Assumed    = "Assumed"
  show Vacuous    = "Vacuous"

------------------------------------------------------------------------
-- ConstraintKind
-- The type of symbolic constraint being imposed.
------------------------------------------------------------------------

||| Classification of symbolic constraints that the reasoning engine
||| can impose, check, or propagate.
public export
data ConstraintKind : Type where
  ||| Type equality constraint (a ~ b).
  TypeEquality   : ConstraintKind
  ||| Subtyping constraint (a <: b).
  Subtype        : ConstraintKind
  ||| Linear resource usage constraint (used exactly once).
  Linearity      : ConstraintKind
  ||| Termination obligation (this function terminates).
  Termination    : ConstraintKind
  ||| Totality obligation (all cases covered).
  Totality       : ConstraintKind
  ||| Invariant preservation (property holds across mutation).
  Invariant      : ConstraintKind
  ||| Refinement type predicate (value satisfies predicate).
  Refinement     : ConstraintKind
  ||| Dependent type index constraint (index matches expected value).
  DependentIndex : ConstraintKind

export
Show ConstraintKind where
  show TypeEquality   = "TypeEquality"
  show Subtype        = "Subtype"
  show Linearity      = "Linearity"
  show Termination    = "Termination"
  show Totality       = "Totality"
  show Invariant      = "Invariant"
  show Refinement     = "Refinement"
  show DependentIndex = "DependentIndex"

------------------------------------------------------------------------
-- NeuralBackend
-- Which neural inference engine to use.
------------------------------------------------------------------------

||| The neural backend providing inference. Different backends have
||| different capabilities, latencies, and trust levels.
public export
data NeuralBackend : Type where
  ||| Local model running on-device (highest trust, lowest latency).
  LocalModel   : NeuralBackend
  ||| Claude API (Anthropic).
  Claude       : NeuralBackend
  ||| Gemini API (Google).
  Gemini       : NeuralBackend
  ||| Mistral API.
  Mistral      : NeuralBackend
  ||| GPT API (OpenAI).
  GPT          : NeuralBackend
  ||| Custom endpoint (user-configured).
  CustomNeural : NeuralBackend

export
Show NeuralBackend where
  show LocalModel   = "LocalModel"
  show Claude       = "Claude"
  show Gemini       = "Gemini"
  show Mistral      = "Mistral"
  show GPT          = "GPT"
  show CustomNeural = "CustomNeural"

------------------------------------------------------------------------
-- Confidence
-- Confidence level in a neurosymbolic result.
------------------------------------------------------------------------

||| Confidence classification for a neurosymbolic result.
||| Symbolic results are always Verified or Failed (binary).
||| Neural results use the gradient levels.
||| Hybrid results inherit the lower of the two confidences.
public export
data Confidence : Type where
  ||| Formally verified — proof exists and has been checked.
  Verified    : Confidence
  ||| High confidence neural prediction (>95% model confidence).
  HighNeural  : Confidence
  ||| Medium confidence neural prediction (70-95%).
  MediumNeural : Confidence
  ||| Low confidence neural prediction (<70%).
  LowNeural   : Confidence
  ||| Unknown — no confidence assessment available.
  Unknown     : Confidence
  ||| Contradicted — symbolic and neural disagree.
  Contradicted : Confidence

export
Show Confidence where
  show Verified      = "Verified"
  show HighNeural    = "HighNeural"
  show MediumNeural  = "MediumNeural"
  show LowNeural     = "LowNeural"
  show Unknown       = "Unknown"
  show Contradicted  = "Contradicted"

------------------------------------------------------------------------
-- DriftKind
-- How symbolic and neural results can diverge.
------------------------------------------------------------------------

||| Classification of divergence between symbolic and neural layers.
||| Drift detection is the core safety mechanism of neurosymbolic systems.
public export
data DriftKind : Type where
  ||| No drift — symbolic and neural agree.
  NoDrift        : DriftKind
  ||| Semantic drift — same conclusion, different reasoning paths.
  SemanticDrift  : DriftKind
  ||| Confidence drift — agreement on result, disagreement on certainty.
  ConfidenceDrift : DriftKind
  ||| Factual drift — different conclusions about the same query.
  FactualDrift   : DriftKind
  ||| Temporal drift — results diverge over time (model staleness).
  TemporalDrift  : DriftKind
  ||| Catastrophic drift — neural output violates a proven invariant.
  CatastrophicDrift : DriftKind

export
Show DriftKind where
  show NoDrift           = "NoDrift"
  show SemanticDrift     = "SemanticDrift"
  show ConfidenceDrift   = "ConfidenceDrift"
  show FactualDrift      = "FactualDrift"
  show TemporalDrift     = "TemporalDrift"
  show CatastrophicDrift = "CatastrophicDrift"
