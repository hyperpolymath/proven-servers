// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Telnet protocol types for proven-servers.

package com.hyperpolymath.proven

/** Command matching the Idris2 ABI tags. */
enum class Command(val tag: Int) {
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

    companion object {
        fun fromTag(tag: Int): Command? = entries.find { it.tag == tag }
    }
}

/** TelnetOption matching the Idris2 ABI tags. */
enum class TelnetOption(val tag: Int) {
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

    companion object {
        fun fromTag(tag: Int): TelnetOption? = entries.find { it.tag == tag }
    }
}

/** NegotiationState matching the Idris2 ABI tags. */
enum class NegotiationState(val tag: Int) {
    INACTIVE(0),
    WILL_SENT(1),
    DO_SENT(2),
    NEGOTIATION_STATE__ACTIVE(3);

    companion object {
        fun fromTag(tag: Int): NegotiationState? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    NEGOTIATING(1),
    SESSION_STATE__ACTIVE(2),
    SUBNEG(3),
    CLOSING(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
