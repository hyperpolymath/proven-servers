// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// DHCP protocol types for proven-servers.

package com.hyperpolymath.proven

/** MessageType matching the Idris2 ABI tags. */
enum class MessageType(val tag: Int) {
    DISCOVER(0),
    OFFER(1),
    REQUEST(2),
    ACK(3),
    NAK(4),
    RELEASE(5),
    INFORM(6),
    DECLINE(7);

    companion object {
        fun fromTag(tag: Int): MessageType? = entries.find { it.tag == tag }
    }
}

/** OptionCode matching the Idris2 ABI tags. */
enum class OptionCode(val tag: Int) {
    SUBNET_MASK(0),
    ROUTER(1),
    DNS(2),
    DOMAIN_NAME(3),
    LEASE_TIME(4),
    SERVER_ID(5),
    REQUESTED_IP(6),
    MSG_TYPE(7);

    companion object {
        fun fromTag(tag: Int): OptionCode? = entries.find { it.tag == tag }
    }
}

/** HardwareType matching the Idris2 ABI tags. */
enum class HardwareType(val tag: Int) {
    ETHERNET(0),
    IEEE802(1),
    ARCNET(2),
    FRAME_RELAY(3);

    companion object {
        fun fromTag(tag: Int): HardwareType? = entries.find { it.tag == tag }
    }
}

/** DhcpState matching the Idris2 ABI tags. */
enum class DhcpState(val tag: Int) {
    IDLE(0),
    DISCOVER_RECEIVED(1),
    OFFER_SENT(2),
    REQUEST_RECEIVED(3),
    ACK_SENT(4),
    NAK_SENT(5);

    companion object {
        fun fromTag(tag: Int): DhcpState? = entries.find { it.tag == tag }
    }
}

/** LeaseState matching the Idris2 ABI tags. */
enum class LeaseState(val tag: Int) {
    AVAILABLE(0),
    OFFERED(1),
    BOUND(2),
    RENEWING(3),
    REBINDING(4),
    EXPIRED(5);

    companion object {
        fun fromTag(tag: Int): LeaseState? = entries.find { it.tag == tag }
    }
}

/** RelaySubOption matching the Idris2 ABI tags. */
enum class RelaySubOption(val tag: Int) {
    CIRCUIT_ID(0),
    REMOTE_ID(1);

    companion object {
        fun fromTag(tag: Int): RelaySubOption? = entries.find { it.tag == tag }
    }
}
