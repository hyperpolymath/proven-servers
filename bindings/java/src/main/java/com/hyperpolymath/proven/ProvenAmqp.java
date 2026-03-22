// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// AMQP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * AMQP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenAmqp {
    private ProvenAmqp() {}

    /** FrameType (tags 0-3). */
    public enum FrameType {
        METHOD(0),
        HEADER(1),
        BODY(2),
        HEARTBEAT(3);

        private final int tag;
        FrameType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static FrameType fromTag(int tag) {
            for (FrameType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** MethodClass (tags 0-6). */
    public enum MethodClass {
        CONNECTION(0),
        CHANNEL(1),
        EXCHANGE(2),
        QUEUE(3),
        BASIC(4),
        TX(5),
        CONFIRM(6);

        private final int tag;
        MethodClass(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MethodClass fromTag(int tag) {
            for (MethodClass v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ExchangeType (tags 0-3). */
    public enum ExchangeType {
        DIRECT(0),
        FANOUT(1),
        TOPIC(2),
        HEADERS(3);

        private final int tag;
        ExchangeType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ExchangeType fromTag(int tag) {
            for (ExchangeType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DeliveryMode (tags 0-1). */
    public enum DeliveryMode {
        NON_PERSISTENT(0),
        PERSISTENT(1);

        private final int tag;
        DeliveryMode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DeliveryMode fromTag(int tag) {
            for (DeliveryMode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorSeverity (tags 0-1). */
    public enum ErrorSeverity {
        CHANNEL_LEVEL(0),
        CONNECTION_LEVEL(1);

        private final int tag;
        ErrorSeverity(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorSeverity fromTag(int tag) {
            for (ErrorSeverity v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ConnectionState (tags 0-4). */
    public enum ConnectionState {
        IDLE(0),
        NEGOTIATING(1),
        TUNING_OK(2),
        OPEN(3),
        CLOSING(4);

        private final int tag;
        ConnectionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ConnectionState fromTag(int tag) {
            for (ConnectionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ChannelState (tags 0-3). */
    public enum ChannelState {
        CLOSED(0),
        OPENING(1),
        CH_OPEN(2),
        CH_CLOSING(3);

        private final int tag;
        ChannelState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ChannelState fromTag(int tag) {
            for (ChannelState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** BrokerState (tags 0-5). */
    public enum BrokerState {
        IDLE(0),
        CONNECTED(1),
        CHANNEL_OPEN(2),
        CONSUMING(3),
        PUBLISHING(4),
        DISCONNECTING(5);

        private final int tag;
        BrokerState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static BrokerState fromTag(int tag) {
            for (BrokerState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
