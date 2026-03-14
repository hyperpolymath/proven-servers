-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NeSy.Integration: Types for combining symbolic and neural results.
-- This module covers drift detection, result merging strategies, and
-- the protocol for negotiating between disagreeing layers.

module NeSy.Integration

import NeSy.Types

%default total

------------------------------------------------------------------------
-- MergeStrategy
-- How to combine symbolic and neural results when both are available.
------------------------------------------------------------------------

||| Strategy for merging results from symbolic and neural layers.
public export
data MergeStrategy : Type where
  ||| Symbolic result wins unconditionally (formal verification mode).
  SymbolicPrimacy   : MergeStrategy
  ||| Neural result wins unconditionally (generation mode).
  NeuralPrimacy     : MergeStrategy
  ||| Higher confidence wins (adaptive mode).
  ConfidenceWeighted : MergeStrategy
  ||| Both must agree or the result is rejected (consensus mode).
  Consensus         : MergeStrategy
  ||| Return both results with metadata, let the caller decide.
  DualReturn        : MergeStrategy
  ||| Symbolic constrains, neural fills within constraints (guided generation).
  ConstrainedGeneration : MergeStrategy

export
Show MergeStrategy where
  show SymbolicPrimacy       = "SymbolicPrimacy"
  show NeuralPrimacy         = "NeuralPrimacy"
  show ConfidenceWeighted    = "ConfidenceWeighted"
  show Consensus             = "Consensus"
  show DualReturn            = "DualReturn"
  show ConstrainedGeneration = "ConstrainedGeneration"

------------------------------------------------------------------------
-- DriftAction
-- What to do when symbolic-neural drift is detected.
------------------------------------------------------------------------

||| Action to take when drift between symbolic and neural layers is
||| detected. The choice depends on the severity and the application's
||| tolerance for divergence.
public export
data DriftAction : Type where
  ||| Log the drift but accept the neural result (monitoring only).
  LogAndAccept  : DriftAction
  ||| Flag the drift and require human review before accepting.
  FlagForReview : DriftAction
  ||| Reject the neural result, return only the symbolic result.
  RejectNeural  : DriftAction
  ||| Retry the neural inference with a different prompt/seed.
  RetryNeural   : DriftAction
  ||| Escalate to a higher-authority reasoner (e.g. larger model).
  Escalate      : DriftAction
  ||| Halt processing — catastrophic drift, safety stop.
  Halt          : DriftAction

export
Show DriftAction where
  show LogAndAccept  = "LogAndAccept"
  show FlagForReview = "FlagForReview"
  show RejectNeural  = "RejectNeural"
  show RetryNeural   = "RetryNeural"
  show Escalate      = "Escalate"
  show Halt          = "Halt"

------------------------------------------------------------------------
-- EmbeddingSpace
-- Which embedding space a neural representation lives in.
------------------------------------------------------------------------

||| The embedding space used for neural representations. Different
||| spaces have different distance metrics and composition rules.
public export
data EmbeddingSpace : Type where
  ||| Dense vector space (standard transformer embeddings).
  DenseVector     : EmbeddingSpace
  ||| Sparse vector space (TF-IDF, BM25-style).
  SparseVector    : EmbeddingSpace
  ||| Graph embedding (knowledge graph, node2vec).
  GraphEmbedding  : EmbeddingSpace
  ||| Hyperbolic embedding (for hierarchical structures).
  Hyperbolic      : EmbeddingSpace
  ||| Symbolic encoding (one-hot, categorical, no learned representation).
  SymbolicEncoding : EmbeddingSpace

export
Show EmbeddingSpace where
  show DenseVector      = "DenseVector"
  show SparseVector     = "SparseVector"
  show GraphEmbedding   = "GraphEmbedding"
  show Hyperbolic       = "Hyperbolic"
  show SymbolicEncoding = "SymbolicEncoding"

------------------------------------------------------------------------
-- GroundingStatus
-- Whether a neural prediction is grounded in symbolic facts.
------------------------------------------------------------------------

||| Whether a neural output has been grounded (connected to verifiable
||| symbolic facts). Ungrounded neural outputs are the primary source
||| of hallucination in neurosymbolic systems.
public export
data GroundingStatus : Type where
  ||| Fully grounded — every claim traces to a symbolic fact.
  FullyGrounded   : GroundingStatus
  ||| Partially grounded — some claims verified, some not.
  PartiallyGrounded : GroundingStatus
  ||| Ungrounded — no symbolic verification of neural claims.
  Ungrounded      : GroundingStatus
  ||| Grounding in progress — verification running asynchronously.
  GroundingPending : GroundingStatus
  ||| Grounding failed — symbolic layer could not verify claims.
  GroundingFailed  : GroundingStatus

export
Show GroundingStatus where
  show FullyGrounded     = "FullyGrounded"
  show PartiallyGrounded = "PartiallyGrounded"
  show Ungrounded        = "Ungrounded"
  show GroundingPending  = "GroundingPending"
  show GroundingFailed   = "GroundingFailed"
