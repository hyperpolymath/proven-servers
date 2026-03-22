// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DDS protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * DDS protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenDds {
    private ProvenDds() {}

    /** ReliabilityKind (tags 0-1). */
    public enum ReliabilityKind {
        BEST_EFFORT(0),
        RELIABLE(1);

        private final int tag;
        ReliabilityKind(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ReliabilityKind fromTag(int tag) {
            for (ReliabilityKind v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DurabilityKind (tags 0-2). */
    public enum DurabilityKind {
        TRANSIENT_LOCAL(0),
        TRANSIENT(1),
        PERSISTENT(2);

        private final int tag;
        DurabilityKind(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DurabilityKind fromTag(int tag) {
            for (DurabilityKind v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HistoryKind (tags 0-1). */
    public enum HistoryKind {
        KEEP_LAST(0),
        KEEP_ALL(1);

        private final int tag;
        HistoryKind(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HistoryKind fromTag(int tag) {
            for (HistoryKind v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** OwnershipKind (tags 0-1). */
    public enum OwnershipKind {
        SHARED(0),
        EXCLUSIVE(1);

        private final int tag;
        OwnershipKind(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static OwnershipKind fromTag(int tag) {
            for (OwnershipKind v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** EntityType (tags 0-5). */
    public enum EntityType {
        PARTICIPANT(0),
        PUBLISHER(1),
        SUBSCRIBER(2),
        TOPIC(3),
        DATA_WRITER(4),
        DATA_READER(5);

        private final int tag;
        EntityType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static EntityType fromTag(int tag) {
            for (EntityType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ParticipantState (tags 0-4). */
    public enum ParticipantState {
        IDLE(0),
        JOINED(1),
        PUBLISHING(2),
        SUBSCRIBING(3),
        LEAVING(4);

        private final int tag;
        ParticipantState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ParticipantState fromTag(int tag) {
            for (ParticipantState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
