// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Deception protocol types for proven-servers.

package com.hyperpolymath.proven

/** DecoyType matching the Idris2 ABI tags. */
enum class DecoyType(val tag: Int) {
    SERVICE(0),
    CREDENTIAL(1),
    FILE(2),
    NETWORK(3),
    TOKEN(4),
    BREADCRUMB(5);

    companion object {
        fun fromTag(tag: Int): DecoyType? = entries.find { it.tag == tag }
    }
}

/** TriggerEvent matching the Idris2 ABI tags. */
enum class TriggerEvent(val tag: Int) {
    ACCESS(0),
    LOGIN(1),
    READ(2),
    WRITE(3),
    EXECUTE(4),
    SCAN(5);

    companion object {
        fun fromTag(tag: Int): TriggerEvent? = entries.find { it.tag == tag }
    }
}

/** AlertPriority matching the Idris2 ABI tags. */
enum class AlertPriority(val tag: Int) {
    LOW(0),
    MEDIUM(1),
    HIGH(2),
    CRITICAL(3);

    companion object {
        fun fromTag(tag: Int): AlertPriority? = entries.find { it.tag == tag }
    }
}

/** DecoyState matching the Idris2 ABI tags. */
enum class DecoyState(val tag: Int) {
    ACTIVE(0),
    TRIGGERED(1),
    DISABLED(2),
    EXPIRED(3);

    companion object {
        fun fromTag(tag: Int): DecoyState? = entries.find { it.tag == tag }
    }
}

/** ResponseAction matching the Idris2 ABI tags. */
enum class ResponseAction(val tag: Int) {
    ALERT(0),
    REDIRECT(1),
    DELAY(2),
    FINGERPRINT(3),
    ISOLATE(4);

    companion object {
        fun fromTag(tag: Int): ResponseAction? = entries.find { it.tag == tag }
    }
}

/** ServerState matching the Idris2 ABI tags. */
enum class ServerState(val tag: Int) {
    IDLE(0),
    CONFIGURED(1),
    MONITORING(2),
    RESPONDING(3),
    SHUTDOWN(4);

    companion object {
        fun fromTag(tag: Int): ServerState? = entries.find { it.tag == tag }
    }
}
