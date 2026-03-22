// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// BGP protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * BGP protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenBgp {
    private ProvenBgp() {}

    /** BgpState (tags 0-5). */
    public enum BgpState {
        IDLE(0),
        CONNECT(1),
        ACTIVE(2),
        OPEN_SENT(3),
        OPEN_CONFIRM(4),
        ESTABLISHED(5);

        private final int tag;
        BgpState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static BgpState fromTag(int tag) {
            for (BgpState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** BgpEvent (tags 0-18). */
    public enum BgpEvent {
        MANUAL_START(0),
        MANUAL_STOP(1),
        AUTOMATIC_START(2),
        CONNECT_RETRY_TIMER_EXPIRES(3),
        HOLD_TIMER_EXPIRES(4),
        KEEPALIVE_TIMER_EXPIRES(5),
        DELAY_OPEN_TIMER_EXPIRES(6),
        TCP_CONNECTION_VALID(7),
        TCP_CR_ACKED(8),
        TCP_CONNECTION_CONFIRMED(9),
        TCP_CONNECTION_FAILS(10),
        BGP_OPEN_RECEIVED(11),
        BGP_HEADER_ERR(12),
        BGP_OPEN_MSG_ERR(13),
        NOTIF_MSG_VER_ERR(14),
        NOTIF_MSG(15),
        KEEPALIVE_MSG(16),
        UPDATE_MSG(17),
        UPDATE_MSG_ERR(18);

        private final int tag;
        BgpEvent(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static BgpEvent fromTag(int tag) {
            for (BgpEvent v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** MessageType (tags 0-3). */
    public enum MessageType {
        OPEN(0),
        UPDATE(1),
        NOTIFICATION(2),
        KEEPALIVE(3);

        private final int tag;
        MessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MessageType fromTag(int tag) {
            for (MessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorCode (tags 0-5). */
    public enum ErrorCode {
        MESSAGE_HEADER_ERROR(0),
        OPEN_MESSAGE_ERROR(1),
        UPDATE_MESSAGE_ERROR(2),
        HOLD_TIMER_EXPIRED(3),
        FSM_ERROR(4),
        CEASE(5);

        private final int tag;
        ErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorCode fromTag(int tag) {
            for (ErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Origin (tags 0-2). */
    public enum Origin {
        IGP(0),
        EGP(1),
        INCOMPLETE(2);

        private final int tag;
        Origin(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Origin fromTag(int tag) {
            for (Origin v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AsPathSegmentType (tags 0-1). */
    public enum AsPathSegmentType {
        AS_SET(0),
        AS_SEQUENCE(1);

        private final int tag;
        AsPathSegmentType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AsPathSegmentType fromTag(int tag) {
            for (AsPathSegmentType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PathAttrType (tags 0-7). */
    public enum PathAttrType {
        ORIGIN(0),
        AS_PATH(1),
        NEXT_HOP(2),
        MED(3),
        LOCAL_PREF(4),
        ATOMIC_AGGR(5),
        AGGREGATOR(6),
        UNKNOWN(7);

        private final int tag;
        PathAttrType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PathAttrType fromTag(int tag) {
            for (PathAttrType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
