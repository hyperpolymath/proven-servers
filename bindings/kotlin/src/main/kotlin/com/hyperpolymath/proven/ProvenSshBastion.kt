// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SSH Bastion protocol types for proven-servers.

package com.hyperpolymath.proven

/** BastionState matching the Idris2 ABI tags. */
enum class BastionState(val tag: Int) {
    CONNECTED(0),
    KEY_EXCHANGED(1),
    AUTHENTICATED(2),
    CHANNEL_OPEN(3),
    ACTIVE(4),
    CLOSED(5);

    companion object {
        fun fromTag(tag: Int): BastionState? = entries.find { it.tag == tag }
    }
}

/** KexMethod matching the Idris2 ABI tags. */
enum class KexMethod(val tag: Int) {
    CURVE25519(0),
    DH_GROUP14(1),
    DH_GROUP16(2),
    ECDH_P256(3),
    ECDH_P384(4);

    companion object {
        fun fromTag(tag: Int): KexMethod? = entries.find { it.tag == tag }
    }
}

/** BastionAuthMethod matching the Idris2 ABI tags. */
enum class BastionAuthMethod(val tag: Int) {
    PUBLIC_KEY(0),
    PASSWORD(1),
    KEYBOARD(2),
    CERTIFICATE(3);

    companion object {
        fun fromTag(tag: Int): BastionAuthMethod? = entries.find { it.tag == tag }
    }
}

/** BastionChannelType matching the Idris2 ABI tags. */
enum class BastionChannelType(val tag: Int) {
    SESSION(0),
    DIRECT_TCP_IP(1),
    FORWARDED_TCP_IP(2),
    SUBSYSTEM(3);

    companion object {
        fun fromTag(tag: Int): BastionChannelType? = entries.find { it.tag == tag }
    }
}

/** BastionChannelState matching the Idris2 ABI tags. */
enum class BastionChannelState(val tag: Int) {
    OPENING(0),
    OPEN(1),
    CLOSING(2),
    CHANNEL_CLOSED(3);

    companion object {
        fun fromTag(tag: Int): BastionChannelState? = entries.find { it.tag == tag }
    }
}

/** DisconnectReason matching the Idris2 ABI tags. */
enum class DisconnectReason(val tag: Int) {
    HOST_NOT_ALLOWED(0),
    PROTOCOL_ERROR(1),
    KEY_EXCHANGE_FAILED(2),
    AUTH_FAILED(3),
    SERVICE_NOT_AVAILABLE(4),
    BY_APPLICATION(5),
    TOO_MANY_CONNECTIONS(6);

    companion object {
        fun fromTag(tag: Int): DisconnectReason? = entries.find { it.tag == tag }
    }
}
