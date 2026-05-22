// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoQ protocol types for proven-servers.

package com.hyperpolymath.proven

/** StreamType matching the Idris2 ABI tags. */
enum class StreamType(val tag: Int) {
    UNIDIRECTIONAL(0),
    BIDIRECTIONAL(1);

    companion object {
        fun fromTag(tag: Int): StreamType? = entries.find { it.tag == tag }
    }
}

/** ErrorCode matching the Idris2 ABI tags. */
enum class ErrorCode(val tag: Int) {
    NO_ERROR(0),
    INTERNAL_ERROR(1),
    EXCESSIVE_LOAD(2),
    PROTOCOL_ERROR(3);

    companion object {
        fun fromTag(tag: Int): ErrorCode? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    INITIAL(0),
    HANDSHAKING(1),
    READY(2),
    DRAINING(3),
    CLOSED(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}

/** ServerState matching the Idris2 ABI tags. */
enum class ServerState(val tag: Int) {
    IDLE(0),
    BOUND(1),
    LISTENING(2),
    PROCESSING(3),
    SHUTDOWN(4);

    companion object {
        fun fromTag(tag: Int): ServerState? = entries.find { it.tag == tag }
    }
}
