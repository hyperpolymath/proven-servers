// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoT protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * DoT protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenDot {
    private ProvenDot() {}

    /** SessionState (tags 0-4). */
    public enum SessionState {
        CONNECTING(0),
        HANDSHAKING(1),
        ESTABLISHED(2),
        CLOSING(3),
        CLOSED(4);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PaddingStrategy (tags 0-2). */
    public enum PaddingStrategy {
        NO_PADDING(0),
        BLOCK_PADDING(1),
        RANDOM_PADDING(2);

        private final int tag;
        PaddingStrategy(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PaddingStrategy fromTag(int tag) {
            for (PaddingStrategy v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorReason (tags 0-3). */
    public enum ErrorReason {
        HANDSHAKE_FAILED(0),
        CERTIFICATE_INVALID(1),
        TIMEOUT(2),
        UPSTREAM_ERROR(3);

        private final int tag;
        ErrorReason(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorReason fromTag(int tag) {
            for (ErrorReason v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServerState (tags 0-4). */
    public enum ServerState {
        IDLE(0),
        BOUND(1),
        LISTENING(2),
        PROCESSING(3),
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
