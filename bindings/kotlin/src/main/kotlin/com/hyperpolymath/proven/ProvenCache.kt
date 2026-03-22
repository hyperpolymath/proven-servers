// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Cache protocol types for proven-servers.

package com.hyperpolymath.proven

/** Command matching the Idris2 ABI tags. */
enum class Command(val tag: Int) {
    GET(0),
    SET(1),
    DELETE(2),
    EXISTS(3),
    EXPIRE(4),
    TTL(5),
    KEYS(6),
    FLUSH(7),
    INCR(8),
    DECR(9),
    APPEND(10),
    PREPEND(11),
    CAS(12);

    companion object {
        fun fromTag(tag: Int): Command? = entries.find { it.tag == tag }
    }
}

/** EvictionPolicy matching the Idris2 ABI tags. */
enum class EvictionPolicy(val tag: Int) {
    LRU(0),
    LFU(1),
    RANDOM(2),
    EVICT_TTL(3),
    NO_EVICTION(4);

    companion object {
        fun fromTag(tag: Int): EvictionPolicy? = entries.find { it.tag == tag }
    }
}

/** DataType matching the Idris2 ABI tags. */
enum class DataType(val tag: Int) {
    STRING_VAL(0),
    INT_VAL(1),
    LIST_VAL(2),
    SET_VAL(3),
    HASH_VAL(4);

    companion object {
        fun fromTag(tag: Int): DataType? = entries.find { it.tag == tag }
    }
}

/** ErrorCode matching the Idris2 ABI tags. */
enum class ErrorCode(val tag: Int) {
    NOT_FOUND(0),
    TYPE_MISMATCH(1),
    OUT_OF_MEMORY(2),
    KEY_TOO_LONG(3),
    VALUE_TOO_LARGE(4),
    CAS_CONFLICT(5);

    companion object {
        fun fromTag(tag: Int): ErrorCode? = entries.find { it.tag == tag }
    }
}

/** ReplicationMode matching the Idris2 ABI tags. */
enum class ReplicationMode(val tag: Int) {
    NONE(0),
    PRIMARY(1),
    REPLICA(2),
    SENTINEL(3);

    companion object {
        fun fromTag(tag: Int): ReplicationMode? = entries.find { it.tag == tag }
    }
}
