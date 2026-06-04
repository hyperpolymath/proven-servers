// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// sparql.zig — Zig FFI implementation of proven-sparql.
//
// Implements the SPARQL 1.1 endpoint primitive with:
//   - Slot-based endpoint management (up to 64 concurrent endpoints)
//   - Query execution with type tracking (SELECT/CONSTRUCT/ASK/DESCRIBE)
//   - Update operation tracking (INSERT/DELETE/LOAD/CLEAR/CREATE/DROP)
//   - Result format management (XML/JSON/CSV/TSV)
//   - Error state tracking
//   - Query and update counters
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/abi/Types.idr)
//   - C header   (generated/abi/sparql.h)

const std = @import("std");

// ── Enums (matching Idris2 SparqlABI.Types tag assignments exactly) ─────

/// QueryType — matches queryTypeToTag
pub const QueryType = enum(u8) {
    select = 0,
    construct = 1,
    ask = 2,
    describe = 3,
};

/// UpdateType — matches updateTypeToTag
pub const UpdateType = enum(u8) {
    insert = 0,
    delete = 1,
    load = 2,
    clear = 3,
    create = 4,
    drop = 5,
};

/// ResultFormat — matches resultFormatToTag
pub const ResultFormat = enum(u8) {
    xml = 0,
    json = 1,
    csv = 2,
    tsv = 3,
};

/// ErrorType — matches errorTypeToTag
pub const ErrorType = enum(u8) {
    parse_error = 0,
    query_timeout = 1,
    results_too_large = 2,
    unknown_graph = 3,
    access_denied = 4,
};

/// SparqlError — error codes for FFI operations
pub const SparqlError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_query_type = 3,
    invalid_update_type = 4,
    invalid_format = 5,
    invalid_error_type = 6,
    has_error = 7,
};

// ── Endpoint Context ────────────────────────────────────────────────────

const EndpointCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Default result format.
    result_format: ResultFormat,
    /// Number of queries executed.
    query_count: u32,
    /// Number of updates executed.
    update_count: u32,
    /// Last query type (255 = none).
    last_query_type: u8,
    /// Last update type (255 = none).
    last_update_type: u8,
    /// Last error type (255 = no error).
    last_error: u8,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: EndpointCtx = .{
    .active = false,
    .result_format = .xml,
    .query_count = 0,
    .update_count = 0,
    .last_query_type = 255,
    .last_update_type = 255,
    .last_error = 255,
};

var contexts: [MAX_CONTEXTS]EndpointCtx = [_]EndpointCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*EndpointCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match SparqlABI.Foreign.abiVersion (currently 1).
pub export fn sparql_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new SPARQL endpoint context.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn sparql_create(format: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate format (0-3)
    if (format > 3) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.result_format = @enumFromInt(format);
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy an endpoint context, freeing its slot.
pub export fn sparql_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the default ResultFormat tag for a slot.
/// Returns XML (0) for invalid/inactive slots.
pub export fn sparql_get_format(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.result_format);
}

/// Get the number of queries executed.
pub export fn sparql_get_query_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.query_count;
}

/// Get the number of updates executed.
pub export fn sparql_get_update_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.update_count;
}

/// Get the last query type tag (255 = none).
pub export fn sparql_get_last_query_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_query_type;
}

/// Get the last update type tag (255 = none).
pub export fn sparql_get_last_update_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_update_type;
}

/// Get the last error type tag (255 = no error).
pub export fn sparql_get_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── Operations ──────────────────────────────────────────────────────────

/// Set the default result format.
/// Returns SparqlError tag.
pub export fn sparql_set_format(slot: c_int, fmt: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SparqlError.invalid_slot);

    if (fmt > 3) {
        return @intFromEnum(SparqlError.invalid_format);
    }

    ctx.result_format = @enumFromInt(fmt);
    return @intFromEnum(SparqlError.ok);
}

/// Execute a query of the given type.
/// Fails if the endpoint is in an error state.
/// Returns SparqlError tag.
pub export fn sparql_execute_query(slot: c_int, qtype: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SparqlError.invalid_slot);

    // Fail if in error state
    if (ctx.last_error != 255) {
        return @intFromEnum(SparqlError.has_error);
    }

    // Validate query type (0-3)
    if (qtype > 3) {
        return @intFromEnum(SparqlError.invalid_query_type);
    }

    ctx.last_query_type = qtype;
    ctx.query_count += 1;
    return @intFromEnum(SparqlError.ok);
}

/// Execute an update of the given type.
/// Fails if the endpoint is in an error state.
/// Returns SparqlError tag.
pub export fn sparql_execute_update(slot: c_int, utype: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SparqlError.invalid_slot);

    // Fail if in error state
    if (ctx.last_error != 255) {
        return @intFromEnum(SparqlError.has_error);
    }

    // Validate update type (0-5)
    if (utype > 5) {
        return @intFromEnum(SparqlError.invalid_update_type);
    }

    ctx.last_update_type = utype;
    ctx.update_count += 1;
    return @intFromEnum(SparqlError.ok);
}

/// Set the error state.
/// Returns SparqlError tag.
pub export fn sparql_set_error(slot: c_int, err: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(SparqlError.invalid_slot);

    if (err > 4) {
        return @intFromEnum(SparqlError.invalid_error_type);
    }

    ctx.last_error = err;
    return @intFromEnum(SparqlError.ok);
}

/// Clear the error state.
pub export fn sparql_clear_error(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return;
    ctx.last_error = 255;
}
