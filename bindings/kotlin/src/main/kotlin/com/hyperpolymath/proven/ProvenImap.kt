// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IMAP protocol types for proven-servers.

package com.hyperpolymath.proven

/** Command matching the Idris2 ABI tags. */
enum class Command(val tag: Int) {
    LOGIN(0),
    COMMAND__LOGOUT(1),
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

    companion object {
        fun fromTag(tag: Int): Command? = entries.find { it.tag == tag }
    }
}

/** State matching the Idris2 ABI tags. */
enum class State(val tag: Int) {
    NOT_AUTHENTICATED(0),
    AUTHENTICATED(1),
    SELECTED(2),
    STATE__LOGOUT(3);

    companion object {
        fun fromTag(tag: Int): State? = entries.find { it.tag == tag }
    }
}

/** Flag matching the Idris2 ABI tags. */
enum class Flag(val tag: Int) {
    SEEN(0),
    ANSWERED(1),
    FLAGGED(2),
    DELETED(3),
    DRAFT(4),
    RECENT(5);

    companion object {
        fun fromTag(tag: Int): Flag? = entries.find { it.tag == tag }
    }
}
