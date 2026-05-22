// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Database protocol types for proven-servers.

package com.hyperpolymath.proven;

/**
 * Database protocol types for proven-servers matching the Idris2 ABI tags.
 * @author Jonathan D.A. Jewell
 */
public final class ProvenDbserver {
    private ProvenDbserver() {}

    /** QueryType (tags 0-11). */
    public enum QueryType {
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

        private final int tag;
        QueryType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static QueryType fromTag(int tag) {
            for (QueryType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** DataType (tags 0-8). */
    public enum DataType {
        INTEGER(0),
        FLOAT(1),
        TEXT(2),
        BLOB(3),
        BOOLEAN(4),
        TIMESTAMP(5),
        UUID(6),
        JSON(7),
        NULL(8);

        private final int tag;
        DataType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static DataType fromTag(int tag) {
            for (DataType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** IsolationLevel (tags 0-3). */
    public enum IsolationLevel {
        READ_UNCOMMITTED(0),
        READ_COMMITTED(1),
        REPEATABLE_READ(2),
        SERIALIZABLE(3);

        private final int tag;
        IsolationLevel(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static IsolationLevel fromTag(int tag) {
            for (IsolationLevel v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** ErrorCode (tags 0-9). */
    public enum ErrorCode {
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

        private final int tag;
        ErrorCode(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static ErrorCode fromTag(int tag) {
            for (ErrorCode v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** JoinType (tags 0-4). */
    public enum JoinType {
        INNER(0),
        LEFT_OUTER(1),
        RIGHT_OUTER(2),
        FULL_OUTER(3),
        CROSS(4);

        private final int tag;
        JoinType(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static JoinType fromTag(int tag) {
            for (JoinType v : values()) if (v.tag == tag) return v;
            return null;
        }
    }

    /** SessionState (tags 0-5). */
    public enum SessionState {
        IDLE(0),
        CONNECTED(1),
        TRANSACTION(2),
        EXECUTING(3),
        FINALISING(4),
        DISCONNECTING(5);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState v : values()) if (v.tag == tag) return v;
            return null;
        }
    }
}
