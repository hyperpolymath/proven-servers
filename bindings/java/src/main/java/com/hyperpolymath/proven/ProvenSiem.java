// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SIEM protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * SIEM protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSiem {
    private ProvenSiem() {}

    /** EventSeverity (tags 0-4). */
    public enum EventSeverity {
        INFO(0),
        LOW(1),
        MEDIUM(2),
        HIGH(3),
        CRITICAL(4);

        private final int tag;
        EventSeverity(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static EventSeverity fromTag(int tag) {
            for (EventSeverity v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** EventCategory (tags 0-6). */
    public enum EventCategory {
        AUTHENTICATION(0),
        NETWORK_TRAFFIC(1),
        FILE_ACTIVITY(2),
        PROCESS_EXECUTION(3),
        POLICY_VIOLATION(4),
        MALWARE(5),
        DATA_EXFILTRATION(6);

        private final int tag;
        EventCategory(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static EventCategory fromTag(int tag) {
            for (EventCategory v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CorrelationRule (tags 0-4). */
    public enum CorrelationRule {
        THRESHOLD(0),
        SEQUENCE(1),
        AGGREGATION(2),
        ABSENCE(3),
        STATISTICAL(4);

        private final int tag;
        CorrelationRule(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CorrelationRule fromTag(int tag) {
            for (CorrelationRule v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AlertState (tags 0-4). */
    public enum AlertState {
        NEW(0),
        ACKNOWLEDGED(1),
        IN_PROGRESS(2),
        RESOLVED(3),
        FALSE_POSITIVE(4);

        private final int tag;
        AlertState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AlertState fromTag(int tag) {
            for (AlertState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
