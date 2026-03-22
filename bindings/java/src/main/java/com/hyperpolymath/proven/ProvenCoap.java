// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CoAP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * CoAP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenCoap {
    private ProvenCoap() {}

    /** Method (tags 0-3). */
    public enum Method {
        GET(0),
        POST(1),
        PUT(2),
        DELETE(3);

        private final int tag;
        Method(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Method fromTag(int tag) {
            for (Method v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** MessageType (tags 0-3). */
    public enum MessageType {
        CONFIRMABLE(0),
        NON_CONFIRMABLE(1),
        ACKNOWLEDGEMENT(2),
        RESET(3);

        private final int tag;
        MessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MessageType fromTag(int tag) {
            for (MessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ContentFormat (tags 0-6). */
    public enum ContentFormat {
        TEXT_PLAIN(0),
        LINK_FORMAT(1),
        XML(2),
        OCTET_STREAM(3),
        EXI(4),
        JSON(5),
        CBOR(6);

        private final int tag;
        ContentFormat(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ContentFormat fromTag(int tag) {
            for (ContentFormat v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResponseClass (tags 0-4). */
    public enum ResponseClass {
        SUCCESS(0),
        CLIENT_ERROR(1),
        SERVER_ERROR(2),
        SIGNALING(3),
        EMPTY(4);

        private final int tag;
        ResponseClass(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResponseClass fromTag(int tag) {
            for (ResponseClass v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        BOUND(1),
        SERVING(2),
        OBSERVING(3),
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
