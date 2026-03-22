// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Federation protocol types for proven-servers.

package com.hyperpolymath.proven

/** ActivityType matching the Idris2 ABI tags. */
enum class ActivityType(val tag: Int) {
    CREATE(0),
    UPDATE(1),
    DELETE(2),
    FOLLOW(3),
    ACCEPT(4),
    REJECT(5),
    ANNOUNCE(6),
    LIKE(7),
    UNDO(8),
    BLOCK(9),
    FLAG(10);

    companion object {
        fun fromTag(tag: Int): ActivityType? = entries.find { it.tag == tag }
    }
}

/** ActorType matching the Idris2 ABI tags. */
enum class ActorType(val tag: Int) {
    PERSON(0),
    SERVICE(1),
    APPLICATION(2),
    GROUP(3),
    ORGANIZATION(4);

    companion object {
        fun fromTag(tag: Int): ActorType? = entries.find { it.tag == tag }
    }
}

/** DeliveryStatus matching the Idris2 ABI tags. */
enum class DeliveryStatus(val tag: Int) {
    PENDING(0),
    DELIVERED(1),
    FAILED(2),
    REJECTED(3),
    DEFERRED(4);

    companion object {
        fun fromTag(tag: Int): DeliveryStatus? = entries.find { it.tag == tag }
    }
}

/** TrustLevel matching the Idris2 ABI tags. */
enum class TrustLevel(val tag: Int) {
    SELF_SIGNED(0),
    PEER_VERIFIED(1),
    FEDERATION_TRUSTED(2),
    REVOKED(3),
    UNKNOWN(4);

    companion object {
        fun fromTag(tag: Int): TrustLevel? = entries.find { it.tag == tag }
    }
}

/** ObjectType matching the Idris2 ABI tags. */
enum class ObjectType(val tag: Int) {
    NOTE(0),
    ARTICLE(1),
    IMAGE(2),
    VIDEO(3),
    AUDIO(4),
    DOCUMENT(5),
    EVENT(6),
    COLLECTION(7),
    ORDERED_COLLECTION(8);

    companion object {
        fun fromTag(tag: Int): ObjectType? = entries.find { it.tag == tag }
    }
}

/** ServerState matching the Idris2 ABI tags. */
enum class ServerState(val tag: Int) {
    IDLE(0),
    ACTIVE(1),
    PROCESSING(2),
    DELIVERING(3),
    SHUTDOWN(4);

    companion object {
        fun fromTag(tag: Int): ServerState? = entries.find { it.tag == tag }
    }
}
