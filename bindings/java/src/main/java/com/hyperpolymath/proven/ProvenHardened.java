// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Hardened protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Hardened protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenHardened {
    private ProvenHardened() {}

    /** HardeningLevel (tags 0-3). */
    public enum HardeningLevel {
        MINIMAL(0),
        STANDARD(1),
        HIGH(2),
        MAXIMUM(3);

        private final int tag;
        HardeningLevel(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HardeningLevel fromTag(int tag) {
            for (HardeningLevel v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SecurityControl (tags 0-6). */
    public enum SecurityControl {
        ASLR(0),
        DEP(1),
        STACK_CANARY(2),
        CFI(3),
        SANDBOXING(4),
        SECURE_BOOT(5),
        AUDIT_LOG(6);

        private final int tag;
        SecurityControl(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SecurityControl fromTag(int tag) {
            for (SecurityControl v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ComplianceStandard (tags 0-4). */
    public enum ComplianceStandard {
        CIS(0),
        STIG(1),
        NIST80053(2),
        PCI_DSS(3),
        FIPS140(4);

        private final int tag;
        ComplianceStandard(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ComplianceStandard fromTag(int tag) {
            for (ComplianceStandard v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AuditEvent (tags 0-5). */
    public enum AuditEvent {
        PROCESS_START(0),
        FILE_ACCESS(1),
        NETWORK_CONN(2),
        PRIVILEGE_ESCALATION(3),
        CONFIG_CHANGE(4),
        AUTH_ATTEMPT(5);

        private final int tag;
        AuditEvent(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuditEvent fromTag(int tag) {
            for (AuditEvent v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HardenedHealthStatus (tags 0-3). */
    public enum HardenedHealthStatus {
        HEALTHY(0),
        DEGRADED(1),
        COMPROMISED(2),
        UNRESPONSIVE(3);

        private final int tag;
        HardenedHealthStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HardenedHealthStatus fromTag(int tag) {
            for (HardenedHealthStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServerState (tags 0-4). */
    public enum ServerState {
        IDLE(0),
        HARDENING(1),
        ACTIVE(2),
        AUDITING(3),
        SHUTDOWN(4);

        private final int tag;
        ServerState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ServerState fromTag(int tag) {
            for (ServerState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
