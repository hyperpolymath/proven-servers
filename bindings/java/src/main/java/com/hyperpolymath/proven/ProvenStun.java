// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// STUN/TURN protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * STUN/TURN protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenStun {
    private ProvenStun() {}

    /** MessageType (tags 0-11). */
    public enum MessageType {
        BINDING_REQUEST(0),
        BINDING_RESPONSE(1),
        BINDING_ERROR(2),
        ALLOCATE_REQUEST(3),
        ALLOCATE_RESPONSE(4),
        ALLOCATE_ERROR(5),
        REFRESH_REQUEST(6),
        REFRESH_RESPONSE(7),
        SEND_INDICATION(8),
        DATA_INDICATION(9),
        CREATE_PERMISSION(10),
        CHANNEL_BIND(11);

        private final int tag;
        MessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MessageType fromTag(int tag) {
            for (MessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TransportProtocol (tags 0-3). */
    public enum TransportProtocol {
        UDP(0),
        TCP(1),
        TLS(2),
        DTLS(3);

        private final int tag;
        TransportProtocol(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TransportProtocol fromTag(int tag) {
            for (TransportProtocol v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorCode (tags 0-7). */
    public enum ErrorCode {
        TRY_ALTERNATE(0),
        BAD_REQUEST(1),
        UNAUTHORIZED(2),
        FORBIDDEN(3),
        MOBILITY_FORBIDDEN(4),
        STALE_NONCE(5),
        SERVER_ERROR(6),
        INSUFFICIENT_CAPACITY(7);

        private final int tag;
        ErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorCode fromTag(int tag) {
            for (ErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
