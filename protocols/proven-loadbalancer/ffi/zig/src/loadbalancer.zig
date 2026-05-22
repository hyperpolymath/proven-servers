// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// loadbalancer.zig — Zig FFI implementation of proven-loadbalancer.
//
// Implements the load balancer primitive with:
//   - Slot-based pool management (up to 64 concurrent pools)
//   - Backend state tracking (Healthy, Unhealthy, Draining, Disabled)
//   - Multiple load balancing algorithms (RoundRobin, LeastConnections, etc.)
//   - Session persistence modes
//   - Health check type metadata
//   - Round-robin request routing across healthy backends
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/LoadbalancerABI/Layout.idr)
//   - C header   (generated/abi/loadbalancer.h)

const std = @import("std");

// ── Enums (matching Idris2 Layout.idr tag assignments exactly) ──────────

/// Algorithm — matches algorithmToTag
pub const Algorithm = enum(u8) {
    round_robin = 0,
    least_connections = 1,
    ip_hash = 2,
    random = 3,
    weighted_round_robin = 4,
    least_response_time = 5,
};

/// HealthCheckType — matches healthCheckTypeToTag
pub const HealthCheckType = enum(u8) {
    http = 0,
    tcp = 1,
    grpc = 2,
    script = 3,
};

/// BackendState — matches backendStateToTag
pub const BackendState = enum(u8) {
    healthy = 0,
    unhealthy = 1,
    draining = 2,
    disabled = 3,
};

/// SessionPersistence — matches sessionPersistenceToTag
pub const SessionPersistence = enum(u8) {
    none = 0,
    cookie = 1,
    source_ip = 2,
    header = 3,
};

/// Protocol — matches protocolToTag
pub const Protocol = enum(u8) {
    http = 0,
    https = 1,
    tcp = 2,
    udp = 3,
    grpc = 4,
};

/// LBError — matches lbErrorToTag
pub const LBError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_transition = 3,
    no_healthy_backends = 4,
    capacity_exhausted = 5,
    invalid_param = 6,
};

// ── Backend and Pool instances ──────────────────────────────────────────

const MAX_BACKENDS: usize = 64;

const Backend = struct {
    active: bool,
    state: BackendState,
    weight: u32,
    connections: u32,
};

const empty_backend: Backend = .{
    .active = false,
    .state = .healthy,
    .weight = 1,
    .connections = 0,
};

const PoolCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Load balancing algorithm.
    algorithm: Algorithm,
    /// Listener protocol.
    protocol: Protocol,
    /// Session persistence mode.
    persistence: SessionPersistence,
    /// Health check type.
    hc_type: HealthCheckType,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Number of active backends.
    backend_count: u32,
    /// Total requests routed.
    total_requests: u32,
    /// Round-robin index for routing.
    rr_index: u32,
    /// Backend array.
    backends: [MAX_BACKENDS]Backend,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: PoolCtx = .{
    .active = false,
    .algorithm = .round_robin,
    .protocol = .http,
    .persistence = .none,
    .hc_type = .http,
    .last_error = 255,
    .backend_count = 0,
    .total_requests = 0,
    .rr_index = 0,
    .backends = [_]Backend{empty_backend} ** MAX_BACKENDS,
};

var contexts: [MAX_CONTEXTS]PoolCtx = [_]PoolCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

fn getActive(slot: c_int) ?*PoolCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

pub export fn lb_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new load balancer pool.
pub export fn lb_create(algorithm: u8, protocol: u8, persistence: u8, hc_type: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (algorithm > 5) return -1;
    if (protocol > 4) return -1;
    if (persistence > 3) return -1;
    if (hc_type > 3) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.algorithm = @enumFromInt(algorithm);
            ctx.protocol = @enumFromInt(protocol);
            ctx.persistence = @enumFromInt(persistence);
            ctx.hc_type = @enumFromInt(hc_type);
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a load balancer pool.
pub export fn lb_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

pub export fn lb_get_algorithm(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.algorithm);
}

pub export fn lb_get_protocol(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.protocol);
}

pub export fn lb_get_persistence(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.persistence);
}

pub export fn lb_get_health_check_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.hc_type);
}

pub export fn lb_get_backend_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.backend_count;
}

pub export fn lb_get_healthy_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    var count: u32 = 0;
    for (ctx.backends[0..ctx.backend_count]) |b| {
        if (b.active and b.state == .healthy) count += 1;
    }
    return count;
}

pub export fn lb_get_total_requests(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.total_requests;
}

pub export fn lb_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── Backend management ──────────────────────────────────────────────────

/// Add a backend with the given weight. Returns LBError tag.
pub export fn lb_add_backend(slot: c_int, weight: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LBError.invalid_slot);

    if (ctx.backend_count >= MAX_BACKENDS) {
        ctx.last_error = @intFromEnum(LBError.capacity_exhausted);
        return @intFromEnum(LBError.capacity_exhausted);
    }

    if (weight == 0) {
        ctx.last_error = @intFromEnum(LBError.invalid_param);
        return @intFromEnum(LBError.invalid_param);
    }

    ctx.backends[ctx.backend_count] = .{
        .active = true,
        .state = .healthy,
        .weight = weight,
        .connections = 0,
    };
    ctx.backend_count += 1;
    ctx.last_error = 255;
    return @intFromEnum(LBError.ok);
}

/// Set the state of a specific backend. Returns LBError tag.
pub export fn lb_set_backend_state(slot: c_int, backend: u32, state: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LBError.invalid_slot);

    if (backend >= ctx.backend_count) {
        ctx.last_error = @intFromEnum(LBError.invalid_param);
        return @intFromEnum(LBError.invalid_param);
    }

    if (state > 3) {
        ctx.last_error = @intFromEnum(LBError.invalid_param);
        return @intFromEnum(LBError.invalid_param);
    }

    ctx.backends[backend].state = @enumFromInt(state);
    ctx.last_error = 255;
    return @intFromEnum(LBError.ok);
}

/// Get the state of a specific backend.
pub export fn lb_get_backend_state(slot: c_int, backend: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    if (backend >= ctx.backend_count) return 0;
    return @intFromEnum(ctx.backends[backend].state);
}

// ── Request routing ─────────────────────────────────────────────────────

/// Route a request using round-robin across healthy backends.
/// Returns backend index (0+) or -1 if no healthy backends available.
pub export fn lb_route_request(slot: c_int) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return -1;

    if (ctx.backend_count == 0) {
        ctx.last_error = @intFromEnum(LBError.no_healthy_backends);
        return -1;
    }

    // Simple round-robin: scan from rr_index for a healthy backend
    var attempts: u32 = 0;
    while (attempts < ctx.backend_count) : (attempts += 1) {
        const idx = (ctx.rr_index + attempts) % ctx.backend_count;
        if (ctx.backends[idx].active and ctx.backends[idx].state == .healthy) {
            ctx.rr_index = (idx + 1) % ctx.backend_count;
            ctx.total_requests += 1;
            ctx.backends[idx].connections += 1;
            ctx.last_error = 255;
            return @intCast(idx);
        }
    }

    ctx.last_error = @intFromEnum(LBError.no_healthy_backends);
    return -1;
}

/// Set the load balancing algorithm. Returns LBError tag.
pub export fn lb_set_algorithm(slot: c_int, algorithm: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(LBError.invalid_slot);

    if (algorithm > 5) {
        ctx.last_error = @intFromEnum(LBError.invalid_param);
        return @intFromEnum(LBError.invalid_param);
    }

    ctx.algorithm = @enumFromInt(algorithm);
    ctx.last_error = 255;
    return @intFromEnum(LBError.ok);
}
