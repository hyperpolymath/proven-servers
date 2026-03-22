// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Syslog protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Syslog protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSyslog {
    private ProvenSyslog() {}

    /** Severity (tags 0-7). */
    public enum Severity {
        EMERGENCY(0),
        ALERT(1),
        CRITICAL(2),
        ERROR(3),
        WARNING(4),
        NOTICE(5),
        INFORMATIONAL(6),
        DEBUG(7);

        private final int tag;
        Severity(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Severity fromTag(int tag) {
            for (Severity v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Facility (tags 0-23). */
    public enum Facility {
        KERN(0),
        USER(1),
        MAIL(2),
        DAEMON(3),
        AUTH(4),
        SYSLOG(5),
        LPR(6),
        NEWS(7),
        UUCP(8),
        CRON(9),
        AUTH_PRIV(10),
        FTP(11),
        NTP(12),
        AUDIT(13),
        ALERT(14),
        CLOCK(15),
        LOCAL0(16),
        LOCAL1(17),
        LOCAL2(18),
        LOCAL3(19),
        LOCAL4(20),
        LOCAL5(21),
        LOCAL6(22),
        LOCAL7(23);

        private final int tag;
        Facility(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Facility fromTag(int tag) {
            for (Facility v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Transport (tags 0-2). */
    public enum Transport {
        UDP514(0),
        TCP514(1),
        TLS6514(2);

        private final int tag;
        Transport(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Transport fromTag(int tag) {
            for (Transport v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
