// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WASM protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * WASM protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenWasm {
    private ProvenWasm() {}

    /** ValType (tags 0-6). */
    public enum ValType {
        I32(0),
        I64(1),
        F32(2),
        F64(3),
        V128(4),
        FUNC_REF(5),
        EXTERN_REF(6);

        private final int tag;
        ValType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ValType fromTag(int tag) {
            for (ValType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ExternKind (tags 0-3). */
    public enum ExternKind {
        FUNC_EXTERN(0),
        TABLE_EXTERN(1),
        MEM_EXTERN(2),
        GLOBAL_EXTERN(3);

        private final int tag;
        ExternKind(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ExternKind fromTag(int tag) {
            for (ExternKind v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Mutability (tags 0-1). */
    public enum Mutability {
        IMMUTABLE(0),
        MUTABLE(1);

        private final int tag;
        Mutability(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Mutability fromTag(int tag) {
            for (Mutability v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
