/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * nesy_ffi.h: C header for the proven-nesy FFI.
 * Generated from Idris2 ABI definitions, implemented in Zig.
 * This header is consumed by the V-lang triple adapter and
 * any other language binding that needs C ABI compatibility.
 */

#ifndef NESY_FFI_H
#define NESY_FFI_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/* --- ReasoningMode (6 variants) --- */
typedef enum {
    REASONING_MODE_SYMBOLIC       = 0,
    REASONING_MODE_NEURAL         = 1,
    REASONING_MODE_SYM_TO_NEURAL  = 2,
    REASONING_MODE_NEURAL_TO_SYM  = 3,
    REASONING_MODE_ENSEMBLE       = 4,
    REASONING_MODE_CASCADE        = 5
} ReasoningMode;

/* --- ProofStatus (6 variants) --- */
typedef enum {
    PROOF_STATUS_PENDING    = 0,
    PROOF_STATUS_ATTEMPTING = 1,
    PROOF_STATUS_PROVED     = 2,
    PROOF_STATUS_FAILED     = 3,
    PROOF_STATUS_ASSUMED    = 4,
    PROOF_STATUS_VACUOUS    = 5
} ProofStatus;

/* --- ConstraintKind (8 variants) --- */
typedef enum {
    CONSTRAINT_TYPE_EQUALITY   = 0,
    CONSTRAINT_SUBTYPE         = 1,
    CONSTRAINT_LINEARITY       = 2,
    CONSTRAINT_TERMINATION     = 3,
    CONSTRAINT_TOTALITY        = 4,
    CONSTRAINT_INVARIANT       = 5,
    CONSTRAINT_REFINEMENT      = 6,
    CONSTRAINT_DEPENDENT_INDEX = 7
} ConstraintKind;

/* --- NeuralBackend (6 variants) --- */
typedef enum {
    NEURAL_BACKEND_LOCAL_MODEL    = 0,
    NEURAL_BACKEND_CLAUDE         = 1,
    NEURAL_BACKEND_GEMINI         = 2,
    NEURAL_BACKEND_MISTRAL        = 3,
    NEURAL_BACKEND_GPT            = 4,
    NEURAL_BACKEND_CUSTOM_NEURAL  = 5
} NeuralBackend;

/* --- Confidence (6 variants) --- */
typedef enum {
    CONFIDENCE_VERIFIED      = 0,
    CONFIDENCE_HIGH_NEURAL   = 1,
    CONFIDENCE_MEDIUM_NEURAL = 2,
    CONFIDENCE_LOW_NEURAL    = 3,
    CONFIDENCE_UNKNOWN       = 4,
    CONFIDENCE_CONTRADICTED  = 5
} Confidence;

/* --- DriftKind (6 variants) --- */
typedef enum {
    DRIFT_NONE         = 0,
    DRIFT_SEMANTIC     = 1,
    DRIFT_CONFIDENCE   = 2,
    DRIFT_FACTUAL      = 3,
    DRIFT_TEMPORAL     = 4,
    DRIFT_CATASTROPHIC = 5
} DriftKind;

/* --- MergeStrategy (6 variants) --- */
typedef enum {
    MERGE_SYMBOLIC_PRIMACY       = 0,
    MERGE_NEURAL_PRIMACY         = 1,
    MERGE_CONFIDENCE_WEIGHTED    = 2,
    MERGE_CONSENSUS              = 3,
    MERGE_DUAL_RETURN            = 4,
    MERGE_CONSTRAINED_GENERATION = 5
} MergeStrategy;

/* --- DriftAction (6 variants) --- */
typedef enum {
    DRIFT_ACTION_LOG_AND_ACCEPT  = 0,
    DRIFT_ACTION_FLAG_FOR_REVIEW = 1,
    DRIFT_ACTION_REJECT_NEURAL   = 2,
    DRIFT_ACTION_RETRY_NEURAL    = 3,
    DRIFT_ACTION_ESCALATE        = 4,
    DRIFT_ACTION_HALT            = 5
} DriftAction;

/* --- ReasoningPriority (4 variants) --- */
typedef enum {
    REASONING_PRIORITY_BACKGROUND = 0,
    REASONING_PRIORITY_NORMAL     = 1,
    REASONING_PRIORITY_URGENT     = 2,
    REASONING_PRIORITY_CRITICAL   = 3
} ReasoningPriority;

/* --- CachePolicy (4 variants) --- */
typedef enum {
    CACHE_POLICY_ALLOW_CACHE    = 0,
    CACHE_POLICY_FORCE_REFRESH  = 1,
    CACHE_POLICY_SYM_CACHE_ONLY = 2,
    CACHE_POLICY_NO_STORE       = 3
} CachePolicy;

/* --- ProofRequirement (4 variants) --- */
typedef enum {
    PROOF_REQ_NO_PROOF        = 0,
    PROOF_REQ_BEST_EFFORT     = 1,
    PROOF_REQ_PROOF_REQUIRED  = 2,
    PROOF_REQ_MACHINE_CHECKED = 3
} ProofRequirement;

/* --- ResultDisposition (6 variants) --- */
typedef enum {
    RESULT_COMPLETED           = 0,
    RESULT_TIMED_OUT           = 1,
    RESULT_CANCELLED           = 2,
    RESULT_INTERNAL_ERROR      = 3,
    RESULT_REJECTED            = 4,
    RESULT_VERIFICATION_FAILED = 5
} ResultDisposition;

/* --- EmbeddingSpace (5 variants) --- */
typedef enum {
    EMBEDDING_DENSE_VECTOR      = 0,
    EMBEDDING_SPARSE_VECTOR     = 1,
    EMBEDDING_GRAPH             = 2,
    EMBEDDING_HYPERBOLIC        = 3,
    EMBEDDING_SYMBOLIC_ENCODING = 4
} EmbeddingSpace;

/* --- GroundingStatus (5 variants) --- */
typedef enum {
    GROUNDING_FULLY_GROUNDED    = 0,
    GROUNDING_PARTIALLY_GROUNDED = 1,
    GROUNDING_UNGROUNDED        = 2,
    GROUNDING_PENDING           = 3,
    GROUNDING_FAILED            = 4
} GroundingStatus;

/* --- NeSyContext --- */
typedef struct {
    ReasoningMode     mode;
    Confidence        confidence;
    DriftKind         drift;
    MergeStrategy     merge_strategy;
    ProofStatus       proof_status;
    GroundingStatus   grounding;
    ReasoningPriority priority;
    CachePolicy       cache_policy;
    uint32_t          session_id;
    uint8_t           _pad[3];
} NeSyContext;

/* --- Label functions --- */
const char* nesy_reasoning_mode_label(ReasoningMode m);
const char* nesy_proof_status_label(ProofStatus p);
const char* nesy_constraint_kind_label(ConstraintKind c);
const char* nesy_neural_backend_label(NeuralBackend b);
const char* nesy_confidence_label(Confidence c);
const char* nesy_drift_kind_label(DriftKind d);
const char* nesy_merge_strategy_label(MergeStrategy m);
const char* nesy_drift_action_label(DriftAction a);
const char* nesy_grounding_status_label(GroundingStatus g);

/* --- Predicate functions --- */
bool nesy_reasoning_mode_uses_symbolic(ReasoningMode m);
bool nesy_reasoning_mode_uses_neural(ReasoningMode m);
bool nesy_reasoning_mode_is_hybrid(ReasoningMode m);
bool nesy_proof_status_is_terminal(ProofStatus p);
bool nesy_proof_status_is_trusted(ProofStatus p);
bool nesy_neural_backend_is_local(NeuralBackend b);
bool nesy_neural_backend_is_cloud(NeuralBackend b);
bool nesy_confidence_is_actionable(Confidence c);
float nesy_confidence_score(Confidence c);
Confidence nesy_confidence_min(Confidence a, Confidence b);
uint8_t nesy_drift_kind_severity(DriftKind d);
bool nesy_drift_kind_is_urgent(DriftKind d);
bool nesy_merge_strategy_symbolic_can_veto(MergeStrategy m);
bool nesy_grounding_status_is_trusted(GroundingStatus g);

/* --- Drift recommendation --- */
DriftAction nesy_recommend_drift_action(DriftKind d);

/* --- Context lifecycle --- */
NeSyContext nesy_context_create(uint32_t session_id);

#ifdef __cplusplus
}
#endif

#endif /* NESY_FFI_H */
