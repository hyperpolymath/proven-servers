// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTS protocol types for proven-servers.

package com.hyperpolymath.proven

/** RecordType matching the Idris2 ABI tags. */
enum class RecordType(val tag: Int) {
    END_OF_MESSAGE(0),
    NEXT_PROTOCOL(1),
    ERROR(2),
    WARNING(3),
    AEAD_ALGORITHM(4),
    COOKIE(5),
    COOKIE_PLACEHOLDER(6),
    NTSKE_SERVER(7),
    NTSKE_PORT(8);

    companion object {
        fun fromTag(tag: Int): RecordType? = entries.find { it.tag == tag }
    }
}

/** ErrorCode matching the Idris2 ABI tags. */
enum class ErrorCode(val tag: Int) {
    UNRECOGNIZED_CRITICAL(0),
    BAD_REQUEST(1),
    INTERNAL_ERROR(2);

    companion object {
        fun fromTag(tag: Int): ErrorCode? = entries.find { it.tag == tag }
    }
}

/** AeadAlgorithm matching the Idris2 ABI tags. */
enum class AeadAlgorithm(val tag: Int) {
    AEAD_AES128_GCM(0),
    AEAD_AES256_GCM(1),
    AEAD_AES_SIV_CMAC256(2);

    companion object {
        fun fromTag(tag: Int): AeadAlgorithm? = entries.find { it.tag == tag }
    }
}

/** HandshakeState matching the Idris2 ABI tags. */
enum class HandshakeState(val tag: Int) {
    INITIAL(0),
    HANDSHAKE_STATE__NEGOTIATING(1),
    HANDSHAKE_STATE__ESTABLISHED(2),
    FAILED(3);

    companion object {
        fun fromTag(tag: Int): HandshakeState? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    HANDSHAKING(1),
    SESSION_STATE__NEGOTIATING(2),
    SESSION_STATE__ESTABLISHED(3),
    CLOSING(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
