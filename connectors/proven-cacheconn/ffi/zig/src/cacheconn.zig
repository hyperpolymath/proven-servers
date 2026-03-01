// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// cacheconn.zig — Zig FFI implementation for proven-cacheconn.
//
// Skeleton implementation that enforces the cache connection state machine
// at runtime.  Real cache backends (Redis, Memcached, etc.) would replace
// the stub behaviour with actual protocol I/O.

const std = @import("std");

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

pub const ABI_VERSION: u32 = 1;
pub const DEFAULT_TTL: u32 = 3600;
pub const MAX_KEY_LENGTH: u32 = 512;
pub const MAX_VALUE_SIZE: u32 = 1048576;

// ---------------------------------------------------------------------------
// Enum types (tags match C header and Idris2 Layout.idr exactly)
// ---------------------------------------------------------------------------

pub const CacheOp = enum(u8) {
    get = 0,
    set = 1,
    delete = 2,
    exists = 3,
    expire = 4,
    increment = 5,
    decrement = 6,
    flush = 7,
};

pub const CacheResult = enum(u8) {
    hit = 0,
    miss = 1,
    stored = 2,
    deleted = 3,
    expired = 4,
    err = 5,
};

pub const EvictionPolicy = enum(u8) {
    lru = 0,
    lfu = 1,
    fifo = 2,
    ttl_based = 3,
    random = 4,
    no_eviction = 5,
};

pub const CacheState = enum(u8) {
    disconnected = 0,
    connected = 1,
    degraded = 2,
    failed = 3,
};

pub const CacheError = enum(u8) {
    none = 0,
    connection_lost = 1,
    key_not_found = 2,
    value_too_large = 3,
    capacity_exceeded = 4,
    serialization_error = 5,
    timeout = 6,
};

// ---------------------------------------------------------------------------
// Opaque handle struct
// ---------------------------------------------------------------------------

pub const CacheHandle = struct {
    state: CacheState,
    policy: EvictionPolicy,
    port: u16,
};

// ---------------------------------------------------------------------------
// Allocator
// ---------------------------------------------------------------------------

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// ---------------------------------------------------------------------------
// Exported C-ABI functions
// ---------------------------------------------------------------------------

pub export fn cacheconn_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

pub export fn cacheconn_connect(
    host: ?[*:0]const u8,
    port: u16,
    policy: EvictionPolicy,
    err: *CacheError,
) callconv(.c) ?*CacheHandle {
    _ = host;
    const handle = allocator.create(CacheHandle) catch {
        err.* = CacheError.connection_lost;
        return null;
    };
    handle.* = CacheHandle{
        .state = CacheState.connected,
        .policy = policy,
        .port = port,
    };
    err.* = CacheError.none;
    return handle;
}

pub export fn cacheconn_disconnect(h: ?*CacheHandle) callconv(.c) CacheError {
    const handle = h orelse return CacheError.connection_lost;
    switch (handle.state) {
        .connected, .degraded => {
            handle.state = CacheState.disconnected;
            allocator.destroy(handle);
            return CacheError.none;
        },
        .disconnected, .failed => return CacheError.connection_lost,
    }
}

pub export fn cacheconn_state(h: ?*const CacheHandle) callconv(.c) CacheState {
    const handle = h orelse return CacheState.disconnected;
    return handle.state;
}

pub export fn cacheconn_get(
    h: ?*CacheHandle,
    key: ?*const anyopaque,
    key_len: u32,
    val_buf: ?*anyopaque,
    val_cap: u32,
    val_len: ?*u32,
) callconv(.c) CacheResult {
    const handle = h orelse return CacheResult.err;
    _ = key;
    _ = key_len;
    _ = val_buf;
    _ = val_cap;
    switch (handle.state) {
        .connected, .degraded => {
            // Skeleton: always miss
            if (val_len) |vl| vl.* = 0;
            return CacheResult.miss;
        },
        .disconnected, .failed => return CacheResult.err,
    }
}

pub export fn cacheconn_set(
    h: ?*CacheHandle,
    key: ?*const anyopaque,
    key_len: u32,
    val: ?*const anyopaque,
    val_len: u32,
    ttl: u32,
) callconv(.c) CacheResult {
    const handle = h orelse return CacheResult.err;
    _ = key;
    _ = key_len;
    _ = val;
    _ = ttl;
    switch (handle.state) {
        .connected, .degraded => {
            if (val_len > MAX_VALUE_SIZE) return CacheResult.err;
            return CacheResult.stored;
        },
        .disconnected, .failed => return CacheResult.err,
    }
}

pub export fn cacheconn_delete(
    h: ?*CacheHandle,
    key: ?*const anyopaque,
    key_len: u32,
) callconv(.c) CacheResult {
    const handle = h orelse return CacheResult.err;
    _ = key;
    _ = key_len;
    switch (handle.state) {
        .connected, .degraded => return CacheResult.deleted,
        .disconnected, .failed => return CacheResult.err,
    }
}

pub export fn cacheconn_exists(
    h: ?*CacheHandle,
    key: ?*const anyopaque,
    key_len: u32,
) callconv(.c) CacheResult {
    const handle = h orelse return CacheResult.err;
    _ = key;
    _ = key_len;
    switch (handle.state) {
        .connected, .degraded => return CacheResult.miss, // skeleton: nothing exists
        .disconnected, .failed => return CacheResult.err,
    }
}

pub export fn cacheconn_flush(h: ?*CacheHandle) callconv(.c) CacheError {
    const handle = h orelse return CacheError.connection_lost;
    switch (handle.state) {
        .connected => return CacheError.none,
        .degraded => return CacheError.connection_lost, // cannot flush when degraded
        .disconnected, .failed => return CacheError.connection_lost,
    }
}
