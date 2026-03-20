// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// appserver.zig -- Zig FFI implementation of proven-appserver.
//
// Implements the application server state machine with:
//   - 64-slot mutex-protected server pool
//   - Handler registration per server (max 64 handlers)
//   - Per-handler request type configuration
//   - Kubernetes-style health check probes (liveness/readiness/startup)
//   - Full lifecycle: Initializing -> Starting -> Running -> Draining -> Stopping -> Stopped
//   - Deploy strategy stored per instance
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching AppserverABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching AppserverABI.Types.idr tag assignments)
// =========================================================================

/// Request types handled by the application server (ABI tags 0-3).
pub const RequestType = enum(u8) {
    http = 0,
    websocket = 1,
    grpc = 2,
    graphql = 3,
};

/// Lifecycle states of the application server (ABI tags 0-5).
pub const LifecycleState = enum(u8) {
    initializing = 0,
    starting = 1,
    running = 2,
    draining = 3,
    stopping = 4,
    stopped = 5,
};

/// Kubernetes-style health check probes (ABI tags 0-2).
pub const HealthCheck = enum(u8) {
    liveness = 0,
    readiness = 1,
    startup = 2,
};

/// Deployment strategies (ABI tags 0-3).
pub const DeployStrategy = enum(u8) {
    rolling_update = 0,
    blue_green = 1,
    canary = 2,
    recreate = 3,
};

/// Error categories (ABI tags 0-4).
pub const ErrorCategory = enum(u8) {
    client_error = 0,
    server_error = 1,
    timeout = 2,
    circuit_open = 3,
    rate_limited = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent servers.
const MAX_SERVERS: usize = 64;

/// Maximum handlers per server.
const MAX_HANDLERS: usize = 64;

/// Maximum path length in bytes.
const MAX_PATH_LEN: usize = 256;

/// A registered request handler.
const Handler = struct {
    /// URI path pattern.
    path: [MAX_PATH_LEN]u8,
    path_len: u32,
    /// Request type this handler accepts.
    req_type: RequestType,
    /// Whether this handler slot is active.
    active: bool,
};

/// Default (empty) handler.
const empty_handler: Handler = .{
    .path = [_]u8{0} ** MAX_PATH_LEN,
    .path_len = 0,
    .req_type = .http,
    .active = false,
};

/// An application server instance.
const Server = struct {
    /// Current lifecycle state.
    state: LifecycleState,
    /// Bound port.
    port: u16,
    /// Deployment strategy.
    strategy: DeployStrategy,
    /// Registered handlers.
    handlers: [MAX_HANDLERS]Handler,
    /// Number of active handlers.
    handler_count: u32,
    /// Total requests handled (monotonic counter).
    requests_handled: u64,
    /// Whether this server slot is in use.
    active: bool,
};

/// Default (empty) server.
const empty_server: Server = .{
    .state = .initializing,
    .port = 0,
    .strategy = .rolling_update,
    .handlers = [_]Handler{empty_handler} ** MAX_HANDLERS,
    .handler_count = 0,
    .requests_handled = 0,
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

/// Find a handler by path within a server.
fn findHandler(idx: usize, path: []const u8) ?usize {
    for (&servers[idx].handlers, 0..) |*h, i| {
        if (h.active and h.path_len == path.len and
            std.mem.eql(u8, h.path[0..h.path_len], path))
        {
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
pub export fn appserver_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new application server. Returns slot index (>=0) or -1 on failure.
/// The server starts in Initializing state.
pub export fn appserver_create(port: u16, strategy: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (port == 0) return -1;
    if (strategy > 3) return -1;

    for (&servers, 0..) |*srv, i| {
        if (!srv.active) {
            srv.* = empty_server;
            srv.port = port;
            srv.strategy = @enumFromInt(strategy);
            srv.state = .initializing;
            srv.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a server, releasing its slot.
pub export fn appserver_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SERVERS) return;
    servers[@intCast(slot)] = empty_server;
}

// -- State queries ------------------------------------------------------------

/// Returns the current LifecycleState tag.
pub export fn appserver_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // initializing fallback
    return @intFromEnum(servers[idx].state);
}

// -- Lifecycle transitions ----------------------------------------------------

/// Start the server. Returns 0 on success, 1 on rejection.
/// Transitions: Initializing -> Starting.
pub export fn appserver_start(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .initializing) return 1;

    servers[idx].state = .starting;
    return 0;
}

/// Mark the server as ready. Returns 0 on success, 1 on rejection.
/// Transitions: Starting -> Running.
pub export fn appserver_ready(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .starting) return 1;

    servers[idx].state = .running;
    return 0;
}

// -- Handler registration -----------------------------------------------------

/// Register a request handler. Returns 0 on success, 1 on rejection.
/// Only allowed in Running state.
pub export fn appserver_register_handler(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    req_type: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .running) return 1;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 1;
    if (req_type > 3) return 1;

    const path = path_ptr[0..path_len];

    // Reject duplicate path
    if (findHandler(idx, path) != null) return 1;

    // Find free handler slot
    for (&servers[idx].handlers) |*h| {
        if (!h.active) {
            @memcpy(h.path[0..path_len], path);
            h.path_len = path_len;
            h.req_type = @enumFromInt(req_type);
            h.active = true;
            servers[idx].handler_count += 1;
            return 0;
        }
    }
    return 1;
}

/// Returns the number of registered handlers.
pub export fn appserver_handler_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return servers[idx].handler_count;
}

// -- Request handling ---------------------------------------------------------

/// Handle an incoming request. Returns 255 on success, or ErrorCategory tag.
pub export fn appserver_handle_request(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    req_type: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(ErrorCategory.server_error);
    if (servers[idx].state != .running) {
        return @intFromEnum(ErrorCategory.server_error);
    }
    if (path_len == 0 or path_len > MAX_PATH_LEN) return @intFromEnum(ErrorCategory.client_error);
    if (req_type > 3) return @intFromEnum(ErrorCategory.client_error);

    const path = path_ptr[0..path_len];
    const hi = findHandler(idx, path) orelse return @intFromEnum(ErrorCategory.client_error);

    // Check request type match
    const handler_type = servers[idx].handlers[hi].req_type;
    const request_type: RequestType = @enumFromInt(req_type);
    if (handler_type != request_type) {
        return @intFromEnum(ErrorCategory.client_error);
    }

    servers[idx].requests_handled += 1;
    return 255; // success sentinel
}

// -- Health checks ------------------------------------------------------------

/// Check health probe. Returns 1 if healthy, 0 if not.
/// Liveness: true if not Stopped. Readiness: true if Running. Startup: true if past Initializing.
pub export fn appserver_health_check(slot: c_int, probe: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (probe > 2) return 0;

    const state = servers[idx].state;
    const check: HealthCheck = @enumFromInt(probe);

    return switch (check) {
        .liveness => if (state != .stopped) 1 else 0,
        .readiness => if (state == .running) 1 else 0,
        .startup => if (state != .initializing) 1 else 0,
    };
}

// -- Shutdown lifecycle -------------------------------------------------------

/// Begin draining. Returns 0 on success, 1 on rejection.
/// Transitions: Running -> Draining.
pub export fn appserver_drain(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .running) return 1;

    servers[idx].state = .draining;
    return 0;
}

/// Stop the server. Returns 0 on success, 1 on rejection.
/// Transitions: Draining -> Stopping.
pub export fn appserver_stop(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .draining) return 1;

    servers[idx].state = .stopping;
    return 0;
}

/// Complete cleanup. Returns 0 on success, 1 on rejection.
/// Transitions: Stopping -> Stopped.
pub export fn appserver_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (servers[idx].state != .stopping) return 1;

    servers[idx].state = .stopped;
    servers[idx].handlers = [_]Handler{empty_handler} ** MAX_HANDLERS;
    servers[idx].handler_count = 0;
    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a server state transition is valid.
pub export fn appserver_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Initializing -> Starting
    if (from == 1 and to == 2) return 1; // Starting -> Running
    if (from == 2 and to == 3) return 1; // Running -> Draining
    if (from == 3 and to == 4) return 1; // Draining -> Stopping
    if (from == 4 and to == 5) return 1; // Stopping -> Stopped
    return 0;
}
