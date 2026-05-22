// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Neurosym protocol types for proven-servers.

/** InferenceMode matching the Idris2 ABI tags. */
export const InferenceMode = Object.freeze({
  NEURAL: 0,
  SYMBOLIC: 1,
  HYBRID: 2,
  CASCADE: 3,
});

/** SymbolicOp matching the Idris2 ABI tags. */
export const SymbolicOp = Object.freeze({
  UNIFY: 0,
  RESOLVE: 1,
  REWRITE: 2,
  PROVE: 3,
  SEARCH: 4,
  CONSTRAIN: 5,
});

/** NeuralOp matching the Idris2 ABI tags. */
export const NeuralOp = Object.freeze({
  EMBED: 0,
  CLASSIFY: 1,
  GENERATE: 2,
  ATTEND: 3,
  RETRIEVE: 4,
  FINETUNE: 5,
});

/** FusionStrategy matching the Idris2 ABI tags. */
export const FusionStrategy = Object.freeze({
  NEURAL_THEN_SYMBOLIC: 0,
  SYMBOLIC_THEN_NEURAL: 1,
  PARALLEL: 2,
  ITERATIVE: 3,
  GATED: 4,
});

/** ConfidenceLevel matching the Idris2 ABI tags. */
export const ConfidenceLevel = Object.freeze({
  PROVEN: 0,
  HIGH_CONFIDENCE: 1,
  MODERATE: 2,
  LOW_CONFIDENCE: 3,
  UNCERTAIN: 4,
  CONTRADICTED: 5,
});

/** KnowledgeType matching the Idris2 ABI tags. */
export const KnowledgeType = Object.freeze({
  AXIOM: 0,
  LEARNED: 1,
  INFERRED: 2,
  GROUNDED: 3,
  HYPOTHETICAL: 4,
  RETRACTED: 5,
});

/** NeurosymState matching the Idris2 ABI tags. */
export const NeurosymState = Object.freeze({
  IDLE: 0,
  READY: 1,
  INFERRING: 2,
  REASONING: 3,
  FUSING: 4,
  SHUTDOWN: 5,
});
