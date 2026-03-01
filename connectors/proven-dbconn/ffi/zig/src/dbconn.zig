// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// proven-dbconn FFI -- Zig implementation of the database connector ABI.
//
// This module enforces at runtime the state machine transitions that
// the Idris2 ABI proves at compile time.  Together they guarantee that:
//   - Queries cannot be issued on a disconnected handle
//   - Transactions cannot nest (no BEGIN inside BEGIN)
//   - Failed connections must be reset before reuse
//   - All query parameters are typed (no raw string interpolation)
//
// This is a SKELETON implementation -- it enforces the state machine
// and type contracts but does not contain an actual database driver.
// Real drivers (PostgreSQL, MariaDB, VeriSimDB, etc.) implement the
// backend behind this interface.
//
// Enum tag values MUST match:
//   - Idris2 Layout.idr  (src/abi/DBConnABI/Layout.idr)
//   - C header            (generated/abi/dbconn.h)

const std = @import("std");

// ========================================================================
// ABI constants
// ========================================================================

/// ABI version.  Must match PROVEN_DBCONN_ABI_VERSION in the C header
/// and abiVersion in DBConnABI.Foreign.
pub const ABI_VERSION: u32 = 1;

/// Default PostgreSQL port.  Matches DBConn.defaultPort.
pub const DEFAULT_PORT: u16 = 5432;

/// Maximum connections per pool.  Matches DBConn.maxPoolSize.
pub const MAX_POOL_SIZE: u16 = 100;

/// Default query timeout in seconds.  Matches DBConn.queryTimeout.
pub const QUERY_TIMEOUT: u32 = 30;

/// Maximum parameters per prepared statement.  Matches DBConn.maxParamCount.
pub const MAX_PARAM_COUNT: u16 = 65535;

// ========================================================================
// Enum types -- tag values match C header and Idris2 Layout.idr exactly
// ========================================================================

/// Connection lifecycle state.
/// Tags: Disconnected=0, Connected=1, InTransaction=2, Failed=3.
pub const ConnState = enum(u8) {
    disconnected = 0,
    connected = 1,
    in_transaction = 2,
    failed = 3,
};

/// SQL transaction isolation level.
/// Tags: ReadUncommitted=0, ReadCommitted=1, RepeatableRead=2,
///       Serializable=3, Snapshot=4.
pub const IsolationLevel = enum(u8) {
    read_uncommitted = 0,
    read_committed = 1,
    repeatable_read = 2,
    serializable = 3,
    snapshot = 4,
};

/// Typed query parameter kind.
/// Tags: PText=0, PInt=1, PFloat=2, PBool=3, PNull=4,
///       PBytes=5, PTimestamp=6, PUUID=7.
pub const ParamType = enum(u8) {
    text = 0,
    int = 1,
    float = 2,
    bool_ = 3,
    null_ = 4,
    bytes = 5,
    timestamp = 6,
    uuid = 7,
};

/// Query execution result category.
/// Tags: ResultSet=0, RowCount=1, Empty=2, Error=3.
pub const QueryResult = enum(u8) {
    result_set = 0,
    row_count = 1,
    empty = 2,
    err = 3,
};

/// Connection / query error category.
/// Tags: None=0, ConnectionRefused=1, AuthenticationFailed=2,
///       QueryError=3, TransactionError=4, Timeout=5,
///       PoolExhausted=6, ProtocolError=7, TLSRequired=8.
/// Tag 0 (none) has no Idris2 constructor -- it represents success.
pub const ConnError = enum(u8) {
    none = 0,
    connection_refused = 1,
    authentication_failed = 2,
    query_error = 3,
    transaction_error = 4,
    timeout = 5,
    pool_exhausted = 6,
    protocol_error = 7,
    tls_required = 8,
};

/// Connection pool lifecycle state.
/// Tags: Idle=0, Active=1, Draining=2, Closed=3.
pub const PoolState = enum(u8) {
    idle = 0,
    active = 1,
    draining = 2,
    closed = 3,
};

// ========================================================================
// Opaque handle types
// ========================================================================

/// Database connection handle.
/// Tracks connection state and enforces valid transitions at runtime.
/// Backend-specific context (socket, TLS state, etc.) would be added
/// by driver implementations; this skeleton tracks state only.
pub const ConnHandle = struct {
    /// Current lifecycle state of this connection.
    state: ConnState,
    /// Port the connection was established on.
    port: u16,
    /// Whether TLS was required for this connection.
    require_tls: bool,
};

/// Prepared statement handle.
/// Tracks bound parameter count and execution state.
/// Always associated with the ConnHandle that created it.
pub const StmtHandle = struct {
    /// Back-reference to the owning connection.
    conn: *ConnHandle,
    /// Number of parameter slots declared in the SQL.
    param_count: u16,
    /// Number of parameters actually bound so far.
    bound_count: u16,
    /// Whether this statement has been executed.
    /// Once executed, parameters cannot be rebound.
    executed: bool,
};

/// Connection pool.
/// Tracks pool lifecycle state and capacity.
pub const Pool = struct {
    /// Current lifecycle state of this pool.
    state: PoolState,
    /// Maximum number of connections this pool can manage.
    max_connections: u16,
    /// Number of currently checked-out connections.
    active_count: u16,
};

// ========================================================================
// Allocator -- uses Zig's general purpose allocator for safety
// ========================================================================

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// ========================================================================
// Exported C ABI functions
// ========================================================================

/// Return ABI version for compatibility checking.
/// Callers MUST verify this equals PROVEN_DBCONN_ABI_VERSION before
/// calling any other function.
pub export fn dbconn_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

/// Connect to a database.
///
/// State machine: creates a new handle in Connected state.
/// On allocation failure, returns null and sets err to connection_refused.
///
/// Parameters:
///   host        -- hostname (unused in skeleton, reserved for driver)
///   port        -- TCP port number
///   require_tls -- non-zero means TLS is mandatory
///   err         -- pointer to receive the error code
///
/// Returns: non-null handle on success, null on failure.
pub export fn dbconn_connect(
    host: ?[*:0]const u8,
    port: u16,
    require_tls: u8,
    err: *ConnError,
) callconv(.c) ?*ConnHandle {
    // Backend-specific: skeleton does not open real connections.
    _ = host;

    const handle = allocator.create(ConnHandle) catch {
        err.* = ConnError.connection_refused;
        return null;
    };

    handle.* = ConnHandle{
        .state = ConnState.connected,
        .port = port,
        .require_tls = require_tls != 0,
    };

    err.* = ConnError.none;
    return handle;
}

/// Disconnect a connection handle.
///
/// State machine: Connected|InTransaction -> Disconnected.
/// Invalid in Disconnected or Failed state (returns protocol_error).
/// Frees the handle memory on success.
///
/// Returns: ConnError.none on success, or an error code.
pub export fn dbconn_disconnect(h: ?*ConnHandle) callconv(.c) ConnError {
    const handle = h orelse return ConnError.protocol_error;

    switch (handle.state) {
        .connected, .in_transaction => {
            handle.state = ConnState.disconnected;
            allocator.destroy(handle);
            return ConnError.none;
        },
        .disconnected => return ConnError.protocol_error,
        .failed => return ConnError.protocol_error,
    }
}

/// Get the current connection state.
///
/// Returns ConnState.disconnected if h is null.
pub export fn dbconn_state(h: ?*const ConnHandle) callconv(.c) ConnState {
    const handle = h orelse return ConnState.disconnected;
    return handle.state;
}

/// Begin a transaction.
///
/// State machine: Connected -> InTransaction.
/// Returns transaction_error if already in a transaction.
/// Returns protocol_error if Disconnected or Failed.
///
/// Parameters:
///   h   -- connection handle
///   iso -- isolation level (tag from IsolationLevel enum)
///
/// Returns: ConnError.none on success, or an error code.
pub export fn dbconn_begin_tx(h: ?*ConnHandle, iso: IsolationLevel) callconv(.c) ConnError {
    const handle = h orelse return ConnError.protocol_error;
    // Backend-specific: skeleton tracks state only, ignores isolation level.
    _ = iso;

    switch (handle.state) {
        .connected => {
            handle.state = ConnState.in_transaction;
            return ConnError.none;
        },
        .in_transaction => return ConnError.transaction_error,
        .disconnected => return ConnError.protocol_error,
        .failed => return ConnError.protocol_error,
    }
}

/// Commit the current transaction.
///
/// State machine: InTransaction -> Connected.
/// Returns transaction_error if no active transaction (Connected state).
/// Returns protocol_error if Disconnected or Failed.
///
/// Returns: ConnError.none on success, or an error code.
pub export fn dbconn_commit(h: ?*ConnHandle) callconv(.c) ConnError {
    const handle = h orelse return ConnError.protocol_error;

    switch (handle.state) {
        .in_transaction => {
            handle.state = ConnState.connected;
            return ConnError.none;
        },
        .connected => return ConnError.transaction_error,
        .disconnected => return ConnError.protocol_error,
        .failed => return ConnError.protocol_error,
    }
}

/// Rollback the current transaction.
///
/// State machine: InTransaction -> Connected.
/// Returns transaction_error if no active transaction (Connected state).
/// Returns protocol_error if Disconnected or Failed.
///
/// Returns: ConnError.none on success, or an error code.
pub export fn dbconn_rollback(h: ?*ConnHandle) callconv(.c) ConnError {
    const handle = h orelse return ConnError.protocol_error;

    switch (handle.state) {
        .in_transaction => {
            handle.state = ConnState.connected;
            return ConnError.none;
        },
        .connected => return ConnError.transaction_error,
        .disconnected => return ConnError.protocol_error,
        .failed => return ConnError.protocol_error,
    }
}

/// Prepare a parameterised statement.
///
/// State machine: requires Connected or InTransaction (CanQuery states).
/// Returns null and sets err for other states or allocation failure.
///
/// Parameters:
///   h       -- connection handle
///   sql     -- SQL string (unused in skeleton, reserved for driver)
///   sql_len -- length of sql in bytes
///   err     -- pointer to receive the error code
///
/// Returns: non-null statement handle on success, null on failure.
pub export fn dbconn_prepare(
    h: ?*ConnHandle,
    sql: ?[*]const u8,
    sql_len: u32,
    err: *ConnError,
) callconv(.c) ?*StmtHandle {
    const handle = h orelse {
        err.* = ConnError.protocol_error;
        return null;
    };
    // Backend-specific: skeleton does not parse SQL.
    _ = sql;
    _ = sql_len;

    switch (handle.state) {
        .connected, .in_transaction => {},
        .disconnected, .failed => {
            err.* = ConnError.protocol_error;
            return null;
        },
    }

    const stmt = allocator.create(StmtHandle) catch {
        err.* = ConnError.query_error;
        return null;
    };

    stmt.* = StmtHandle{
        .conn = handle,
        .param_count = 0,
        .bound_count = 0,
        .executed = false,
    };

    err.* = ConnError.none;
    return stmt;
}

/// Bind a typed parameter to a prepared statement.
///
/// Validates that:
///   - The statement handle is non-null
///   - The statement has not already been executed
///
/// The ParamType enum guarantees that the type tag is valid at the Zig
/// type level -- no additional range checking is needed.
///
/// Parameters:
///   s         -- statement handle
///   index     -- zero-based parameter index
///   typ       -- parameter type tag
///   value     -- pointer to parameter value (backend-specific)
///   value_len -- length of value in bytes
///
/// Returns: ConnError.none on success, or an error code.
pub export fn dbconn_bind_param(
    s: ?*StmtHandle,
    index: u16,
    typ: ParamType,
    value: ?*const anyopaque,
    value_len: u32,
) callconv(.c) ConnError {
    const stmt = s orelse return ConnError.protocol_error;
    // Backend-specific: skeleton validates state only.
    _ = index;
    _ = typ;
    _ = value;
    _ = value_len;

    if (stmt.executed) return ConnError.protocol_error;

    stmt.bound_count += 1;
    return ConnError.none;
}

/// Execute a prepared statement.
///
/// State machine: verifies the owning connection is still in a CanQuery
/// state (Connected or InTransaction).  Marks the statement as executed.
///
/// Parameters:
///   s   -- statement handle
///   err -- pointer to receive the error code
///
/// Returns: QueryResult tag.  Skeleton always returns empty.
pub export fn dbconn_execute(s: ?*StmtHandle, err: *ConnError) callconv(.c) QueryResult {
    const stmt = s orelse {
        err.* = ConnError.protocol_error;
        return QueryResult.err;
    };

    switch (stmt.conn.state) {
        .connected, .in_transaction => {},
        .disconnected, .failed => {
            err.* = ConnError.protocol_error;
            return QueryResult.err;
        },
    }

    stmt.executed = true;
    err.* = ConnError.none;
    return QueryResult.empty; // Skeleton: no real backend.
}

/// Free a prepared statement.
/// Safe to call with null (no-op).
pub export fn dbconn_stmt_free(s: ?*StmtHandle) callconv(.c) void {
    const stmt = s orelse return;
    allocator.destroy(stmt);
}

/// Create a connection pool.
///
/// max_connections is capped at MAX_POOL_SIZE (100).
/// Returns null on allocation failure.
pub export fn dbconn_pool_create(max_connections: u16) callconv(.c) ?*Pool {
    const capped = if (max_connections > MAX_POOL_SIZE) MAX_POOL_SIZE else max_connections;

    const pool = allocator.create(Pool) catch return null;
    pool.* = Pool{
        .state = PoolState.idle,
        .max_connections = capped,
        .active_count = 0,
    };
    return pool;
}

/// Get pool state.
/// Returns PoolState.closed if p is null.
pub export fn dbconn_pool_state(p: ?*const Pool) callconv(.c) PoolState {
    const pool = p orelse return PoolState.closed;
    return pool.state;
}

/// Drain and destroy a pool.
/// Safe to call with null (no-op).
pub export fn dbconn_pool_destroy(p: ?*Pool) callconv(.c) void {
    const pool = p orelse return;
    pool.state = PoolState.closed;
    allocator.destroy(pool);
}
