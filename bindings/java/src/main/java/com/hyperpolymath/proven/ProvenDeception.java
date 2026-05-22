// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Deception protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Deception protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenDeception {
    private ProvenDeception() {}

    /** DecoyType (tags 0-5). */
    public enum DecoyType {
        SERVICE(0),
        CREDENTIAL(1),
        FILE(2),
        NETWORK(3),
        TOKEN(4),
        BREADCRUMB(5);

        private final int tag;
        DecoyType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DecoyType fromTag(int tag) {
            for (DecoyType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TriggerEvent (tags 0-5). */
    public enum TriggerEvent {
        ACCESS(0),
        LOGIN(1),
        READ(2),
        WRITE(3),
        EXECUTE(4),
        SCAN(5);

        private final int tag;
        TriggerEvent(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TriggerEvent fromTag(int tag) {
            for (TriggerEvent v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AlertPriority (tags 0-3). */
    public enum AlertPriority {
        LOW(0),
        MEDIUM(1),
        HIGH(2),
        CRITICAL(3);

        private final int tag;
        AlertPriority(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AlertPriority fromTag(int tag) {
            for (AlertPriority v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DecoyState (tags 0-3). */
    public enum DecoyState {
        ACTIVE(0),
        TRIGGERED(1),
        DISABLED(2),
        EXPIRED(3);

        private final int tag;
        DecoyState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DecoyState fromTag(int tag) {
            for (DecoyState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ResponseAction (tags 0-4). */
    public enum ResponseAction {
        ALERT(0),
        REDIRECT(1),
        DELAY(2),
        FINGERPRINT(3),
        ISOLATE(4);

        private final int tag;
        ResponseAction(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ResponseAction fromTag(int tag) {
            for (ResponseAction v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServerState (tags 0-4). */
    public enum ServerState {
        IDLE(0),
        CONFIGURED(1),
        MONITORING(2),
        RESPONDING(3),
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
