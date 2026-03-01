// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Integration tests for proven-dbconn FFI.
//
// Verifies that the Zig state machine enforcement works correctly:
//   - ABI version is correct
//   - Connection lifecycle (connect, disconnect)
//   - Transaction lifecycle (begin, commit, rollback)
//   - Invalid transition rejection
//   - Prepared statement lifecycle (prepare, bind, execute, free)
//   - Pool lifecycle (create, query state, destroy)
//   - Pool max size capping
//   - Null handle safety (all functions must handle null gracefully)
//
// These tests exercise the same invariants that the Idris2 ABI proves
// at compile time, confirming that the runtime implementation honours
// the formal specification.

const std = @import("std");
const dbconn = @import("dbconn");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ========================================================================
// ABI version
// ========================================================================

test "ABI version matches" {
    try expectEqual(@as(u32, 1), dbconn.dbconn_abi_version());
}

// ========================================================================
// Connection lifecycle
// ========================================================================

test "connect and disconnect lifecycle" {
    var err: dbconn.ConnError = .none;
    const h = dbconn.dbconn_connect(null, 5432, 1, &err);
    try expect(h != null);
    try expectEqual(dbconn.ConnError.none, err);
    try expectEqual(dbconn.ConnState.connected, dbconn.dbconn_state(h));

    const disc_err = dbconn.dbconn_disconnect(h);
    try expectEqual(dbconn.ConnError.none, disc_err);
}

test "connect sets port and TLS flag" {
    var err: dbconn.ConnError = .none;
    const h = dbconn.dbconn_connect(null, 3306, 0, &err).?;
    try expectEqual(@as(u16, 3306), h.port);
    try expectEqual(false, h.require_tls);

    _ = dbconn.dbconn_disconnect(h);
}

// ========================================================================
// Transaction lifecycle
// ========================================================================

test "transaction lifecycle: begin, commit" {
    var err: dbconn.ConnError = .none;
    const h = dbconn.dbconn_connect(null, 5432, 0, &err).?;

    // Begin transaction.
    const begin_err = dbconn.dbconn_begin_tx(h, .serializable);
    try expectEqual(dbconn.ConnError.none, begin_err);
    try expectEqual(dbconn.ConnState.in_transaction, dbconn.dbconn_state(h));

    // Cannot begin again while in transaction.
    const begin2_err = dbconn.dbconn_begin_tx(h, .read_committed);
    try expectEqual(dbconn.ConnError.transaction_error, begin2_err);

    // Commit returns to Connected.
    const commit_err = dbconn.dbconn_commit(h);
    try expectEqual(dbconn.ConnError.none, commit_err);
    try expectEqual(dbconn.ConnState.connected, dbconn.dbconn_state(h));

    _ = dbconn.dbconn_disconnect(h);
}

test "transaction lifecycle: begin, rollback" {
    var err: dbconn.ConnError = .none;
    const h = dbconn.dbconn_connect(null, 5432, 0, &err).?;

    const begin_err = dbconn.dbconn_begin_tx(h, .repeatable_read);
    try expectEqual(dbconn.ConnError.none, begin_err);

    const rb_err = dbconn.dbconn_rollback(h);
    try expectEqual(dbconn.ConnError.none, rb_err);
    try expectEqual(dbconn.ConnState.connected, dbconn.dbconn_state(h));

    _ = dbconn.dbconn_disconnect(h);
}

test "cannot commit without active transaction" {
    var err: dbconn.ConnError = .none;
    const h = dbconn.dbconn_connect(null, 5432, 0, &err).?;

    const commit_err = dbconn.dbconn_commit(h);
    try expectEqual(dbconn.ConnError.transaction_error, commit_err);

    _ = dbconn.dbconn_disconnect(h);
}

test "cannot rollback without active transaction" {
    var err: dbconn.ConnError = .none;
    const h = dbconn.dbconn_connect(null, 5432, 0, &err).?;

    const rb_err = dbconn.dbconn_rollback(h);
    try expectEqual(dbconn.ConnError.transaction_error, rb_err);

    _ = dbconn.dbconn_disconnect(h);
}

// ========================================================================
// Prepared statement lifecycle
// ========================================================================

test "prepare and execute statement" {
    var err: dbconn.ConnError = .none;
    const h = dbconn.dbconn_connect(null, 5432, 0, &err).?;

    const stmt = dbconn.dbconn_prepare(h, null, 0, &err).?;
    try expectEqual(dbconn.ConnError.none, err);

    // Bind a parameter.
    const bind_err = dbconn.dbconn_bind_param(stmt, 0, .text, null, 0);
    try expectEqual(dbconn.ConnError.none, bind_err);

    // Execute.
    const result = dbconn.dbconn_execute(stmt, &err);
    try expectEqual(dbconn.QueryResult.empty, result);
    try expectEqual(dbconn.ConnError.none, err);

    // Cannot rebind after execute.
    const rebind_err = dbconn.dbconn_bind_param(stmt, 1, .int, null, 0);
    try expectEqual(dbconn.ConnError.protocol_error, rebind_err);

    dbconn.dbconn_stmt_free(stmt);
    _ = dbconn.dbconn_disconnect(h);
}

test "prepare inside transaction" {
    var err: dbconn.ConnError = .none;
    const h = dbconn.dbconn_connect(null, 5432, 0, &err).?;

    _ = dbconn.dbconn_begin_tx(h, .read_committed);

    const stmt = dbconn.dbconn_prepare(h, null, 0, &err).?;
    try expectEqual(dbconn.ConnError.none, err);

    const result = dbconn.dbconn_execute(stmt, &err);
    try expectEqual(dbconn.QueryResult.empty, result);

    dbconn.dbconn_stmt_free(stmt);
    _ = dbconn.dbconn_commit(h);
    _ = dbconn.dbconn_disconnect(h);
}

// ========================================================================
// Pool lifecycle
// ========================================================================

test "pool lifecycle" {
    const pool = dbconn.dbconn_pool_create(10).?;
    try expectEqual(dbconn.PoolState.idle, dbconn.dbconn_pool_state(pool));

    dbconn.dbconn_pool_destroy(pool);
}

test "pool max size is capped" {
    // Request 200 connections -- should be capped to MAX_POOL_SIZE (100).
    const pool = dbconn.dbconn_pool_create(200).?;
    try expectEqual(@as(u16, 100), pool.max_connections);

    dbconn.dbconn_pool_destroy(pool);
}

test "pool at exact max size is not capped" {
    const pool = dbconn.dbconn_pool_create(100).?;
    try expectEqual(@as(u16, 100), pool.max_connections);

    dbconn.dbconn_pool_destroy(pool);
}

// ========================================================================
// Null handle safety
// ========================================================================

test "null handle safety" {
    // All functions must handle null gracefully without crashing.
    try expectEqual(dbconn.ConnState.disconnected, dbconn.dbconn_state(null));
    try expectEqual(dbconn.ConnError.protocol_error, dbconn.dbconn_disconnect(null));
    try expectEqual(dbconn.ConnError.protocol_error, dbconn.dbconn_begin_tx(null, .serializable));
    try expectEqual(dbconn.ConnError.protocol_error, dbconn.dbconn_commit(null));
    try expectEqual(dbconn.ConnError.protocol_error, dbconn.dbconn_rollback(null));
    try expectEqual(dbconn.PoolState.closed, dbconn.dbconn_pool_state(null));

    var err: dbconn.ConnError = .none;
    try expect(dbconn.dbconn_prepare(null, null, 0, &err) == null);
    try expectEqual(dbconn.ConnError.protocol_error, err);
}

test "null statement handle safety" {
    try expectEqual(dbconn.ConnError.protocol_error, dbconn.dbconn_bind_param(null, 0, .text, null, 0));

    var err: dbconn.ConnError = .none;
    try expectEqual(dbconn.QueryResult.err, dbconn.dbconn_execute(null, &err));
    try expectEqual(dbconn.ConnError.protocol_error, err);

    // stmt_free with null is a no-op (should not crash).
    dbconn.dbconn_stmt_free(null);
}

test "pool destroy with null is no-op" {
    // Should not crash.
    dbconn.dbconn_pool_destroy(null);
}

// ========================================================================
// Enum tag value consistency
// ========================================================================

test "ConnState enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(dbconn.ConnState.disconnected));
    try expectEqual(@as(u8, 1), @intFromEnum(dbconn.ConnState.connected));
    try expectEqual(@as(u8, 2), @intFromEnum(dbconn.ConnState.in_transaction));
    try expectEqual(@as(u8, 3), @intFromEnum(dbconn.ConnState.failed));
}

test "IsolationLevel enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(dbconn.IsolationLevel.read_uncommitted));
    try expectEqual(@as(u8, 1), @intFromEnum(dbconn.IsolationLevel.read_committed));
    try expectEqual(@as(u8, 2), @intFromEnum(dbconn.IsolationLevel.repeatable_read));
    try expectEqual(@as(u8, 3), @intFromEnum(dbconn.IsolationLevel.serializable));
    try expectEqual(@as(u8, 4), @intFromEnum(dbconn.IsolationLevel.snapshot));
}

test "ParamType enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(dbconn.ParamType.text));
    try expectEqual(@as(u8, 1), @intFromEnum(dbconn.ParamType.int));
    try expectEqual(@as(u8, 2), @intFromEnum(dbconn.ParamType.float));
    try expectEqual(@as(u8, 3), @intFromEnum(dbconn.ParamType.bool_));
    try expectEqual(@as(u8, 4), @intFromEnum(dbconn.ParamType.null_));
    try expectEqual(@as(u8, 5), @intFromEnum(dbconn.ParamType.bytes));
    try expectEqual(@as(u8, 6), @intFromEnum(dbconn.ParamType.timestamp));
    try expectEqual(@as(u8, 7), @intFromEnum(dbconn.ParamType.uuid));
}

test "QueryResult enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(dbconn.QueryResult.result_set));
    try expectEqual(@as(u8, 1), @intFromEnum(dbconn.QueryResult.row_count));
    try expectEqual(@as(u8, 2), @intFromEnum(dbconn.QueryResult.empty));
    try expectEqual(@as(u8, 3), @intFromEnum(dbconn.QueryResult.err));
}

test "ConnError enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(dbconn.ConnError.none));
    try expectEqual(@as(u8, 1), @intFromEnum(dbconn.ConnError.connection_refused));
    try expectEqual(@as(u8, 2), @intFromEnum(dbconn.ConnError.authentication_failed));
    try expectEqual(@as(u8, 3), @intFromEnum(dbconn.ConnError.query_error));
    try expectEqual(@as(u8, 4), @intFromEnum(dbconn.ConnError.transaction_error));
    try expectEqual(@as(u8, 5), @intFromEnum(dbconn.ConnError.timeout));
    try expectEqual(@as(u8, 6), @intFromEnum(dbconn.ConnError.pool_exhausted));
    try expectEqual(@as(u8, 7), @intFromEnum(dbconn.ConnError.protocol_error));
    try expectEqual(@as(u8, 8), @intFromEnum(dbconn.ConnError.tls_required));
}

test "PoolState enum tags match C header" {
    try expectEqual(@as(u8, 0), @intFromEnum(dbconn.PoolState.idle));
    try expectEqual(@as(u8, 1), @intFromEnum(dbconn.PoolState.active));
    try expectEqual(@as(u8, 2), @intFromEnum(dbconn.PoolState.draining));
    try expectEqual(@as(u8, 3), @intFromEnum(dbconn.PoolState.closed));
}
