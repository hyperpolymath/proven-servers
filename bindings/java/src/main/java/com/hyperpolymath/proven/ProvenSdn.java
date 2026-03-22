// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SDN protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * SDN protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSdn {
    private ProvenSdn() {}

    /** SdnMessageType (tags 0-11). */
    public enum SdnMessageType {
        HELLO(0),
        ERROR(1),
        ECHO_REQUEST(2),
        ECHO_REPLY(3),
        FEATURES_REQUEST(4),
        FEATURES_REPLY(5),
        FLOW_MOD(6),
        PACKET_IN(7),
        PACKET_OUT(8),
        PORT_STATUS(9),
        BARRIER_REQUEST(10),
        BARRIER_REPLY(11);

        private final int tag;
        SdnMessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SdnMessageType fromTag(int tag) {
            for (SdnMessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** FlowAction (tags 0-6). */
    public enum FlowAction {
        OUTPUT(0),
        SET_FIELD(1),
        DROP(2),
        PUSH_VLAN(3),
        POP_VLAN(4),
        SET_QUEUE(5),
        GROUP(6);

        private final int tag;
        FlowAction(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static FlowAction fromTag(int tag) {
            for (FlowAction v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** MatchField (tags 0-10). */
    public enum MatchField {
        IN_PORT(0),
        ETH_DST(1),
        ETH_SRC(2),
        ETH_TYPE(3),
        VLAN_ID(4),
        IP_SRC(5),
        IP_DST(6),
        TCP_SRC(7),
        TCP_DST(8),
        UDP_SRC(9),
        UDP_DST(10);

        private final int tag;
        MatchField(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MatchField fromTag(int tag) {
            for (MatchField v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PortState (tags 0-2). */
    public enum PortState {
        UP(0),
        DOWN(1),
        BLOCKED(2);

        private final int tag;
        PortState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PortState fromTag(int tag) {
            for (PortState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
