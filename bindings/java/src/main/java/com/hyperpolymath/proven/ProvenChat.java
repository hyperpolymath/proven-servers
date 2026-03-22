// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Chat protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Chat protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenChat {
    private ProvenChat() {}

    /** MessageType (tags 0-8). */
    public enum MessageType {
        TEXT(0),
        IMAGE(1),
        FILE(2),
        SYSTEM(3),
        REACTION(4),
        EDIT(5),
        DELETE(6),
        REPLY(7),
        THREAD(8);

        private final int tag;
        MessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MessageType fromTag(int tag) {
            for (MessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PresenceStatus (tags 0-4). */
    public enum PresenceStatus {
        ONLINE(0),
        AWAY(1),
        DND(2),
        INVISIBLE(3),
        OFFLINE(4);

        private final int tag;
        PresenceStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PresenceStatus fromTag(int tag) {
            for (PresenceStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** RoomType (tags 0-3). */
    public enum RoomType {
        DIRECT(0),
        GROUP(1),
        CHANNEL(2),
        BROADCAST(3);

        private final int tag;
        RoomType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RoomType fromTag(int tag) {
            for (RoomType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Permission (tags 0-7). */
    public enum Permission {
        READ(0),
        WRITE(1),
        ADMIN(2),
        INVITE(3),
        KICK(4),
        BAN(5),
        PIN(6),
        DELETE_OTHERS(7);

        private final int tag;
        Permission(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Permission fromTag(int tag) {
            for (Permission v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Event (tags 0-6). */
    public enum Event {
        MESSAGE_SENT(0),
        MESSAGE_DELIVERED(1),
        MESSAGE_READ(2),
        USER_JOINED(3),
        USER_LEFT(4),
        TYPING(5),
        ROOM_CREATED(6);

        private final int tag;
        Event(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Event fromTag(int tag) {
            for (Event v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
