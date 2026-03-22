// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SSH Bastion protocol bindings for proven-servers.

package com.hyperpolymath.proven;

/**
 * SSH Bastion protocol bindings for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenSshBastion {
    private ProvenSshBastion() {}

    /** BastionState (tags 0-5). */
    public enum BastionState {
        BASTION_CONNECTED(0),
        BASTION_KEY_EXCHANGED(1),
        BASTION_AUTHENTICATED(2),
        BASTION_CHANNEL_OPEN(3),
        BASTION_ACTIVE(4),
        BASTION_CLOSED(5);

        private final int tag;
        BastionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static BastionState fromTag(int tag) {
            for (BastionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** KexMethod (tags 0-4). */
    public enum KexMethod {
        KEX_CURVE25519(0),
        KEX_DH_GROUP14(1),
        KEX_DH_GROUP16(2),
        KEX_ECDH_P256(3),
        KEX_ECDH_P384(4);

        private final int tag;
        KexMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static KexMethod fromTag(int tag) {
            for (KexMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AuthMethod (tags 0-3). */
    public enum AuthMethod {
        AUTH_PUBLIC_KEY(0),
        AUTH_PASSWORD(1),
        AUTH_KEYBOARD(2),
        AUTH_CERTIFICATE(3);

        private final int tag;
        AuthMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthMethod fromTag(int tag) {
            for (AuthMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ChannelType (tags 0-3). */
    public enum ChannelType {
        CHANNEL_SESSION(0),
        CHANNEL_DIRECT_TCP_IP(1),
        CHANNEL_FORWARDED_TCP_IP(2),
        CHANNEL_SUBSYSTEM(3);

        private final int tag;
        ChannelType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ChannelType fromTag(int tag) {
            for (ChannelType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ChannelState (tags 0-3). */
    public enum ChannelState {
        CHANNEL_OPENING(0),
        CHANNEL_OPEN(1),
        CHANNEL_CLOSING(2),
        CHANNEL_CLOSED(3);

        private final int tag;
        ChannelState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ChannelState fromTag(int tag) {
            for (ChannelState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DisconnectReason (tags 0-6). */
    public enum DisconnectReason {
        DISCONNECT_HOST_NOT_ALLOWED(0),
        DISCONNECT_PROTOCOL_ERROR(1),
        DISCONNECT_KEY_EXCHANGE_FAILED(2),
        DISCONNECT_AUTH_FAILED(3),
        DISCONNECT_SERVICE_NOT_AVAILABLE(4),
        DISCONNECT_BY_APPLICATION(5),
        DISCONNECT_TOO_MANY_CONNECTIONS(6);

        private final int tag;
        DisconnectReason(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DisconnectReason fromTag(int tag) {
            for (DisconnectReason v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
