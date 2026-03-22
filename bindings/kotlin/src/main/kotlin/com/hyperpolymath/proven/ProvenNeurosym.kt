// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Neurosym protocol types for proven-servers.

package com.hyperpolymath.proven

/** InferenceMode matching the Idris2 ABI tags. */
enum class InferenceMode(val tag: Int) {
    NEURAL(0),
    SYMBOLIC(1),
    HYBRID(2),
    CASCADE(3);

    companion object {
        fun fromTag(tag: Int): InferenceMode? = entries.find { it.tag == tag }
    }
}

/** SymbolicOp matching the Idris2 ABI tags. */
enum class SymbolicOp(val tag: Int) {
    UNIFY(0),
    RESOLVE(1),
    REWRITE(2),
    PROVE(3),
    SEARCH(4),
    CONSTRAIN(5);

    companion object {
        fun fromTag(tag: Int): SymbolicOp? = entries.find { it.tag == tag }
    }
}

/** NeuralOp matching the Idris2 ABI tags. */
enum class NeuralOp(val tag: Int) {
    EMBED(0),
    CLASSIFY(1),
    GENERATE(2),
    ATTEND(3),
    RETRIEVE(4),
    FINETUNE(5);

    companion object {
        fun fromTag(tag: Int): NeuralOp? = entries.find { it.tag == tag }
    }
}

/** FusionStrategy matching the Idris2 ABI tags. */
enum class FusionStrategy(val tag: Int) {
    NEURAL_THEN_SYMBOLIC(0),
    SYMBOLIC_THEN_NEURAL(1),
    PARALLEL(2),
    ITERATIVE(3),
    GATED(4);

    companion object {
        fun fromTag(tag: Int): FusionStrategy? = entries.find { it.tag == tag }
    }
}

/** ConfidenceLevel matching the Idris2 ABI tags. */
enum class ConfidenceLevel(val tag: Int) {
    PROVEN(0),
    HIGH_CONFIDENCE(1),
    MODERATE(2),
    LOW_CONFIDENCE(3),
    UNCERTAIN(4),
    CONTRADICTED(5);

    companion object {
        fun fromTag(tag: Int): ConfidenceLevel? = entries.find { it.tag == tag }
    }
}

/** KnowledgeType matching the Idris2 ABI tags. */
enum class KnowledgeType(val tag: Int) {
    AXIOM(0),
    LEARNED(1),
    INFERRED(2),
    GROUNDED(3),
    HYPOTHETICAL(4),
    RETRACTED(5);

    companion object {
        fun fromTag(tag: Int): KnowledgeType? = entries.find { it.tag == tag }
    }
}

/** NeurosymState matching the Idris2 ABI tags. */
enum class NeurosymState(val tag: Int) {
    IDLE(0),
    READY(1),
    INFERRING(2),
    REASONING(3),
    FUSING(4),
    SHUTDOWN(5);

    companion object {
        fun fromTag(tag: Int): NeurosymState? = entries.find { it.tag == tag }
    }
}
