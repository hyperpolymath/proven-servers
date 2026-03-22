// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Cache protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Cache protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenCache {
    private ProvenCache() {}

    /** Command (tags 0-12). */
    public enum Command {
        GET(0),
        SET(1),
        DELETE(2),
        EXISTS(3),
        EXPIRE(4),
        TTL(5),
        KEYS(6),
        FLUSH(7),
        INCR(8),
        DECR(9),
        APPEND(10),
        PREPEND(11),
        CAS(12);

        private final int tag;
        Command(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Command fromTag(int tag) {
            for (Command v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** EvictionPolicy (tags 0-4). */
    public enum EvictionPolicy {
        LRU(0),
        LFU(1),
        RANDOM(2),
        EVICT_TTL(3),
        NO_EVICTION(4);

        private final int tag;
        EvictionPolicy(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static EvictionPolicy fromTag(int tag) {
            for (EvictionPolicy v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DataType (tags 0-4). */
    public enum DataType {
        STRING_VAL(0),
        INT_VAL(1),
        LIST_VAL(2),
        SET_VAL(3),
        HASH_VAL(4);

        private final int tag;
        DataType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DataType fromTag(int tag) {
            for (DataType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorCode (tags 0-5). */
    public enum ErrorCode {
        NOT_FOUND(0),
        TYPE_MISMATCH(1),
        OUT_OF_MEMORY(2),
        KEY_TOO_LONG(3),
        VALUE_TOO_LARGE(4),
        CAS_CONFLICT(5);

        private final int tag;
        ErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorCode fromTag(int tag) {
            for (ErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ReplicationMode (tags 0-3). */
    public enum ReplicationMode {
        NONE(0),
        PRIMARY(1),
        REPLICA(2),
        SENTINEL(3);

        private final int tag;
        ReplicationMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ReplicationMode fromTag(int tag) {
            for (ReplicationMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
