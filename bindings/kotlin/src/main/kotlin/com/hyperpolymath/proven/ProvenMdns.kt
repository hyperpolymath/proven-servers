// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mDNS protocol types for proven-servers.

package com.hyperpolymath.proven

/** MdnsRecordType matching the Idris2 ABI tags. */
enum class MdnsRecordType(val tag: Int) {
    A(0),
    AAAA(1),
    PTR(2),
    SRV(3),
    TXT(4);

    companion object {
        fun fromTag(tag: Int): MdnsRecordType? = entries.find { it.tag == tag }
    }
}

/** QueryType matching the Idris2 ABI tags. */
enum class QueryType(val tag: Int) {
    STANDARD(0),
    ONE_SHOT(1),
    CONTINUOUS(2);

    companion object {
        fun fromTag(tag: Int): QueryType? = entries.find { it.tag == tag }
    }
}

/** ConflictAction matching the Idris2 ABI tags. */
enum class ConflictAction(val tag: Int) {
    PROBE(0),
    DEFEND(1),
    WITHDRAW(2);

    companion object {
        fun fromTag(tag: Int): ConflictAction? = entries.find { it.tag == tag }
    }
}

/** ServiceFlag matching the Idris2 ABI tags. */
enum class ServiceFlag(val tag: Int) {
    UNIQUE(0),
    SHARED(1);

    companion object {
        fun fromTag(tag: Int): ServiceFlag? = entries.find { it.tag == tag }
    }
}

/** ResponderState matching the Idris2 ABI tags. */
enum class ResponderState(val tag: Int) {
    IDLE(0),
    PROBING(1),
    ANNOUNCING(2),
    RUNNING(3),
    SHUTTING_DOWN(4);

    companion object {
        fun fromTag(tag: Int): ResponderState? = entries.find { it.tag == tag }
    }
}
