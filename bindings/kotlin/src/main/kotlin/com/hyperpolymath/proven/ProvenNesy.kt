// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NeSy protocol types for proven-servers.

package com.hyperpolymath.proven

/** ReasoningMode matching the Idris2 ABI tags. */
enum class ReasoningMode(val tag: Int) {
    SYMBOLIC(0),
    NEURAL(1),
    SYM_TO_NEURAL(2),
    NEURAL_TO_SYM(3),
    ENSEMBLE(4),
    CASCADE(5);

    companion object {
        fun fromTag(tag: Int): ReasoningMode? = entries.find { it.tag == tag }
    }
}

/** ProofStatus matching the Idris2 ABI tags. */
enum class ProofStatus(val tag: Int) {
    PENDING(0),
    ATTEMPTING(1),
    PROVED(2),
    FAILED(3),
    ASSUMED(4),
    VACUOUS(5);

    companion object {
        fun fromTag(tag: Int): ProofStatus? = entries.find { it.tag == tag }
    }
}

/** ConstraintKind matching the Idris2 ABI tags. */
enum class ConstraintKind(val tag: Int) {
    TYPE_EQUALITY(0),
    SUBTYPE(1),
    LINEARITY(2),
    TERMINATION(3),
    TOTALITY(4),
    INVARIANT(5),
    REFINEMENT(6),
    DEPENDENT_INDEX(7);

    companion object {
        fun fromTag(tag: Int): ConstraintKind? = entries.find { it.tag == tag }
    }
}

/** NeuralBackend matching the Idris2 ABI tags. */
enum class NeuralBackend(val tag: Int) {
    LOCAL_MODEL(0),
    CLAUDE(1),
    GEMINI(2),
    MISTRAL(3),
    GPT(4),
    CUSTOM_NEURAL(5);

    companion object {
        fun fromTag(tag: Int): NeuralBackend? = entries.find { it.tag == tag }
    }
}

/** Confidence matching the Idris2 ABI tags. */
enum class Confidence(val tag: Int) {
    VERIFIED(0),
    HIGH_NEURAL(1),
    MEDIUM_NEURAL(2),
    LOW_NEURAL(3),
    UNKNOWN(4),
    CONTRADICTED(5);

    companion object {
        fun fromTag(tag: Int): Confidence? = entries.find { it.tag == tag }
    }
}

/** DriftKind matching the Idris2 ABI tags. */
enum class DriftKind(val tag: Int) {
    NO_DRIFT(0),
    SEMANTIC_DRIFT(1),
    CONFIDENCE_DRIFT(2),
    FACTUAL_DRIFT(3),
    TEMPORAL_DRIFT(4),
    CATASTROPHIC_DRIFT(5);

    companion object {
        fun fromTag(tag: Int): DriftKind? = entries.find { it.tag == tag }
    }
}

/** NeSyState matching the Idris2 ABI tags. */
enum class NeSyState(val tag: Int) {
    IDLE(0),
    READY(1),
    REASONING(2),
    VERIFYING(3),
    DRIFT(4),
    SHUTDOWN(5);

    companion object {
        fun fromTag(tag: Int): NeSyState? = entries.find { it.tag == tag }
    }
}
