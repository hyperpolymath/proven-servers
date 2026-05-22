// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CoAP protocol types for proven-servers.

package com.hyperpolymath.proven

/** Method matching the Idris2 ABI tags. */
enum class Method(val tag: Int) {
    GET(0),
    POST(1),
    PUT(2),
    DELETE(3);

    companion object {
        fun fromTag(tag: Int): Method? = entries.find { it.tag == tag }
    }
}

/** MessageType matching the Idris2 ABI tags. */
enum class MessageType(val tag: Int) {
    CONFIRMABLE(0),
    NON_CONFIRMABLE(1),
    ACKNOWLEDGEMENT(2),
    RESET(3);

    companion object {
        fun fromTag(tag: Int): MessageType? = entries.find { it.tag == tag }
    }
}

/** ContentFormat matching the Idris2 ABI tags. */
enum class ContentFormat(val tag: Int) {
    TEXT_PLAIN(0),
    LINK_FORMAT(1),
    XML(2),
    OCTET_STREAM(3),
    EXI(4),
    JSON(5),
    CBOR(6);

    companion object {
        fun fromTag(tag: Int): ContentFormat? = entries.find { it.tag == tag }
    }
}

/** ResponseClass matching the Idris2 ABI tags. */
enum class ResponseClass(val tag: Int) {
    SUCCESS(0),
    CLIENT_ERROR(1),
    SERVER_ERROR(2),
    SIGNALING(3),
    EMPTY(4);

    companion object {
        fun fromTag(tag: Int): ResponseClass? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    BOUND(1),
    SERVING(2),
    OBSERVING(3),
    SHUTDOWN(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
