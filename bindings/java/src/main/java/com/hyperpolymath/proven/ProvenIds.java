// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IDS protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * IDS protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenIds {
    private ProvenIds() {}

    /** AlertSeverity (tags 0-3). */
    public enum AlertSeverity {
        LOW(0),
        MEDIUM(1),
        HIGH(2),
        CRITICAL(3);

        private final int tag;
        AlertSeverity(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AlertSeverity fromTag(int tag) {
            for (AlertSeverity v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DetectionMethod (tags 0-3). */
    public enum DetectionMethod {
        SIGNATURE(0),
        ANOMALY(1),
        STATEFUL(2),
        HEURISTIC(3);

        private final int tag;
        DetectionMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DetectionMethod fromTag(int tag) {
            for (DetectionMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** IdsProtocol (tags 0-6). */
    public enum IdsProtocol {
        TCP(0),
        UDP(1),
        ICMP(2),
        DNS(3),
        HTTP(4),
        TLS(5),
        SSH(6);

        private final int tag;
        IdsProtocol(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static IdsProtocol fromTag(int tag) {
            for (IdsProtocol v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** IdsAction (tags 0-4). */
    public enum IdsAction {
        ALERT(0),
        DROP(1),
        LOG(2),
        BLOCK(3),
        PASS(4);

        private final int tag;
        IdsAction(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static IdsAction fromTag(int tag) {
            for (IdsAction v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Direction (tags 0-2). */
    public enum Direction {
        INBOUND(0),
        OUTBOUND(1),
        BOTH(2);

        private final int tag;
        Direction(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Direction fromTag(int tag) {
            for (Direction v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ThreatLevel (tags 0-4). */
    public enum ThreatLevel {
        INFO(0),
        LOW(1),
        MEDIUM(2),
        HIGH(3),
        CRITICAL(4);

        private final int tag;
        ThreatLevel(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ThreatLevel fromTag(int tag) {
            for (ThreatLevel v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
