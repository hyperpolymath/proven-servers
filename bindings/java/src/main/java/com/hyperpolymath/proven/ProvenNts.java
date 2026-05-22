// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTS protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * NTS protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenNts {
    private ProvenNts() {}

    /** RecordType (tags 0-8). */
    public enum RecordType {
        END_OF_MESSAGE(0),
        NEXT_PROTOCOL(1),
        ERROR(2),
        WARNING(3),
        AEAD_ALGORITHM(4),
        COOKIE(5),
        COOKIE_PLACEHOLDER(6),
        NTSKE_SERVER(7),
        NTSKE_PORT(8);

        private final int tag;
        RecordType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RecordType fromTag(int tag) {
            for (RecordType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorCode (tags 0-2). */
    public enum ErrorCode {
        UNRECOGNIZED_CRITICAL(0),
        BAD_REQUEST(1),
        INTERNAL_ERROR(2);

        private final int tag;
        ErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorCode fromTag(int tag) {
            for (ErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AeadAlgorithm (tags 0-2). */
    public enum AeadAlgorithm {
        AEAD_AES128_GCM(0),
        AEAD_AES256_GCM(1),
        AEAD_AES_SIV_CMAC256(2);

        private final int tag;
        AeadAlgorithm(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AeadAlgorithm fromTag(int tag) {
            for (AeadAlgorithm v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HandshakeState (tags 0-3). */
    public enum HandshakeState {
        INITIAL(0),
        NEGOTIATING(1),
        ESTABLISHED(2),
        FAILED(3);

        private final int tag;
        HandshakeState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HandshakeState fromTag(int tag) {
            for (HandshakeState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        HANDSHAKING(1),
        NEGOTIATING(2),
        ESTABLISHED(3),
        CLOSING(4);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
