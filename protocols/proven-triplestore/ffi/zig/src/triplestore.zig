// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// triplestore.zig -- Zig FFI implementation of proven-triplestore.
//
// Implements the RDF triple store state machine with:
//   - 64-slot mutex-protected store session pool
//   - Triple/quad insertion and deletion
//   - Pattern-based triple lookup (exact match)
//   - Transaction begin/commit/rollback
//   - Bulk import lifecycle
//   - Store state machine (Idle -> Ready -> Transaction/Importing -> Closing)
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching TriplestoreABI.Types exactly.

const std = @import("std");

// =========================================================================
// Enums (matching TriplestoreABI.Types tag assignments)
// =========================================================================

/// RDF statement types (ABI tags 0-1).
pub const StatementType = enum(u8) {
    triple = 0,
    quad = 1,
};

/// Index orderings (ABI tags 0-5).
pub const IndexOrder = enum(u8) {
    spo = 0,
    pos = 1,
    osp = 2,
    gspo = 3,
    gpos = 4,
    gosp = 5,
};

/// Storage backends (ABI tags 0-3).
pub const StorageBackend = enum(u8) {
    in_memory = 0,
    btree = 1,
    lsm = 2,
    persistent = 3,
};

/// Import formats (ABI tags 0-5).
pub const ImportFormat = enum(u8) {
    n_triples = 0,
    turtle = 1,
    rdf_xml = 2,
    json_ld = 3,
    n_quads = 4,
    trig = 5,
};

/// Transaction isolation levels (ABI tags 0-2).
pub const TransactionIsolation = enum(u8) {
    read_committed = 0,
    serializable = 1,
    snapshot = 2,
};

/// Store lifecycle states (ABI tags 0-4).
pub const StoreState = enum(u8) {
    idle = 0,
    ready = 1,
    transaction = 2,
    importing = 3,
    closing = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 8;

/// Maximum triples per store session.
const MAX_TRIPLES: usize = 256;

/// Maximum URI/literal length.
const MAX_TERM_LEN: usize = 512;

/// An RDF triple (subject, predicate, object).
const Triple = struct {
    subject: [MAX_TERM_LEN]u8,
    subject_len: u32,
    predicate: [MAX_TERM_LEN]u8,
    predicate_len: u32,
    object: [MAX_TERM_LEN]u8,
    object_len: u32,
    /// Optional graph for quads (len=0 means default graph / triple).
    graph: [MAX_TERM_LEN]u8,
    graph_len: u32,
    /// Whether this slot is in use.
    active: bool,
};

/// Default (empty) triple.
const empty_triple: Triple = .{
    .subject = [_]u8{0} ** MAX_TERM_LEN,
    .subject_len = 0,
    .predicate = [_]u8{0} ** MAX_TERM_LEN,
    .predicate_len = 0,
    .object = [_]u8{0} ** MAX_TERM_LEN,
    .object_len = 0,
    .graph = [_]u8{0} ** MAX_TERM_LEN,
    .graph_len = 0,
    .active = false,
};

/// A triple store session.
const Session = struct {
    /// Current store lifecycle state.
    state: StoreState,
    /// Storage backend.
    backend: StorageBackend,
    /// Transaction isolation level.
    isolation: TransactionIsolation,
    /// Current import format (valid only during import).
    import_format: ImportFormat,
    /// Triple storage.
    triples: [MAX_TRIPLES]Triple,
    /// Number of active triples.
    triple_count: u32,
    /// Number of triples at transaction start (for rollback).
    txn_snapshot_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .backend = .in_memory,
    .isolation = .read_committed,
    .import_format = .n_triples,
    .triples = [_]Triple{empty_triple} ** MAX_TRIPLES,
    .triple_count = 0,
    .txn_snapshot_count = 0,
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

/// Check if two byte slices are equal.
fn bytesEqual(a: []const u8, b: []const u8) bool {
    if (a.len != b.len) return false;
    return std.mem.eql(u8, a, b);
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn triplestore_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new store session. Returns slot index (>=0) or -1 on failure.
pub export fn triplestore_create(backend: u8, isolation: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (backend > 3) return -1;
    if (isolation > 2) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            s.backend = @enumFromInt(backend);
            s.isolation = @enumFromInt(isolation);
            s.state = .ready;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session, releasing its slot.
pub export fn triplestore_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current StoreState tag for a session.
pub export fn triplestore_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Add an RDF triple. Returns 0 on success, 1 on rejection.
pub export fn triplestore_add_triple(
    slot: c_int,
    s_ptr: [*]const u8,
    s_len: u32,
    p_ptr: [*]const u8,
    p_len: u32,
    o_ptr: [*]const u8,
    o_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .ready and state != .transaction and state != .importing) return 1;
    if (s_len == 0 or s_len > MAX_TERM_LEN) return 1;
    if (p_len == 0 or p_len > MAX_TERM_LEN) return 1;
    if (o_len == 0 or o_len > MAX_TERM_LEN) return 1;

    // Find a free triple slot
    for (&sessions[idx].triples) |*t| {
        if (!t.active) {
            @memcpy(t.subject[0..s_len], s_ptr[0..s_len]);
            t.subject_len = s_len;
            @memcpy(t.predicate[0..p_len], p_ptr[0..p_len]);
            t.predicate_len = p_len;
            @memcpy(t.object[0..o_len], o_ptr[0..o_len]);
            t.object_len = o_len;
            t.graph_len = 0;
            t.active = true;
            sessions[idx].triple_count += 1;
            return 0;
        }
    }
    return 1; // No free slots
}

/// Add an RDF quad. Returns 0 on success, 1 on rejection.
pub export fn triplestore_add_quad(
    slot: c_int,
    g_ptr: [*]const u8,
    g_len: u32,
    s_ptr: [*]const u8,
    s_len: u32,
    p_ptr: [*]const u8,
    p_len: u32,
    o_ptr: [*]const u8,
    o_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .ready and state != .transaction and state != .importing) return 1;
    if (g_len == 0 or g_len > MAX_TERM_LEN) return 1;
    if (s_len == 0 or s_len > MAX_TERM_LEN) return 1;
    if (p_len == 0 or p_len > MAX_TERM_LEN) return 1;
    if (o_len == 0 or o_len > MAX_TERM_LEN) return 1;

    for (&sessions[idx].triples) |*t| {
        if (!t.active) {
            @memcpy(t.graph[0..g_len], g_ptr[0..g_len]);
            t.graph_len = g_len;
            @memcpy(t.subject[0..s_len], s_ptr[0..s_len]);
            t.subject_len = s_len;
            @memcpy(t.predicate[0..p_len], p_ptr[0..p_len]);
            t.predicate_len = p_len;
            @memcpy(t.object[0..o_len], o_ptr[0..o_len]);
            t.object_len = o_len;
            t.active = true;
            sessions[idx].triple_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Remove a triple by exact match. Returns 0 on success, 1 on not found.
pub export fn triplestore_remove(
    slot: c_int,
    s_ptr: [*]const u8,
    s_len: u32,
    p_ptr: [*]const u8,
    p_len: u32,
    o_ptr: [*]const u8,
    o_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state != .ready and state != .transaction) return 1;

    const s = s_ptr[0..s_len];
    const p = p_ptr[0..p_len];
    const o = o_ptr[0..o_len];

    for (&sessions[idx].triples) |*t| {
        if (t.active and
            t.subject_len == s_len and bytesEqual(t.subject[0..t.subject_len], s) and
            t.predicate_len == p_len and bytesEqual(t.predicate[0..t.predicate_len], p) and
            t.object_len == o_len and bytesEqual(t.object[0..t.object_len], o))
        {
            t.active = false;
            sessions[idx].triple_count -= 1;
            return 0;
        }
    }
    return 1;
}

/// Returns total triple count.
pub export fn triplestore_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].triple_count;
}

/// Check if a triple exists (exact match). Returns 1 if exists, 0 if not.
pub export fn triplestore_has(
    slot: c_int,
    s_ptr: [*]const u8,
    s_len: u32,
    p_ptr: [*]const u8,
    p_len: u32,
    o_ptr: [*]const u8,
    o_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;

    const s = s_ptr[0..s_len];
    const p = p_ptr[0..p_len];
    const o = o_ptr[0..o_len];

    for (&sessions[idx].triples) |*t| {
        if (t.active and
            t.subject_len == s_len and bytesEqual(t.subject[0..t.subject_len], s) and
            t.predicate_len == p_len and bytesEqual(t.predicate[0..t.predicate_len], p) and
            t.object_len == o_len and bytesEqual(t.object[0..t.object_len], o))
        {
            return 1;
        }
    }
    return 0;
}

/// Begin a transaction. Returns 0 on success, 1 on rejection.
/// Transitions Ready -> Transaction.
pub export fn triplestore_txn_begin(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready) return 1;

    sessions[idx].txn_snapshot_count = sessions[idx].triple_count;
    sessions[idx].state = .transaction;
    return 0;
}

/// Commit a transaction. Returns 0 on success, 1 on rejection.
/// Transitions Transaction -> Ready.
pub export fn triplestore_txn_commit(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .transaction) return 1;

    sessions[idx].state = .ready;
    return 0;
}

/// Rollback a transaction. Returns 0 on success, 1 on rejection.
/// Transitions Transaction -> Ready, reverting triple count.
pub export fn triplestore_txn_rollback(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .transaction) return 1;

    // Simplified rollback: deactivate triples added during transaction
    var count: u32 = 0;
    for (&sessions[idx].triples) |*t| {
        if (t.active) {
            if (count >= sessions[idx].txn_snapshot_count) {
                t.active = false;
            } else {
                count += 1;
            }
        }
    }
    sessions[idx].triple_count = sessions[idx].txn_snapshot_count;
    sessions[idx].state = .ready;
    return 0;
}

/// Begin a bulk import. Returns 0 on success, 1 on rejection.
/// Transitions Ready -> Importing.
pub export fn triplestore_import_begin(slot: c_int, format: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready) return 1;
    if (format > 5) return 1;

    sessions[idx].import_format = @enumFromInt(format);
    sessions[idx].state = .importing;
    return 0;
}

/// End a bulk import. Returns 0 on success, 1 on rejection.
/// Transitions Importing -> Ready.
pub export fn triplestore_import_end(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .importing) return 1;

    sessions[idx].state = .ready;
    return 0;
}

/// Disconnect the store. Returns 0 on success, 1 on rejection.
pub export fn triplestore_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .ready) {
        sessions[idx].state = .closing;
        return 0;
    }
    return 1;
}

/// Complete cleanup after disconnect. Returns 0 on success, 1 on rejection.
pub export fn triplestore_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .closing) return 1;

    sessions[idx].state = .idle;
    sessions[idx].triples = [_]Triple{empty_triple} ** MAX_TRIPLES;
    sessions[idx].triple_count = 0;
    return 0;
}

/// Check if a store state transition is valid.
pub export fn triplestore_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Ready
    if (from == 1 and to == 2) return 1; // Ready -> Transaction
    if (from == 2 and to == 1) return 1; // Transaction -> Ready (commit/rollback)
    if (from == 1 and to == 3) return 1; // Ready -> Importing
    if (from == 3 and to == 1) return 1; // Importing -> Ready
    if (from == 1 and to == 4) return 1; // Ready -> Closing
    if (from == 4 and to == 0) return 1; // Closing -> Idle
    return 0;
}

/// Returns number of active sessions.
pub export fn triplestore_session_count() callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    var count: u32 = 0;
    for (&sessions) |*s| {
        if (s.active) count += 1;
    }
    return count;
}
