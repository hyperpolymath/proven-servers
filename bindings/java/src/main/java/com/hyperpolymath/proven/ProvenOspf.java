// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OSPF protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * OSPF protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenOspf {
    private ProvenOspf() {}

    /** PacketType (tags 0-4). */
    public enum PacketType {
        HELLO(0),
        DATABASE_DESCRIPTION(1),
        LINK_STATE_REQUEST(2),
        LINK_STATE_UPDATE(3),
        LINK_STATE_ACK(4);

        private final int tag;
        PacketType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PacketType fromTag(int tag) {
            for (PacketType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NeighborState (tags 0-7). */
    public enum NeighborState {
        DOWN(0),
        ATTEMPT(1),
        INIT(2),
        TWO_WAY(3),
        EX_START(4),
        EXCHANGE(5),
        LOADING(6),
        FULL(7);

        private final int tag;
        NeighborState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NeighborState fromTag(int tag) {
            for (NeighborState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** LsaType (tags 0-4). */
    public enum LsaType {
        ROUTER_LSA(0),
        NETWORK_LSA(1),
        SUMMARY_LSA(2),
        ASBR_SUMMARY_LSA(3),
        AS_EXTERNAL_LSA(4);

        private final int tag;
        LsaType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LsaType fromTag(int tag) {
            for (LsaType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AreaType (tags 0-3). */
    public enum AreaType {
        NORMAL(0),
        STUB(1),
        TOTALLY_STUB(2),
        NSSA(3);

        private final int tag;
        AreaType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AreaType fromTag(int tag) {
            for (AreaType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** OspfError (tags 0-6). */
    public enum OspfError {
        OK(0),
        INVALID_SLOT(1),
        NOT_ACTIVE(2),
        INVALID_TRANSITION(3),
        INVALID_PACKET(4),
        AREA_ERROR(5),
        FLOOD_LIMIT(6);

        private final int tag;
        OspfError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static OspfError fromTag(int tag) {
            for (OspfError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
