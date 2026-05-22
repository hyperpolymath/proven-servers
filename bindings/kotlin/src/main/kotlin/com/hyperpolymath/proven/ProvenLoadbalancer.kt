// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Load Balancer protocol types for proven-servers.

package com.hyperpolymath.proven

/** Algorithm matching the Idris2 ABI tags. */
enum class Algorithm(val tag: Int) {
    ROUND_ROBIN(0),
    LEAST_CONNECTIONS(1),
    IP_HASH(2),
    RANDOM(3),
    WEIGHTED_ROUND_ROBIN(4),
    LEAST_RESPONSE_TIME(5);

    companion object {
        fun fromTag(tag: Int): Algorithm? = entries.find { it.tag == tag }
    }
}

/** HealthCheckType matching the Idris2 ABI tags. */
enum class HealthCheckType(val tag: Int) {
    HEALTH_CHECK_TYPE__HTTP(0),
    HEALTH_CHECK_TYPE__TCP(1),
    HEALTH_CHECK_TYPE__GRPC(2),
    SCRIPT(3);

    companion object {
        fun fromTag(tag: Int): HealthCheckType? = entries.find { it.tag == tag }
    }
}

/** BackendState matching the Idris2 ABI tags. */
enum class BackendState(val tag: Int) {
    HEALTHY(0),
    UNHEALTHY(1),
    DRAINING(2),
    DISABLED(3);

    companion object {
        fun fromTag(tag: Int): BackendState? = entries.find { it.tag == tag }
    }
}

/** SessionPersistence matching the Idris2 ABI tags. */
enum class SessionPersistence(val tag: Int) {
    NONE(0),
    COOKIE(1),
    SOURCE_IP(2),
    HEADER(3);

    companion object {
        fun fromTag(tag: Int): SessionPersistence? = entries.find { it.tag == tag }
    }
}

/** LbProtocol matching the Idris2 ABI tags. */
enum class LbProtocol(val tag: Int) {
    LB_PROTOCOL__HTTP(0),
    HTTPS(1),
    LB_PROTOCOL__TCP(2),
    UDP(3),
    LB_PROTOCOL__GRPC(4);

    companion object {
        fun fromTag(tag: Int): LbProtocol? = entries.find { it.tag == tag }
    }
}
