// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// coap.zig -- Zig FFI implementation of proven-coap.
//
// Implements the CoAP (RFC 7252) server endpoint state machine with:
//   - 64-slot mutex-protected endpoint pool
//   - Resource registration per endpoint (max 32 resources)
//   - Observation tracking per resource (RFC 7641, max 64 observers)
//   - Method bitmask per resource (GET=0x01, POST=0x02, PUT=0x04, DELETE=0x08)
//   - Request handling with method validation
//   - Thread-safe via per-pool mutex
//
// All exported functions use C calling convention (callconv(.c)) and
// communicate state via u8 tags matching CoAPABI.Types.idr exactly.

const std = @import("std");

// =========================================================================
// Enums (matching CoAPABI.Types.idr tag assignments)
// =========================================================================

/// CoAP request methods (ABI tags 0-3).
pub const Method = enum(u8) {
    get = 0,
    post = 1,
    put = 2,
    delete = 3,
};

/// CoAP message types (ABI tags 0-3).
pub const MessageType = enum(u8) {
    confirmable = 0,
    non_confirmable = 1,
    acknowledgement = 2,
    reset = 3,
};

/// CoAP content formats (ABI tags 0-6).
pub const ContentFormat = enum(u8) {
    text_plain = 0,
    link_format = 1,
    xml = 2,
    octet_stream = 3,
    exi = 4,
    json = 5,
    cbor = 6,
};

/// CoAP response class (ABI tags 0-4).
pub const ResponseClass = enum(u8) {
    success = 0,
    client_error = 1,
    server_error = 2,
    signaling = 3,
    empty = 4,
};

/// CoAP server endpoint lifecycle states (ABI tags 0-4).
pub const SessionState = enum(u8) {
    idle = 0,
    bound = 1,
    serving = 2,
    observing = 3,
    shutdown = 4,
};

// =========================================================================
// Internal data structures
// =========================================================================

/// Maximum concurrent endpoints.
const MAX_ENDPOINTS: usize = 64;

/// Maximum resources per endpoint.
const MAX_RESOURCES: usize = 32;

/// Maximum observers per endpoint (across all resources).
const MAX_OBSERVERS: usize = 64;

/// Maximum URI path length in bytes.
const MAX_PATH_LEN: usize = 256;

/// A registered CoAP resource.
const Resource = struct {
    /// URI path (e.g., "/temperature", "/light").
    path: [MAX_PATH_LEN]u8,
    path_len: u32,
    /// Allowed methods bitmask: bit0=GET, bit1=POST, bit2=PUT, bit3=DELETE.
    methods: u8,
    /// Whether this resource slot is active.
    active: bool,
};

/// An observation subscription (RFC 7641).
const Observer = struct {
    /// URI path of the observed resource.
    path: [MAX_PATH_LEN]u8,
    path_len: u32,
    /// Client token for matching responses.
    token: u64,
    /// Whether this observer slot is active.
    active: bool,
};

/// A CoAP server endpoint.
const Endpoint = struct {
    /// Current endpoint lifecycle state.
    state: SessionState,
    /// Bound UDP port.
    port: u16,
    /// Registered resources.
    resources: [MAX_RESOURCES]Resource,
    /// Number of active resources.
    resource_count: u32,
    /// Observation subscriptions.
    observers: [MAX_OBSERVERS]Observer,
    /// Number of active observers.
    observer_count: u32,
    /// Total requests handled (monotonic counter).
    requests_handled: u64,
    /// Whether this endpoint slot is in use.
    active: bool,
};

/// Default (empty) resource.
const empty_resource: Resource = .{
    .path = [_]u8{0} ** MAX_PATH_LEN,
    .path_len = 0,
    .methods = 0,
    .active = false,
};

/// Default (empty) observer.
const empty_observer: Observer = .{
    .path = [_]u8{0} ** MAX_PATH_LEN,
    .path_len = 0,
    .token = 0,
    .active = false,
};

/// Default (empty) endpoint.
const empty_endpoint: Endpoint = .{
    .state = .idle,
    .port = 0,
    .resources = [_]Resource{empty_resource} ** MAX_RESOURCES,
    .resource_count = 0,
    .observers = [_]Observer{empty_observer} ** MAX_OBSERVERS,
    .observer_count = 0,
    .requests_handled = 0,
    .active = false,
};

// =========================================================================
// Global state
// =========================================================================

var endpoints: [MAX_ENDPOINTS]Endpoint = [_]Endpoint{empty_endpoint} ** MAX_ENDPOINTS;
var mutex: std.Thread.Mutex = .{};

// =========================================================================
// Internal helpers
// =========================================================================

/// Validate a slot index, returning null if out of range or inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_ENDPOINTS) return null;
    const idx: usize = @intCast(slot);
    if (!endpoints[idx].active) return null;
    return idx;
}

/// Find a resource by path within an endpoint.
fn findResource(idx: usize, path: []const u8) ?usize {
    for (&endpoints[idx].resources, 0..) |*r, i| {
        if (r.active and r.path_len == path.len and
            std.mem.eql(u8, r.path[0..r.path_len], path))
        {
            return i;
        }
    }
    return null;
}

/// Check if a method tag is valid (0-3).
fn validMethod(method: u8) bool {
    return method <= 3;
}

/// Convert a method tag to its bitmask position.
fn methodBit(method: u8) u8 {
    return @as(u8, 1) << @intCast(method);
}

// =========================================================================
// Exported C ABI functions
// =========================================================================

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match Foreign.abiVersion in Idris2.
pub export fn coap_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new CoAP endpoint. Returns slot index (>=0) or -1 on failure.
/// The endpoint starts in Bound state (Idle -> Bound transition applied).
pub export fn coap_create(port: u16) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (port == 0) return -1;

    for (&endpoints, 0..) |*ep, i| {
        if (!ep.active) {
            ep.* = empty_endpoint;
            ep.port = port;
            ep.state = .bound; // Idle -> Bound
            ep.active = true;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy an endpoint, releasing its slot.
pub export fn coap_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_ENDPOINTS) return;
    endpoints[@intCast(slot)] = empty_endpoint;
}

// -- State queries ------------------------------------------------------------

/// Returns the current SessionState tag for an endpoint.
pub export fn coap_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0; // idle fallback
    return @intFromEnum(endpoints[idx].state);
}

/// Returns 1 if the endpoint can serve requests, 0 otherwise.
pub export fn coap_can_serve(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const state = endpoints[idx].state;
    return if (state == .serving or state == .observing) 1 else 0;
}

// -- Resource management ------------------------------------------------------

/// Register a resource at a URI path. Returns 0 on success, 1 on rejection.
/// Transitions: Bound -> Serving, or stays Serving/Observing.
pub export fn coap_register_resource(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    methods: u8,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = endpoints[idx].state;
    if (state != .bound and state != .serving and state != .observing) return 1;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 1;
    if (methods == 0 or methods > 0x0F) return 1; // must have at least one method, max 4 bits

    const path = path_ptr[0..path_len];

    // Check for duplicate resource path
    if (findResource(idx, path) != null) return 1;

    // Find a free resource slot
    for (&endpoints[idx].resources) |*r| {
        if (!r.active) {
            @memcpy(r.path[0..path_len], path);
            r.path_len = path_len;
            r.methods = methods;
            r.active = true;
            endpoints[idx].resource_count += 1;
            if (endpoints[idx].state == .bound) {
                endpoints[idx].state = .serving;
            }
            return 0;
        }
    }
    return 1;
}

/// Unregister a resource by path. Returns 0 on success, 1 on rejection.
/// May transition Serving -> Bound if last resource.
pub export fn coap_unregister_resource(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 1;

    const path = path_ptr[0..path_len];
    const ri = findResource(idx, path) orelse return 1;

    // Cancel all observers for this resource
    for (&endpoints[idx].observers) |*obs| {
        if (obs.active and obs.path_len == path_len and
            std.mem.eql(u8, obs.path[0..obs.path_len], path))
        {
            obs.active = false;
            obs.path_len = 0;
            endpoints[idx].observer_count -= 1;
        }
    }

    endpoints[idx].resources[ri].active = false;
    endpoints[idx].resource_count -= 1;

    // If no resources remain, transition to Bound
    if (endpoints[idx].resource_count == 0) {
        if (endpoints[idx].state == .serving or endpoints[idx].state == .observing) {
            endpoints[idx].state = .bound;
        }
    } else if (endpoints[idx].observer_count == 0 and endpoints[idx].state == .observing) {
        endpoints[idx].state = .serving;
    }

    return 0;
}

/// Returns the number of registered resources for an endpoint.
pub export fn coap_resource_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return endpoints[idx].resource_count;
}

// -- Request handling ---------------------------------------------------------

/// Handle an incoming request. Returns ResponseClass tag.
/// Validates method against resource's allowed methods bitmask.
pub export fn coap_handle_request(
    slot: c_int,
    method: u8,
    msg_type: u8,
    msg_id: u16,
    token_len: u8,
    path_ptr: [*]const u8,
    path_len: u32,
    payload_ptr: [*]const u8,
    payload_len: u32,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = msg_type;
    _ = msg_id;
    _ = token_len;
    _ = payload_ptr;
    _ = payload_len;

    const idx = validSlot(slot) orelse return @intFromEnum(ResponseClass.server_error);
    const state = endpoints[idx].state;
    if (state != .serving and state != .observing) {
        return @intFromEnum(ResponseClass.server_error);
    }
    if (!validMethod(method)) return @intFromEnum(ResponseClass.client_error);
    if (path_len == 0 or path_len > MAX_PATH_LEN) return @intFromEnum(ResponseClass.client_error);

    const path = path_ptr[0..path_len];
    const ri = findResource(idx, path) orelse return @intFromEnum(ResponseClass.client_error); // 4.04 Not Found

    // Check if the method is allowed for this resource
    const bit = methodBit(method);
    if (endpoints[idx].resources[ri].methods & bit == 0) {
        return @intFromEnum(ResponseClass.client_error); // 4.05 Method Not Allowed
    }

    endpoints[idx].requests_handled += 1;
    return @intFromEnum(ResponseClass.success); // 2.xx
}

// -- Observation (RFC 7641) ---------------------------------------------------

/// Add an observer for a resource. Returns 0 on success, 1 on rejection.
/// Transitions: Serving -> Observing, or stays Observing.
pub export fn coap_add_observer(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    token: u64,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = endpoints[idx].state;
    if (state != .serving and state != .observing) return 1;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 1;

    const path = path_ptr[0..path_len];

    // Verify resource exists
    if (findResource(idx, path) == null) return 1;

    // Find a free observer slot
    for (&endpoints[idx].observers) |*obs| {
        if (!obs.active) {
            @memcpy(obs.path[0..path_len], path);
            obs.path_len = path_len;
            obs.token = token;
            obs.active = true;
            endpoints[idx].observer_count += 1;
            endpoints[idx].state = .observing;
            return 0;
        }
    }
    return 1;
}

/// Remove an observer. Returns 0 on success, 1 on rejection.
/// May transition Observing -> Serving if last observer.
pub export fn coap_remove_observer(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
    token: u64,
) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 1;

    const path = path_ptr[0..path_len];

    for (&endpoints[idx].observers) |*obs| {
        if (obs.active and obs.token == token and obs.path_len == path_len and
            std.mem.eql(u8, obs.path[0..obs.path_len], path))
        {
            obs.active = false;
            obs.path_len = 0;
            endpoints[idx].observer_count -= 1;

            if (endpoints[idx].observer_count == 0 and endpoints[idx].state == .observing) {
                endpoints[idx].state = .serving;
            }
            return 0;
        }
    }
    return 1;
}

/// Returns the total number of active observers.
pub export fn coap_observer_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return endpoints[idx].observer_count;
}

/// Notify all observers of a resource. Returns number of observers notified.
pub export fn coap_notify_observers(
    slot: c_int,
    path_ptr: [*]const u8,
    path_len: u32,
) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 0;
    if (path_len == 0 or path_len > MAX_PATH_LEN) return 0;

    const path = path_ptr[0..path_len];
    var notified: u32 = 0;

    for (&endpoints[idx].observers) |*obs| {
        if (obs.active and obs.path_len == path_len and
            std.mem.eql(u8, obs.path[0..obs.path_len], path))
        {
            notified += 1;
        }
    }
    return notified;
}

// -- Shutdown / Cleanup -------------------------------------------------------

/// Shutdown the endpoint. Returns 0 on success, 1 on rejection.
pub export fn coap_shutdown(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    const state = endpoints[idx].state;
    if (state == .bound or state == .serving or state == .observing) {
        endpoints[idx].state = .shutdown;
        return 0;
    }
    return 1;
}

/// Complete cleanup after shutdown. Returns 0 on success, 1 on rejection.
pub export fn coap_cleanup(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const idx = validSlot(slot) orelse return 1;
    if (endpoints[idx].state != .shutdown) return 1;

    endpoints[idx].state = .idle;
    endpoints[idx].resources = [_]Resource{empty_resource} ** MAX_RESOURCES;
    endpoints[idx].resource_count = 0;
    endpoints[idx].observers = [_]Observer{empty_observer} ** MAX_OBSERVERS;
    endpoints[idx].observer_count = 0;

    return 0;
}

// -- Stateless transition table -----------------------------------------------

/// Check if an endpoint state transition is valid.
pub export fn coap_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> Bound
    if (from == 1 and to == 2) return 1; // Bound -> Serving
    if (from == 2 and to == 2) return 1; // Serving -> Serving (add more resources)
    if (from == 2 and to == 1) return 1; // Serving -> Bound (all resources removed)
    if (from == 2 and to == 3) return 1; // Serving -> Observing
    if (from == 3 and to == 3) return 1; // Observing -> Observing
    if (from == 3 and to == 2) return 1; // Observing -> Serving (all observers removed)
    if (from == 1 and to == 4) return 1; // Bound -> Shutdown
    if (from == 2 and to == 4) return 1; // Serving -> Shutdown
    if (from == 3 and to == 4) return 1; // Observing -> Shutdown
    if (from == 4 and to == 0) return 1; // Shutdown -> Idle
    return 0;
}
