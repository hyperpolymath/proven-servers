// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Honeypot protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Honeypot protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenHoneypot {
    private ProvenHoneypot() {}

    /** ServiceEmulation (tags 0-6). */
    public enum ServiceEmulation {
        SSH(0),
        HTTP(1),
        FTP(2),
        SMTP(3),
        TELNET(4),
        MYSQL(5),
        RDP(6);

        private final int tag;
        ServiceEmulation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ServiceEmulation fromTag(int tag) {
            for (ServiceEmulation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** InteractionLevel (tags 0-2). */
    public enum InteractionLevel {
        LOW(0),
        MEDIUM(1),
        HIGH(2);

        private final int tag;
        InteractionLevel(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static InteractionLevel fromTag(int tag) {
            for (InteractionLevel v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HoneypotAlertSeverity (tags 0-4). */
    public enum HoneypotAlertSeverity {
        INFO(0),
        AS_LOW(1),
        AS_MEDIUM(2),
        AS_HIGH(3),
        CRITICAL(4);

        private final int tag;
        HoneypotAlertSeverity(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HoneypotAlertSeverity fromTag(int tag) {
            for (HoneypotAlertSeverity v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AttackerAction (tags 0-5). */
    public enum AttackerAction {
        SCAN(0),
        BRUTE_FORCE(1),
        EXPLOIT(2),
        PAYLOAD(3),
        LATERAL(4),
        EXFILTRATION(5);

        private final int tag;
        AttackerAction(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AttackerAction fromTag(int tag) {
            for (AttackerAction v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServerState (tags 0-3). */
    public enum ServerState {
        IDLE(0),
        DEPLOYED(1),
        ENGAGED(2),
        SHUTDOWN(3);

        private final int tag;
        ServerState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ServerState fromTag(int tag) {
            for (ServerState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
