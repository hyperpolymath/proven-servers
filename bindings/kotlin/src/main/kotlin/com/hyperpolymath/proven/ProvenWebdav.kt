// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebDAV protocol types for proven-servers.

package com.hyperpolymath.proven

/** Method matching the Idris2 ABI tags. */
enum class Method(val tag: Int) {
    PROPFIND(0),
    PROPPATCH(1),
    MKCOL(2),
    COPY(3),
    MOVE(4),
    LOCK(5),
    UNLOCK(6);

    companion object {
        fun fromTag(tag: Int): Method? = entries.find { it.tag == tag }
    }
}

/** StatusCode matching the Idris2 ABI tags. */
enum class StatusCode(val tag: Int) {
    MULTI_STATUS(0),
    UNPROCESSABLE_ENTITY(1),
    LOCKED(2),
    FAILED_DEPENDENCY(3),
    INSUFFICIENT_STORAGE(4);

    companion object {
        fun fromTag(tag: Int): StatusCode? = entries.find { it.tag == tag }
    }
}

/** LockScope matching the Idris2 ABI tags. */
enum class LockScope(val tag: Int) {
    EXCLUSIVE(0),
    SHARED(1);

    companion object {
        fun fromTag(tag: Int): LockScope? = entries.find { it.tag == tag }
    }
}

/** LockType matching the Idris2 ABI tags. */
enum class LockType(val tag: Int) {
    WRITE(0);

    companion object {
        fun fromTag(tag: Int): LockType? = entries.find { it.tag == tag }
    }
}

/** Depth matching the Idris2 ABI tags. */
enum class Depth(val tag: Int) {
    ZERO(0),
    ONE(1),
    INFINITY(2);

    companion object {
        fun fromTag(tag: Int): Depth? = entries.find { it.tag == tag }
    }
}

/** PropertyOp matching the Idris2 ABI tags. */
enum class PropertyOp(val tag: Int) {
    SET(0),
    REMOVE(1);

    companion object {
        fun fromTag(tag: Int): PropertyOp? = entries.find { it.tag == tag }
    }
}
