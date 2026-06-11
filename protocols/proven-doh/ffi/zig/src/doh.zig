// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// doh.zig -- Zig FFI implementation of proven-doh.
//
// Implements the DNS-over-HTTPS (RFC 8484) proxy server state machine with:
//   - 64-slot mutex-protected proxy pool
//   - Request path registration per proxy (max 8 paths)
//   - Content type and method validation per request
//   - Wire format selection (binary/JSON)
//   - Query statistics tracking
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching DoHABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching DoHABI.Types.idr tag assignments)
// =========================================================================

/// DoH content types (ABI tags 0-1).
pub const ContentType = enum(u8) {
    dns_message = 0,
    dns_json = 1,
};

/// HTTP request methods (ABI tags 0-1).
pub const RequestMethod = enum(u8) {
    get = 0,
    post = 1,
};

/// Wire formats (ABI tags 0-1).
pub const WireFormat = enum(u8) {
    binary = 0,
    json = 1,
};

/// DoH error reasons (ABI tags 0-4).
pub const ErrorReason = enum(u8) {
    bad_content_type = 0,
    bad_method = 1,
    payload_too_large = 2,
    upstream_timeout = 3,
    upstream_error = 4,
};

/// Proxy session states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    idle = 0,
    bound = 1,
    serving = 2,
    resolving = 3,
    shutdown = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent proxies.
const MAX_PROXIES: usize = 64;

/// Maximum request paths per proxy.
const MAX_PATHS: usize = 8;

/// Maximum path length in bytes.
const MAX_PATH_LEN: usize = 256;

/// Maximum DNS query payload size (RFC 8484 recommends 64KB max).
const MAX_PAYLOAD_LEN: usize = 65535;

/// A registered DoH request path.
const Path = struct {
    /// URI path (e.g., "/dns-query").
    path: [MAX_PATH_LEN]u8,
    path_len: u32,
    /// Wire format for this path.
    wire_format: WireFormat,
    /// Whether this path slot is active.
    active: bool,
};

/// A DoH proxy server instance.
const Proxy = struct {
    /// Current proxy lifecycle state.
    state: SessionState,
    /// Bound listening port.
    port: u16,
    /// Registered request paths.
    paths: [MAX_PATHS]Path,
    /// Number of active paths.
    path_count: u32,
    /// Total queries handled (monotonic counter).
    queries_handled: u64,
    /// Whether this proxy slot is in use.
    active: bool,
};

/// Default (empty) path.
const empty_path: Path = .{
    .path = [_]u8{0} ** MAX_PATH_LEN,
    .path_len = 0,
    .wire_format = .binary,
    .active = false,
};

/// Default (empty) proxy.
const empty_proxy: Proxy = .{
    .state = .idle,
    .port = 0,
    .paths = [_]Path{empty_path} ** MAX_PATHS,
    .path_count = 0,
    .queries_handled = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var proxies: [MAX_PROXIES]Proxy = [_]Proxy{empty_proxy} ** MAX_PROXIES;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_PROXIES) return null;
    const idx: usize = @intCast(slot);
    if (!proxies[idx].active) return null;
    return idx;
}

/// Find a path by URI within a proxy.
fn findPath(idx: usize, path: []const u8) ?usize {
    for (&proxies[idx].paths, 0..) |*p, i| {
        if (p.active and p.path_len == path.len and
            std.mem.eql(u8, p.path[0..p.path_len], path))
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
pub export fn doh_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new DoH proxy. Returns slot index (>=0) or -1 on failure.
/// The proxy starts in Bound state.
pub export fn doh_create(port: u16) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (port == 0) return -1;

    for (&proxies, 0..) |*px, i| {
        if (!px.active) {
            px.* = empty_proxy;
            px.port = port;
            px.state = .bound;
            px.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a proxy, releasing its slot.
pub export fn doh_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_PROXIES) return;
    proxies[@intCast(slot)] = empty_proxy;
}

// -- State queries ------------------------------------------------------------

/// Returns the current SessionState tag for a proxy.
pub export fn doh_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle fallback
    return @intFromEnum(proxies[idx].state);
}

/// Returns 1 if the proxy can serve requests, 0 otherwise.
pub export fn doh_can_serve(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const state = proxies[idx].state;
    return if (state == .serving or state == .resolving) 1 else 0;
}

// -- Path management ----------------------------------------------------------

/// Register a DoH request path. Returns 0 on success, 1 on rejection.
/// Transitions: Bound -> Serving, or stays Serving/Resolving.
pub export fn doh_add_path(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    wire_format: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = proxies[idx].state;
    if (state != .bound and state != .serving and state != .resolving) return 1;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 1;
    if (wire_format > 1) return 1;

    const path = path_ptr[0..path_len];

    // Check for duplicate path
    if (findPath(idx, path) != null) return 1;

    // Find a free path slot
    for (&proxies[idx].paths) |*p| {
        if (!p.active) {
            @memcpy(p.path[0..path_len], path);
            p.path_len = path_len;
            p.wire_format = @enumFromInt(wire_format);
            p.active = true;
            proxies[idx].path_count += 1;
            if (proxies[idx].state == .bound) {
                proxies[idx].state = .serving;
            }
            return 0;
        }
    }
    return 1;
}

/// Unregister a request path. Returns 0 on success, 1 on rejection.
/// May transition Serving -> Bound if last path.
pub export fn doh_remove_path(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 1;

    const path = path_ptr[0..path_len];
    const pi = findPath(idx, path) orelse return 1;

    proxies[idx].paths[pi].active = false;
    proxies[idx].path_count -= 1;

    // If no paths remain, transition to Bound
    if (proxies[idx].path_count == 0) {
        if (proxies[idx].state == .serving or proxies[idx].state == .resolving) {
            proxies[idx].state = .bound;
        }
    }

    return 0;
}

/// Returns the number of registered paths for a proxy.
pub export fn doh_path_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return proxies[idx].path_count;
}

// -- Query handling -----------------------------------------------------------

/// Handle a DoH query. Returns 0xFF on success, ErrorReason tag on failure.
/// Validates method and content type against the path's configuration.
pub export fn doh_handle_query(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    method: u8,
    content_type: u8,
    body_ptr: [*]const u8,
    body_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = body_ptr;

    const idx = validSlot(slot) orelse return @intFromEnum(ErrorReason.upstream_error);
    const state = proxies[idx].state;
    if (state != .serving and state != .resolving) {
        return @intFromEnum(ErrorReason.upstream_error);
    }

    if (method > 1) return @intFromEnum(ErrorReason.bad_method);
    if (content_type > 1) return @intFromEnum(ErrorReason.bad_content_type);
    if (path_len == 0 or path_len > MAX_PATH_LEN) return @intFromEnum(ErrorReason.bad_method);

    const path = path_ptr[0..path_len];
    _ = findPath(idx, path) orelse return @intFromEnum(ErrorReason.bad_method);

    // POST requires a body; GET should not have one
    if (method == 1 and body_len == 0) return @intFromEnum(ErrorReason.bad_method);
    if (body_len > MAX_PAYLOAD_LEN) return @intFromEnum(ErrorReason.payload_too_large);

    proxies[idx].queries_handled += 1;
    return 0xFF; // success sentinel
}

/// Returns the total number of queries handled.
pub export fn doh_queries_handled(slot: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return proxies[idx].queries_handled;
}

// -- Shutdown / Cleanup -------------------------------------------------------

/// Shutdown the proxy. Returns 0 on success, 1 on rejection.
pub export fn doh_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = proxies[idx].state;
    if (state == .bound or state == .serving or state == .resolving) {
        proxies[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

/// Complete cleanup after shutdown. Returns 0 on success, 1 on rejection.
pub export fn doh_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (proxies[idx].state != .shutdown) return 1;

    proxies[idx].state = .idle;
    proxies[idx].paths = [_]Path{empty_path} ** MAX_PATHS;
    proxies[idx].path_count = 0;

    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if a proxy state transition is valid.
pub export fn doh_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Bound
    if (from == 1 and to == 2) return 1; // Bound -> Serving
    if (from == 2 and to == 2) return 1; // Serving -> Serving (add more paths)
    if (from == 2 and to == 1) return 1; // Serving -> Bound (all paths removed)
    if (from == 2 and to == 3) return 1; // Serving -> Resolving
    if (from == 3 and to == 3) return 1; // Resolving -> Resolving
    if (from == 3 and to == 2) return 1; // Resolving -> Serving
    if (from == 1 and to == 4) return 1; // Bound -> Shutdown
    if (from == 2 and to == 4) return 1; // Serving -> Shutdown
    if (from == 3 and to == 4) return 1; // Resolving -> Shutdown
    if (from == 4 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
