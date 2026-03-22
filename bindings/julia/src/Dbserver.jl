# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-dbserver protocol (database server).
#
# Wraps the C-ABI functions from protocols/proven-dbserver/ffi/zig/src/dbserver.zig
# via ccall into libproven_dbserver.so.

module Dbserver

using ..ProvenServers: check_status, check_slot, SlotId

export QueryType, DataType, IsolationLevel, ErrorCode, JoinType, SessionState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_dbserver"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Database query types (SQL DML/DDL).  Matches `QueryType` in `DbserverABI.Types`."""
@enum QueryType::UInt8 begin
    SELECT = 0
    INSERT = 1
    UPDATE = 2
    DELETE = 3
    CREATE_TABLE = 4
    DROP_TABLE = 5
    ALTER_TABLE = 6
    CREATE_INDEX = 7
    DROP_INDEX = 8
    BEGIN = 9
    COMMIT = 10
    ROLLBACK = 11
end


"""Database column/value data types.  Matches `DataType` in `DbserverABI.Types`."""
@enum DataType::UInt8 begin
    INTEGER = 0
    FLOAT = 1
    TEXT = 2
    BLOB = 3
    BOOLEAN = 4
    TIMESTAMP = 5
    UUID = 6
    JSON = 7
    NULL = 8
end


"""Transaction isolation levels (ANSI SQL).  Matches `IsolationLevel` in `DbserverABI.Types`."""
@enum IsolationLevel::UInt8 begin
    READ_UNCOMMITTED = 0
    READ_COMMITTED = 1
    REPEATABLE_READ = 2
    SERIALIZABLE = 3
end


"""Database error codes.  Matches `ErrorCode` in `DbserverABI.Types`."""
@enum ErrorCode::UInt8 begin
    SYNTAX_ERROR = 0
    TABLE_NOT_FOUND = 1
    COLUMN_NOT_FOUND = 2
    DUPLICATE_KEY = 3
    CONSTRAINT_VIOLATION = 4
    TYPE_MISMATCH = 5
    DEADLOCK_DETECTED = 6
    TRANSACTION_ABORTED = 7
    DISK_FULL = 8
    CONNECTION_LOST = 9
end


"""SQL JOIN types.  Matches `JoinType` in `DbserverABI.Types`."""
@enum JoinType::UInt8 begin
    INNER = 0
    LEFT_OUTER = 1
    RIGHT_OUTER = 2
    FULL_OUTER = 3
    CROSS = 4
end


"""Database session lifecycle states.  Matches `SessionState` in `DbserverABI.Types`."""
@enum SessionState::UInt8 begin
    IDLE = 0
    CONNECTED = 1
    TRANSACTION = 2
    EXECUTING = 3
    FINALISING = 4
    DISCONNECTING = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_dbserver."""
function abi_version()::UInt32
    ccall((:dbserver_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new database server context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:dbserver_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given database server context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:dbserver_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SessionState

Get the current database server lifecycle state.
"""
function get_state(slot::SlotId)::SessionState
    SessionState(ccall((:dbserver_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SessionState, to::SessionState) -> Bool

Check whether a database server state transition is valid.
"""
function can_transition(from::SessionState, to::SessionState)::Bool
    ccall((:dbserver_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Dbserver
