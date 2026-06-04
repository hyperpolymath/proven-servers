// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// dbserver.zig -- Zig FFI implementation of proven-dbserver.
//
// Implements the database server session state machine with:
//   - 64-slot mutex-protected session pool
//   - Transaction lifecycle per session
//   - Query execution tracking
//   - Isolation level management
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching DbserverABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching DbserverABI.Types.idr tag assignments)
// =========================================================================

/// Query types (ABI tags 0-11).
pub const QueryType = enum(u8) {
    select = 0,
    insert = 1,
    update = 2,
    delete = 3,
    create_table = 4,
    drop_table = 5,
    alter_table = 6,
    create_index = 7,
    drop_index = 8,
    begin = 9,
    commit = 10,
    rollback = 11,
};

/// Column data types (ABI tags 0-8).
pub const DataType = enum(u8) {
    integer = 0,
    float = 1,
    text = 2,
    blob = 3,
    boolean = 4,
    timestamp = 5,
    uuid = 6,
    json = 7,
    null_type = 8,
};

/// Transaction isolation levels (ABI tags 0-3).
pub const IsolationLevel = enum(u8) {
    read_uncommitted = 0,
    read_committed = 1,
    repeatable_read = 2,
    serializable = 3,
};

/// Error codes (ABI tags 0-9).
pub const ErrorCode = enum(u8) {
    syntax_error = 0,
    table_not_found = 1,
    column_not_found = 2,
    duplicate_key = 3,
    constraint_violation = 4,
    type_mismatch = 5,
    deadlock_detected = 6,
    transaction_aborted = 7,
    disk_full = 8,
    connection_lost = 9,
};

/// Join types (ABI tags 0-4).
pub const JoinType = enum(u8) {
    inner = 0,
    left_outer = 1,
    right_outer = 2,
    full_outer = 3,
    cross = 4,
};

/// Session lifecycle states (ABI tags 0-5).
pub const SessionState = enum(u8) {
    idle = 0,
    connected = 1,
    transaction = 2,
    executing = 3,
    finalising = 4,
    disconnecting = 5,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum database name length in bytes.
const MAX_NAME_LEN: usize = 256;

/// A database session.
const Session = struct {
    /// Current session lifecycle state.
    state: SessionState,
    /// Database name.
    name: [MAX_NAME_LEN]u8,
    name_len: u32,
    /// Transaction isolation level.
    isolation: IsolationLevel,
    /// Whether inside an explicit transaction.
    in_transaction: bool,
    /// Total queries executed in this session.
    query_count: u32,
    /// Whether executing returns to Transaction or Connected.
    exec_return_to_tx: bool,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .name = [_]u8{0} ** MAX_NAME_LEN,
    .name_len = 0,
    .isolation = .read_committed,
    .in_transaction = false,
    .query_count = 0,
    .exec_return_to_tx = false,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var sessions: [MAX_SESSIONS]Session = [_]Session{empty_session} ** MAX_SESSIONS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

// -- ABI version ----------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn db_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ------------------------------------------------------------

/// Create a new database session. Returns slot index (>=0) or -1 on failure.
/// The session starts in Connected state (Idle -> Connected transition).
pub export fn db_create(
    name_ptr: [*]const u8,
    name_len: u32,
    isolation: u8,
) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (name_len == 0 or name_len > MAX_NAME_LEN) return -1;
    if (isolation > 3) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.name[0..name_len], name_ptr[0..name_len]);
            s.name_len = name_len;
            s.isolation = @enumFromInt(isolation);
            s.state = .connected;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn db_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

// -- State queries --------------------------------------------------------

/// Returns the current SessionState tag for a session.
pub export fn db_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Returns 1 if the session is inside an explicit transaction, 0 otherwise.
pub export fn db_in_transaction(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].in_transaction) 1 else 0;
}

/// Returns total queries executed in this session.
pub export fn db_query_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].query_count;
}

/// Returns the isolation level for a session.
pub export fn db_isolation_level(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1; // default read_committed
    return @intFromEnum(sessions[idx].isolation);
}

// -- Query execution ------------------------------------------------------

/// Execute a query. Returns 0 on success, 1 on rejection (wrong state/type).
/// Transitions Connected -> Executing -> Connected, or
/// Transaction -> Executing -> Transaction.
pub export fn db_execute(
    slot: c_int,
    query_type: u8,
    sql_ptr: [*]const u8,
    sql_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = sql_ptr;
    _ = sql_len;

    const idx = validSlot(slot) orelse return 1;
    if (query_type > 11) return 1;

    const state = sessions[idx].state;
    if (state != .connected and state != .transaction) return 1;

    // Track whether we should return to Transaction state
    sessions[idx].exec_return_to_tx = (state == .transaction);
    sessions[idx].state = .executing;

    // Immediately complete the execution (simulated)
    sessions[idx].query_count += 1;
    if (sessions[idx].exec_return_to_tx) {
        sessions[idx].state = .transaction;
    } else {
        sessions[idx].state = .connected;
    }

    return 0;
}

// -- Transaction management -----------------------------------------------

/// Begin an explicit transaction.
/// Transitions Connected -> Transaction.
pub export fn db_begin_tx(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .connected) return 1;

    sessions[idx].state = .transaction;
    sessions[idx].in_transaction = true;
    return 0;
}

/// Commit the current transaction.
/// Transitions Transaction -> Finalising -> Connected.
pub export fn db_commit(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .transaction) return 1;

    sessions[idx].state = .finalising;
    // Immediately complete (simulated)
    sessions[idx].state = .connected;
    sessions[idx].in_transaction = false;
    return 0;
}

/// Rollback the current transaction.
/// Transitions Transaction -> Finalising -> Connected.
pub export fn db_rollback(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .transaction) return 1;

    sessions[idx].state = .finalising;
    // Immediately complete (simulated)
    sessions[idx].state = .connected;
    sessions[idx].in_transaction = false;
    return 0;
}

// -- Disconnect / Cleanup -------------------------------------------------

/// Disconnect the session.
/// Transitions Connected/Transaction/Executing -> Disconnecting.
pub export fn db_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .connected or state == .transaction or state == .executing) {
        sessions[idx].state = .disconnecting;
        return 0;
    }
    return 1;
}

/// Complete cleanup after disconnect.
/// Transitions Disconnecting -> Idle.
pub export fn db_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnecting) return 1;

    sessions[idx].state = .idle;
    sessions[idx].in_transaction = false;
    sessions[idx].query_count = 0;

    return 0;
}

// -- Stateless transition table -------------------------------------------

/// Check if a session state transition is valid.
pub export fn db_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Connected
    if (from == 1 and to == 2) return 1; // Connected -> Transaction
    if (from == 1 and to == 3) return 1; // Connected -> Executing
    if (from == 2 and to == 3) return 1; // Transaction -> Executing
    if (from == 3 and to == 1) return 1; // Executing -> Connected
    if (from == 3 and to == 2) return 1; // Executing -> Transaction
    if (from == 2 and to == 4) return 1; // Transaction -> Finalising
    if (from == 4 and to == 1) return 1; // Finalising -> Connected
    if (from == 1 and to == 5) return 1; // Connected -> Disconnecting
    if (from == 2 and to == 5) return 1; // Transaction -> Disconnecting
    if (from == 3 and to == 5) return 1; // Executing -> Disconnecting
    if (from == 5 and to == 0) return 1; // Disconnecting -> Idle
    return 0;
}
