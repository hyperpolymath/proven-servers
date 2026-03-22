// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Honeypot protocol types for proven-servers.

package com.hyperpolymath.proven

/** ServiceEmulation matching the Idris2 ABI tags. */
enum class ServiceEmulation(val tag: Int) {
    SSH(0),
    HTTP(1),
    FTP(2),
    SMTP(3),
    TELNET(4),
    MYSQL(5),
    RDP(6);

    companion object {
        fun fromTag(tag: Int): ServiceEmulation? = entries.find { it.tag == tag }
    }
}

/** InteractionLevel matching the Idris2 ABI tags. */
enum class InteractionLevel(val tag: Int) {
    LOW(0),
    MEDIUM(1),
    HIGH(2);

    companion object {
        fun fromTag(tag: Int): InteractionLevel? = entries.find { it.tag == tag }
    }
}

/** HoneypotAlertSeverity matching the Idris2 ABI tags. */
enum class HoneypotAlertSeverity(val tag: Int) {
    INFO(0),
    AS_LOW(1),
    AS_MEDIUM(2),
    AS_HIGH(3),
    CRITICAL(4);

    companion object {
        fun fromTag(tag: Int): HoneypotAlertSeverity? = entries.find { it.tag == tag }
    }
}

/** AttackerAction matching the Idris2 ABI tags. */
enum class AttackerAction(val tag: Int) {
    SCAN(0),
    BRUTE_FORCE(1),
    EXPLOIT(2),
    PAYLOAD(3),
    LATERAL(4),
    EXFILTRATION(5);

    companion object {
        fun fromTag(tag: Int): AttackerAction? = entries.find { it.tag == tag }
    }
}

/** ServerState matching the Idris2 ABI tags. */
enum class ServerState(val tag: Int) {
    IDLE(0),
    DEPLOYED(1),
    ENGAGED(2),
    SHUTDOWN(3);

    companion object {
        fun fromTag(tag: Int): ServerState? = entries.find { it.tag == tag }
    }
}
