-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Database protocol types for proven-servers.

local M = {}

--- QueryType matching the Idris2 ABI tags.
M.QueryType = {
    SELECT = 0,
    INSERT = 1,
    UPDATE = 2,
    DELETE = 3,
    CREATE_TABLE = 4,
    DROP_TABLE = 5,
    ALTER_TABLE = 6,
    CREATE_INDEX = 7,
    DROP_INDEX = 8,
    BEGIN = 9,
    COMMIT = 10,
    ROLLBACK = 11,
}

--- DataType matching the Idris2 ABI tags.
M.DataType = {
    INTEGER = 0,
    FLOAT = 1,
    TEXT = 2,
    BLOB = 3,
    BOOLEAN = 4,
    TIMESTAMP = 5,
    UUID = 6,
    JSON = 7,
    NULL = 8,
}

--- IsolationLevel matching the Idris2 ABI tags.
M.IsolationLevel = {
    READ_UNCOMMITTED = 0,
    READ_COMMITTED = 1,
    REPEATABLE_READ = 2,
    SERIALIZABLE = 3,
}

--- ErrorCode matching the Idris2 ABI tags.
M.ErrorCode = {
    SYNTAX_ERROR = 0,
    TABLE_NOT_FOUND = 1,
    COLUMN_NOT_FOUND = 2,
    DUPLICATE_KEY = 3,
    CONSTRAINT_VIOLATION = 4,
    TYPE_MISMATCH = 5,
    DEADLOCK_DETECTED = 6,
    TRANSACTION_ABORTED = 7,
    DISK_FULL = 8,
    CONNECTION_LOST = 9,
}

--- JoinType matching the Idris2 ABI tags.
M.JoinType = {
    INNER = 0,
    LEFT_OUTER = 1,
    RIGHT_OUTER = 2,
    FULL_OUTER = 3,
    CROSS = 4,
}

--- SessionState matching the Idris2 ABI tags.
M.SessionState = {
    IDLE = 0,
    CONNECTED = 1,
    TRANSACTION = 2,
    EXECUTING = 3,
    FINALISING = 4,
    DISCONNECTING = 5,
}

return M
