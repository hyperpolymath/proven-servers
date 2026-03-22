// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Container protocol types for proven-servers.

package com.hyperpolymath.proven

/** ContainerState matching the Idris2 ABI tags. */
enum class ContainerState(val tag: Int) {
    CREATING(0),
    RUNNING(1),
    PAUSED(2),
    RESTARTING(3),
    STOPPED(4),
    REMOVING(5),
    DEAD(6);

    companion object {
        fun fromTag(tag: Int): ContainerState? = entries.find { it.tag == tag }
    }
}

/** ContainerOperation matching the Idris2 ABI tags. */
enum class ContainerOperation(val tag: Int) {
    CREATE(0),
    START(1),
    STOP(2),
    RESTART(3),
    PAUSE(4),
    UNPAUSE(5),
    KILL(6),
    REMOVE(7),
    EXEC(8),
    LOGS(9),
    INSPECT(10);

    companion object {
        fun fromTag(tag: Int): ContainerOperation? = entries.find { it.tag == tag }
    }
}

/** NetworkMode matching the Idris2 ABI tags. */
enum class NetworkMode(val tag: Int) {
    BRIDGE(0),
    HOST(1),
    NONE(2),
    OVERLAY(3),
    MACVLAN(4);

    companion object {
        fun fromTag(tag: Int): NetworkMode? = entries.find { it.tag == tag }
    }
}

/** VolumeType matching the Idris2 ABI tags. */
enum class VolumeType(val tag: Int) {
    BIND(0),
    NAMED(1),
    TMPFS(2);

    companion object {
        fun fromTag(tag: Int): VolumeType? = entries.find { it.tag == tag }
    }
}

/** RestartPolicy matching the Idris2 ABI tags. */
enum class RestartPolicy(val tag: Int) {
    NO(0),
    ALWAYS(1),
    ON_FAILURE(2),
    UNLESS_STOPPED(3);

    companion object {
        fun fromTag(tag: Int): RestartPolicy? = entries.find { it.tag == tag }
    }
}

/** HealthStatus matching the Idris2 ABI tags. */
enum class HealthStatus(val tag: Int) {
    STARTING(0),
    HEALTHY(1),
    UNHEALTHY(2),
    NO_CHECK(3);

    companion object {
        fun fromTag(tag: Int): HealthStatus? = entries.find { it.tag == tag }
    }
}
