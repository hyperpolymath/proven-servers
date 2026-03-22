// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// VPN protocol types for proven-servers.

package com.hyperpolymath.proven

/** TunnelType matching the Idris2 ABI tags. */
enum class TunnelType(val tag: Int) {
    IPSEC(0),
    WIREGUARD(1),
    OPENVPN(2),
    L2TP(3);

    companion object {
        fun fromTag(tag: Int): TunnelType? = entries.find { it.tag == tag }
    }
}

/** TunnelPhase matching the Idris2 ABI tags. */
enum class TunnelPhase(val tag: Int) {
    IDLE(0),
    PHASE1_INIT(1),
    PHASE1_AUTH(2),
    PHASE1_DONE(3),
    PHASE2_NEGOTIATING(4),
    ESTABLISHED(5),
    TUNNEL_PHASE__EXPIRED(6);

    companion object {
        fun fromTag(tag: Int): TunnelPhase? = entries.find { it.tag == tag }
    }
}

/** EncryptionAlgorithm matching the Idris2 ABI tags. */
enum class EncryptionAlgorithm(val tag: Int) {
    AES128_CBC(0),
    AES256_CBC(1),
    AES128_GCM(2),
    AES256_GCM(3),
    CHACHA20_POLY1305(4),
    NULL_CIPHER(5);

    companion object {
        fun fromTag(tag: Int): EncryptionAlgorithm? = entries.find { it.tag == tag }
    }
}

/** IntegrityAlgorithm matching the Idris2 ABI tags. */
enum class IntegrityAlgorithm(val tag: Int) {
    HMAC_SHA1(0),
    HMAC_SHA256(1),
    HMAC_SHA384(2),
    HMAC_SHA512(3),
    NO_INTEGRITY(4);

    companion object {
        fun fromTag(tag: Int): IntegrityAlgorithm? = entries.find { it.tag == tag }
    }
}

/** DhGroup matching the Idris2 ABI tags. */
enum class DhGroup(val tag: Int) {
    DH14(0),
    ECP256(1),
    ECP384(2),
    CURVE25519(3);

    companion object {
        fun fromTag(tag: Int): DhGroup? = entries.find { it.tag == tag }
    }
}

/** SaLifecycle matching the Idris2 ABI tags. */
enum class SaLifecycle(val tag: Int) {
    NONE(0),
    ACTIVE(1),
    REKEYING(2),
    SA_LIFECYCLE__EXPIRED(3),
    DELETED(4);

    companion object {
        fun fromTag(tag: Int): SaLifecycle? = entries.find { it.tag == tag }
    }
}

/** IkeVersion matching the Idris2 ABI tags. */
enum class IkeVersion(val tag: Int) {
    V1(0),
    V2(1);

    companion object {
        fun fromTag(tag: Int): IkeVersion? = entries.find { it.tag == tag }
    }
}

/** VpnError matching the Idris2 ABI tags. */
enum class VpnError(val tag: Int) {
    AUTHENTICATION_FAILED(0),
    NO_PROPOSAL_CHOSEN(1),
    LIFETIME_EXPIRED(2),
    INVALID_SPI(3),
    REPLAY_DETECTED(4),
    NEGOTIATION_TIMEOUT(5);

    companion object {
        fun fromTag(tag: Int): VpnError? = entries.find { it.tag == tag }
    }
}
