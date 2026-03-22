// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IMAP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * IMAP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenImap {
    private ProvenImap() {}

    /** Command (tags 0-13). */
    public enum Command {
        LOGIN(0),
        LOGOUT(1),
        SELECT(2),
        EXAMINE(3),
        CREATE(4),
        DELETE(5),
        RENAME(6),
        LIST(7),
        FETCH(8),
        STORE(9),
        SEARCH(10),
        COPY(11),
        NOOP(12),
        CAPABILITY(13);

        private final int tag;
        Command(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Command fromTag(int tag) {
            for (Command v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** State (tags 0-3). */
    public enum State {
        NOT_AUTHENTICATED(0),
        AUTHENTICATED(1),
        SELECTED(2),
        LOGOUT(3);

        private final int tag;
        State(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static State fromTag(int tag) {
            for (State v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Flag (tags 0-5). */
    public enum Flag {
        SEEN(0),
        ANSWERED(1),
        FLAGGED(2),
        DELETED(3),
        DRAFT(4),
        RECENT(5);

        private final int tag;
        Flag(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Flag fromTag(int tag) {
            for (Flag v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
