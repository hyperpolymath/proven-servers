// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Neurosym protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Neurosym protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenNeurosym {
    private ProvenNeurosym() {}

    /** InferenceMode (tags 0-3). */
    public enum InferenceMode {
        NEURAL(0),
        SYMBOLIC(1),
        HYBRID(2),
        CASCADE(3);

        private final int tag;
        InferenceMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static InferenceMode fromTag(int tag) {
            for (InferenceMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SymbolicOp (tags 0-5). */
    public enum SymbolicOp {
        UNIFY(0),
        RESOLVE(1),
        REWRITE(2),
        PROVE(3),
        SEARCH(4),
        CONSTRAIN(5);

        private final int tag;
        SymbolicOp(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SymbolicOp fromTag(int tag) {
            for (SymbolicOp v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NeuralOp (tags 0-5). */
    public enum NeuralOp {
        EMBED(0),
        CLASSIFY(1),
        GENERATE(2),
        ATTEND(3),
        RETRIEVE(4),
        FINETUNE(5);

        private final int tag;
        NeuralOp(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NeuralOp fromTag(int tag) {
            for (NeuralOp v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** FusionStrategy (tags 0-4). */
    public enum FusionStrategy {
        NEURAL_THEN_SYMBOLIC(0),
        SYMBOLIC_THEN_NEURAL(1),
        PARALLEL(2),
        ITERATIVE(3),
        GATED(4);

        private final int tag;
        FusionStrategy(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static FusionStrategy fromTag(int tag) {
            for (FusionStrategy v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ConfidenceLevel (tags 0-5). */
    public enum ConfidenceLevel {
        PROVEN(0),
        HIGH_CONFIDENCE(1),
        MODERATE(2),
        LOW_CONFIDENCE(3),
        UNCERTAIN(4),
        CONTRADICTED(5);

        private final int tag;
        ConfidenceLevel(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ConfidenceLevel fromTag(int tag) {
            for (ConfidenceLevel v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** KnowledgeType (tags 0-5). */
    public enum KnowledgeType {
        AXIOM(0),
        LEARNED(1),
        INFERRED(2),
        GROUNDED(3),
        HYPOTHETICAL(4),
        RETRACTED(5);

        private final int tag;
        KnowledgeType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static KnowledgeType fromTag(int tag) {
            for (KnowledgeType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NeurosymState (tags 0-5). */
    public enum NeurosymState {
        IDLE(0),
        READY(1),
        INFERRING(2),
        REASONING(3),
        FUSING(4),
        SHUTDOWN(5);

        private final int tag;
        NeurosymState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NeurosymState fromTag(int tag) {
            for (NeurosymState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
