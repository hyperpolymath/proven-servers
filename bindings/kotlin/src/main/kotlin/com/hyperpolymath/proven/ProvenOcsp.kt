// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OCSP protocol types for proven-servers.

package com.hyperpolymath.proven

/** CertStatus matching the Idris2 ABI tags. */
enum class CertStatus(val tag: Int) {
    GOOD(0),
    REVOKED(1),
    UNKNOWN(2);

    companion object {
        fun fromTag(tag: Int): CertStatus? = entries.find { it.tag == tag }
    }
}

/** ResponseStatus matching the Idris2 ABI tags. */
enum class ResponseStatus(val tag: Int) {
    SUCCESSFUL(0),
    MALFORMED_REQUEST(1),
    INTERNAL_ERROR(2),
    TRY_LATER(3),
    SIG_REQUIRED(4),
    UNAUTHORIZED(5);

    companion object {
        fun fromTag(tag: Int): ResponseStatus? = entries.find { it.tag == tag }
    }
}

/** HashAlgorithm matching the Idris2 ABI tags. */
enum class HashAlgorithm(val tag: Int) {
    SHA1(0),
    SHA256(1),
    SHA384(2),
    SHA512(3);

    companion object {
        fun fromTag(tag: Int): HashAlgorithm? = entries.find { it.tag == tag }
    }
}

/** ResponderState matching the Idris2 ABI tags. */
enum class ResponderState(val tag: Int) {
    IDLE(0),
    READY(1),
    PROCESSING(2),
    SIGNING(3),
    CLOSING(4);

    companion object {
        fun fromTag(tag: Int): ResponderState? = entries.find { it.tag == tag }
    }
}
