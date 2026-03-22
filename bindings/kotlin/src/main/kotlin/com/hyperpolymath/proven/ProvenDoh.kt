// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoH protocol types for proven-servers.

package com.hyperpolymath.proven

/** ContentType matching the Idris2 ABI tags. */
enum class ContentType(val tag: Int) {
    DNS_MESSAGE(0),
    DNS_JSON(1);

    companion object {
        fun fromTag(tag: Int): ContentType? = entries.find { it.tag == tag }
    }
}

/** RequestMethod matching the Idris2 ABI tags. */
enum class RequestMethod(val tag: Int) {
    GET(0),
    POST(1);

    companion object {
        fun fromTag(tag: Int): RequestMethod? = entries.find { it.tag == tag }
    }
}

/** WireFormat matching the Idris2 ABI tags. */
enum class WireFormat(val tag: Int) {
    BINARY(0),
    JSON(1);

    companion object {
        fun fromTag(tag: Int): WireFormat? = entries.find { it.tag == tag }
    }
}

/** ErrorReason matching the Idris2 ABI tags. */
enum class ErrorReason(val tag: Int) {
    BAD_CONTENT_TYPE(0),
    BAD_METHOD(1),
    PAYLOAD_TOO_LARGE(2),
    UPSTREAM_TIMEOUT(3),
    UPSTREAM_ERROR(4);

    companion object {
        fun fromTag(tag: Int): ErrorReason? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    BOUND(1),
    SERVING(2),
    RESOLVING(3),
    SHUTDOWN(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
