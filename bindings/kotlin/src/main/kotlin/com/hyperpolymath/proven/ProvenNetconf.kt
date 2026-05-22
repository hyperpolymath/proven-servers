// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// NETCONF protocol types for proven-servers.

package com.hyperpolymath.proven

/** NetconfOperation matching the Idris2 ABI tags. */
enum class NetconfOperation(val tag: Int) {
    GET(0),
    GET_CONFIG(1),
    EDIT_CONFIG(2),
    COPY_CONFIG(3),
    DELETE_CONFIG(4),
    LOCK(5),
    UNLOCK(6),
    CLOSE_SESSION(7),
    KILL_SESSION(8),
    COMMIT(9),
    VALIDATE(10),
    DISCARD_CHANGES(11);

    companion object {
        fun fromTag(tag: Int): NetconfOperation? = entries.find { it.tag == tag }
    }
}

/** Datastore matching the Idris2 ABI tags. */
enum class Datastore(val tag: Int) {
    RUNNING(0),
    STARTUP(1),
    CANDIDATE(2);

    companion object {
        fun fromTag(tag: Int): Datastore? = entries.find { it.tag == tag }
    }
}

/** EditOperation matching the Idris2 ABI tags. */
enum class EditOperation(val tag: Int) {
    MERGE(0),
    REPLACE(1),
    CREATE(2),
    DELETE(3),
    REMOVE(4);

    companion object {
        fun fromTag(tag: Int): EditOperation? = entries.find { it.tag == tag }
    }
}

/** NetconfErrorType matching the Idris2 ABI tags. */
enum class NetconfErrorType(val tag: Int) {
    TRANSPORT(0),
    RPC(1),
    PROTOCOL(2),
    APPLICATION(3);

    companion object {
        fun fromTag(tag: Int): NetconfErrorType? = entries.find { it.tag == tag }
    }
}

/** ErrorSeverity matching the Idris2 ABI tags. */
enum class ErrorSeverity(val tag: Int) {
    ERROR(0),
    WARNING(1);

    companion object {
        fun fromTag(tag: Int): ErrorSeverity? = entries.find { it.tag == tag }
    }
}

/** NetconfState matching the Idris2 ABI tags. */
enum class NetconfState(val tag: Int) {
    IDLE(0),
    CONNECTED(1),
    LOCKED(2),
    EDITING(3),
    CLOSING(4),
    TERMINATED(5);

    companion object {
        fun fromTag(tag: Int): NetconfState? = entries.find { it.tag == tag }
    }
}
