// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ODNS protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * ODNS protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenOdns {
    private ProvenOdns() {}

    /** Role (tags 0-2). */
    public enum Role {
        CLIENT(0),
        PROXY(1),
        TARGET(2);

        private final int tag;
        Role(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Role fromTag(int tag) {
            for (Role v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** OdnsMessageType (tags 0-1). */
    public enum OdnsMessageType {
        QUERY(0),
        RESPONSE(1);

        private final int tag;
        OdnsMessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static OdnsMessageType fromTag(int tag) {
            for (OdnsMessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** OdnsErrorReason (tags 0-4). */
    public enum OdnsErrorReason {
        PROXY_ERROR(0),
        TARGET_ERROR(1),
        DECRYPTION_FAILED(2),
        INVALID_CONFIG(3),
        PAYLOAD_TOO_LARGE(4);

        private final int tag;
        OdnsErrorReason(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static OdnsErrorReason fromTag(int tag) {
            for (OdnsErrorReason v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** EncapsulationFormat (tags 0-0). */
    public enum EncapsulationFormat {
        HPKE(0);

        private final int tag;
        EncapsulationFormat(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static EncapsulationFormat fromTag(int tag) {
            for (EncapsulationFormat v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        KEY_EXCHANGE(1),
        READY(2),
        PROCESSING(3),
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
