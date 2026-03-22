// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TACACS+ protocol types for proven-servers.

package com.hyperpolymath.proven

/** PacketType matching the Idris2 ABI tags. */
enum class PacketType(val tag: Int) {
    AUTHENTICATION(0),
    AUTHORIZATION(1),
    ACCOUNTING(2);

    companion object {
        fun fromTag(tag: Int): PacketType? = entries.find { it.tag == tag }
    }
}

/** AuthenType matching the Idris2 ABI tags. */
enum class AuthenType(val tag: Int) {
    ASCII(0),
    PAP(1),
    CHAP(2),
    MS_CHAP_V1(3),
    MS_CHAP_V2(4);

    companion object {
        fun fromTag(tag: Int): AuthenType? = entries.find { it.tag == tag }
    }
}

/** AuthenAction matching the Idris2 ABI tags. */
enum class AuthenAction(val tag: Int) {
    LOGIN(0),
    CHANGE_PASS(1),
    SEND_AUTH(2);

    companion object {
        fun fromTag(tag: Int): AuthenAction? = entries.find { it.tag == tag }
    }
}

/** AuthenStatus matching the Idris2 ABI tags. */
enum class AuthenStatus(val tag: Int) {
    PASS(0),
    AUTHEN_STATUS__FAIL(1),
    GET_DATA(2),
    GET_USER(3),
    GET_PASS(4),
    RESTART(5),
    AUTHEN_STATUS__ERROR(6),
    AUTHEN_STATUS__FOLLOW(7);

    companion object {
        fun fromTag(tag: Int): AuthenStatus? = entries.find { it.tag == tag }
    }
}

/** AuthorStatus matching the Idris2 ABI tags. */
enum class AuthorStatus(val tag: Int) {
    PASS_ADD(0),
    PASS_REPL(1),
    AUTHOR_STATUS__FAIL(2),
    AUTHOR_STATUS__ERROR(3),
    AUTHOR_STATUS__FOLLOW(4);

    companion object {
        fun fromTag(tag: Int): AuthorStatus? = entries.find { it.tag == tag }
    }
}

/** AcctStatus matching the Idris2 ABI tags. */
enum class AcctStatus(val tag: Int) {
    SUCCESS(0),
    ACCT_STATUS__ERROR(1),
    ACCT_STATUS__FOLLOW(2);

    companion object {
        fun fromTag(tag: Int): AcctStatus? = entries.find { it.tag == tag }
    }
}

/** AcctFlag matching the Idris2 ABI tags. */
enum class AcctFlag(val tag: Int) {
    START(0),
    STOP(1),
    WATCHDOG(2);

    companion object {
        fun fromTag(tag: Int): AcctFlag? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    AUTHENTICATING(1),
    AUTHORIZING(2),
    ACTIVE(3),
    CLOSING(4);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
