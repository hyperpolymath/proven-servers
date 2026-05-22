// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CA protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * CA protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenCa {
    private ProvenCa() {}

    /** CertType (tags 0-6). */
    public enum CertType {
        ROOT(0),
        INTERMEDIATE(1),
        END_ENTITY(2),
        CROSS_SIGNED(3),
        CODE_SIGNING(4),
        EMAIL_PROTECTION(5),
        OCSP_SIGNING(6);

        private final int tag;
        CertType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CertType fromTag(int tag) {
            for (CertType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** KeyAlgorithm (tags 0-5). */
    public enum KeyAlgorithm {
        RSA2048(0),
        RSA4096(1),
        ECDSA_P256(2),
        ECDSA_P384(3),
        ED25519(4),
        ED448(5);

        private final int tag;
        KeyAlgorithm(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static KeyAlgorithm fromTag(int tag) {
            for (KeyAlgorithm v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SignatureAlgorithm (tags 0-6). */
    public enum SignatureAlgorithm {
        SHA256_WITH_RSA(0),
        SHA384_WITH_RSA(1),
        SHA512_WITH_RSA(2),
        SHA256_WITH_ECDSA(3),
        SHA384_WITH_ECDSA(4),
        PURE_ED25519(5),
        PURE_ED448(6);

        private final int tag;
        SignatureAlgorithm(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SignatureAlgorithm fromTag(int tag) {
            for (SignatureAlgorithm v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CertState (tags 0-4). */
    public enum CertState {
        PENDING(0),
        ACTIVE(1),
        REVOKED(2),
        EXPIRED(3),
        SUSPENDED(4);

        private final int tag;
        CertState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CertState fromTag(int tag) {
            for (CertState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** RevocationReason (tags 0-6). */
    public enum RevocationReason {
        UNSPECIFIED(0),
        KEY_COMPROMISE(1),
        CA_COMPROMISE(2),
        AFFILIATION_CHANGED(3),
        SUPERSEDED(4),
        CESSATION_OF_OPERATION(5),
        CERTIFICATE_HOLD(6);

        private final int tag;
        RevocationReason(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static RevocationReason fromTag(int tag) {
            for (RevocationReason v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** CrlStatus (tags 0-3). */
    public enum CrlStatus {
        CURRENT(0),
        CRL_EXPIRED(1),
        CRL_PENDING(2),
        CRL_ERROR(3);

        private final int tag;
        CrlStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static CrlStatus fromTag(int tag) {
            for (CrlStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** OcspStatus (tags 0-3). */
    public enum OcspStatus {
        GOOD(0),
        OCSP_REVOKED(1),
        UNKNOWN(2),
        UNAVAILABLE(3);

        private final int tag;
        OcspStatus(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static OcspStatus fromTag(int tag) {
            for (OcspStatus v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** Extension (tags 0-5). */
    public enum Extension {
        BASIC_CONSTRAINTS(0),
        KEY_USAGE(1),
        EXT_KEY_USAGE(2),
        SUBJECT_ALT_NAME(3),
        AUTHORITY_INFO_ACCESS(4),
        CRL_DISTRIBUTION_POINTS(5);

        private final int tag;
        Extension(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static Extension fromTag(int tag) {
            for (Extension v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** KeyUsageBit (tags 0-8). */
    public enum KeyUsageBit {
        DIGITAL_SIGNATURE(0),
        NON_REPUDIATION(1),
        KEY_ENCIPHERMENT(2),
        DATA_ENCIPHERMENT(3),
        KEY_AGREEMENT(4),
        KEY_CERT_SIGN(5),
        CRL_SIGN(6),
        ENCIPHER_ONLY(7),
        DECIPHER_ONLY(8);

        private final int tag;
        KeyUsageBit(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static KeyUsageBit fromTag(int tag) {
            for (KeyUsageBit v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
