// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// apiserver.zig -- Zig FFI implementation of proven-apiserver.
//
// Implements the API gateway server state machine with:
//   - 64-slot mutex-protected gateway pool
//   - Route registration per gateway (max 128 routes)
//   - Per-route auth scheme, version, and response format
//   - Rate limiting with configurable strategy
//   - Request routing with auth and version validation
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching ApiserverABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching ApiserverABI.Types.idr tag assignments)
// =========================================================================

/// Authentication schemes (ABI tags 0-5).
pub const AuthScheme = enum(u8) {
    api_key = 0,
    bearer = 1,
    basic = 2,
    oauth2 = 3,
    hmac = 4,
    mtls = 5,
};

/// Rate limiting strategies (ABI tags 0-3).
pub const RateLimitStrategy = enum(u8) {
    fixed_window = 0,
    sliding_window = 1,
    token_bucket = 2,
    leaky_bucket = 3,
};

/// API versions (ABI tags 0-4).
pub const APIVersion = enum(u8) {
    v1 = 0,
    v2 = 1,
    v3 = 2,
    latest = 3,
    deprecated = 4,
};

/// Response formats (ABI tags 0-3).
pub const ResponseFormat = enum(u8) {
    json = 0,
    xml = 1,
    protobuf = 2,
    messagepack = 3,
};

/// Gateway error codes (ABI tags 0-5).
pub const GatewayError = enum(u8) {
    unauthorized = 0,
    rate_limited = 1,
    not_found = 2,
    bad_request = 3,
    service_unavailable = 4,
    circuit_open = 5,
};

/// Gateway lifecycle states (ABI tags 0-3).
pub const GatewayState = enum(u8) {
    ready = 0,
    serving = 1,
    draining = 2,
    stopped = 3,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent gateways.
const MAX_GATEWAYS: usize = 64;

/// Maximum routes per gateway.
const MAX_ROUTES: usize = 128;

/// Maximum URI path length in bytes.
const MAX_PATH_LEN: usize = 256;

/// A registered API route.
const Route = struct {
    /// URI path (e.g., "/api/v1/users").
    path: [MAX_PATH_LEN]u8,
    path_len: u32,
    /// API version this route serves.
    version: APIVersion,
    /// Required auth scheme.
    auth: AuthScheme,
    /// Response format for this route.
    format: ResponseFormat,
    /// Whether this route slot is active.
    active: bool,
};

/// Default (empty) route.
const empty_route: Route = .{
    .path = [_]u8{0} ** MAX_PATH_LEN,
    .path_len = 0,
    .version = .v1,
    .auth = .api_key,
    .format = .json,
    .active = false,
};

/// An API gateway instance.
const Gateway = struct {
    /// Current lifecycle state.
    state: GatewayState,
    /// Bound port.
    port: u16,
    /// Registered routes.
    routes: [MAX_ROUTES]Route,
    /// Number of active routes.
    route_count: u32,
    /// Rate limit strategy.
    rate_strategy: RateLimitStrategy,
    /// Maximum requests per window.
    rate_max: u32,
    /// Current request count in window.
    rate_current: u32,
    /// Total requests handled (monotonic counter).
    requests_handled: u64,
    /// Whether this gateway slot is in use.
    active: bool,
};

/// Default (empty) gateway.
const empty_gateway: Gateway = .{
    .state = .ready,
    .port = 0,
    .routes = [_]Route{empty_route} ** MAX_ROUTES,
    .route_count = 0,
    .rate_strategy = .fixed_window,
    .rate_max = 0,
    .rate_current = 0,
    .requests_handled = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var gateways: [MAX_GATEWAYS]Gateway = [_]Gateway{empty_gateway} ** MAX_GATEWAYS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_GATEWAYS) return null;
    const idx: usize = @intCast(slot);
    if (!gateways[idx].active) return null;
    return idx;
}

/// Find a route by path within a gateway.
fn findRoute(idx: usize, path: []const u8) ?usize {
    for (&gateways[idx].routes, 0..) |*r, i| {
        if (r.active and r.path_len == path.len and
            std.mem.eql(u8, r.path[0..r.path_len], path))
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
pub export fn apiserver_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new API gateway. Returns slot index (>=0) or -1 on failure.
/// The gateway starts in Ready state.
pub export fn apiserver_create(port: u16) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (port == 0) return -1;

    for (&gateways, 0..) |*gw, i| {
        if (!gw.active) {
            gw.* = empty_gateway;
            gw.port = port;
            gw.state = .ready;
            gw.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a gateway, releasing its slot.
pub export fn apiserver_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_GATEWAYS) return;
    gateways[@intCast(slot)] = empty_gateway;
}

// -- State queries ------------------------------------------------------------

/// Returns the current GatewayState tag.
pub export fn apiserver_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // ready fallback
    return @intFromEnum(gateways[idx].state);
}

// -- Route management ---------------------------------------------------------

/// Register an API route. Returns 0 on success, 1 on rejection.
/// Transitions: Ready -> Serving (on first route).
pub export fn apiserver_register_route(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    version: u8,
    auth: u8,
    format: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = gateways[idx].state;
    if (state != .ready and state != .serving) return 1;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 1;
    if (version > 4) return 1;
    if (auth > 5) return 1;
    if (format > 3) return 1;

    const path = path_ptr[0..path_len];

    // Reject duplicate path
    if (findRoute(idx, path) != null) return 1;

    // Find free route slot
    for (&gateways[idx].routes) |*r| {
        if (!r.active) {
            @memcpy(r.path[0..path_len], path);
            r.path_len = path_len;
            r.version = @enumFromInt(version);
            r.auth = @enumFromInt(auth);
            r.format = @enumFromInt(format);
            r.active = true;
            gateways[idx].route_count += 1;
            if (gateways[idx].state == .ready) {
                gateways[idx].state = .serving;
            }
            return 0;
        }
    }
    return 1;
}

/// Unregister an API route by path. Returns 0 on success, 1 on rejection.
/// May transition Serving -> Ready if last route.
pub export fn apiserver_unregister_route(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 1;

    const path = path_ptr[0..path_len];
    const ri = findRoute(idx, path) orelse return 1;

    gateways[idx].routes[ri].active = false;
    gateways[idx].route_count -= 1;

    if (gateways[idx].route_count == 0 and gateways[idx].state == .serving) {
        gateways[idx].state = .ready;
    }

    return 0;
}

/// Returns the number of registered routes.
pub export fn apiserver_route_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return gateways[idx].route_count;
}

// -- Request handling ---------------------------------------------------------

/// Handle an incoming API request. Returns 255 on success, or GatewayError tag.
/// Validates path existence, version match, and auth scheme.
pub export fn apiserver_handle_request(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    version: u8,
    auth: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return @intFromEnum(GatewayError.service_unavailable);
    if (gateways[idx].state != .serving) {
        return @intFromEnum(GatewayError.service_unavailable);
    }
    if (path_len == 0 or path_len > MAX_PATH_LEN) return @intFromEnum(GatewayError.bad_request);
    if (version > 4) return @intFromEnum(GatewayError.bad_request);
    if (auth > 5) return @intFromEnum(GatewayError.bad_request);

    const path = path_ptr[0..path_len];
    const ri = findRoute(idx, path) orelse return @intFromEnum(GatewayError.not_found);

    // Check version match (Latest matches any)
    const route_ver = gateways[idx].routes[ri].version;
    const req_ver: APIVersion = @enumFromInt(version);
    if (route_ver != .latest and req_ver != .latest and route_ver != req_ver) {
        return @intFromEnum(GatewayError.not_found);
    }

    // Check auth scheme match
    const route_auth = gateways[idx].routes[ri].auth;
    const req_auth: AuthScheme = @enumFromInt(auth);
    if (route_auth != req_auth) {
        return @intFromEnum(GatewayError.unauthorized);
    }

    // Check rate limit
    if (gateways[idx].rate_max > 0 and gateways[idx].rate_current >= gateways[idx].rate_max) {
        return @intFromEnum(GatewayError.rate_limited);
    }

    gateways[idx].rate_current += 1;
    gateways[idx].requests_handled += 1;
    return 255; // success sentinel
}

// -- Rate limiting ------------------------------------------------------------

/// Set rate limiting strategy and maximum requests. Returns 0 on success.
pub export fn apiserver_set_rate_limit(slot: c_int, strategy: u8, max_requests: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (strategy > 3) return 1;

    gateways[idx].rate_strategy = @enumFromInt(strategy);
    gateways[idx].rate_max = max_requests;
    gateways[idx].rate_current = 0;
    return 0;
}

/// Check if a request is within rate limit. Returns 1 if allowed, 0 if denied.
pub export fn apiserver_check_rate_limit(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (gateways[idx].rate_max == 0) return 1; // no limit set
    return if (gateways[idx].rate_current < gateways[idx].rate_max) 1 else 0;
}

/// Returns total requests handled (monotonic counter).
pub export fn apiserver_request_count(slot: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return gateways[idx].requests_handled;
}

// -- Shutdown / Cleanup -------------------------------------------------------

/// Shutdown the gateway. Returns 0 on success, 1 on rejection.
/// Transitions: Serving/Ready -> Draining.
pub export fn apiserver_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = gateways[idx].state;
    if (state == .ready or state == .serving) {
        gateways[idx].state = .draining;
        return 0;
    }
    return 1;
}

/// Complete cleanup after shutdown. Returns 0 on success, 1 on rejection.
/// Transitions: Draining -> Stopped.
pub export fn apiserver_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (gateways[idx].state != .draining) return 1;

    gateways[idx].state = .stopped;
    gateways[idx].routes = [_]Route{empty_route} ** MAX_ROUTES;
    gateways[idx].route_count = 0;
    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a gateway state transition is valid.
pub export fn apiserver_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Ready -> Serving
    if (from == 1 and to == 0) return 1; // Serving -> Ready (last route removed)
    if (from == 1 and to == 1) return 1; // Serving -> Serving (add more routes)
    if (from == 0 and to == 2) return 1; // Ready -> Draining
    if (from == 1 and to == 2) return 1; // Serving -> Draining
    if (from == 2 and to == 3) return 1; // Draining -> Stopped
    return 0;
}
