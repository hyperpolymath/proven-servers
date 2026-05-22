// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BFD protocol types for proven-servers.

package com.hyperpolymath.proven

/** BfdState matching the Idris2 ABI tags. */
enum class BfdState(val tag: Int) {
    ADMIN_DOWN(0),
    DOWN(1),
    INIT(2),
    UP(3);

    companion object {
        fun fromTag(tag: Int): BfdState? = entries.find { it.tag == tag }
    }
}

/** Diagnostic matching the Idris2 ABI tags. */
enum class Diagnostic(val tag: Int) {
    NO_DIAGNOSTIC(0),
    CONTROL_DETECTION_TIME_EXPIRED(1),
    ECHO_FUNCTION_FAILED(2),
    NEIGHBOR_SIGNALED_SESSION_DOWN(3),
    FORWARDING_PLANE_RESET(4),
    PATH_DOWN(5),
    CONCATENATED_PATH_DOWN(6),
    ADMINISTRATIVELY_DOWN(7),
    REVERSE_CONCATENATED_PATH_DOWN(8);

    companion object {
        fun fromTag(tag: Int): Diagnostic? = entries.find { it.tag == tag }
    }
}

/** SessionMode matching the Idris2 ABI tags. */
enum class SessionMode(val tag: Int) {
    ASYNC_MODE(0),
    DEMAND_MODE(1);

    companion object {
        fun fromTag(tag: Int): SessionMode? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    SS_DOWN(1),
    NEGOTIATING(2),
    ESTABLISHED(3),
    TEARDOWN(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
