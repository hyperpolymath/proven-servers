// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Federation protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Federation protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenFederation {
    private ProvenFederation() {}

    /** ActivityType (tags 0-10). */
    public enum ActivityType {
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

        private final int tag;
        ActivityType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ActivityType fromTag(int tag) {
            for (ActivityType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ActorType (tags 0-4). */
    public enum ActorType {
        PERSON(0),
        SERVICE(1),
        APPLICATION(2),
        GROUP(3),
        ORGANIZATION(4);

        private final int tag;
        ActorType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ActorType fromTag(int tag) {
            for (ActorType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DeliveryStatus (tags 0-4). */
    public enum DeliveryStatus {
        PENDING(0),
        DELIVERED(1),
        FAILED(2),
        REJECTED(3),
        DEFERRED(4);

        private final int tag;
        DeliveryStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DeliveryStatus fromTag(int tag) {
            for (DeliveryStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TrustLevel (tags 0-4). */
    public enum TrustLevel {
        SELF_SIGNED(0),
        PEER_VERIFIED(1),
        FEDERATION_TRUSTED(2),
        REVOKED(3),
        UNKNOWN(4);

        private final int tag;
        TrustLevel(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TrustLevel fromTag(int tag) {
            for (TrustLevel v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ObjectType (tags 0-8). */
    public enum ObjectType {
        NOTE(0),
        ARTICLE(1),
        IMAGE(2),
        VIDEO(3),
        AUDIO(4),
        DOCUMENT(5),
        EVENT(6),
        COLLECTION(7),
        ORDERED_COLLECTION(8);

        private final int tag;
        ObjectType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ObjectType fromTag(int tag) {
            for (ObjectType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServerState (tags 0-4). */
    public enum ServerState {
        IDLE(0),
        ACTIVE(1),
        PROCESSING(2),
        DELIVERING(3),
        SHUTDOWN(4);

        private final int tag;
        ServerState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ServerState fromTag(int tag) {
            for (ServerState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
