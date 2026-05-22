// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kerberos protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Kerberos protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenKerberos {
    private ProvenKerberos() {}

    /** MessageType (tags 0-9). */
    public enum MessageType {
        AS_REQ(0),
        AS_REP(1),
        TGS_REQ(2),
        TGS_REP(3),
        AP_REQ(4),
        AP_REP(5),
        KRB_ERROR(6),
        KRB_SAFE(7),
        KRB_PRIV(8),
        KRB_CRED(9);

        private final int tag;
        MessageType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MessageType fromTag(int tag) {
            for (MessageType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** EncryptionType (tags 0-4). */
    public enum EncryptionType {
        AES256_CTS_HMAC_SHA1(0),
        AES128_CTS_HMAC_SHA1(1),
        AES256_CTS_HMAC_SHA384(2),
        RC4_HMAC(3),
        DES3_CBC_SHA1(4);

        private final int tag;
        EncryptionType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static EncryptionType fromTag(int tag) {
            for (EncryptionType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PrincipalType (tags 0-6). */
    public enum PrincipalType {
        NT_UNKNOWN(0),
        NT_PRINCIPAL(1),
        NT_SRV_INST(2),
        NT_SRV_HST(3),
        NT_UID(4),
        NT_X500(5),
        NT_ENTERPRISE(6);

        private final int tag;
        PrincipalType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PrincipalType fromTag(int tag) {
            for (PrincipalType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TicketFlag (tags 0-6). */
    public enum TicketFlag {
        FORWARDABLE(0),
        FORWARDED(1),
        PROXIABLE(2),
        PROXY(3),
        RENEWABLE(4),
        PRE_AUTHENT(5),
        HW_AUTHENT(6);

        private final int tag;
        TicketFlag(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TicketFlag fromTag(int tag) {
            for (TicketFlag v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorCode (tags 0-9). */
    public enum ErrorCode {
        KDC_ERR_NONE(0),
        KDC_ERR_NAME_EXP(1),
        KDC_ERR_SERVICE_EXP(2),
        KDC_ERR_BAD_PVNO(3),
        KDC_ERR_C_OLD_MAST_KVNO(4),
        KDC_ERR_S_OLD_MAST_KVNO(5),
        KDC_ERR_C_PRINCIPAL_UNKNOWN(6),
        KDC_ERR_S_PRINCIPAL_UNKNOWN(7),
        KDC_ERR_PREAUTH_FAILED(8),
        KDC_ERR_PREAUTH_REQUIRED(9);

        private final int tag;
        ErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorCode fromTag(int tag) {
            for (ErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AuthState (tags 0-4). */
    public enum AuthState {
        INITIAL(0),
        TGT_OBTAINED(1),
        SERVICE_TICKET_OBTAINED(2),
        AUTHENTICATED(3),
        AUTH_FAILED(4);

        private final int tag;
        AuthState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthState fromTag(int tag) {
            for (AuthState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** EncStrength (tags 0-2). */
    public enum EncStrength {
        STRONG(0),
        MEDIUM(1),
        WEAK(2);

        private final int tag;
        EncStrength(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static EncStrength fromTag(int tag) {
            for (EncStrength v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** PreAuthType (tags 0-3). */
    public enum PreAuthType {
        PA_ENC_TIMESTAMP(0),
        PA_ETYPE_INFO2(1),
        PA_FX_FAST(2),
        PA_FX_COOKIE(3);

        private final int tag;
        PreAuthType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static PreAuthType fromTag(int tag) {
            for (PreAuthType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** NegotiationState (tags 0-3). */
    public enum NegotiationState {
        NEG_IDLE(0),
        PROPOSED(1),
        SELECTED(2),
        NEG_FAILED(3);

        private final int tag;
        NegotiationState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static NegotiationState fromTag(int tag) {
            for (NegotiationState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
