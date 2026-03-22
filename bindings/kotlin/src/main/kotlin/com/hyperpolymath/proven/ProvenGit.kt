// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Git protocol types for proven-servers.

package com.hyperpolymath.proven

/** Command matching the Idris2 ABI tags. */
enum class Command(val tag: Int) {
    UPLOAD_PACK(0),
    RECEIVE_PACK(1),
    UPLOAD_ARCHIVE(2);

    companion object {
        fun fromTag(tag: Int): Command? = entries.find { it.tag == tag }
    }
}

/** PacketType matching the Idris2 ABI tags. */
enum class PacketType(val tag: Int) {
    FLUSH(0),
    DELIMITER(1),
    RESPONSE_END(2),
    DATA(3),
    PKT_ERROR(4),
    SIDEBAND_DATA(5),
    SIDEBAND_PROGRESS(6),
    SIDEBAND_ERROR(7);

    companion object {
        fun fromTag(tag: Int): PacketType? = entries.find { it.tag == tag }
    }
}

/** RefType matching the Idris2 ABI tags. */
enum class RefType(val tag: Int) {
    BRANCH(0),
    TAG(1),
    HEAD(2),
    REMOTE(3),
    GIT_NOTE(4);

    companion object {
        fun fromTag(tag: Int): RefType? = entries.find { it.tag == tag }
    }
}

/** Capability matching the Idris2 ABI tags. */
enum class Capability(val tag: Int) {
    MULTI_ACK(0),
    THIN_PACK(1),
    SIDE_BAND64K(2),
    OFS_DELTA(3),
    SHALLOW(4),
    DEEPEN_SINCE(5),
    DEEPEN_NOT(6),
    FILTER_SPEC(7),
    OBJECT_FORMAT(8);

    companion object {
        fun fromTag(tag: Int): Capability? = entries.find { it.tag == tag }
    }
}

/** HookResult matching the Idris2 ABI tags. */
enum class HookResult(val tag: Int) {
    ACCEPT(0),
    REJECT(1);

    companion object {
        fun fromTag(tag: Int): HookResult? = entries.find { it.tag == tag }
    }
}

/** ServerState matching the Idris2 ABI tags. */
enum class ServerState(val tag: Int) {
    IDLE(0),
    DISCOVERY(1),
    NEGOTIATING(2),
    TRANSFER(3),
    SHUTDOWN(4);

    companion object {
        fun fromTag(tag: Int): ServerState? = entries.find { it.tag == tag }
    }
}
