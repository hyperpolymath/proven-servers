// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// API Server protocol types for proven-servers.

package com.hyperpolymath.proven

/** AuthScheme matching the Idris2 ABI tags. */
enum class AuthScheme(val tag: Int) {
    API_KEY(0),
    BEARER(1),
    BASIC(2),
    O_AUTH2(3),
    HMAC(4),
    MTLS(5);

    companion object {
        fun fromTag(tag: Int): AuthScheme? = entries.find { it.tag == tag }
    }
}

/** RateLimitStrategy matching the Idris2 ABI tags. */
enum class RateLimitStrategy(val tag: Int) {
    FIXED_WINDOW(0),
    SLIDING_WINDOW(1),
    TOKEN_BUCKET(2),
    LEAKY_BUCKET(3);

    companion object {
        fun fromTag(tag: Int): RateLimitStrategy? = entries.find { it.tag == tag }
    }
}

/** ApiVersion matching the Idris2 ABI tags. */
enum class ApiVersion(val tag: Int) {
    V1(0),
    V2(1),
    V3(2),
    LATEST(3),
    DEPRECATED(4);

    companion object {
        fun fromTag(tag: Int): ApiVersion? = entries.find { it.tag == tag }
    }
}

/** ResponseFormat matching the Idris2 ABI tags. */
enum class ResponseFormat(val tag: Int) {
    JSON(0),
    XML(1),
    PROTOBUF(2),
    MESSAGE_PACK(3);

    companion object {
        fun fromTag(tag: Int): ResponseFormat? = entries.find { it.tag == tag }
    }
}

/** GatewayError matching the Idris2 ABI tags. */
enum class GatewayError(val tag: Int) {
    UNAUTHORIZED(0),
    RATE_LIMITED(1),
    NOT_FOUND(2),
    BAD_REQUEST(3),
    SERVICE_UNAVAILABLE(4),
    CIRCUIT_OPEN(5);

    companion object {
        fun fromTag(tag: Int): GatewayError? = entries.find { it.tag == tag }
    }
}
