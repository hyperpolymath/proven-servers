// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mDNS protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * mDNS protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenMdns {
    private ProvenMdns() {}

    /** MdnsRecordType (tags 0-4). */
    public enum MdnsRecordType {
        A(0),
        AAAA(1),
        PTR(2),
        SRV(3),
        TXT(4);

        private final int tag;
        MdnsRecordType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MdnsRecordType fromTag(int tag) {
            for (MdnsRecordType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** QueryType (tags 0-2). */
    public enum QueryType {
        STANDARD(0),
        ONE_SHOT(1),
        CONTINUOUS(2);

        private final int tag;
        QueryType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static QueryType fromTag(int tag) {
            for (QueryType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ConflictAction (tags 0-2). */
    public enum ConflictAction {
        PROBE(0),
        DEFEND(1),
        WITHDRAW(2);

        private final int tag;
        ConflictAction(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ConflictAction fromTag(int tag) {
            for (ConflictAction v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServiceFlag (tags 0-1). */
    public enum ServiceFlag {
        UNIQUE(0),
        SHARED(1);

        private final int tag;
        ServiceFlag(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ServiceFlag fromTag(int tag) {
            for (ServiceFlag v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResponderState (tags 0-4). */
    public enum ResponderState {
        IDLE(0),
        PROBING(1),
        ANNOUNCING(2),
        RUNNING(3),
        SHUTTING_DOWN(4);

        private final int tag;
        ResponderState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResponderState fromTag(int tag) {
            for (ResponderState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
