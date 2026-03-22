// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Database protocol types for proven-servers.

package com.hyperpolymath.proven

/** QueryType matching the Idris2 ABI tags. */
enum class QueryType(val tag: Int) {
    SELECT(0),
    INSERT(1),
    UPDATE(2),
    DELETE(3),
    CREATE_TABLE(4),
    DROP_TABLE(5),
    ALTER_TABLE(6),
    CREATE_INDEX(7),
    DROP_INDEX(8),
    BEGIN(9),
    COMMIT(10),
    ROLLBACK(11);

    companion object {
        fun fromTag(tag: Int): QueryType? = entries.find { it.tag == tag }
    }
}

/** DataType matching the Idris2 ABI tags. */
enum class DataType(val tag: Int) {
    INTEGER(0),
    FLOAT(1),
    TEXT(2),
    BLOB(3),
    BOOLEAN(4),
    TIMESTAMP(5),
    UUID(6),
    JSON(7),
    NULL(8);

    companion object {
        fun fromTag(tag: Int): DataType? = entries.find { it.tag == tag }
    }
}

/** IsolationLevel matching the Idris2 ABI tags. */
enum class IsolationLevel(val tag: Int) {
    READ_UNCOMMITTED(0),
    READ_COMMITTED(1),
    REPEATABLE_READ(2),
    SERIALIZABLE(3);

    companion object {
        fun fromTag(tag: Int): IsolationLevel? = entries.find { it.tag == tag }
    }
}

/** ErrorCode matching the Idris2 ABI tags. */
enum class ErrorCode(val tag: Int) {
    SYNTAX_ERROR(0),
    TABLE_NOT_FOUND(1),
    COLUMN_NOT_FOUND(2),
    DUPLICATE_KEY(3),
    CONSTRAINT_VIOLATION(4),
    TYPE_MISMATCH(5),
    DEADLOCK_DETECTED(6),
    TRANSACTION_ABORTED(7),
    DISK_FULL(8),
    CONNECTION_LOST(9);

    companion object {
        fun fromTag(tag: Int): ErrorCode? = entries.find { it.tag == tag }
    }
}

/** JoinType matching the Idris2 ABI tags. */
enum class JoinType(val tag: Int) {
    INNER(0),
    LEFT_OUTER(1),
    RIGHT_OUTER(2),
    FULL_OUTER(3),
    CROSS(4);

    companion object {
        fun fromTag(tag: Int): JoinType? = entries.find { it.tag == tag }
    }
}

/** SessionState matching the Idris2 ABI tags. */
enum class SessionState(val tag: Int) {
    IDLE(0),
    CONNECTED(1),
    TRANSACTION(2),
    EXECUTING(3),
    FINALISING(4),
    DISCONNECTING(5);

    companion object {
        fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
    }
}
