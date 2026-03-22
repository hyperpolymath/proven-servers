// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// POP3 protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * POP3 protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenPop3 {
    private ProvenPop3() {}

    /** Command (tags 0-10). */
    public enum Command {
        USER(0),
        PASS(1),
        STAT(2),
        LIST(3),
        RETR(4),
        DELE(5),
        NOOP(6),
        RSET(7),
        QUIT(8),
        TOP(9),
        UIDL(10);

        private final int tag;
        Command(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Command fromTag(int tag) {
            for (Command v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** State (tags 0-2). */
    public enum State {
        AUTHORIZATION(0),
        TRANSACTION(1),
        UPDATE(2);

        private final int tag;
        State(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static State fromTag(int tag) {
            for (State v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Response (tags 0-1). */
    public enum Response {
        OK(0),
        ERR(1);

        private final int tag;
        Response(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Response fromTag(int tag) {
            for (Response v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Pop3Error (tags 0-5). */
    public enum Pop3Error {
        OK(0),
        INVALID_SLOT(1),
        NOT_ACTIVE(2),
        INVALID_TRANSITION(3),
        INVALID_COMMAND(4),
        AUTH_FAILED(5);

        private final int tag;
        Pop3Error(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Pop3Error fromTag(int tag) {
            for (Pop3Error v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
