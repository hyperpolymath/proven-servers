// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebSocket protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * WebSocket protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenWebsocket {
    private ProvenWebsocket() {}

    /** Opcode (tags 0-5). */
    public enum Opcode {
        CONTINUATION(0),
        TEXT(1),
        BINARY(2),
        CLOSE(3),
        PING(4),
        PONG(5);

        private final int tag;
        Opcode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Opcode fromTag(int tag) {
            for (Opcode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CloseCode (tags 0-10). */
    public enum CloseCode {
        NORMAL(0),
        GOING_AWAY(1),
        PROTOCOL_ERROR(2),
        UNSUPPORTED_DATA(3),
        NO_STATUS(4),
        ABNORMAL(5),
        INVALID_PAYLOAD(6),
        POLICY_VIOLATION(7),
        MESSAGE_TOO_BIG(8),
        MANDATORY_EXTENSION(9),
        INTERNAL_ERROR(10);

        private final int tag;
        CloseCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CloseCode fromTag(int tag) {
            for (CloseCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
