// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OCSP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * OCSP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenOcsp {
    private ProvenOcsp() {}

    /** CertStatus (tags 0-2). */
    public enum CertStatus {
        GOOD(0),
        REVOKED(1),
        UNKNOWN(2);

        private final int tag;
        CertStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CertStatus fromTag(int tag) {
            for (CertStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResponseStatus (tags 0-5). */
    public enum ResponseStatus {
        SUCCESSFUL(0),
        MALFORMED_REQUEST(1),
        INTERNAL_ERROR(2),
        TRY_LATER(3),
        SIG_REQUIRED(4),
        UNAUTHORIZED(5);

        private final int tag;
        ResponseStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResponseStatus fromTag(int tag) {
            for (ResponseStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HashAlgorithm (tags 0-3). */
    public enum HashAlgorithm {
        SHA1(0),
        SHA256(1),
        SHA384(2),
        SHA512(3);

        private final int tag;
        HashAlgorithm(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HashAlgorithm fromTag(int tag) {
            for (HashAlgorithm v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResponderState (tags 0-4). */
    public enum ResponderState {
        IDLE(0),
        READY(1),
        PROCESSING(2),
        SIGNING(3),
        CLOSING(4);

        private final int tag;
        ResponderState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResponderState fromTag(int tag) {
            for (ResponderState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
