// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Auth protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Auth protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenAuthserver {
    private ProvenAuthserver() {}

    /** AuthMethod (tags 0-7). */
    public enum AuthMethod {
        PASSWORD(0),
        CERTIFICATE(1),
        O_AUTH2(2),
        SAML(3),
        FIDO2(4),
        KERBEROS(5),
        LDAP(6),
        RADIUS(7);

        private final int tag;
        AuthMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthMethod fromTag(int tag) {
            for (AuthMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** TokenType (tags 0-3). */
    public enum TokenType {
        ACCESS(0),
        REFRESH(1),
        ID(2),
        API(3);

        private final int tag;
        TokenType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static TokenType fromTag(int tag) {
            for (TokenType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** AuthResult (tags 0-5). */
    public enum AuthResult {
        SUCCESS(0),
        INVALID_CREDENTIALS(1),
        ACCOUNT_LOCKED(2),
        ACCOUNT_EXPIRED(3),
        MFA_REQUIRED(4),
        IP_BLOCKED(5);

        private final int tag;
        AuthResult(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static AuthResult fromTag(int tag) {
            for (AuthResult v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** MfaMethod (tags 0-4). */
    public enum MfaMethod {
        TOTP(0),
        SMS(1),
        PUSH(2),
        FIDO2_MFA(3),
        EMAIL(4);

        private final int tag;
        MfaMethod(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static MfaMethod fromTag(int tag) {
            for (MfaMethod v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-3). */
    public enum SessionState {
        ACTIVE(0),
        EXPIRED(1),
        REVOKED(2),
        LOCKED(3);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
