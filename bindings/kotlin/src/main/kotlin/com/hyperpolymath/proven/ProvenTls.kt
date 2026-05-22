// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TLS protocol types for proven-servers.

package com.hyperpolymath.proven

/** TlsState matching the Idris2 ABI tags. */
enum class TlsState(val tag: Int) {
    TLS_IDLE(0),
    TLS_CLIENT_HELLO(1),
    TLS_SERVER_HELLO(2),
    TLS_NEGOTIATING(3),
    TLS_ESTABLISHED(4),
    TLS_RENEGOTIATING(5),
    TLS_SHUTDOWN(6);

    companion object {
        fun fromTag(tag: Int): TlsState? = entries.find { it.tag == tag }
    }
}

/** TlsVersion matching the Idris2 ABI tags. */
enum class TlsVersion(val tag: Int) {
    TLS12(0),
    TLS13(1);

    companion object {
        fun fromTag(tag: Int): TlsVersion? = entries.find { it.tag == tag }
    }
}

/** CipherSuite matching the Idris2 ABI tags. */
enum class CipherSuite(val tag: Int) {
    AES_GCM128_SHA256(0),
    AES_GCM256_SHA384(1),
    CHACHA20_POLY1305_SHA256(2),
    AES_CCM128_SHA256(3);

    companion object {
        fun fromTag(tag: Int): CipherSuite? = entries.find { it.tag == tag }
    }
}
