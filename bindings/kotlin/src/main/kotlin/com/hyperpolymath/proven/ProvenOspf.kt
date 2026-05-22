// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OSPF protocol types for proven-servers.

package com.hyperpolymath.proven

/** PacketType matching the Idris2 ABI tags. */
enum class PacketType(val tag: Int) {
    HELLO(0),
    DATABASE_DESCRIPTION(1),
    LINK_STATE_REQUEST(2),
    LINK_STATE_UPDATE(3),
    LINK_STATE_ACK(4);

    companion object {
        fun fromTag(tag: Int): PacketType? = entries.find { it.tag == tag }
    }
}

/** NeighborState matching the Idris2 ABI tags. */
enum class NeighborState(val tag: Int) {
    DOWN(0),
    ATTEMPT(1),
    INIT(2),
    TWO_WAY(3),
    EX_START(4),
    EXCHANGE(5),
    LOADING(6),
    FULL(7);

    companion object {
        fun fromTag(tag: Int): NeighborState? = entries.find { it.tag == tag }
    }
}

/** LsaType matching the Idris2 ABI tags. */
enum class LsaType(val tag: Int) {
    ROUTER_LSA(0),
    NETWORK_LSA(1),
    SUMMARY_LSA(2),
    ASBR_SUMMARY_LSA(3),
    AS_EXTERNAL_LSA(4);

    companion object {
        fun fromTag(tag: Int): LsaType? = entries.find { it.tag == tag }
    }
}

/** AreaType matching the Idris2 ABI tags. */
enum class AreaType(val tag: Int) {
    NORMAL(0),
    STUB(1),
    TOTALLY_STUB(2),
    NSSA(3);

    companion object {
        fun fromTag(tag: Int): AreaType? = entries.find { it.tag == tag }
    }
}

/** OspfError matching the Idris2 ABI tags. */
enum class OspfError(val tag: Int) {
    OK(0),
    INVALID_SLOT(1),
    NOT_ACTIVE(2),
    INVALID_TRANSITION(3),
    INVALID_PACKET(4),
    AREA_ERROR(5),
    FLOOD_LIMIT(6);

    companion object {
        fun fromTag(tag: Int): OspfError? = entries.find { it.tag == tag }
    }
}
