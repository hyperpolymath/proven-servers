// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoH protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * DoH protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenDoh {
    private ProvenDoh() {}

    /** ContentType (tags 0-1). */
    public enum ContentType {
        DNS_MESSAGE(0),
        DNS_JSON(1);

        private final int tag;
        ContentType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ContentType fromTag(int tag) {
            for (ContentType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** RequestMethod (tags 0-1). */
    public enum RequestMethod {
        GET(0),
        POST(1);

        private final int tag;
        RequestMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RequestMethod fromTag(int tag) {
            for (RequestMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** WireFormat (tags 0-1). */
    public enum WireFormat {
        BINARY(0),
        JSON(1);

        private final int tag;
        WireFormat(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static WireFormat fromTag(int tag) {
            for (WireFormat v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorReason (tags 0-4). */
    public enum ErrorReason {
        BAD_CONTENT_TYPE(0),
        BAD_METHOD(1),
        PAYLOAD_TOO_LARGE(2),
        UPSTREAM_TIMEOUT(3),
        UPSTREAM_ERROR(4);

        private final int tag;
        ErrorReason(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorReason fromTag(int tag) {
            for (ErrorReason v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        BOUND(1),
        SERVING(2),
        RESOLVING(3),
        SHUTDOWN(4);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
