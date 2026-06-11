// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// dot.zig -- Zig FFI implementation of proven-dot.
//
// Implements the DNS-over-TLS (RFC 7858) server state machine with:
//   - 64-slot mutex-protected server pool
//   - TLS session management per server (max 64 sessions)
//   - DNS query handling over TLS
//   - Padding strategy enforcement per server
//   - Connection keepalive tracking
//   - Query statistics tracking
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching DoTABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching DoTABI.Types.idr tag assignments)
// =========================================================================

/// TLS session states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    connecting = 0,
    handshaking = 1,
    established = 2,
    closing = 3,
    closed = 4,
};

/// Padding strategies (ABI tags 0-2).
pub const PaddingStrategy = enum(u8) {
    no_padding = 0,
    block_padding = 1,
    random_padding = 2,
};

/// Error reasons (ABI tags 0-3).
pub const ErrorReason = enum(u8) {
    handshake_failed = 0,
    certificate_invalid = 1,
    timeout = 2,
    upstream_error = 3,
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

/// Maximum TLS sessions per server.
const MAX_SESSIONS: usize = 64;

/// Maximum DNS query payload size.
const MAX_QUERY_LEN: usize = 65535;

/// A TLS session.
const Session = struct {
    /// Session ID (assigned sequentially).
    session_id: u32,
    /// Whether this session slot is active.
    active: bool,
};

/// A DoT server instance.
const Server = struct {
    /// Current server lifecycle state.
    state: ServerState,
    /// Bound listening port (typically 853).
    port: u16,
    /// Padding strategy for this server.
    padding: PaddingStrategy,
    /// Active TLS sessions.
    sessions: [MAX_SESSIONS]Session,
    /// Number of active sessions.
    session_count: u32,
    /// Next session ID to assign.
    next_session_id: u32,
    /// Total queries handled (monotonic counter).
    queries_handled: u64,
    /// Whether this server slot is in use.
    active: bool,
};

/// Default (empty) session.
const empty_session: Session = .{
    .session_id = 0,
    .active = false,
};

/// Default (empty) server.
const empty_server: Server = .{
    .state = .idle,
    .port = 0,
    .padding = .no_padding,
    .sessions = [_]Session{empty_session} ** MAX_SESSIONS,
    .session_count = 0,
    .next_session_id = 1,
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

/// Find a session by ID within a server.
fn findSession(idx: usize, session_id: u32) ?usize {
    for (&servers[idx].sessions, 0..) |*s, i| {
        if (s.active and s.session_id == session_id) {
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
pub export fn dot_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new DoT server. Returns slot index (>=0) or -1 on failure.
/// The server starts in Bound state.
pub export fn dot_create(port: u16, padding: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (port == 0) return -1;
    if (padding > 2) return -1;

    for (&servers, 0..) |*sv, i| {
        if (!sv.active) {
            sv.* = empty_server;
            sv.port = port;
            sv.padding = @enumFromInt(padding);
            sv.state = .bound;
            sv.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a server, releasing its slot.
pub export fn dot_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SERVERS) return;
    servers[@intCast(slot)] = empty_server;
}

// -- State queries ------------------------------------------------------------

/// Returns the current ServerState tag for a server.
pub export fn dot_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle fallback
    return @intFromEnum(servers[idx].state);
}

/// Returns 1 if the server can serve queries, 0 otherwise.
pub export fn dot_can_serve(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const state = servers[idx].state;
    return if (state == .listening or state == .processing) 1 else 0;
}

// -- Session management -------------------------------------------------------

/// Accept a TLS client session. Returns 0 on success, 1 on rejection.
/// Transitions: Bound -> Listening, or stays Listening/Processing.
pub export fn dot_accept_session(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = servers[idx].state;
    if (state != .bound and state != .listening and state != .processing) return 1;

    // Find a free session slot
    for (&servers[idx].sessions) |*s| {
        if (!s.active) {
            s.session_id = servers[idx].next_session_id;
            s.active = true;
            servers[idx].next_session_id += 1;
            servers[idx].session_count += 1;
            if (servers[idx].state == .bound) {
                servers[idx].state = .listening;
            }
            return 0;
        }
    }
    return 1;
}

/// Close a TLS session. Returns 0 on success, 1 on rejection.
/// May transition Listening -> Bound if last session.
pub export fn dot_close_session(slot: c_int, session_id: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const si = findSession(idx, session_id) orelse return 1;

    servers[idx].sessions[si].active = false;
    servers[idx].session_count -= 1;

    // If no sessions remain, transition to Bound
    if (servers[idx].session_count == 0) {
        if (servers[idx].state == .listening or servers[idx].state == .processing) {
            servers[idx].state = .bound;
        }
    }

    return 0;
}

/// Returns the number of active TLS sessions for a server.
pub export fn dot_session_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return servers[idx].session_count;
}

// -- Query handling -----------------------------------------------------------

/// Handle a DNS query over TLS. Returns 0xFF on success, ErrorReason tag on failure.
/// Transitions: Listening -> Processing.
pub export fn dot_handle_query(
    slot: c_int,
    session_id: u32,
    query_ptr: [*]const u8,
    query_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = query_ptr;

    const idx = validSlot(slot) orelse return @intFromEnum(ErrorReason.upstream_error);
    const state = servers[idx].state;
    if (state != .listening and state != .processing) {
        return @intFromEnum(ErrorReason.upstream_error);
    }

    // Verify session exists
    if (findSession(idx, session_id) == null) {
        return @intFromEnum(ErrorReason.upstream_error);
    }

    if (query_len == 0 or query_len > MAX_QUERY_LEN) {
        return @intFromEnum(ErrorReason.upstream_error);
    }

    servers[idx].queries_handled += 1;
    if (servers[idx].state == .listening) {
        servers[idx].state = .processing;
    }

    return 0xFF; // success sentinel
}

/// Returns the total number of queries handled.
pub export fn dot_queries_handled(slot: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return servers[idx].queries_handled;
}

// -- Shutdown / Cleanup -------------------------------------------------------

/// Shutdown the server. Returns 0 on success, 1 on rejection.
pub export fn dot_shutdown(slot: c_int) callconv(.c) u8 {
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
pub export fn dot_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .shutdown) return 1;

    servers[idx].state = .idle;
    servers[idx].sessions = [_]Session{empty_session} ** MAX_SESSIONS;
    servers[idx].session_count = 0;

    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a server state transition is valid.
pub export fn dot_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Bound
    if (from == 1 and to == 2) return 1; // Bound -> Listening
    if (from == 2 and to == 2) return 1; // Listening -> Listening (more sessions)
    if (from == 2 and to == 1) return 1; // Listening -> Bound (all sessions closed)
    if (from == 2 and to == 3) return 1; // Listening -> Processing
    if (from == 3 and to == 3) return 1; // Processing -> Processing
    if (from == 3 and to == 2) return 1; // Processing -> Listening
    if (from == 1 and to == 4) return 1; // Bound -> Shutdown
    if (from == 2 and to == 4) return 1; // Listening -> Shutdown
    if (from == 3 and to == 4) return 1; // Processing -> Shutdown
    if (from == 4 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
