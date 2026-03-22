// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SIEM protocol types for proven-servers.

package com.hyperpolymath.proven

/** EventSeverity matching the Idris2 ABI tags. */
enum class EventSeverity(val tag: Int) {
    INFO(0),
    LOW(1),
    MEDIUM(2),
    HIGH(3),
    CRITICAL(4);

    companion object {
        fun fromTag(tag: Int): EventSeverity? = entries.find { it.tag == tag }
    }
}

/** EventCategory matching the Idris2 ABI tags. */
enum class EventCategory(val tag: Int) {
    AUTHENTICATION(0),
    NETWORK_TRAFFIC(1),
    FILE_ACTIVITY(2),
    PROCESS_EXECUTION(3),
    POLICY_VIOLATION(4),
    MALWARE(5),
    DATA_EXFILTRATION(6);

    companion object {
        fun fromTag(tag: Int): EventCategory? = entries.find { it.tag == tag }
    }
}

/** CorrelationRule matching the Idris2 ABI tags. */
enum class CorrelationRule(val tag: Int) {
    THRESHOLD(0),
    SEQUENCE(1),
    AGGREGATION(2),
    ABSENCE(3),
    STATISTICAL(4);

    companion object {
        fun fromTag(tag: Int): CorrelationRule? = entries.find { it.tag == tag }
    }
}

/** AlertState matching the Idris2 ABI tags. */
enum class AlertState(val tag: Int) {
    NEW(0),
    ACKNOWLEDGED(1),
    IN_PROGRESS(2),
    RESOLVED(3),
    FALSE_POSITIVE(4);

    companion object {
        fun fromTag(tag: Int): AlertState? = entries.find { it.tag == tag }
    }
}
