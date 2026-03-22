// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Monitor protocol types for proven-servers.

package com.hyperpolymath.proven

/** CheckType matching the Idris2 ABI tags. */
enum class CheckType(val tag: Int) {
    HTTP(0),
    TCP(1),
    UDP(2),
    ICMP(3),
    DNS(4),
    CERTIFICATE(5),
    DISK(6),
    CPU(7),
    MEMORY(8),
    PROCESS(9),
    CUSTOM(10);

    companion object {
        fun fromTag(tag: Int): CheckType? = entries.find { it.tag == tag }
    }
}

/** Status matching the Idris2 ABI tags. */
enum class Status(val tag: Int) {
    UP(0),
    DOWN(1),
    DEGRADED(2),
    UNKNOWN(3),
    MAINTENANCE(4);

    companion object {
        fun fromTag(tag: Int): Status? = entries.find { it.tag == tag }
    }
}

/** AlertChannel matching the Idris2 ABI tags. */
enum class AlertChannel(val tag: Int) {
    EMAIL(0),
    SMS(1),
    WEBHOOK(2),
    SLACK(3),
    PAGER_DUTY(4);

    companion object {
        fun fromTag(tag: Int): AlertChannel? = entries.find { it.tag == tag }
    }
}

/** Severity matching the Idris2 ABI tags. */
enum class Severity(val tag: Int) {
    INFO(0),
    WARNING(1),
    ERROR(2),
    CRITICAL(3);

    companion object {
        fun fromTag(tag: Int): Severity? = entries.find { it.tag == tag }
    }
}

/** CheckState matching the Idris2 ABI tags. */
enum class CheckState(val tag: Int) {
    PENDING(0),
    CHECK_STATE__RUNNING(1),
    PASSED(2),
    FAILED(3),
    TIMEOUT(4),
    CS_ERROR(5);

    companion object {
        fun fromTag(tag: Int): CheckState? = entries.find { it.tag == tag }
    }
}

/** MonitorState matching the Idris2 ABI tags. */
enum class MonitorState(val tag: Int) {
    IDLE(0),
    CONFIGURED(1),
    MONITOR_STATE__RUNNING(2),
    MON_PAUSED(3),
    ALERTING(4),
    SHUTDOWN(5);

    companion object {
        fun fromTag(tag: Int): MonitorState? = entries.find { it.tag == tag }
    }
}
