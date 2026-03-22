// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TACACS+ protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * TACACS+ protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenTacacs {
    private ProvenTacacs() {}

    /** PacketType (tags 0-2). */
    public enum PacketType {
        AUTHENTICATION(0),
        AUTHORIZATION(1),
        ACCOUNTING(2);

        private final int tag;
        PacketType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PacketType fromTag(int tag) {
            for (PacketType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AuthenType (tags 0-4). */
    public enum AuthenType {
        ASCII(0),
        PAP(1),
        CHAP(2),
        MS_CHAP_V1(3),
        MS_CHAP_V2(4);

        private final int tag;
        AuthenType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthenType fromTag(int tag) {
            for (AuthenType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AuthenAction (tags 0-2). */
    public enum AuthenAction {
        LOGIN(0),
        CHANGE_PASS(1),
        SEND_AUTH(2);

        private final int tag;
        AuthenAction(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthenAction fromTag(int tag) {
            for (AuthenAction v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AuthenStatus (tags 0-7). */
    public enum AuthenStatus {
        PASS(0),
        FAIL(1),
        GET_DATA(2),
        GET_USER(3),
        GET_PASS(4),
        RESTART(5),
        ERROR(6),
        FOLLOW(7);

        private final int tag;
        AuthenStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthenStatus fromTag(int tag) {
            for (AuthenStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AuthorStatus (tags 0-4). */
    public enum AuthorStatus {
        PASS_ADD(0),
        PASS_REPL(1),
        FAIL(2),
        ERROR(3),
        FOLLOW(4);

        private final int tag;
        AuthorStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthorStatus fromTag(int tag) {
            for (AuthorStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AcctStatus (tags 0-2). */
    public enum AcctStatus {
        SUCCESS(0),
        ERROR(1),
        FOLLOW(2);

        private final int tag;
        AcctStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AcctStatus fromTag(int tag) {
            for (AcctStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AcctFlag (tags 0-2). */
    public enum AcctFlag {
        START(0),
        STOP(1),
        WATCHDOG(2);

        private final int tag;
        AcctFlag(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AcctFlag fromTag(int tag) {
            for (AcctFlag v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        AUTHENTICATING(1),
        AUTHORIZING(2),
        ACTIVE(3),
        CLOSING(4);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
