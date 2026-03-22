// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Telnet protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Telnet protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenTelnet {
    private ProvenTelnet() {}

    /** Command (tags 0-15). */
    public enum Command {
        SE(0),
        NOP(1),
        DATA_MARK(2),
        BREAK(3),
        INTERRUPT_PROCESS(4),
        ABORT_OUTPUT(5),
        ARE_YOU_THERE(6),
        ERASE_CHAR(7),
        ERASE_LINE(8),
        GO_AHEAD(9),
        SB(10),
        WILL(11),
        WONT(12),
        DO(13),
        DONT(14),
        IAC(15);

        private final int tag;
        Command(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Command fromTag(int tag) {
            for (Command v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TelnetOption (tags 0-9). */
    public enum TelnetOption {
        ECHO(0),
        SUPPRESS_GO_AHEAD(1),
        STATUS(2),
        TIMING_MARK(3),
        TERMINAL_TYPE(4),
        WINDOW_SIZE(5),
        TERMINAL_SPEED(6),
        REMOTE_FLOW_CONTROL(7),
        LINEMODE(8),
        ENVIRONMENT(9);

        private final int tag;
        TelnetOption(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TelnetOption fromTag(int tag) {
            for (TelnetOption v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NegotiationState (tags 0-3). */
    public enum NegotiationState {
        INACTIVE(0),
        WILL_SENT(1),
        DO_SENT(2),
        ACTIVE(3);

        private final int tag;
        NegotiationState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NegotiationState fromTag(int tag) {
            for (NegotiationState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-4). */
    public enum SessionState {
        IDLE(0),
        NEGOTIATING(1),
        ACTIVE(2),
        SUBNEG(3),
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
