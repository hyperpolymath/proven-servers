// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// IRC protocol types for proven-servers.

package com.hyperpolymath.proven

/** Command matching the Idris2 ABI tags. */
enum class Command(val tag: Int) {
    NICK(0),
    USER(1),
    JOIN(2),
    PART(3),
    PRIVMSG(4),
    NOTICE(5),
    QUIT(6),
    PING(7),
    PONG(8),
    MODE(9),
    KICK(10),
    TOPIC(11),
    INVITE(12),
    NAMES(13),
    LIST(14),
    WHO(15),
    WHOIS(16);

    companion object {
        fun fromTag(tag: Int): Command? = entries.find { it.tag == tag }
    }
}

/** NumericReply matching the Idris2 ABI tags. */
enum class NumericReply(val tag: Int) {
    WELCOME(0),
    YOUR_HOST(1),
    CREATED(2),
    MY_INFO(3),
    BOUNCE(4),
    NUMERIC_REPLY__NICK_IN_USE(5),
    NO_SUCH_NICK(6),
    NO_SUCH_CHANNEL(7),
    CHANNEL_IS_FULL(8),
    INVITE_ONLY_CHAN(9),
    BANNED_FROM_CHAN(10);

    companion object {
        fun fromTag(tag: Int): NumericReply? = entries.find { it.tag == tag }
    }
}

/** ChannelMode matching the Idris2 ABI tags. */
enum class ChannelMode(val tag: Int) {
    OP(0),
    VOICE(1),
    BAN(2),
    LIMIT(3),
    CHANNEL_MODE__INVITE_ONLY(4),
    MODERATED(5),
    NO_EXTERNAL_MSGS(6),
    TOPIC_LOCK(7),
    SECRET(8),
    PRIVATE(9);

    companion object {
        fun fromTag(tag: Int): ChannelMode? = entries.find { it.tag == tag }
    }
}

/** State matching the Idris2 ABI tags. */
enum class State(val tag: Int) {
    DISCONNECTED(0),
    CONNECTING(1),
    REGISTERED(2),
    IN_CHANNEL(3),
    QUITTING(4);

    companion object {
        fun fromTag(tag: Int): State? = entries.find { it.tag == tag }
    }
}

/** IrcError matching the Idris2 ABI tags. */
enum class IrcError(val tag: Int) {
    NONE(0),
    IRC_ERROR__NICK_IN_USE(1),
    CHANNEL_FULL(2),
    IRC_ERROR__INVITE_ONLY(3),
    BANNED(4),
    NOT_REGISTERED(5);

    companion object {
        fun fromTag(tag: Int): IrcError? = entries.find { it.tag == tag }
    }
}
