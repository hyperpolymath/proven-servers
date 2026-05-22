// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CardDAV protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * CardDAV protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenCarddav {
    private ProvenCarddav() {}

    /** PropertyType (tags 0-8). */
    public enum PropertyType {
        FN_NAME(0),
        N(1),
        EMAIL(2),
        TEL(3),
        ADR(4),
        ORG(5),
        PHOTO(6),
        URL(7),
        NOTE(8);

        private final int tag;
        PropertyType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PropertyType fromTag(int tag) {
            for (PropertyType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CardMethod (tags 0-6). */
    public enum CardMethod {
        GET(0),
        PUT(1),
        DELETE(2),
        PROPFIND(3),
        PROPPATCH(4),
        REPORT(5),
        MKCOL(6);

        private final int tag;
        CardMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CardMethod fromTag(int tag) {
            for (CardMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** VCardVersion (tags 0-1). */
    public enum VCardVersion {
        VCARD3(0),
        VCARD4(1);

        private final int tag;
        VCardVersion(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static VCardVersion fromTag(int tag) {
            for (VCardVersion v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CardError (tags 0-5). */
    public enum CardError {
        VALID_ADDRESS_DATA(0),
        NO_RESOURCE_TYPE(1),
        MAX_RESOURCE_SIZE(2),
        UID_CONFLICT(3),
        SUPPORTED_ADDRESS_DATA(4),
        PRECONDITION_FAILED(5);

        private final int tag;
        CardError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CardError fromTag(int tag) {
            for (CardError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServerState (tags 0-3). */
    public enum ServerState {
        IDLE(0),
        BOUND(1),
        SERVING(2),
        SHUTDOWN(3);

        private final int tag;
        ServerState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ServerState fromTag(int tag) {
            for (ServerState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
