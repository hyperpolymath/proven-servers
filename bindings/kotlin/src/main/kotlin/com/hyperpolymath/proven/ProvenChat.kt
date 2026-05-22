// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Chat protocol types for proven-servers.

package com.hyperpolymath.proven

/** MessageType matching the Idris2 ABI tags. */
enum class MessageType(val tag: Int) {
    TEXT(0),
    IMAGE(1),
    FILE(2),
    SYSTEM(3),
    REACTION(4),
    EDIT(5),
    DELETE(6),
    REPLY(7),
    THREAD(8);

    companion object {
        fun fromTag(tag: Int): MessageType? = entries.find { it.tag == tag }
    }
}

/** PresenceStatus matching the Idris2 ABI tags. */
enum class PresenceStatus(val tag: Int) {
    ONLINE(0),
    AWAY(1),
    DND(2),
    INVISIBLE(3),
    OFFLINE(4);

    companion object {
        fun fromTag(tag: Int): PresenceStatus? = entries.find { it.tag == tag }
    }
}

/** RoomType matching the Idris2 ABI tags. */
enum class RoomType(val tag: Int) {
    DIRECT(0),
    GROUP(1),
    CHANNEL(2),
    BROADCAST(3);

    companion object {
        fun fromTag(tag: Int): RoomType? = entries.find { it.tag == tag }
    }
}

/** Permission matching the Idris2 ABI tags. */
enum class Permission(val tag: Int) {
    READ(0),
    WRITE(1),
    ADMIN(2),
    INVITE(3),
    KICK(4),
    BAN(5),
    PIN(6),
    DELETE_OTHERS(7);

    companion object {
        fun fromTag(tag: Int): Permission? = entries.find { it.tag == tag }
    }
}

/** Event matching the Idris2 ABI tags. */
enum class Event(val tag: Int) {
    MESSAGE_SENT(0),
    MESSAGE_DELIVERED(1),
    MESSAGE_READ(2),
    USER_JOINED(3),
    USER_LEFT(4),
    TYPING(5),
    ROOM_CREATED(6);

    companion object {
        fun fromTag(tag: Int): Event? = entries.find { it.tag == tag }
    }
}
