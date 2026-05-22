// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Auth protocol types for proven-servers.

package com.hyperpolymath.proven

/** AuthMethod matching the Idris2 ABI tags. */
enum class AuthMethod(val tag: Int) {
    PASSWORD(0),
    CERTIFICATE(1),
    O_AUTH2(2),
    SAML(3),
    FIDO2(4),
    KERBEROS(5),
    LDAP(6),
    RADIUS(7);

    companion object {
        fun fromTag(tag: Int): AuthMethod? = entries.find { it.tag == tag }
    }
}

/** TokenType matching the Idris2 ABI tags. */
enum class TokenType(val tag: Int) {
    ACCESS(0),
    REFRESH(1),
    ID(2),
    API(3);

    companion object {
        fun fromTag(tag: Int): TokenType? = entries.find { it.tag == tag }
    }
}

/** AuthResult matching the Idris2 ABI tags. */
enum class AuthResult(val tag: Int) {
    SUCCESS(0),
    INVALID_CREDENTIALS(1),
    ACCOUNT_LOCKED(2),
    ACCOUNT_EXPIRED(3),
    MFA_REQUIRED(4),
    IP_BLOCKED(5);

    companion object {
        fun fromTag(tag: Int): AuthResult? = entries.find { it.tag == tag }
    }
}

/** MfaMethod matching the Idris2 ABI tags. */
enum class MfaMethod(val tag: Int) {
    TOTP(0),
    SMS(1),
    PUSH(2),
    FIDO2_MFA(3),
    EMAIL(4);

    companion object {
        fun fromTag(tag: Int): MfaMethod? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    ACTIVE(0),
    EXPIRED(1),
    REVOKED(2),
    LOCKED(3);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
