// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// XMPP protocol types for proven-servers.

package com.hyperpolymath.proven

/** StanzaType matching the Idris2 ABI tags. */
enum class StanzaType(val tag: Int) {
    MESSAGE(0),
    PRESENCE(1),
    IQ(2);

    companion object {
        fun fromTag(tag: Int): StanzaType? = entries.find { it.tag == tag }
    }
}

/** MessageType matching the Idris2 ABI tags. */
enum class MessageType(val tag: Int) {
    CHAT(0),
    MESSAGE_TYPE__ERROR(1),
    GROUPCHAT(2),
    HEADLINE(3),
    NORMAL(4);

    companion object {
        fun fromTag(tag: Int): MessageType? = entries.find { it.tag == tag }
    }
}

/** PresenceType matching the Idris2 ABI tags. */
enum class PresenceType(val tag: Int) {
    AVAILABLE(0),
    AWAY(1),
    DND(2),
    XA(3),
    UNAVAILABLE(4);

    companion object {
        fun fromTag(tag: Int): PresenceType? = entries.find { it.tag == tag }
    }
}

/** IqType matching the Idris2 ABI tags. */
enum class IqType(val tag: Int) {
    GET(0),
    SET(1),
    RESULT(2),
    IQ_TYPE__ERROR(3);

    companion object {
        fun fromTag(tag: Int): IqType? = entries.find { it.tag == tag }
    }
}

/** StreamError matching the Idris2 ABI tags. */
enum class StreamError(val tag: Int) {
    BAD_FORMAT(0),
    CONFLICT(1),
    CONNECTION_TIMEOUT(2),
    HOST_GONE(3),
    HOST_UNKNOWN(4),
    NOT_AUTHORIZED(5),
    POLICY_VIOLATION(6),
    RESOURCE_CONSTRAINT(7),
    SYSTEM_SHUTDOWN(8);

    companion object {
        fun fromTag(tag: Int): StreamError? = entries.find { it.tag == tag }
    }
}
