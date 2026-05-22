// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// proxy.zig — Zig FFI implementation of proven-proxy.
//
// Implements an HTTP forward/reverse proxy primitive with:
//   - Slot-based context management (up to 64 concurrent connections)
//   - Forward/Reverse proxy mode selection
//   - Hop-by-hop header stripping validation (RFC 2616 Section 13.5.1)
//   - Cache-Control directive tracking (RFC 7234)
//   - Request counting and cache hit tracking
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/abi/Types.idr)

const std = @import("std");

// ── Enums (matching Idris2 Types.idr tag assignments exactly) ──────────

/// ProxyMode — matches proxyModeToTag
pub const ProxyMode = enum(u8) {
    forward = 0,
    reverse = 1,
};

/// HopByHopHeader — matches hopByHopHeaderToTag
pub const HopByHopHeader = enum(u8) {
    connection = 0,
    keep_alive = 1,
    proxy_auth = 2,
    proxy_authz = 3,
    te = 4,
    trailers = 5,
    transfer_encoding = 6,
    upgrade = 7,
};

/// CacheDirective — matches cacheDirectiveToTag
pub const CacheDirective = enum(u8) {
    no_cache = 0,
    no_store = 1,
    max_age = 2,
    public = 3,
    private = 4,
    must_revalidate = 5,
};

/// ProxyError — matches proxyErrorToTag
pub const ProxyError = enum(u8) {
    bad_gateway = 0,
    gateway_timeout = 1,
    upstream_refused = 2,
    upstream_tls = 3,
};

/// ProxyFFIError — matches proxyFFIErrorToTag
pub const ProxyFFIError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_upstream = 3,
    cache_error = 4,
    header_violation = 5,
};

// ── Proxy Context instance ──────────────────────────────────────────────

const ProxyCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Proxy operating mode (forward or reverse).
    mode: ProxyMode,
    /// Active cache-control directive.
    cache_directive: CacheDirective,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Number of proxied requests.
    request_count: u32,
    /// Number of cache hits.
    cache_hits: u32,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: ProxyCtx = .{
    .active = false,
    .mode = .forward,
    .cache_directive = .no_cache,
    .last_error = 255,
    .request_count = 0,
    .cache_hits = 0,
};

var contexts: [MAX_CONTEXTS]ProxyCtx = [_]ProxyCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*ProxyCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match ProxyABI.Foreign.abiVersion (currently 1).
pub export fn proxy_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new proxy context.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn proxy_create(mode: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (mode > 1) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.mode = @enumFromInt(mode);
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a proxy context, freeing its slot.
pub export fn proxy_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the ProxyMode tag for a slot.
pub export fn proxy_get_mode(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.mode);
}

/// Get the active CacheDirective tag.
pub export fn proxy_get_cache_directive(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.cache_directive);
}

/// Get the request count.
pub export fn proxy_get_request_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.request_count;
}

/// Get the cache hit count.
pub export fn proxy_get_cache_hits(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 0;
    return ctx.cache_hits;
}

/// Get the last error tag, or 255 if no error.
pub export fn proxy_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── Cache directive management ──────────────────────────────────────────

/// Set the active cache directive.
pub export fn proxy_set_cache_directive(slot: c_int, directive: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(ProxyFFIError.invalid_slot);

    if (directive > 5) {
        ctx.last_error = @intFromEnum(ProxyFFIError.cache_error);
        return @intFromEnum(ProxyFFIError.cache_error);
    }

    ctx.cache_directive = @enumFromInt(directive);
    ctx.last_error = 255;
    return @intFromEnum(ProxyFFIError.ok);
}

// ── Hop-by-hop header checking ──────────────────────────────────────────

/// Check if a header must be stripped during proxying.
/// Returns 1 if the header is hop-by-hop (must strip), 0 if pass-through.
/// All 8 hop-by-hop headers (tags 0-7) MUST be stripped per RFC 2616.
pub export fn proxy_check_hop_header(slot: c_int, header: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    _ = getActive(slot) orelse return 0;

    // All valid hop-by-hop headers (0-7) must be stripped
    if (header <= 7) return 1;
    return 0;
}

// ── Request tracking ────────────────────────────────────────────────────

/// Record a proxied request.
pub export fn proxy_record_request(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(ProxyFFIError.invalid_slot);

    ctx.request_count += 1;
    ctx.last_error = 255;
    return @intFromEnum(ProxyFFIError.ok);
}

/// Record a cache hit.
pub export fn proxy_record_cache_hit(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(ProxyFFIError.invalid_slot);

    ctx.cache_hits += 1;
    ctx.last_error = 255;
    return @intFromEnum(ProxyFFIError.ok);
}
