// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-triplestore FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Triple insertion and count
//   - Quad insertion
//   - Triple removal
//   - Triple existence check (has)
//   - Transaction begin/commit/rollback
//   - Bulk import begin/end
//   - Disconnect / cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Session count tracking

const std = @import("std");
const ts = @import("triplestore");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ts.triplestore_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "StatementType encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ts.StatementType.triple));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ts.StatementType.quad));
}

test "IndexOrder encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ts.IndexOrder.spo));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ts.IndexOrder.pos));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ts.IndexOrder.osp));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ts.IndexOrder.gspo));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ts.IndexOrder.gpos));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ts.IndexOrder.gosp));
}

test "StorageBackend encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ts.StorageBackend.in_memory));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ts.StorageBackend.btree));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ts.StorageBackend.lsm));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ts.StorageBackend.persistent));
}

test "ImportFormat encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ts.ImportFormat.n_triples));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ts.ImportFormat.turtle));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ts.ImportFormat.rdf_xml));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ts.ImportFormat.json_ld));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ts.ImportFormat.n_quads));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ts.ImportFormat.trig));
}

test "TransactionIsolation encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ts.TransactionIsolation.read_committed));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ts.TransactionIsolation.serializable));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ts.TransactionIsolation.snapshot));
}

test "StoreState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ts.StoreState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ts.StoreState.ready));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ts.StoreState.transaction));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ts.StoreState.importing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ts.StoreState.closing));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Ready state" {
    const slot = ts.triplestore_create(0, 0); // in_memory, read_committed
    try std.testing.expect(slot >= 0);
    defer ts.triplestore_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_state(slot)); // Ready
}

test "create rejects invalid backend" {
    try std.testing.expectEqual(@as(c_int, -1), ts.triplestore_create(99, 0));
}

test "create rejects invalid isolation" {
    try std.testing.expectEqual(@as(c_int, -1), ts.triplestore_create(0, 99));
}

test "destroy is safe with invalid slot" {
    ts.triplestore_destroy(-1);
    ts.triplestore_destroy(999);
}

// =========================================================================
// Triple operations
// =========================================================================

test "add_triple inserts and counts" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    const s = "http://example.org/s";
    const p = "http://example.org/p";
    const o = "http://example.org/o";
    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_add_triple(
        slot, s.ptr, s.len, p.ptr, p.len, o.ptr, o.len,
    ));
    try std.testing.expectEqual(@as(u32, 1), ts.triplestore_count(slot));
}

test "add_quad inserts quad with graph" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    const g = "http://example.org/graph";
    const s = "http://example.org/s";
    const p = "http://example.org/p";
    const o = "http://example.org/o";
    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_add_quad(
        slot, g.ptr, g.len, s.ptr, s.len, p.ptr, p.len, o.ptr, o.len,
    ));
    try std.testing.expectEqual(@as(u32, 1), ts.triplestore_count(slot));
}

test "has finds existing triple" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    const s = "http://example.org/alice";
    const p = "http://xmlns.com/foaf/0.1/name";
    const o = "Alice";
    _ = ts.triplestore_add_triple(slot, s.ptr, s.len, p.ptr, p.len, o.ptr, o.len);

    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_has(
        slot, s.ptr, s.len, p.ptr, p.len, o.ptr, o.len,
    ));
}

test "has returns 0 for missing triple" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    const s = "http://example.org/bob";
    const p = "http://xmlns.com/foaf/0.1/name";
    const o = "Bob";
    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_has(
        slot, s.ptr, s.len, p.ptr, p.len, o.ptr, o.len,
    ));
}

test "remove deletes triple" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    const s = "http://example.org/s";
    const p = "http://example.org/p";
    const o = "http://example.org/o";
    _ = ts.triplestore_add_triple(slot, s.ptr, s.len, p.ptr, p.len, o.ptr, o.len);
    try std.testing.expectEqual(@as(u32, 1), ts.triplestore_count(slot));

    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_remove(
        slot, s.ptr, s.len, p.ptr, p.len, o.ptr, o.len,
    ));
    try std.testing.expectEqual(@as(u32, 0), ts.triplestore_count(slot));
}

test "remove returns 1 for missing triple" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    const s = "http://example.org/missing";
    const p = "http://example.org/p";
    const o = "http://example.org/o";
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_remove(
        slot, s.ptr, s.len, p.ptr, p.len, o.ptr, o.len,
    ));
}

// =========================================================================
// Transactions
// =========================================================================

test "txn_begin transitions Ready -> Transaction" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_txn_begin(slot));
    try std.testing.expectEqual(@as(u8, 2), ts.triplestore_state(slot)); // Transaction
}

test "txn_commit transitions Transaction -> Ready" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    _ = ts.triplestore_txn_begin(slot);

    const s = "http://example.org/s";
    const p = "http://example.org/p";
    const o = "http://example.org/o";
    _ = ts.triplestore_add_triple(slot, s.ptr, s.len, p.ptr, p.len, o.ptr, o.len);

    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_txn_commit(slot));
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_state(slot)); // Ready
    try std.testing.expectEqual(@as(u32, 1), ts.triplestore_count(slot)); // triple persists
}

test "txn_rollback reverts triple count" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    // Pre-populate with one triple
    const s1 = "http://example.org/before";
    const p = "http://example.org/p";
    const o = "http://example.org/o";
    _ = ts.triplestore_add_triple(slot, s1.ptr, s1.len, p.ptr, p.len, o.ptr, o.len);
    try std.testing.expectEqual(@as(u32, 1), ts.triplestore_count(slot));

    _ = ts.triplestore_txn_begin(slot);

    const s2 = "http://example.org/during";
    _ = ts.triplestore_add_triple(slot, s2.ptr, s2.len, p.ptr, p.len, o.ptr, o.len);
    try std.testing.expectEqual(@as(u32, 2), ts.triplestore_count(slot));

    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_txn_rollback(slot));
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_state(slot)); // Ready
    try std.testing.expectEqual(@as(u32, 1), ts.triplestore_count(slot)); // reverted
}

test "txn_begin rejected from non-Ready" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    _ = ts.triplestore_txn_begin(slot);
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_txn_begin(slot)); // already in txn
}

// =========================================================================
// Bulk import
// =========================================================================

test "import lifecycle Ready -> Importing -> Ready" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_import_begin(slot, 1)); // turtle
    try std.testing.expectEqual(@as(u8, 3), ts.triplestore_state(slot)); // Importing

    // Can add triples during import
    const s = "http://example.org/s";
    const p = "http://example.org/p";
    const o = "http://example.org/o";
    _ = ts.triplestore_add_triple(slot, s.ptr, s.len, p.ptr, p.len, o.ptr, o.len);

    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_import_end(slot));
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_state(slot)); // Ready
}

test "import_begin rejects invalid format" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_import_begin(slot, 99));
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Ready -> Closing" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 4), ts.triplestore_state(slot)); // Closing
}

test "cleanup transitions Closing -> Idle" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    _ = ts.triplestore_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_state(slot)); // Idle
}

test "disconnect rejected from Transaction" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);

    _ = ts.triplestore_txn_begin(slot);
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_disconnect(slot));
}

test "cleanup rejected from non-Closing" {
    const slot = ts.triplestore_create(0, 0);
    defer ts.triplestore_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_cleanup(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "triplestore_can_transition matches Types.idr" {
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_can_transition(0, 1)); // Idle -> Ready
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_can_transition(1, 2)); // Ready -> Transaction
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_can_transition(2, 1)); // Transaction -> Ready
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_can_transition(1, 3)); // Ready -> Importing
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_can_transition(3, 1)); // Importing -> Ready
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_can_transition(1, 4)); // Ready -> Closing
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_can_transition(4, 0)); // Closing -> Idle

    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_can_transition(0, 2)); // Idle -/-> Transaction
    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_can_transition(2, 4)); // Transaction -/-> Closing
    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_can_transition(3, 4)); // Importing -/-> Closing
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), ts.triplestore_state(-1));
    try std.testing.expectEqual(@as(u32, 0), ts.triplestore_count(-1));
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), ts.triplestore_cleanup(-1));
}

// =========================================================================
// Session count
// =========================================================================

test "session_count tracks active sessions" {
    const initial = ts.triplestore_session_count();
    const slot = ts.triplestore_create(0, 0);
    try std.testing.expectEqual(initial + 1, ts.triplestore_session_count());
    ts.triplestore_destroy(slot);
    try std.testing.expectEqual(initial, ts.triplestore_session_count());
}
