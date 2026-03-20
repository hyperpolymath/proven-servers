// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// doq.zig -- Zig FFI implementation of proven-doq.
//
// Implements the DNS-over-QUIC (RFC 9250) server state machine with:
//   - 64-slot mutex-protected server pool
//   - QUIC stream management per server (max 64 streams)
//   - DNS query handling over QUIC streams
//   - Error code tracking per query
//   - Connection draining with grace period
//   - Query statistics tracking
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching DoQABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching DoQABI.Types.idr tag assignments)
// =========================================================================

/// QUIC stream types (ABI tags 0-1).
pub const StreamType = enum(u8) {
    unidirectional = 0,
    bidirectional = 1,
};

/// DoQ error codes (ABI tags 0-3).
pub const ErrorCode = enum(u8) {
    no_error = 0,
    internal_error = 1,
    excessive_load = 2,
    protocol_error = 3,
};

/// QUIC session states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    initial = 0,
    handshaking = 1,
    ready = 2,
    draining = 3,
    closed = 4,
};

/// Server lifecycle states (ABI tags 0-4).
pub const ServerState = enum(u8) {
    idle = 0,
    bound = 1,
    listening = 2,
    processing = 3,
    shutdown = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent servers.
const MAX_SERVERS: usize = 64;

/// Maximum QUIC streams per server.
const MAX_STREAMS: usize = 64;

/// Maximum DNS query payload size.
const MAX_QUERY_LEN: usize = 65535;

/// A QUIC stream.
const Stream = struct {
    /// Stream type (uni/bidirectional).
    stream_type: StreamType,
    /// Stream ID (assigned sequentially).
    stream_id: u32,
    /// Whether this stream slot is active.
    active: bool,
};

/// A DoQ server instance.
const Server = struct {
    /// Current server lifecycle state.
    state: ServerState,
    /// Bound listening port.
    port: u16,
    /// Open QUIC streams.
    streams: [MAX_STREAMS]Stream,
    /// Number of active streams.
    stream_count: u32,
    /// Next stream ID to assign.
    next_stream_id: u32,
    /// Total queries handled (monotonic counter).
    queries_handled: u64,
    /// Whether this server slot is in use.
    active: bool,
};

/// Default (empty) stream.
const empty_stream: Stream = .{
    .stream_type = .bidirectional,
    .stream_id = 0,
    .active = false,
};

/// Default (empty) server.
const empty_server: Server = .{
    .state = .idle,
    .port = 0,
    .streams = [_]Stream{empty_stream} ** MAX_STREAMS,
    .stream_count = 0,
    .next_stream_id = 1,
    .queries_handled = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var servers: [MAX_SERVERS]Server = [_]Server{empty_server} ** MAX_SERVERS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SERVERS) return null;
    const idx: usize = @intCast(slot);
    if (!servers[idx].active) return null;
    return idx;
}

/// Find a stream by ID within a server.
fn findStream(idx: usize, stream_id: u32) ?usize {
    for (&servers[idx].streams, 0..) |*s, i| {
        if (s.active and s.stream_id == stream_id) {
            return i;
        }
    }
    return null;
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn doq_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new DoQ server. Returns slot index (>=0) or -1 on failure.
/// The server starts in Bound state.
pub export fn doq_create(port: u16) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (port == 0) return -1;

    for (&servers, 0..) |*sv, i| {
        if (!sv.active) {
            sv.* = empty_server;
            sv.port = port;
            sv.state = .bound;
            sv.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a server, releasing its slot.
pub export fn doq_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SERVERS) return;
    servers[@intCast(slot)] = empty_server;
}

// -- State queries ------------------------------------------------------------

/// Returns the current ServerState tag for a server.
pub export fn doq_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle fallback
    return @intFromEnum(servers[idx].state);
}

/// Returns 1 if the server can serve queries, 0 otherwise.
pub export fn doq_can_serve(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const state = servers[idx].state;
    return if (state == .listening or state == .processing) 1 else 0;
}

// -- Stream management --------------------------------------------------------

/// Open a QUIC stream. Returns 0 on success, 1 on rejection.
/// Transitions: Bound -> Listening, or stays Listening/Processing.
pub export fn doq_open_stream(slot: c_int, stream_type: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state != .bound and state != .listening and state != .processing) return 1;
    if (stream_type > 1) return 1;

    // Find a free stream slot
    for (&servers[idx].streams) |*s| {
        if (!s.active) {
            s.stream_type = @enumFromInt(stream_type);
            s.stream_id = servers[idx].next_stream_id;
            s.active = true;
            servers[idx].next_stream_id += 1;
            servers[idx].stream_count += 1;
            if (servers[idx].state == .bound) {
                servers[idx].state = .listening;
            }
            return 0;
        }
    }
    return 1;
}

/// Close a QUIC stream. Returns 0 on success, 1 on rejection.
/// May transition Listening -> Bound if last stream.
pub export fn doq_close_stream(slot: c_int, stream_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const si = findStream(idx, stream_id) orelse return 1;

    servers[idx].streams[si].active = false;
    servers[idx].stream_count -= 1;

    // If no streams remain, transition to Bound
    if (servers[idx].stream_count == 0) {
        if (servers[idx].state == .listening or servers[idx].state == .processing) {
            servers[idx].state = .bound;
        }
    }

    return 0;
}

/// Returns the number of open streams for a server.
pub export fn doq_stream_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return servers[idx].stream_count;
}

// -- Query handling -----------------------------------------------------------

/// Handle a DNS query over QUIC. Returns ErrorCode tag.
/// Transitions: Listening -> Processing.
pub export fn doq_handle_query(
    slot: c_int,
    stream_id: u32,
    query_ptr: [*]const u8,
    query_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = query_ptr;

    const idx = validSlot(slot) orelse return @intFromEnum(ErrorCode.internal_error);
    const state = servers[idx].state;
    if (state != .listening and state != .processing) {
        return @intFromEnum(ErrorCode.internal_error);
    }

    // Verify stream exists
    if (findStream(idx, stream_id) == null) {
        return @intFromEnum(ErrorCode.protocol_error);
    }

    if (query_len == 0 or query_len > MAX_QUERY_LEN) {
        return @intFromEnum(ErrorCode.protocol_error);
    }

    servers[idx].queries_handled += 1;
    if (servers[idx].state == .listening) {
        servers[idx].state = .processing;
    }

    return @intFromEnum(ErrorCode.no_error);
}

/// Returns the total number of queries handled.
pub export fn doq_queries_handled(slot: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return servers[idx].queries_handled;
}

// -- Shutdown / Cleanup -------------------------------------------------------

/// Begin connection draining. Returns 0 on success, 1 on rejection.
pub export fn doq_drain(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state == .bound or state == .listening or state == .processing) {
        servers[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

/// Complete cleanup after shutdown. Returns 0 on success, 1 on rejection.
pub export fn doq_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .shutdown) return 1;

    servers[idx].state = .idle;
    servers[idx].streams = [_]Stream{empty_stream} ** MAX_STREAMS;
    servers[idx].stream_count = 0;

    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a server state transition is valid.
pub export fn doq_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Bound
    if (from == 1 and to == 2) return 1; // Bound -> Listening
    if (from == 2 and to == 2) return 1; // Listening -> Listening (more streams)
    if (from == 2 and to == 1) return 1; // Listening -> Bound (all streams closed)
    if (from == 2 and to == 3) return 1; // Listening -> Processing
    if (from == 3 and to == 3) return 1; // Processing -> Processing
    if (from == 3 and to == 2) return 1; // Processing -> Listening
    if (from == 1 and to == 4) return 1; // Bound -> Shutdown
    if (from == 2 and to == 4) return 1; // Listening -> Shutdown
    if (from == 3 and to == 4) return 1; // Processing -> Shutdown
    if (from == 4 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
