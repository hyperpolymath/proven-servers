// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig — Integration tests for the proven-sparql FFI.
//
// Tests cover:
//   - ABI version check
//   - Endpoint lifecycle (create, destroy, state queries)
//   - Result format management
//   - Query execution and type tracking
//   - Update execution and type tracking
//   - Error state management
//   - Blocking queries/updates in error state
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const sparql = @import("sparql");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), sparql.sparql_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = sparql.sparql_create(0); // XML
    try expect(slot >= 0);
    sparql.sparql_destroy(slot);
}

test "create with invalid format returns -1" {
    const slot = sparql.sparql_create(99);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    sparql.sparql_destroy(-1);
    sparql.sparql_destroy(999);
}

test "double destroy is safe" {
    const slot = sparql.sparql_create(0);
    sparql.sparql_destroy(slot);
    sparql.sparql_destroy(slot);
}

// ── State Queries on Fresh Endpoint ─────────────────────────────────────

test "fresh endpoint has specified format" {
    const slot = sparql.sparql_create(1); // JSON
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 1), sparql.sparql_get_format(slot));
}

test "fresh endpoint has zero query count" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u32, 0), sparql.sparql_get_query_count(slot));
}

test "fresh endpoint has zero update count" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u32, 0), sparql.sparql_get_update_count(slot));
}

test "fresh endpoint has no last query type (255)" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 255), sparql.sparql_get_last_query_type(slot));
}

test "fresh endpoint has no last update type (255)" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 255), sparql.sparql_get_last_update_type(slot));
}

test "fresh endpoint has no error (255)" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 255), sparql.sparql_get_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_format on invalid slot returns 0" {
    try expectEqual(@as(u8, 0), sparql.sparql_get_format(-1));
}

test "get_query_count on invalid slot returns 0" {
    try expectEqual(@as(u32, 0), sparql.sparql_get_query_count(-1));
}

test "get_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), sparql.sparql_get_error(-1));
}

// ── Result Format Management ────────────────────────────────────────────

test "set format succeeds" {
    const slot = sparql.sparql_create(0); // XML
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 0), sparql.sparql_set_format(slot, 3)); // TSV
    try expectEqual(@as(u8, 3), sparql.sparql_get_format(slot));
}

test "set invalid format fails" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 5), sparql.sparql_set_format(slot, 99)); // InvalidFormat
}

test "set format on invalid slot fails" {
    try expectEqual(@as(u8, 1), sparql.sparql_set_format(-1, 0)); // InvalidSlot
}

// ── Query Execution ─────────────────────────────────────────────────────

test "execute SELECT query succeeds" {
    const slot = sparql.sparql_create(1); // JSON
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 0), sparql.sparql_execute_query(slot, 0)); // Select
    try expectEqual(@as(u32, 1), sparql.sparql_get_query_count(slot));
    try expectEqual(@as(u8, 0), sparql.sparql_get_last_query_type(slot));
}

test "execute CONSTRUCT query succeeds" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 0), sparql.sparql_execute_query(slot, 1)); // Construct
    try expectEqual(@as(u8, 1), sparql.sparql_get_last_query_type(slot));
}

test "execute ASK query succeeds" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 0), sparql.sparql_execute_query(slot, 2)); // Ask
}

test "execute DESCRIBE query succeeds" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 0), sparql.sparql_execute_query(slot, 3)); // Describe
}

test "execute invalid query type fails" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 3), sparql.sparql_execute_query(slot, 99)); // InvalidQueryType
}

test "execute query on invalid slot fails" {
    try expectEqual(@as(u8, 1), sparql.sparql_execute_query(-1, 0)); // InvalidSlot
}

test "multiple queries increment count" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    _ = sparql.sparql_execute_query(slot, 0);
    _ = sparql.sparql_execute_query(slot, 1);
    _ = sparql.sparql_execute_query(slot, 2);
    try expectEqual(@as(u32, 3), sparql.sparql_get_query_count(slot));
}

// ── Update Execution ────────────────────────────────────────────────────

test "execute INSERT update succeeds" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 0), sparql.sparql_execute_update(slot, 0)); // Insert
    try expectEqual(@as(u32, 1), sparql.sparql_get_update_count(slot));
    try expectEqual(@as(u8, 0), sparql.sparql_get_last_update_type(slot));
}

test "execute all update types" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    var i: u8 = 0;
    while (i <= 5) : (i += 1) {
        try expectEqual(@as(u8, 0), sparql.sparql_execute_update(slot, i));
    }
    try expectEqual(@as(u32, 6), sparql.sparql_get_update_count(slot));
    try expectEqual(@as(u8, 5), sparql.sparql_get_last_update_type(slot)); // Drop
}

test "execute invalid update type fails" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 4), sparql.sparql_execute_update(slot, 99)); // InvalidUpdateType
}

// ── Error State Management ──────────────────────────────────────────────

test "set error state" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 0), sparql.sparql_set_error(slot, 1)); // QueryTimeout
    try expectEqual(@as(u8, 1), sparql.sparql_get_error(slot));
}

test "set all valid error types" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    var i: u8 = 0;
    while (i <= 4) : (i += 1) {
        try expectEqual(@as(u8, 0), sparql.sparql_set_error(slot, i));
        try expectEqual(i, sparql.sparql_get_error(slot));
        sparql.sparql_clear_error(slot);
    }
}

test "set invalid error type fails" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    try expectEqual(@as(u8, 6), sparql.sparql_set_error(slot, 99)); // InvalidErrorType
}

test "clear error state" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    _ = sparql.sparql_set_error(slot, 0);
    sparql.sparql_clear_error(slot);
    try expectEqual(@as(u8, 255), sparql.sparql_get_error(slot));
}

// ── Error State Blocking ────────────────────────────────────────────────

test "query blocked in error state" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    _ = sparql.sparql_set_error(slot, 0); // ParseError
    try expectEqual(@as(u8, 7), sparql.sparql_execute_query(slot, 0)); // HasError
}

test "update blocked in error state" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    _ = sparql.sparql_set_error(slot, 4); // AccessDenied
    try expectEqual(@as(u8, 7), sparql.sparql_execute_update(slot, 0)); // HasError
}

test "clear error unblocks queries" {
    const slot = sparql.sparql_create(0);
    defer sparql.sparql_destroy(slot);
    _ = sparql.sparql_set_error(slot, 1);
    sparql.sparql_clear_error(slot);
    try expectEqual(@as(u8, 0), sparql.sparql_execute_query(slot, 0)); // Ok
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full lifecycle: create, query, update, error, recover, destroy" {
    const slot = sparql.sparql_create(1); // JSON format
    defer sparql.sparql_destroy(slot);

    // Execute queries
    try expectEqual(@as(u8, 0), sparql.sparql_execute_query(slot, 0)); // Select
    try expectEqual(@as(u8, 0), sparql.sparql_execute_query(slot, 2)); // Ask
    try expectEqual(@as(u32, 2), sparql.sparql_get_query_count(slot));

    // Execute updates
    try expectEqual(@as(u8, 0), sparql.sparql_execute_update(slot, 0)); // Insert
    try expectEqual(@as(u32, 1), sparql.sparql_get_update_count(slot));

    // Change format
    try expectEqual(@as(u8, 0), sparql.sparql_set_format(slot, 2)); // CSV
    try expectEqual(@as(u8, 2), sparql.sparql_get_format(slot));

    // Error occurs
    _ = sparql.sparql_set_error(slot, 1); // QueryTimeout
    try expectEqual(@as(u8, 7), sparql.sparql_execute_query(slot, 0)); // Blocked

    // Recover
    sparql.sparql_clear_error(slot);
    try expectEqual(@as(u8, 0), sparql.sparql_execute_query(slot, 3)); // Describe
    try expectEqual(@as(u32, 3), sparql.sparql_get_query_count(slot));
}
