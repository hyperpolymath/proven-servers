// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Proxy protocol types for proven-servers.

package com.hyperpolymath.proven

/** ProxyMode matching the Idris2 ABI tags. */
enum class ProxyMode(val tag: Int) {
    FORWARD(0),
    REVERSE(1);

    companion object {
        fun fromTag(tag: Int): ProxyMode? = entries.find { it.tag == tag }
    }
}

/** HopByHopHeader matching the Idris2 ABI tags. */
enum class HopByHopHeader(val tag: Int) {
    CONNECTION(0),
    KEEP_ALIVE(1),
    PROXY_AUTH(2),
    PROXY_AUTHZ(3),
    TE(4),
    TRAILERS(5),
    TRANSFER_ENCODING(6),
    UPGRADE(7);

    companion object {
        fun fromTag(tag: Int): HopByHopHeader? = entries.find { it.tag == tag }
    }
}

/** CacheDirective matching the Idris2 ABI tags. */
enum class CacheDirective(val tag: Int) {
    NO_CACHE(0),
    NO_STORE(1),
    MAX_AGE(2),
    PUBLIC(3),
    PRIVATE(4),
    MUST_REVALIDATE(5);

    companion object {
        fun fromTag(tag: Int): CacheDirective? = entries.find { it.tag == tag }
    }
}

/** ProxyError matching the Idris2 ABI tags. */
enum class ProxyError(val tag: Int) {
    BAD_GATEWAY(0),
    GATEWAY_TIMEOUT(1),
    UPSTREAM_REFUSED(2),
    UPSTREAM_TLS(3);

    companion object {
        fun fromTag(tag: Int): ProxyError? = entries.find { it.tag == tag }
    }
}
