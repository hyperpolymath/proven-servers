// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SOCKS5 protocol types for proven-servers.

package com.hyperpolymath.proven

/** AuthMethod matching the Idris2 ABI tags. */
enum class AuthMethod(val tag: Int) {
    NO_AUTH(0),
    GSSAPI(1),
    USERNAME_PASSWORD(2),
    NO_ACCEPTABLE(3);

    companion object {
        fun fromTag(tag: Int): AuthMethod? = entries.find { it.tag == tag }
    }
}

/** Command matching the Idris2 ABI tags. */
enum class Command(val tag: Int) {
    CONNECT(0),
    BIND(1),
    UDP_ASSOCIATE(2);

    companion object {
        fun fromTag(tag: Int): Command? = entries.find { it.tag == tag }
    }
}

/** AddressType matching the Idris2 ABI tags. */
enum class AddressType(val tag: Int) {
    I_PV4(0),
    DOMAIN_NAME(1),
    I_PV6(2);

    companion object {
        fun fromTag(tag: Int): AddressType? = entries.find { it.tag == tag }
    }
}

/** Reply matching the Idris2 ABI tags. */
enum class Reply(val tag: Int) {
    SUCCEEDED(0),
    GENERAL_FAILURE(1),
    NOT_ALLOWED(2),
    NETWORK_UNREACHABLE(3),
    HOST_UNREACHABLE(4),
    CONNECTION_REFUSED(5),
    TTL_EXPIRED(6),
    COMMAND_NOT_SUPPORTED(7),
    ADDRESS_TYPE_NOT_SUPPORTED(8);

    companion object {
        fun fromTag(tag: Int): Reply? = entries.find { it.tag == tag }
    }
}

/** State matching the Idris2 ABI tags. */
enum class State(val tag: Int) {
    INITIAL(0),
    AUTHENTICATING(1),
    AUTHENTICATED(2),
    CONNECTING(3),
    ESTABLISHED(4),
    CLOSED(5);

    companion object {
        fun fromTag(tag: Int): State? = entries.find { it.tag == tag }
    }
}
