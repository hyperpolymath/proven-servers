// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DHCP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * DHCP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenDhcp {
    private ProvenDhcp() {}

    /** MessageType (tags 0-7). */
    public enum MessageType {
        DISCOVER(0),
        OFFER(1),
        REQUEST(2),
        ACK(3),
        NAK(4),
        RELEASE(5),
        INFORM(6),
        DECLINE(7);

        private final int tag;
        MessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MessageType fromTag(int tag) {
            for (MessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** OptionCode (tags 0-7). */
    public enum OptionCode {
        SUBNET_MASK(0),
        ROUTER(1),
        DNS(2),
        DOMAIN_NAME(3),
        LEASE_TIME(4),
        SERVER_ID(5),
        REQUESTED_IP(6),
        MSG_TYPE(7);

        private final int tag;
        OptionCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static OptionCode fromTag(int tag) {
            for (OptionCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** HardwareType (tags 0-3). */
    public enum HardwareType {
        ETHERNET(0),
        IEEE802(1),
        ARCNET(2),
        FRAME_RELAY(3);

        private final int tag;
        HardwareType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static HardwareType fromTag(int tag) {
            for (HardwareType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DhcpState (tags 0-5). */
    public enum DhcpState {
        IDLE(0),
        DISCOVER_RECEIVED(1),
        OFFER_SENT(2),
        REQUEST_RECEIVED(3),
        ACK_SENT(4),
        NAK_SENT(5);

        private final int tag;
        DhcpState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DhcpState fromTag(int tag) {
            for (DhcpState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** LeaseState (tags 0-5). */
    public enum LeaseState {
        AVAILABLE(0),
        OFFERED(1),
        BOUND(2),
        RENEWING(3),
        REBINDING(4),
        EXPIRED(5);

        private final int tag;
        LeaseState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static LeaseState fromTag(int tag) {
            for (LeaseState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** RelaySubOption (tags 0-1). */
    public enum RelaySubOption {
        CIRCUIT_ID(0),
        REMOTE_ID(1);

        private final int tag;
        RelaySubOption(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RelaySubOption fromTag(int tag) {
            for (RelaySubOption v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
