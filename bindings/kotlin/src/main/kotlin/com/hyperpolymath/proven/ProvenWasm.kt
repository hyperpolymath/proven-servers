// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WASM protocol types for proven-servers.

package com.hyperpolymath.proven

/** ValType matching the Idris2 ABI tags. */
enum class ValType(val tag: Int) {
    I32(0),
    I64(1),
    F32(2),
    F64(3),
    V128(4),
    FUNC_REF(5),
    EXTERN_REF(6);

    companion object {
        fun fromTag(tag: Int): ValType? = entries.find { it.tag == tag }
    }
}

/** ExternKind matching the Idris2 ABI tags. */
enum class ExternKind(val tag: Int) {
    FUNC_EXTERN(0),
    TABLE_EXTERN(1),
    MEM_EXTERN(2),
    GLOBAL_EXTERN(3);

    companion object {
        fun fromTag(tag: Int): ExternKind? = entries.find { it.tag == tag }
    }
}

/** Mutability matching the Idris2 ABI tags. */
enum class Mutability(val tag: Int) {
    IMMUTABLE(0),
    MUTABLE(1);

    companion object {
        fun fromTag(tag: Int): Mutability? = entries.find { it.tag == tag }
    }
}
