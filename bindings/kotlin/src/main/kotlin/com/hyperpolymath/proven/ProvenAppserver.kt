// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// App Server protocol types for proven-servers.

package com.hyperpolymath.proven

/** RequestType matching the Idris2 ABI tags. */
enum class RequestType(val tag: Int) {
    HTTP(0),
    WEB_SOCKET(1),
    GRPC(2),
    GRAPH_QL(3);

    companion object {
        fun fromTag(tag: Int): RequestType? = entries.find { it.tag == tag }
    }
}

/** LifecycleState matching the Idris2 ABI tags. */
enum class LifecycleState(val tag: Int) {
    INITIALIZING(0),
    STARTING(1),
    RUNNING(2),
    DRAINING(3),
    STOPPING(4),
    STOPPED(5);

    companion object {
        fun fromTag(tag: Int): LifecycleState? = entries.find { it.tag == tag }
    }
}

/** HealthCheck matching the Idris2 ABI tags. */
enum class HealthCheck(val tag: Int) {
    LIVENESS(0),
    READINESS(1),
    STARTUP(2);

    companion object {
        fun fromTag(tag: Int): HealthCheck? = entries.find { it.tag == tag }
    }
}

/** DeployStrategy matching the Idris2 ABI tags. */
enum class DeployStrategy(val tag: Int) {
    ROLLING_UPDATE(0),
    BLUE_GREEN(1),
    CANARY(2),
    RECREATE(3);

    companion object {
        fun fromTag(tag: Int): DeployStrategy? = entries.find { it.tag == tag }
    }
}

/** ErrorCategory matching the Idris2 ABI tags. */
enum class ErrorCategory(val tag: Int) {
    CLIENT_ERROR(0),
    SERVER_ERROR(1),
    TIMEOUT(2),
    CIRCUIT_OPEN(3),
    RATE_LIMITED(4);

    companion object {
        fun fromTag(tag: Int): ErrorCategory? = entries.find { it.tag == tag }
    }
}
