// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Game Server protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Game Server protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenGameserver {
    private ProvenGameserver() {}

    /** SessionType (tags 0-4). */
    public enum SessionType {
        LOBBY(0),
        MATCH(1),
        PRACTICE(2),
        SPECTATOR(3),
        TOURNAMENT(4);

        private final int tag;
        SessionType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionType fromTag(int tag) {
            for (SessionType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PlayerState (tags 0-5). */
    public enum PlayerState {
        IDLE(0),
        QUEUING(1),
        LOADING(2),
        PLAYING(3),
        SPECTATING(4),
        DISCONNECTED(5);

        private final int tag;
        PlayerState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PlayerState fromTag(int tag) {
            for (PlayerState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** MatchState (tags 0-5). */
    public enum MatchState {
        WAITING(0),
        STARTING(1),
        IN_PROGRESS(2),
        PAUSED(3),
        ENDING(4),
        COMPLETE(5);

        private final int tag;
        MatchState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MatchState fromTag(int tag) {
            for (MatchState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
