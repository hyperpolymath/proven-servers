// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DoT protocol types for proven-servers.

package com.hyperpolymath.proven

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    CONNECTING(0),
    HANDSHAKING(1),
    ESTABLISHED(2),
    CLOSING(3),
    CLOSED(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}

/** PaddingStrategy matching the Idris2 ABI tags. */
enum class PaddingStrategy(val tag: Int) {
    NO_PADDING(0),
    BLOCK_PADDING(1),
    RANDOM_PADDING(2);

    companion object {
        fun fromTag(tag: Int): PaddingStrategy? = entries.find { it.tag == tag }
    }
}

/** ErrorReason matching the Idris2 ABI tags. */
enum class ErrorReason(val tag: Int) {
    HANDSHAKE_FAILED(0),
    CERTIFICATE_INVALID(1),
    TIMEOUT(2),
    UPSTREAM_ERROR(3);

    companion object {
        fun fromTag(tag: Int): ErrorReason? = entries.find { it.tag == tag }
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
