// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// POP3 protocol types for proven-servers.

package com.hyperpolymath.proven

/** Command matching the Idris2 ABI tags. */
enum class Command(val tag: Int) {
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

    companion object {
        fun fromTag(tag: Int): Command? = entries.find { it.tag == tag }
    }
}

/** State matching the Idris2 ABI tags. */
enum class State(val tag: Int) {
    AUTHORIZATION(0),
    TRANSACTION(1),
    UPDATE(2);

    companion object {
        fun fromTag(tag: Int): State? = entries.find { it.tag == tag }
    }
}

/** Response matching the Idris2 ABI tags. */
enum class Response(val tag: Int) {
    RESPONSE__OK(0),
    ERR(1);

    companion object {
        fun fromTag(tag: Int): Response? = entries.find { it.tag == tag }
    }
}

/** Pop3Error matching the Idris2 ABI tags. */
enum class Pop3Error(val tag: Int) {
    POP3_ERROR__OK(0),
    INVALID_SLOT(1),
    NOT_ACTIVE(2),
    INVALID_TRANSITION(3),
    INVALID_COMMAND(4),
    AUTH_FAILED(5);

    companion object {
        fun fromTag(tag: Int): Pop3Error? = entries.find { it.tag == tag }
    }
}
