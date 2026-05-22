// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Zero Trust protocol types for proven-servers.

package com.hyperpolymath.proven

/** PolicyType matching the Idris2 ABI tags. */
enum class PolicyType(val tag: Int) {
    ALWAYS_VERIFY(0),
    NEVER_TRUST(1),
    LEAST_PRIVILEGE(2),
    MICRO_SEGMENTATION(3);

    companion object {
        fun fromTag(tag: Int): PolicyType? = entries.find { it.tag == tag }
    }
}

/** IdentityConfidence matching the Idris2 ABI tags. */
enum class IdentityConfidence(val tag: Int) {
    UNVERIFIED(0),
    BASIC_AUTH(1),
    MFA_VERIFIED(2),
    STRONG_AUTH(3),
    CONTINUOUS_AUTH(4);

    companion object {
        fun fromTag(tag: Int): IdentityConfidence? = entries.find { it.tag == tag }
    }
}

/** DeviceTrustScore matching the Idris2 ABI tags. */
enum class DeviceTrustScore(val tag: Int) {
    DEVICE_UNKNOWN(0),
    DEVICE_PARTIAL(1),
    DEVICE_COMPLIANT(2),
    DEVICE_MANAGED(3),
    DEVICE_HARDENED(4);

    companion object {
        fun fromTag(tag: Int): DeviceTrustScore? = entries.find { it.tag == tag }
    }
}

/** AccessDecision matching the Idris2 ABI tags. */
enum class AccessDecision(val tag: Int) {
    ALLOW(0),
    DENY(1),
    CHALLENGE(2),
    STEP_UP(3);

    companion object {
        fun fromTag(tag: Int): AccessDecision? = entries.find { it.tag == tag }
    }
}

/** ContextSignalKind matching the Idris2 ABI tags. */
enum class ContextSignalKind(val tag: Int) {
    LOCATION(0),
    TIME(1),
    DEVICE(2),
    BEHAVIOR(3),
    NETWORK(4);

    companion object {
        fun fromTag(tag: Int): ContextSignalKind? = entries.find { it.tag == tag }
    }
}

/** AuthFactor matching the Idris2 ABI tags. */
enum class AuthFactor(val tag: Int) {
    CERTIFICATE(0),
    TOKEN(1),
    BIOMETRIC(2),
    FIDO2(3),
    TOTP(4),
    PUSH(5);

    companion object {
        fun fromTag(tag: Int): AuthFactor? = entries.find { it.tag == tag }
    }
}
