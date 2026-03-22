// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CT Log protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * CT Log protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenCtlog {
    private ProvenCtlog() {}

    /** LogEntryType (tags 0-1). */
    public enum LogEntryType {
        X509_ENTRY(0),
        PRECERT_ENTRY(1);

        private final int tag;
        LogEntryType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LogEntryType fromTag(int tag) {
            for (LogEntryType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SignatureType (tags 0-1). */
    public enum SignatureType {
        CERTIFICATE_TIMESTAMP(0),
        TREE_HASH(1);

        private final int tag;
        SignatureType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SignatureType fromTag(int tag) {
            for (SignatureType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** MerkleLeafType (tags 0-0). */
    public enum MerkleLeafType {
        TIMESTAMPED_ENTRY(0);

        private final int tag;
        MerkleLeafType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MerkleLeafType fromTag(int tag) {
            for (MerkleLeafType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SubmissionStatus (tags 0-5). */
    public enum SubmissionStatus {
        ACCEPTED(0),
        DUPLICATE(1),
        RATE_LIMITED(2),
        REJECTED(3),
        INVALID_CHAIN(4),
        UNKNOWN_ANCHOR(5);

        private final int tag;
        SubmissionStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SubmissionStatus fromTag(int tag) {
            for (SubmissionStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** VerificationResult (tags 0-3). */
    public enum VerificationResult {
        VALID_PROOF(0),
        INVALID_PROOF(1),
        INCONSISTENT_TREE(2),
        STALE_STH(3);

        private final int tag;
        VerificationResult(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static VerificationResult fromTag(int tag) {
            for (VerificationResult v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServerState (tags 0-4). */
    public enum ServerState {
        IDLE(0),
        ACTIVE(1),
        MERGING(2),
        SIGNING(3),
        SHUTDOWN(4);

        private final int tag;
        ServerState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ServerState fromTag(int tag) {
            for (ServerState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
