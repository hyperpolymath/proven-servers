// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PTP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * PTP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenPtp {
    private ProvenPtp() {}

    /** PtpMessageType (tags 0-9). */
    public enum PtpMessageType {
        SYNC(0),
        DELAY_REQ(1),
        PDELAY_REQ(2),
        PDELAY_RESP(3),
        FOLLOW_UP(4),
        DELAY_RESP(5),
        PDELAY_RESP_FOLLOW_UP(6),
        ANNOUNCE(7),
        SIGNALING(8),
        MANAGEMENT(9);

        private final int tag;
        PtpMessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PtpMessageType fromTag(int tag) {
            for (PtpMessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ClockClass (tags 0-3). */
    public enum ClockClass {
        PRIMARY_CLOCK(0),
        APPLICATION_SPECIFIC(1),
        SLAVE_ONLY(2),
        DEFAULT_CLASS(3);

        private final int tag;
        ClockClass(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ClockClass fromTag(int tag) {
            for (ClockClass v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PtpPortState (tags 0-8). */
    public enum PtpPortState {
        INITIALIZING(0),
        FAULTY(1),
        DISABLED(2),
        LISTENING(3),
        PRE_MASTER(4),
        MASTER(5),
        PASSIVE(6),
        UNCALIBRATED(7),
        SLAVE(8);

        private final int tag;
        PtpPortState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PtpPortState fromTag(int tag) {
            for (PtpPortState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DelayMechanism (tags 0-2). */
    public enum DelayMechanism {
        E2_E(0),
        P2_P(1),
        DM_DISABLED(2);

        private final int tag;
        DelayMechanism(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DelayMechanism fromTag(int tag) {
            for (DelayMechanism v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
