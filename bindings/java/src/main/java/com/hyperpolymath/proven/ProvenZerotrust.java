// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Zero Trust protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Zero Trust protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenZerotrust {
    private ProvenZerotrust() {}

    /** PolicyType (tags 0-3). */
    public enum PolicyType {
        ALWAYS_VERIFY(0),
        NEVER_TRUST(1),
        LEAST_PRIVILEGE(2),
        MICRO_SEGMENTATION(3);

        private final int tag;
        PolicyType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PolicyType fromTag(int tag) {
            for (PolicyType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** IdentityConfidence (tags 0-4). */
    public enum IdentityConfidence {
        UNVERIFIED(0),
        BASIC_AUTH(1),
        MFA_VERIFIED(2),
        STRONG_AUTH(3),
        CONTINUOUS_AUTH(4);

        private final int tag;
        IdentityConfidence(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static IdentityConfidence fromTag(int tag) {
            for (IdentityConfidence v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DeviceTrustScore (tags 0-4). */
    public enum DeviceTrustScore {
        DEVICE_UNKNOWN(0),
        DEVICE_PARTIAL(1),
        DEVICE_COMPLIANT(2),
        DEVICE_MANAGED(3),
        DEVICE_HARDENED(4);

        private final int tag;
        DeviceTrustScore(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DeviceTrustScore fromTag(int tag) {
            for (DeviceTrustScore v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AccessDecision (tags 0-3). */
    public enum AccessDecision {
        ALLOW(0),
        DENY(1),
        CHALLENGE(2),
        STEP_UP(3);

        private final int tag;
        AccessDecision(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AccessDecision fromTag(int tag) {
            for (AccessDecision v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ContextSignalKind (tags 0-4). */
    public enum ContextSignalKind {
        LOCATION(0),
        TIME(1),
        DEVICE(2),
        BEHAVIOR(3),
        NETWORK(4);

        private final int tag;
        ContextSignalKind(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ContextSignalKind fromTag(int tag) {
            for (ContextSignalKind v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AuthFactor (tags 0-5). */
    public enum AuthFactor {
        CERTIFICATE(0),
        TOKEN(1),
        BIOMETRIC(2),
        FIDO2(3),
        TOTP(4),
        PUSH(5);

        private final int tag;
        AuthFactor(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthFactor fromTag(int tag) {
            for (AuthFactor v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
