// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Triplestore protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Triplestore protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenTriplestore {
    private ProvenTriplestore() {}

    /** Statement (tags 0-1). */
    public enum Statement {
        TRIPLE(0),
        QUAD(1);

        private final int tag;
        Statement(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Statement fromTag(int tag) {
            for (Statement v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** IndexOrder (tags 0-5). */
    public enum IndexOrder {
        SPO(0),
        POS(1),
        OSP(2),
        GSPO(3),
        GPOS(4),
        GOSP(5);

        private final int tag;
        IndexOrder(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static IndexOrder fromTag(int tag) {
            for (IndexOrder v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** StorageBackend (tags 0-3). */
    public enum StorageBackend {
        IN_MEMORY(0),
        B_TREE(1),
        LSM(2),
        PERSISTENT(3);

        private final int tag;
        StorageBackend(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StorageBackend fromTag(int tag) {
            for (StorageBackend v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ImportFormat (tags 0-5). */
    public enum ImportFormat {
        N_TRIPLES(0),
        TURTLE(1),
        RDF_XML(2),
        JSON_LD(3),
        N_QUADS(4),
        TRIG(5);

        private final int tag;
        ImportFormat(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ImportFormat fromTag(int tag) {
            for (ImportFormat v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TransactionIsolation (tags 0-2). */
    public enum TransactionIsolation {
        READ_COMMITTED(0),
        SERIALIZABLE(1),
        SNAPSHOT(2);

        private final int tag;
        TransactionIsolation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TransactionIsolation fromTag(int tag) {
            for (TransactionIsolation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** StoreState (tags 0-4). */
    public enum StoreState {
        IDLE(0),
        READY(1),
        IN_TRANSACTION(2),
        IMPORTING(3),
        CLOSING(4);

        private final int tag;
        StoreState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StoreState fromTag(int tag) {
            for (StoreState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
