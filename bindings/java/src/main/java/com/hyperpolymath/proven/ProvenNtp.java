// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NTP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * NTP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenNtp {
    private ProvenNtp() {}

    /** LeapIndicator (tags 0-3). */
    public enum LeapIndicator {
        NO_WARNING(0),
        LAST_MINUTE61(1),
        LAST_MINUTE59(2),
        UNSYNCHRONISED(3);

        private final int tag;
        LeapIndicator(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LeapIndicator fromTag(int tag) {
            for (LeapIndicator v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NtpMode (tags 0-7). */
    public enum NtpMode {
        RESERVED(0),
        SYMMETRIC_ACTIVE(1),
        SYMMETRIC_PASSIVE(2),
        CLIENT(3),
        SERVER(4),
        BROADCAST(5),
        CONTROL_MESSAGE(6),
        PRIVATE(7);

        private final int tag;
        NtpMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NtpMode fromTag(int tag) {
            for (NtpMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ExchangeState (tags 0-3). */
    public enum ExchangeState {
        IDLE(0),
        REQUEST_RECEIVED(1),
        TIMESTAMP_CALCULATED(2),
        RESPONSE_SENT(3);

        private final int tag;
        ExchangeState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ExchangeState fromTag(int tag) {
            for (ExchangeState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ClockDisciplineState (tags 0-4). */
    public enum ClockDisciplineState {
        UNSET(0),
        SPIKE(1),
        FREQ(2),
        SYNC(3),
        PANIC(4);

        private final int tag;
        ClockDisciplineState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ClockDisciplineState fromTag(int tag) {
            for (ClockDisciplineState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** KissCode (tags 0-3). */
    public enum KissCode {
        DENY(0),
        RSTR(1),
        RATE(2),
        OTHER(3);

        private final int tag;
        KissCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static KissCode fromTag(int tag) {
            for (KissCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NtpError (tags 0-5). */
    public enum NtpError {
        OK(0),
        INVALID_SLOT(1),
        NOT_ACTIVE(2),
        INVALID_PACKET(3),
        KISS_OF_DEATH(4),
        STRATUM_TOO_HIGH(5);

        private final int tag;
        NtpError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NtpError fromTag(int tag) {
            for (NtpError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
