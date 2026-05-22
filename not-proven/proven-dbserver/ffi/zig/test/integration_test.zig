// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-dbserver FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Query execution
//   - Transaction lifecycle (begin/commit/rollback)
//   - Isolation level management
//   - Disconnect / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const db = @import("dbserver");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), db.db_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "QueryType encoding matches Types.idr (12 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(db.QueryType.select));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(db.QueryType.insert));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(db.QueryType.update));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(db.QueryType.delete));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(db.QueryType.create_table));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(db.QueryType.drop_table));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(db.QueryType.alter_table));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(db.QueryType.create_index));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(db.QueryType.drop_index));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(db.QueryType.begin));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(db.QueryType.commit));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(db.QueryType.rollback));
}

test "DataType encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(db.DataType.integer));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(db.DataType.float));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(db.DataType.text));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(db.DataType.blob));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(db.DataType.boolean));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(db.DataType.timestamp));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(db.DataType.uuid));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(db.DataType.json));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(db.DataType.null_type));
}

test "IsolationLevel encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(db.IsolationLevel.read_uncommitted));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(db.IsolationLevel.read_committed));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(db.IsolationLevel.repeatable_read));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(db.IsolationLevel.serializable));
}

test "ErrorCode encoding matches Types.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(db.ErrorCode.syntax_error));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(db.ErrorCode.table_not_found));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(db.ErrorCode.column_not_found));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(db.ErrorCode.duplicate_key));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(db.ErrorCode.constraint_violation));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(db.ErrorCode.type_mismatch));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(db.ErrorCode.deadlock_detected));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(db.ErrorCode.transaction_aborted));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(db.ErrorCode.disk_full));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(db.ErrorCode.connection_lost));
}

test "JoinType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(db.JoinType.inner));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(db.JoinType.left_outer));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(db.JoinType.right_outer));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(db.JoinType.full_outer));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(db.JoinType.cross));
}

test "SessionState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(db.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(db.SessionState.connected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(db.SessionState.transaction));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(db.SessionState.executing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(db.SessionState.finalising));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(db.SessionState.disconnecting));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Connected state" {
    const name = "testdb";
    const slot = db.db_create(name.ptr, name.len, 1);
    try std.testing.expect(slot >= 0);
    defer db.db_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), db.db_state(slot)); // Connected
}

test "create rejects empty name" {
    const name = "x";
    const slot = db.db_create(name.ptr, 0, 1);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid isolation level" {
    const name = "badiso";
    const slot = db.db_create(name.ptr, name.len, 99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    db.db_destroy(-1);
    db.db_destroy(999);
}

// =========================================================================
// Query execution
// =========================================================================

test "execute succeeds from Connected" {
    const name = "execdb";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    const sql = "SELECT 1";
    try std.testing.expectEqual(@as(u8, 0), db.db_execute(slot, 0, sql.ptr, sql.len));
    try std.testing.expectEqual(@as(u32, 1), db.db_query_count(slot));
    try std.testing.expectEqual(@as(u8, 1), db.db_state(slot)); // back to Connected
}

test "execute succeeds from Transaction" {
    const name = "txexecdb";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    _ = db.db_begin_tx(slot);
    const sql = "INSERT INTO t VALUES(1)";
    try std.testing.expectEqual(@as(u8, 0), db.db_execute(slot, 1, sql.ptr, sql.len));
    try std.testing.expectEqual(@as(u8, 2), db.db_state(slot)); // back to Transaction
}

test "execute rejects invalid query type" {
    const name = "badquery";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    const sql = "INVALID";
    try std.testing.expectEqual(@as(u8, 1), db.db_execute(slot, 99, sql.ptr, sql.len));
}

// =========================================================================
// Transaction lifecycle
// =========================================================================

test "begin_tx transitions Connected -> Transaction" {
    const name = "txdb";
    const slot = db.db_create(name.ptr, name.len, 3); // serializable
    defer db.db_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), db.db_begin_tx(slot));
    try std.testing.expectEqual(@as(u8, 2), db.db_state(slot)); // Transaction
    try std.testing.expectEqual(@as(u8, 1), db.db_in_transaction(slot));
}

test "commit transitions Transaction -> Connected" {
    const name = "commitdb";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    _ = db.db_begin_tx(slot);
    try std.testing.expectEqual(@as(u8, 0), db.db_commit(slot));
    try std.testing.expectEqual(@as(u8, 1), db.db_state(slot)); // Connected
    try std.testing.expectEqual(@as(u8, 0), db.db_in_transaction(slot));
}

test "rollback transitions Transaction -> Connected" {
    const name = "rollbackdb";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    _ = db.db_begin_tx(slot);
    try std.testing.expectEqual(@as(u8, 0), db.db_rollback(slot));
    try std.testing.expectEqual(@as(u8, 1), db.db_state(slot)); // Connected
    try std.testing.expectEqual(@as(u8, 0), db.db_in_transaction(slot));
}

test "commit rejects when not in Transaction" {
    const name = "badcommit";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), db.db_commit(slot));
}

test "begin_tx rejects when already in Transaction" {
    const name = "doubletx";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    _ = db.db_begin_tx(slot);
    try std.testing.expectEqual(@as(u8, 1), db.db_begin_tx(slot));
}

// =========================================================================
// Isolation level
// =========================================================================

test "isolation_level returns configured level" {
    const name = "isodb";
    const slot = db.db_create(name.ptr, name.len, 3); // serializable
    defer db.db_destroy(slot);

    try std.testing.expectEqual(@as(u8, 3), db.db_isolation_level(slot));
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Connected -> Disconnecting" {
    const name = "discdb";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), db.db_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 5), db.db_state(slot)); // Disconnecting
}

test "disconnect from Transaction" {
    const name = "txdisc";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    _ = db.db_begin_tx(slot);
    try std.testing.expectEqual(@as(u8, 0), db.db_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 5), db.db_state(slot));
}

test "cleanup transitions Disconnecting -> Idle" {
    const name = "cleandb";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    _ = db.db_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), db.db_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), db.db_state(slot)); // Idle
}

test "cleanup clears query count" {
    const name = "cleardb";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    const sql = "SELECT 1";
    _ = db.db_execute(slot, 0, sql.ptr, sql.len);
    _ = db.db_disconnect(slot);
    _ = db.db_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), db.db_query_count(slot));
}

test "cleanup rejected from non-Disconnecting state" {
    const name = "badclean";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), db.db_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "db_can_transition matches Types.idr transitions" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(0, 1)); // Idle -> Connected
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(1, 2)); // Connected -> Transaction
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(1, 3)); // Connected -> Executing
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(2, 3)); // Transaction -> Executing
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(3, 1)); // Executing -> Connected
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(3, 2)); // Executing -> Transaction
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(2, 4)); // Transaction -> Finalising
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(4, 1)); // Finalising -> Connected
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(1, 5)); // Connected -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(2, 5)); // Transaction -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(3, 5)); // Executing -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), db.db_can_transition(5, 0)); // Disconnecting -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), db.db_can_transition(0, 2)); // Idle -/-> Transaction
    try std.testing.expectEqual(@as(u8, 0), db.db_can_transition(0, 3)); // Idle -/-> Executing
    try std.testing.expectEqual(@as(u8, 0), db.db_can_transition(5, 1)); // Disconnecting -/-> Connected
    try std.testing.expectEqual(@as(u8, 0), db.db_can_transition(0, 5)); // Idle -/-> Disconnecting
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), db.db_state(-1));
    try std.testing.expectEqual(@as(u8, 0), db.db_in_transaction(-1));
    try std.testing.expectEqual(@as(u32, 0), db.db_query_count(-1));
    try std.testing.expectEqual(@as(u8, 1), db.db_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), db.db_cleanup(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot execute from Idle" {
    const name = "idleexec";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    _ = db.db_disconnect(slot);
    _ = db.db_cleanup(slot);
    const sql = "SELECT 1";
    try std.testing.expectEqual(@as(u8, 1), db.db_execute(slot, 0, sql.ptr, sql.len));
}

test "cannot begin transaction from Disconnecting" {
    const name = "disctx";
    const slot = db.db_create(name.ptr, name.len, 1);
    defer db.db_destroy(slot);

    _ = db.db_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 1), db.db_begin_tx(slot));
}
