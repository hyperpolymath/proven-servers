// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BFD protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * BFD protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenBfd {
    private ProvenBfd() {}

    /** BfdState (tags 0-3). */
    public enum BfdState {
        ADMIN_DOWN(0),
        DOWN(1),
        INIT(2),
        UP(3);

        private final int tag;
        BfdState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static BfdState fromTag(int tag) {
            for (BfdState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Diagnostic (tags 0-8). */
    public enum Diagnostic {
        NO_DIAGNOSTIC(0),
        CONTROL_DETECTION_TIME_EXPIRED(1),
        ECHO_FUNCTION_FAILED(2),
        NEIGHBOR_SIGNALED_SESSION_DOWN(3),
        FORWARDING_PLANE_RESET(4),
        PATH_DOWN(5),
        CONCATENATED_PATH_DOWN(6),
        ADMINISTRATIVELY_DOWN(7),
        REVERSE_CONCATENATED_PATH_DOWN(8);

        private final int tag;
        Diagnostic(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Diagnostic fromTag(int tag) {
            for (Diagnostic v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionMode (tags 0-1). */
    public enum SessionMode {
        ASYNC_MODE(0),
        DEMAND_MODE(1);

        private final int tag;
        SessionMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionMode fromTag(int tag) {
            for (SessionMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        SS_DOWN(1),
        NEGOTIATING(2),
        ESTABLISHED(3),
        TEARDOWN(4);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
