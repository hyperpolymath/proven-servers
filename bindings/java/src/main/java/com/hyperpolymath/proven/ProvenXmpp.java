// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// XMPP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * XMPP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenXmpp {
    private ProvenXmpp() {}

    /** StanzaType (tags 0-2). */
    public enum StanzaType {
        MESSAGE(0),
        PRESENCE(1),
        IQ(2);

        private final int tag;
        StanzaType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StanzaType fromTag(int tag) {
            for (StanzaType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** MessageType (tags 0-4). */
    public enum MessageType {
        CHAT(0),
        ERROR(1),
        GROUPCHAT(2),
        HEADLINE(3),
        NORMAL(4);

        private final int tag;
        MessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MessageType fromTag(int tag) {
            for (MessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PresenceType (tags 0-4). */
    public enum PresenceType {
        AVAILABLE(0),
        AWAY(1),
        DND(2),
        XA(3),
        UNAVAILABLE(4);

        private final int tag;
        PresenceType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PresenceType fromTag(int tag) {
            for (PresenceType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** IqType (tags 0-3). */
    public enum IqType {
        GET(0),
        SET(1),
        RESULT(2),
        ERROR(3);

        private final int tag;
        IqType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static IqType fromTag(int tag) {
            for (IqType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** StreamError (tags 0-8). */
    public enum StreamError {
        BAD_FORMAT(0),
        CONFLICT(1),
        CONNECTION_TIMEOUT(2),
        HOST_GONE(3),
        HOST_UNKNOWN(4),
        NOT_AUTHORIZED(5),
        POLICY_VIOLATION(6),
        RESOURCE_CONSTRAINT(7),
        SYSTEM_SHUTDOWN(8);

        private final int tag;
        StreamError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static StreamError fromTag(int tag) {
            for (StreamError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
