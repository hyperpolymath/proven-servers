// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDAP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * LDAP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenLdap {
    private ProvenLdap() {}

    /** SessionState (tags 0-3). */
    public enum SessionState {
        ANONYMOUS(0),
        BOUND(1),
        CLOSED(2),
        BINDING(3);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Operation (tags 0-9). */
    public enum Operation {
        BIND(0),
        UNBIND(1),
        SEARCH(2),
        MODIFY(3),
        ADD(4),
        DELETE(5),
        MOD_DN(6),
        COMPARE(7),
        ABANDON(8),
        EXTENDED(9);

        private final int tag;
        Operation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Operation fromTag(int tag) {
            for (Operation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SearchScope (tags 0-2). */
    public enum SearchScope {
        BASE_OBJECT(0),
        SINGLE_LEVEL(1),
        WHOLE_SUBTREE(2);

        private final int tag;
        SearchScope(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SearchScope fromTag(int tag) {
            for (SearchScope v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResultCode (tags 0-10). */
    public enum ResultCode {
        SUCCESS(0),
        OPERATIONS_ERROR(1),
        PROTOCOL_ERROR(2),
        TIME_LIMIT_EXCEEDED(3),
        SIZE_LIMIT_EXCEEDED(4),
        AUTH_METHOD_NOT_SUPPORTED(5),
        NO_SUCH_OBJECT(6),
        INVALID_CREDENTIALS(7),
        INSUFFICIENT_ACCESS_RIGHTS(8),
        BUSY(9),
        UNAVAILABLE(10);

        private final int tag;
        ResultCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResultCode fromTag(int tag) {
            for (ResultCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
