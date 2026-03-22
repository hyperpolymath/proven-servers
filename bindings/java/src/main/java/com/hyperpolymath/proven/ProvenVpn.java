// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VPN protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * VPN protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenVpn {
    private ProvenVpn() {}

    /** TunnelType (tags 0-3). */
    public enum TunnelType {
        IPSEC(0),
        WIREGUARD(1),
        OPENVPN(2),
        L2TP(3);

        private final int tag;
        TunnelType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TunnelType fromTag(int tag) {
            for (TunnelType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TunnelPhase (tags 0-6). */
    public enum TunnelPhase {
        IDLE(0),
        PHASE1_INIT(1),
        PHASE1_AUTH(2),
        PHASE1_DONE(3),
        PHASE2_NEGOTIATING(4),
        ESTABLISHED(5),
        EXPIRED(6);

        private final int tag;
        TunnelPhase(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TunnelPhase fromTag(int tag) {
            for (TunnelPhase v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** EncryptionAlgorithm (tags 0-5). */
    public enum EncryptionAlgorithm {
        AES128_CBC(0),
        AES256_CBC(1),
        AES128_GCM(2),
        AES256_GCM(3),
        CHACHA20_POLY1305(4),
        NULL_CIPHER(5);

        private final int tag;
        EncryptionAlgorithm(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static EncryptionAlgorithm fromTag(int tag) {
            for (EncryptionAlgorithm v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** IntegrityAlgorithm (tags 0-4). */
    public enum IntegrityAlgorithm {
        HMAC_SHA1(0),
        HMAC_SHA256(1),
        HMAC_SHA384(2),
        HMAC_SHA512(3),
        NO_INTEGRITY(4);

        private final int tag;
        IntegrityAlgorithm(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static IntegrityAlgorithm fromTag(int tag) {
            for (IntegrityAlgorithm v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DhGroup (tags 0-3). */
    public enum DhGroup {
        DH14(0),
        ECP256(1),
        ECP384(2),
        CURVE25519(3);

        private final int tag;
        DhGroup(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DhGroup fromTag(int tag) {
            for (DhGroup v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SaLifecycle (tags 0-4). */
    public enum SaLifecycle {
        NONE(0),
        ACTIVE(1),
        REKEYING(2),
        EXPIRED(3),
        DELETED(4);

        private final int tag;
        SaLifecycle(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SaLifecycle fromTag(int tag) {
            for (SaLifecycle v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** IkeVersion (tags 0-1). */
    public enum IkeVersion {
        V1(0),
        V2(1);

        private final int tag;
        IkeVersion(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static IkeVersion fromTag(int tag) {
            for (IkeVersion v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** VpnError (tags 0-5). */
    public enum VpnError {
        AUTHENTICATION_FAILED(0),
        NO_PROPOSAL_CHOSEN(1),
        LIFETIME_EXPIRED(2),
        INVALID_SPI(3),
        REPLAY_DETECTED(4),
        NEGOTIATION_TIMEOUT(5);

        private final int tag;
        VpnError(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static VpnError fromTag(int tag) {
            for (VpnError v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
