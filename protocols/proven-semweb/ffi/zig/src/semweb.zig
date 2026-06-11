// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// semweb.zig -- Zig FFI implementation of proven-semweb.
//
// Implements a semantic web graph store state machine with:
//   - 64-slot mutex-protected graph store pool
//   - Triple storage (subject/predicate/object as name slices)
//   - Content negotiation for RDF serialisation formats
//   - HTTP method validation
//   - Store lifecycle: Idle -> Ready -> Serving -> Disconnecting
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching SemwebABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching SemwebABI.Types.idr tag assignments)
// =========================================================================

/// RDF serialisation formats (ABI tags 0-5).
pub const Format = enum(u8) {
    rdfxml = 0,
    turtle = 1,
    ntriples = 2,
    nquads = 3,
    jsonld = 4,
    trig = 5,
};

/// Semantic web resource types (ABI tags 0-4).
pub const ResourceType = enum(u8) {
    class = 0,
    property = 1,
    individual = 2,
    ontology = 3,
    named_graph = 4,
};

/// HTTP methods (ABI tags 0-4).
pub const HTTPMethod = enum(u8) {
    get = 0,
    post = 1,
    put = 2,
    patch = 3,
    delete = 4,
};

/// Content negotiation types (ABI tags 0-3).
pub const ContentNegotiation = enum(u8) {
    neg_rdfxml = 0,
    neg_turtle = 1,
    neg_jsonld = 2,
    neg_html = 3,
};

/// Error codes (ABI tags 0-4).
pub const ErrorCode = enum(u8) {
    not_found = 0,
    invalid_uri = 1,
    malformed_rdf = 2,
    unsupported_format = 3,
    conflicting_triples = 4,
};

/// Store lifecycle states (ABI tags 0-4).
pub const StoreState = enum(u8) {
    idle = 0,
    ready = 1,
    serving = 2,
    disconnecting = 3,
    destroyed = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent sessions.
const MAX_SESSIONS: usize = 64;

/// Maximum triples per store.
const MAX_TRIPLES: usize = 256;

/// Maximum name length for triple components (subject/predicate/object).
const MAX_NAME_LEN: usize = 256;

/// Maximum base URI length.
const MAX_URI_LEN: usize = 512;

/// A triple (subject, predicate, object).
const Triple = struct {
    subject: [MAX_NAME_LEN]u8,
    subj_len: u32,
    predicate: [MAX_NAME_LEN]u8,
    pred_len: u32,
    object: [MAX_NAME_LEN]u8,
    obj_len: u32,
    active: bool,
};

/// Default (empty) triple.
const empty_triple: Triple = .{
    .subject = [_]u8{0} ** MAX_NAME_LEN,
    .subj_len = 0,
    .predicate = [_]u8{0} ** MAX_NAME_LEN,
    .pred_len = 0,
    .object = [_]u8{0} ** MAX_NAME_LEN,
    .obj_len = 0,
    .active = false,
};

/// A graph store session.
const Session = struct {
    /// Current store lifecycle state.
    state: StoreState,
    /// Base URI of this store.
    base_uri: [MAX_URI_LEN]u8,
    uri_len: u32,
    /// Current serialisation format.
    format: Format,
    /// Triple store.
    triples: [MAX_TRIPLES]Triple,
    /// Triple count.
    triple_count: u32,
    /// Whether this session slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .state = .idle,
    .base_uri = [_]u8{0} ** MAX_URI_LEN,
    .uri_len = 0,
    .format = .turtle,
    .triples = [_]Triple{empty_triple} ** MAX_TRIPLES,
    .triple_count = 0,
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

/// Compare two name slices stored in fixed arrays.
fn nameEql(a: []const u8, b: []const u8) bool {
    return std.mem.eql(u8, a, b);
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

/// Returns the ABI version number.
pub export fn semweb_abi_version() callconv(.c) u32 {
    return 1;
}

/// Create a new graph store. Returns slot index or -1 on failure.
pub export fn semweb_create(base_uri_ptr: [*]const u8, base_uri_len: u32) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (base_uri_len == 0 or base_uri_len > MAX_URI_LEN) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = empty_session;
            @memcpy(s.base_uri[0..base_uri_len], base_uri_ptr[0..base_uri_len]);
            s.uri_len = base_uri_len;
            s.state = .ready;
            s.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a session.
pub export fn semweb_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)] = empty_session;
}

/// Returns the current StoreState tag.
pub export fn semweb_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Add a triple. Returns 0 on success, 1 on rejection.
pub export fn semweb_add_triple(
    slot: c_int,
    subj_ptr: [*]const u8,
    subj_len: u32,
    pred_ptr: [*]const u8,
    pred_len: u32,
    obj_ptr: [*]const u8,
    obj_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .ready and sessions[idx].state != .serving) return 1;
    if (subj_len == 0 or subj_len > MAX_NAME_LEN) return 1;
    if (pred_len == 0 or pred_len > MAX_NAME_LEN) return 1;
    if (obj_len == 0 or obj_len > MAX_NAME_LEN) return 1;

    // Check for duplicate triple
    const subj = subj_ptr[0..subj_len];
    const pred = pred_ptr[0..pred_len];
    const obj = obj_ptr[0..obj_len];
    for (&sessions[idx].triples) |*t| {
        if (t.active and t.subj_len == subj_len and t.pred_len == pred_len and t.obj_len == obj_len and
            nameEql(t.subject[0..t.subj_len], subj) and
            nameEql(t.predicate[0..t.pred_len], pred) and
            nameEql(t.object[0..t.obj_len], obj))
        {
            return 1; // duplicate
        }
    }

    // Find a free slot
    for (&sessions[idx].triples) |*t| {
        if (!t.active) {
            @memcpy(t.subject[0..subj_len], subj);
            t.subj_len = subj_len;
            @memcpy(t.predicate[0..pred_len], pred);
            t.pred_len = pred_len;
            @memcpy(t.object[0..obj_len], obj);
            t.obj_len = obj_len;
            t.active = true;
            sessions[idx].triple_count += 1;
            sessions[idx].state = .serving;
            return 0;
        }
    }
    return 1;
}

/// Remove a triple. Returns 0 on success, 1 on rejection.
pub export fn semweb_remove_triple(
    slot: c_int,
    subj_ptr: [*]const u8,
    subj_len: u32,
    pred_ptr: [*]const u8,
    pred_len: u32,
    obj_ptr: [*]const u8,
    obj_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (subj_len == 0 or subj_len > MAX_NAME_LEN) return 1;
    if (pred_len == 0 or pred_len > MAX_NAME_LEN) return 1;
    if (obj_len == 0 or obj_len > MAX_NAME_LEN) return 1;

    const subj = subj_ptr[0..subj_len];
    const pred = pred_ptr[0..pred_len];
    const obj = obj_ptr[0..obj_len];

    for (&sessions[idx].triples) |*t| {
        if (t.active and t.subj_len == subj_len and t.pred_len == pred_len and t.obj_len == obj_len and
            nameEql(t.subject[0..t.subj_len], subj) and
            nameEql(t.predicate[0..t.pred_len], pred) and
            nameEql(t.object[0..t.obj_len], obj))
        {
            t.active = false;
            t.subj_len = 0;
            t.pred_len = 0;
            t.obj_len = 0;
            sessions[idx].triple_count -= 1;
            if (sessions[idx].triple_count == 0 and sessions[idx].state == .serving) {
                sessions[idx].state = .ready;
            }
            return 0;
        }
    }
    return 1;
}

/// Returns the number of active triples.
pub export fn semweb_triple_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return sessions[idx].triple_count;
}

/// Check if a triple exists. Returns 1 if found, 0 otherwise.
pub export fn semweb_has_triple(
    slot: c_int,
    subj_ptr: [*]const u8,
    subj_len: u32,
    pred_ptr: [*]const u8,
    pred_len: u32,
    obj_ptr: [*]const u8,
    obj_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (subj_len == 0 or subj_len > MAX_NAME_LEN) return 0;
    if (pred_len == 0 or pred_len > MAX_NAME_LEN) return 0;
    if (obj_len == 0 or obj_len > MAX_NAME_LEN) return 0;

    const subj = subj_ptr[0..subj_len];
    const pred = pred_ptr[0..pred_len];
    const obj = obj_ptr[0..obj_len];

    for (&sessions[idx].triples) |*t| {
        if (t.active and t.subj_len == subj_len and t.pred_len == pred_len and t.obj_len == obj_len and
            nameEql(t.subject[0..t.subj_len], subj) and
            nameEql(t.predicate[0..t.pred_len], pred) and
            nameEql(t.object[0..t.obj_len], obj))
        {
            return 1;
        }
    }
    return 0;
}

/// Negotiate format from Accept header. Returns Format tag or 255 for unsupported.
pub export fn semweb_negotiate_format(accept_ptr: [*]const u8, accept_len: u32) callconv(.c) u8 {
    if (accept_len == 0 or accept_len > MAX_URI_LEN) return 255;
    const accept = accept_ptr[0..accept_len];

    // Simple content negotiation by substring matching
    if (std.mem.indexOf(u8, accept, "text/turtle") != null) return 1;
    if (std.mem.indexOf(u8, accept, "application/ld+json") != null) return 4;
    if (std.mem.indexOf(u8, accept, "application/rdf+xml") != null) return 0;
    if (std.mem.indexOf(u8, accept, "application/n-triples") != null) return 2;
    if (std.mem.indexOf(u8, accept, "application/n-quads") != null) return 3;
    if (std.mem.indexOf(u8, accept, "application/trig") != null) return 5;
    if (std.mem.indexOf(u8, accept, "*/*") != null) return 1; // default to Turtle
    return 255;
}

/// Set the serialisation format. Returns 0 on success, 1 on rejection.
pub export fn semweb_set_format(slot: c_int, format: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (format > 5) return 1;
    sessions[idx].format = @enumFromInt(format);
    return 0;
}

/// Get the current serialisation format tag.
pub export fn semweb_get_format(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1; // turtle fallback
    return @intFromEnum(sessions[idx].format);
}

/// Handle an HTTP request. Returns ErrorCode tag or 255 for OK.
pub export fn semweb_handle_request(slot: c_int, method: u8, uri_ptr: [*]const u8, uri_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // NotFound
    if (sessions[idx].state != .ready and sessions[idx].state != .serving) return 0;
    if (method > 4) return 1; // InvalidURI (method out of range)
    if (uri_len == 0 or uri_len > MAX_URI_LEN) return 1; // InvalidURI
    _ = uri_ptr;
    return 255; // OK
}

/// Disconnect. Returns 0 on success, 1 on rejection.
pub export fn semweb_disconnect(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = sessions[idx].state;
    if (state == .idle or state == .disconnecting or state == .destroyed) return 1;
    sessions[idx].state = .disconnecting;
    return 0;
}

/// Cleanup. Transitions Disconnecting -> Destroyed.
pub export fn semweb_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state != .disconnecting) return 1;
    sessions[idx].state = .destroyed;
    sessions[idx].triples = [_]Triple{empty_triple} ** MAX_TRIPLES;
    sessions[idx].triple_count = 0;
    return 0;
}

/// Check if a store state transition is valid.
pub export fn semweb_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Ready
    if (from == 1 and to == 2) return 1; // Ready -> Serving
    if (from == 2 and to == 1) return 1; // Serving -> Ready (all triples removed)
    if (from == 1 and to == 3) return 1; // Ready -> Disconnecting
    if (from == 2 and to == 3) return 1; // Serving -> Disconnecting
    if (from == 3 and to == 4) return 1; // Disconnecting -> Destroyed
    return 0;
}

/// Returns number of active sessions.
pub export fn semweb_active_count() callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    var count: u32 = 0;
    for (&sessions) |*s| {
        if (s.active) count += 1;
    }
    return count;
}
