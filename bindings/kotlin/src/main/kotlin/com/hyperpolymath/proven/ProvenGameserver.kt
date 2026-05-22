// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Game Server protocol types for proven-servers.

package com.hyperpolymath.proven

/** SessionType matching the Idris2 ABI tags. */
enum class SessionType(val tag: Int) {
    LOBBY(0),
    MATCH(1),
    PRACTICE(2),
    SPECTATOR(3),
    TOURNAMENT(4);

    companion object {
        fun fromTag(tag: Int): SessionType? = entries.find { it.tag == tag }
    }
}

/** PlayerState matching the Idris2 ABI tags. */
enum class PlayerState(val tag: Int) {
    IDLE(0),
    QUEUING(1),
    LOADING(2),
    PLAYING(3),
    SPECTATING(4),
    DISCONNECTED(5);

    companion object {
        fun fromTag(tag: Int): PlayerState? = entries.find { it.tag == tag }
    }
}

/** MatchState matching the Idris2 ABI tags. */
enum class MatchState(val tag: Int) {
    WAITING(0),
    STARTING(1),
    IN_PROGRESS(2),
    PAUSED(3),
    ENDING(4),
    COMPLETE(5);

    companion object {
        fun fromTag(tag: Int): MatchState? = entries.find { it.tag == tag }
    }
}
