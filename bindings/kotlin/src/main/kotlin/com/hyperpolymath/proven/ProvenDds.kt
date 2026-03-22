// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DDS protocol types for proven-servers.

package com.hyperpolymath.proven

/** ReliabilityKind matching the Idris2 ABI tags. */
enum class ReliabilityKind(val tag: Int) {
    BEST_EFFORT(0),
    RELIABLE(1);

    companion object {
        fun fromTag(tag: Int): ReliabilityKind? = entries.find { it.tag == tag }
    }
}

/** DurabilityKind matching the Idris2 ABI tags. */
enum class DurabilityKind(val tag: Int) {
    TRANSIENT_LOCAL(1),
    TRANSIENT(2),
    PERSISTENT(3);

    companion object {
        fun fromTag(tag: Int): DurabilityKind? = entries.find { it.tag == tag }
    }
}

/** HistoryKind matching the Idris2 ABI tags. */
enum class HistoryKind(val tag: Int) {
    KEEP_LAST(0),
    KEEP_ALL(1);

    companion object {
        fun fromTag(tag: Int): HistoryKind? = entries.find { it.tag == tag }
    }
}

/** OwnershipKind matching the Idris2 ABI tags. */
enum class OwnershipKind(val tag: Int) {
    SHARED(0),
    EXCLUSIVE(1);

    companion object {
        fun fromTag(tag: Int): OwnershipKind? = entries.find { it.tag == tag }
    }
}

/** EntityType matching the Idris2 ABI tags. */
enum class EntityType(val tag: Int) {
    PARTICIPANT(0),
    PUBLISHER(1),
    SUBSCRIBER(2),
    TOPIC(3),
    DATA_WRITER(4),
    DATA_READER(5);

    companion object {
        fun fromTag(tag: Int): EntityType? = entries.find { it.tag == tag }
    }
}

/** ParticipantState matching the Idris2 ABI tags. */
enum class ParticipantState(val tag: Int) {
    IDLE(0),
    JOINED(1),
    PUBLISHING(2),
    SUBSCRIBING(3),
    LEAVING(4);

    companion object {
        fun fromTag(tag: Int): ParticipantState? = entries.find { it.tag == tag }
    }
}
