// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// NeSy protocol types for proven-servers.

/** ReasoningMode matching the Idris2 ABI tags. */
export const ReasoningMode = Object.freeze({
  SYMBOLIC: 0,
  NEURAL: 1,
  SYM_TO_NEURAL: 2,
  NEURAL_TO_SYM: 3,
  ENSEMBLE: 4,
  CASCADE: 5,
});

/** ProofStatus matching the Idris2 ABI tags. */
export const ProofStatus = Object.freeze({
  PENDING: 0,
  ATTEMPTING: 1,
  PROVED: 2,
  FAILED: 3,
  ASSUMED: 4,
  VACUOUS: 5,
});

/** ConstraintKind matching the Idris2 ABI tags. */
export const ConstraintKind = Object.freeze({
  TYPE_EQUALITY: 0,
  SUBTYPE: 1,
  LINEARITY: 2,
  TERMINATION: 3,
  TOTALITY: 4,
  INVARIANT: 5,
  REFINEMENT: 6,
  DEPENDENT_INDEX: 7,
});

/** NeuralBackend matching the Idris2 ABI tags. */
export const NeuralBackend = Object.freeze({
  LOCAL_MODEL: 0,
  CLAUDE: 1,
  GEMINI: 2,
  MISTRAL: 3,
  GPT: 4,
  CUSTOM_NEURAL: 5,
});

/** Confidence matching the Idris2 ABI tags. */
export const Confidence = Object.freeze({
  VERIFIED: 0,
  HIGH_NEURAL: 1,
  MEDIUM_NEURAL: 2,
  LOW_NEURAL: 3,
  UNKNOWN: 4,
  CONTRADICTED: 5,
});

/** DriftKind matching the Idris2 ABI tags. */
export const DriftKind = Object.freeze({
  NO_DRIFT: 0,
  SEMANTIC_DRIFT: 1,
  CONFIDENCE_DRIFT: 2,
  FACTUAL_DRIFT: 3,
  TEMPORAL_DRIFT: 4,
  CATASTROPHIC_DRIFT: 5,
});

/** NeSyState matching the Idris2 ABI tags. */
export const NeSyState = Object.freeze({
  IDLE: 0,
  READY: 1,
  REASONING: 2,
  VERIFYING: 3,
  DRIFT: 4,
  SHUTDOWN: 5,
});
