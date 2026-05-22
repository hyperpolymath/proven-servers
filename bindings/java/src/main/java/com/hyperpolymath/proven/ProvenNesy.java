// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NeSy protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * NeSy protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenNesy {
    private ProvenNesy() {}

    /** ReasoningMode (tags 0-5). */
    public enum ReasoningMode {
        SYMBOLIC(0),
        NEURAL(1),
        SYM_TO_NEURAL(2),
        NEURAL_TO_SYM(3),
        ENSEMBLE(4),
        CASCADE(5);

        private final int tag;
        ReasoningMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ReasoningMode fromTag(int tag) {
            for (ReasoningMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ProofStatus (tags 0-5). */
    public enum ProofStatus {
        PENDING(0),
        ATTEMPTING(1),
        PROVED(2),
        FAILED(3),
        ASSUMED(4),
        VACUOUS(5);

        private final int tag;
        ProofStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ProofStatus fromTag(int tag) {
            for (ProofStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ConstraintKind (tags 0-7). */
    public enum ConstraintKind {
        TYPE_EQUALITY(0),
        SUBTYPE(1),
        LINEARITY(2),
        TERMINATION(3),
        TOTALITY(4),
        INVARIANT(5),
        REFINEMENT(6),
        DEPENDENT_INDEX(7);

        private final int tag;
        ConstraintKind(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ConstraintKind fromTag(int tag) {
            for (ConstraintKind v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NeuralBackend (tags 0-5). */
    public enum NeuralBackend {
        LOCAL_MODEL(0),
        CLAUDE(1),
        GEMINI(2),
        MISTRAL(3),
        GPT(4),
        CUSTOM_NEURAL(5);

        private final int tag;
        NeuralBackend(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NeuralBackend fromTag(int tag) {
            for (NeuralBackend v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Confidence (tags 0-5). */
    public enum Confidence {
        VERIFIED(0),
        HIGH_NEURAL(1),
        MEDIUM_NEURAL(2),
        LOW_NEURAL(3),
        UNKNOWN(4),
        CONTRADICTED(5);

        private final int tag;
        Confidence(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Confidence fromTag(int tag) {
            for (Confidence v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DriftKind (tags 0-5). */
    public enum DriftKind {
        NO_DRIFT(0),
        SEMANTIC_DRIFT(1),
        CONFIDENCE_DRIFT(2),
        FACTUAL_DRIFT(3),
        TEMPORAL_DRIFT(4),
        CATASTROPHIC_DRIFT(5);

        private final int tag;
        DriftKind(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DriftKind fromTag(int tag) {
            for (DriftKind v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NeSyState (tags 0-5). */
    public enum NeSyState {
        IDLE(0),
        READY(1),
        REASONING(2),
        VERIFYING(3),
        DRIFT(4),
        SHUTDOWN(5);

        private final int tag;
        NeSyState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NeSyState fromTag(int tag) {
            for (NeSyState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
