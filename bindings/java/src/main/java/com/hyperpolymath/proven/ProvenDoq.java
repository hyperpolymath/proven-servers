// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoQ protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * DoQ protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenDoq {
    private ProvenDoq() {}

    /** StreamType (tags 0-1). */
    public enum StreamType {
        UNIDIRECTIONAL(0),
        BIDIRECTIONAL(1);

        private final int tag;
        StreamType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StreamType fromTag(int tag) {
            for (StreamType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorCode (tags 0-3). */
    public enum ErrorCode {
        NO_ERROR(0),
        INTERNAL_ERROR(1),
        EXCESSIVE_LOAD(2),
        PROTOCOL_ERROR(3);

        private final int tag;
        ErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorCode fromTag(int tag) {
            for (ErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        INITIAL(0),
        HANDSHAKING(1),
        READY(2),
        DRAINING(3),
        CLOSED(4);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
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
