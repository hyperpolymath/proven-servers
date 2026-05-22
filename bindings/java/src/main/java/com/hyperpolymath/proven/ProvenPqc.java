// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PQC protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * PQC protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenPqc {
    private ProvenPqc() {}

    /** PqcAlgorithm (tags 0-7). */
    public enum PqcAlgorithm {
        CRYSTALS_KYBER(0),
        CRYSTALS_DILITHIUM(1),
        FALCON(2),
        SPHINCS_PLUS(3),
        CLASSIC_MCELIECE(4),
        BIKE(5),
        HQC(6),
        FRODOKEM(7);

        private final int tag;
        PqcAlgorithm(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PqcAlgorithm fromTag(int tag) {
            for (PqcAlgorithm v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NistLevel (tags 0-4). */
    public enum NistLevel {
        NIST1(0),
        NIST2(1),
        NIST3(2),
        NIST4(3),
        NIST5(4);

        private final int tag;
        NistLevel(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NistLevel fromTag(int tag) {
            for (NistLevel v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Operation (tags 0-4). */
    public enum Operation {
        KEYGEN(0),
        ENCAPSULATE(1),
        DECAPSULATE(2),
        SIGN(3),
        VERIFY(4);

        private final int tag;
        Operation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Operation fromTag(int tag) {
            for (Operation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HybridMode (tags 0-2). */
    public enum HybridMode {
        CLASSICAL_ONLY(0),
        PQC_ONLY(1),
        HYBRID(2);

        private final int tag;
        HybridMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HybridMode fromTag(int tag) {
            for (HybridMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AlgorithmCategory (tags 0-1). */
    public enum AlgorithmCategory {
        KEM(0),
        SIGNATURE(1);

        private final int tag;
        AlgorithmCategory(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AlgorithmCategory fromTag(int tag) {
            for (AlgorithmCategory v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** KeyState (tags 0-5). */
    public enum KeyState {
        EMPTY(0),
        GENERATING(1),
        GENERATED(2),
        ACTIVE(3),
        EXPIRED(4),
        COMPROMISED(5);

        private final int tag;
        KeyState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static KeyState fromTag(int tag) {
            for (KeyState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
