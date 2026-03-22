// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// RADIUS protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * RADIUS protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenRadius {
    private ProvenRadius() {}

    /** PacketType (tags 0-5). */
    public enum PacketType {
        ACCESS_REQUEST(0),
        ACCESS_ACCEPT(1),
        ACCESS_REJECT(2),
        ACCOUNTING_REQUEST(3),
        ACCOUNTING_RESPONSE(4),
        ACCESS_CHALLENGE(5);

        private final int tag;
        PacketType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PacketType fromTag(int tag) {
            for (PacketType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AttributeType (tags 0-8). */
    public enum AttributeType {
        USER_NAME(0),
        USER_PASSWORD(1),
        NAS_IP_ADDRESS(2),
        NAS_PORT(3),
        SERVICE_TYPE(4),
        FRAMED_PROTOCOL(5),
        FRAMED_IP_ADDRESS(6),
        REPLY_MESSAGE(7),
        SESSION_TIMEOUT(8);

        private final int tag;
        AttributeType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AttributeType fromTag(int tag) {
            for (AttributeType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ServiceType (tags 0-5). */
    public enum ServiceType {
        LOGIN(0),
        FRAMED(1),
        CALLBACK_LOGIN(2),
        CALLBACK_FRAMED(3),
        OUTBOUND(4),
        ADMINISTRATIVE(5);

        private final int tag;
        ServiceType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ServiceType fromTag(int tag) {
            for (ServiceType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AuthMethod (tags 0-4). */
    public enum AuthMethod {
        PAP(0),
        CHAP(1),
        MSCHAP(2),
        MSCHAPV2(3),
        EAP(4);

        private final int tag;
        AuthMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthMethod fromTag(int tag) {
            for (AuthMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-6). */
    public enum SessionState {
        IDLE(0),
        AUTHENTICATING(1),
        AUTHORIZED(2),
        REJECTED(3),
        CHALLENGED(4),
        ACCOUNTING(5),
        COMPLETE(6);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** RadiusResult (tags 0-4). */
    public enum RadiusResult {
        OK(0),
        ERR(1),
        INVALID_PARAM(2),
        POOL_EXHAUSTED(3),
        BAD_SECRET(4);

        private final int tag;
        RadiusResult(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RadiusResult fromTag(int tag) {
            for (RadiusResult v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
