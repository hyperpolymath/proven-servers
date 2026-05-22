// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// SDN protocol types for proven-servers.

package com.hyperpolymath.proven

/** SdnMessageType matching the Idris2 ABI tags. */
enum class SdnMessageType(val tag: Int) {
    HELLO(0),
    ERROR(1),
    ECHO_REQUEST(2),
    ECHO_REPLY(3),
    FEATURES_REQUEST(4),
    FEATURES_REPLY(5),
    FLOW_MOD(6),
    PACKET_IN(7),
    PACKET_OUT(8),
    PORT_STATUS(9),
    BARRIER_REQUEST(10),
    BARRIER_REPLY(11);

    companion object {
        fun fromTag(tag: Int): SdnMessageType? = entries.find { it.tag == tag }
    }
}

/** FlowAction matching the Idris2 ABI tags. */
enum class FlowAction(val tag: Int) {
    OUTPUT(0),
    SET_FIELD(1),
    DROP(2),
    PUSH_VLAN(3),
    POP_VLAN(4),
    SET_QUEUE(5),
    GROUP(6);

    companion object {
        fun fromTag(tag: Int): FlowAction? = entries.find { it.tag == tag }
    }
}

/** MatchField matching the Idris2 ABI tags. */
enum class MatchField(val tag: Int) {
    IN_PORT(0),
    ETH_DST(1),
    ETH_SRC(2),
    ETH_TYPE(3),
    VLAN_ID(4),
    IP_SRC(5),
    IP_DST(6),
    TCP_SRC(7),
    TCP_DST(8),
    UDP_SRC(9),
    UDP_DST(10);

    companion object {
        fun fromTag(tag: Int): MatchField? = entries.find { it.tag == tag }
    }
}

/** PortState matching the Idris2 ABI tags. */
enum class PortState(val tag: Int) {
    UP(0),
    DOWN(1),
    BLOCKED(2);

    companion object {
        fun fromTag(tag: Int): PortState? = entries.find { it.tag == tag }
    }
}
