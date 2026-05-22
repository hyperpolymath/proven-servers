// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// KMS protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * KMS protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenKms {
    private ProvenKms() {}

    /** ObjectType (tags 0-5). */
    public enum ObjectType {
        SYMMETRIC_KEY(0),
        PUBLIC_KEY(1),
        PRIVATE_KEY(2),
        SECRET_DATA(3),
        CERTIFICATE(4),
        OPAQUE_DATA(5);

        private final int tag;
        ObjectType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ObjectType fromTag(int tag) {
            for (ObjectType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Operation (tags 0-14). */
    public enum Operation {
        CREATE(0),
        GET(1),
        ACTIVATE(2),
        REVOKE(3),
        DESTROY(4),
        LOCATE(5),
        REGISTER(6),
        REKEY(7),
        ENCRYPT(8),
        DECRYPT(9),
        SIGN(10),
        VERIFY(11),
        WRAP(12),
        UNWRAP(13),
        MAC(14);

        private final int tag;
        Operation(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Operation fromTag(int tag) {
            for (Operation v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** KeyState (tags 0-5). */
    public enum KeyState {
        PRE_ACTIVE(0),
        ACTIVE(1),
        DEACTIVATED(2),
        COMPROMISED(3),
        DESTROYED(4),
        DESTROYED_COMPROMISED(5);

        private final int tag;
        KeyState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static KeyState fromTag(int tag) {
            for (KeyState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** KmsAlgorithm (tags 0-8). */
    public enum KmsAlgorithm {
        AES128(0),
        AES256(1),
        RSA2048(2),
        RSA4096(3),
        ECDSA_P256(4),
        ECDSA_P384(5),
        ED25519(6),
        CHACHA20_POLY1305(7),
        HMAC_SHA256(8);

        private final int tag;
        KmsAlgorithm(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static KmsAlgorithm fromTag(int tag) {
            for (KmsAlgorithm v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
