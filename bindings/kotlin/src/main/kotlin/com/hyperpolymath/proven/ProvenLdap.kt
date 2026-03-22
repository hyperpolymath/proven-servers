// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// LDAP protocol types for proven-servers.

package com.hyperpolymath.proven

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    ANONYMOUS(0),
    BOUND(1),
    CLOSED(2),
    BINDING(3);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}

/** Operation matching the Idris2 ABI tags. */
enum class Operation(val tag: Int) {
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

    companion object {
        fun fromTag(tag: Int): Operation? = entries.find { it.tag == tag }
    }
}

/** SearchScope matching the Idris2 ABI tags. */
enum class SearchScope(val tag: Int) {
    BASE_OBJECT(0),
    SINGLE_LEVEL(1),
    WHOLE_SUBTREE(2);

    companion object {
        fun fromTag(tag: Int): SearchScope? = entries.find { it.tag == tag }
    }
}

/** ResultCode matching the Idris2 ABI tags. */
enum class ResultCode(val tag: Int) {
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

    companion object {
        fun fromTag(tag: Int): ResultCode? = entries.find { it.tag == tag }
    }
}
