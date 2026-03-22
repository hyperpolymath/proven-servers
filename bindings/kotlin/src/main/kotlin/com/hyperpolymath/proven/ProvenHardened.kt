// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Hardened protocol types for proven-servers.

package com.hyperpolymath.proven

/** HardeningLevel matching the Idris2 ABI tags. */
enum class HardeningLevel(val tag: Int) {
    MINIMAL(0),
    STANDARD(1),
    HIGH(2),
    MAXIMUM(3);

    companion object {
        fun fromTag(tag: Int): HardeningLevel? = entries.find { it.tag == tag }
    }
}

/** SecurityControl matching the Idris2 ABI tags. */
enum class SecurityControl(val tag: Int) {
    ASLR(0),
    DEP(1),
    STACK_CANARY(2),
    CFI(3),
    SANDBOXING(4),
    SECURE_BOOT(5),
    AUDIT_LOG(6);

    companion object {
        fun fromTag(tag: Int): SecurityControl? = entries.find { it.tag == tag }
    }
}

/** ComplianceStandard matching the Idris2 ABI tags. */
enum class ComplianceStandard(val tag: Int) {
    CIS(0),
    STIG(1),
    NIST80053(2),
    PCI_DSS(3),
    FIPS140(4);

    companion object {
        fun fromTag(tag: Int): ComplianceStandard? = entries.find { it.tag == tag }
    }
}

/** AuditEvent matching the Idris2 ABI tags. */
enum class AuditEvent(val tag: Int) {
    PROCESS_START(0),
    FILE_ACCESS(1),
    NETWORK_CONN(2),
    PRIVILEGE_ESCALATION(3),
    CONFIG_CHANGE(4),
    AUTH_ATTEMPT(5);

    companion object {
        fun fromTag(tag: Int): AuditEvent? = entries.find { it.tag == tag }
    }
}

/** HardenedHealthStatus matching the Idris2 ABI tags. */
enum class HardenedHealthStatus(val tag: Int) {
    HEALTHY(0),
    DEGRADED(1),
    COMPROMISED(2),
    UNRESPONSIVE(3);

    companion object {
        fun fromTag(tag: Int): HardenedHealthStatus? = entries.find { it.tag == tag }
    }
}

/** ServerState matching the Idris2 ABI tags. */
enum class ServerState(val tag: Int) {
    IDLE(0),
    HARDENING(1),
    ACTIVE(2),
    AUDITING(3),
    SHUTDOWN(4);

    companion object {
        fun fromTag(tag: Int): ServerState? = entries.find { it.tag == tag }
    }
}
