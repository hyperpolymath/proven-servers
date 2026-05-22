// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebDAV protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * WebDAV protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenWebdav {
    private ProvenWebdav() {}

    /** Method (tags 0-6). */
    public enum Method {
        PROPFIND(0),
        PROPPATCH(1),
        MKCOL(2),
        COPY(3),
        MOVE(4),
        LOCK(5),
        UNLOCK(6);

        private final int tag;
        Method(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Method fromTag(int tag) {
            for (Method v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** StatusCode (tags 0-4). */
    public enum StatusCode {
        MULTI_STATUS(0),
        UNPROCESSABLE_ENTITY(1),
        LOCKED(2),
        FAILED_DEPENDENCY(3),
        INSUFFICIENT_STORAGE(4);

        private final int tag;
        StatusCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StatusCode fromTag(int tag) {
            for (StatusCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** LockScope (tags 0-1). */
    public enum LockScope {
        EXCLUSIVE(0),
        SHARED(1);

        private final int tag;
        LockScope(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LockScope fromTag(int tag) {
            for (LockScope v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** LockType (tags 0-0). */
    public enum LockType {
        WRITE(0);

        private final int tag;
        LockType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LockType fromTag(int tag) {
            for (LockType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Depth (tags 0-2). */
    public enum Depth {
        ZERO(0),
        ONE(1),
        INFINITY(2);

        private final int tag;
        Depth(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Depth fromTag(int tag) {
            for (Depth v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PropertyOp (tags 0-1). */
    public enum PropertyOp {
        SET(0),
        REMOVE(1);

        private final int tag;
        PropertyOp(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PropertyOp fromTag(int tag) {
            for (PropertyOp v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
