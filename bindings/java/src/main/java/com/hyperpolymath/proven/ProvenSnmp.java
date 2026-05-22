// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SNMP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * SNMP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSnmp {
    private ProvenSnmp() {}

    /** Version (tags 0-2). */
    public enum Version {
        V1(0),
        V2C(1),
        V3(2);

        private final int tag;
        Version(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Version fromTag(int tag) {
            for (Version v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PduType (tags 0-6). */
    public enum PduType {
        GET_REQUEST(0),
        GET_NEXT_REQUEST(1),
        GET_RESPONSE(2),
        SET_REQUEST(3),
        GET_BULK_REQUEST(4),
        INFORM_REQUEST(5),
        SNMP_V2_TRAP(6);

        private final int tag;
        PduType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PduType fromTag(int tag) {
            for (PduType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorStatus (tags 0-15). */
    public enum ErrorStatus {
        NO_ERROR(0),
        TOO_BIG(1),
        NO_SUCH_NAME(2),
        BAD_VALUE(3),
        READ_ONLY(4),
        GEN_ERR(5),
        NO_ACCESS(6),
        WRONG_TYPE(7),
        WRONG_LENGTH(8),
        WRONG_VALUE(9),
        NO_CREATION(10),
        INCONSISTENT_VALUE(11),
        RESOURCE_UNAVAILABLE(12),
        COMMIT_FAILED(13),
        UNDO_FAILED(14),
        AUTHORIZATION_ERROR(15);

        private final int tag;
        ErrorStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorStatus fromTag(int tag) {
            for (ErrorStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
