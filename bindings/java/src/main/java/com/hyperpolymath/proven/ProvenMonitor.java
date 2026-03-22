// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Monitor protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Monitor protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenMonitor {
    private ProvenMonitor() {}

    /** CheckType (tags 0-10). */
    public enum CheckType {
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

        private final int tag;
        CheckType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CheckType fromTag(int tag) {
            for (CheckType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Status (tags 0-4). */
    public enum Status {
        UP(0),
        DOWN(1),
        DEGRADED(2),
        UNKNOWN(3),
        MAINTENANCE(4);

        private final int tag;
        Status(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Status fromTag(int tag) {
            for (Status v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AlertChannel (tags 0-4). */
    public enum AlertChannel {
        EMAIL(0),
        SMS(1),
        WEBHOOK(2),
        SLACK(3),
        PAGER_DUTY(4);

        private final int tag;
        AlertChannel(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AlertChannel fromTag(int tag) {
            for (AlertChannel v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Severity (tags 0-3). */
    public enum Severity {
        INFO(0),
        WARNING(1),
        ERROR(2),
        CRITICAL(3);

        private final int tag;
        Severity(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Severity fromTag(int tag) {
            for (Severity v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CheckState (tags 0-5). */
    public enum CheckState {
        PENDING(0),
        RUNNING(1),
        PASSED(2),
        FAILED(3),
        TIMEOUT(4),
        CS_ERROR(5);

        private final int tag;
        CheckState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CheckState fromTag(int tag) {
            for (CheckState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** MonitorState (tags 0-5). */
    public enum MonitorState {
        IDLE(0),
        CONFIGURED(1),
        RUNNING(2),
        MON_PAUSED(3),
        ALERTING(4),
        SHUTDOWN(5);

        private final int tag;
        MonitorState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MonitorState fromTag(int tag) {
            for (MonitorState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
