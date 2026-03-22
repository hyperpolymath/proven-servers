// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IDS protocol types for proven-servers.

package com.hyperpolymath.proven

/** AlertSeverity matching the Idris2 ABI tags. */
enum class AlertSeverity(val tag: Int) {
    ALERT_SEVERITY__LOW(0),
    ALERT_SEVERITY__MEDIUM(1),
    ALERT_SEVERITY__HIGH(2),
    ALERT_SEVERITY__CRITICAL(3);

    companion object {
        fun fromTag(tag: Int): AlertSeverity? = entries.find { it.tag == tag }
    }
}

/** DetectionMethod matching the Idris2 ABI tags. */
enum class DetectionMethod(val tag: Int) {
    SIGNATURE(0),
    ANOMALY(1),
    STATEFUL(2),
    HEURISTIC(3);

    companion object {
        fun fromTag(tag: Int): DetectionMethod? = entries.find { it.tag == tag }
    }
}

/** IdsProtocol matching the Idris2 ABI tags. */
enum class IdsProtocol(val tag: Int) {
    TCP(0),
    UDP(1),
    ICMP(2),
    DNS(3),
    HTTP(4),
    TLS(5),
    SSH(6);

    companion object {
        fun fromTag(tag: Int): IdsProtocol? = entries.find { it.tag == tag }
    }
}

/** IdsAction matching the Idris2 ABI tags. */
enum class IdsAction(val tag: Int) {
    ALERT(0),
    DROP(1),
    LOG(2),
    BLOCK(3),
    PASS(4);

    companion object {
        fun fromTag(tag: Int): IdsAction? = entries.find { it.tag == tag }
    }
}

/** Direction matching the Idris2 ABI tags. */
enum class Direction(val tag: Int) {
    INBOUND(0),
    OUTBOUND(1),
    BOTH(2);

    companion object {
        fun fromTag(tag: Int): Direction? = entries.find { it.tag == tag }
    }
}

/** ThreatLevel matching the Idris2 ABI tags. */
enum class ThreatLevel(val tag: Int) {
    INFO(0),
    THREAT_LEVEL__LOW(1),
    THREAT_LEVEL__MEDIUM(2),
    THREAT_LEVEL__HIGH(3),
    THREAT_LEVEL__CRITICAL(4);

    companion object {
        fun fromTag(tag: Int): ThreatLevel? = entries.find { it.tag == tag }
    }
}
