// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// resolverconn.zig — Zig FFI implementation for proven-resolverconn.
//
// Skeleton implementation enforcing the DNS resolver state machine.

const std = @import("std");

pub const ABI_VERSION: u32 = 1;
pub const DEFAULT_TIMEOUT: u32 = 5;
pub const MAX_RETRIES: u32 = 3;
pub const MAX_CACHE_ENTRIES: u32 = 10000;
pub const MIN_TTL: u32 = 60;

pub const RecordType = enum(u8) {
    a = 0,
    aaaa = 1,
    cname = 2,
    mx = 3,
    txt = 4,
    srv = 5,
    ns = 6,
    soa = 7,
    ptr = 8,
    caa = 9,
    tlsa = 10,
    svcb = 11,
    https = 12,
};

pub const ResolverState = enum(u8) {
    ready = 0,
    querying = 1,
    cached = 2,
    failed = 3,
};

pub const DNSSECStatus = enum(u8) {
    secure = 0,
    insecure = 1,
    bogus = 2,
    indeterminate = 3,
};

pub const ResolverError = enum(u8) {
    none = 0,
    nxdomain = 1,
    server_failure = 2,
    refused = 3,
    timeout = 4,
    dnssec_validation_failed = 5,
    network_unreachable = 6,
    truncated_response = 7,
};

pub const CachePolicy = enum(u8) {
    use_cache = 0,
    bypass_cache = 1,
    cache_only = 2,
    refresh_cache = 3,
};

pub const ResolverHandle = struct {
    state: ResolverState,
    port: u16,
};

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub export fn resolverconn_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

pub export fn resolverconn_create(
    upstream: ?[*:0]const u8,
    port: u16,
    err: *ResolverError,
) callconv(.c) ?*ResolverHandle {
    _ = upstream;
    const handle = allocator.create(ResolverHandle) catch {
        err.* = ResolverError.network_unreachable;
        return null;
    };
    handle.* = ResolverHandle{
        .state = ResolverState.ready,
        .port = port,
    };
    err.* = ResolverError.none;
    return handle;
}

pub export fn resolverconn_destroy(h: ?*ResolverHandle) callconv(.c) void {
    const handle = h orelse return;
    allocator.destroy(handle);
}

pub export fn resolverconn_state(h: ?*const ResolverHandle) callconv(.c) ResolverState {
    const handle = h orelse return ResolverState.failed;
    return handle.state;
}

pub export fn resolverconn_resolve(
    h: ?*ResolverHandle,
    name: ?[*]const u8,
    name_len: u32,
    rtype: RecordType,
    policy: CachePolicy,
    buf: ?*anyopaque,
    buf_cap: u32,
    buf_len: ?*u32,
    dnssec: ?*DNSSECStatus,
) callconv(.c) ResolverError {
    const handle = h orelse return ResolverError.network_unreachable;
    _ = name;
    _ = name_len;
    _ = rtype;
    _ = buf;
    _ = buf_cap;

    switch (handle.state) {
        .ready => {
            // Skeleton: simulate query -> ready cycle
            handle.state = ResolverState.querying;

            // Check cache policy
            switch (policy) {
                .cache_only => {
                    // Nothing in cache (skeleton)
                    handle.state = ResolverState.ready;
                    return ResolverError.nxdomain;
                },
                else => {},
            }

            // Simulate successful resolution
            handle.state = ResolverState.ready;
            if (buf_len) |bl| bl.* = 0;
            if (dnssec) |ds| ds.* = DNSSECStatus.insecure;
            return ResolverError.none;
        },
        .querying, .cached, .failed => return ResolverError.network_unreachable,
    }
}

pub export fn resolverconn_reset(h: ?*ResolverHandle) callconv(.c) ResolverError {
    const handle = h orelse return ResolverError.network_unreachable;
    switch (handle.state) {
        .failed => {
            handle.state = ResolverState.ready;
            return ResolverError.none;
        },
        .ready => return ResolverError.none, // already ready
        .querying, .cached => return ResolverError.network_unreachable,
    }
}

pub export fn resolverconn_cache_flush(h: ?*ResolverHandle) callconv(.c) ResolverError {
    const handle = h orelse return ResolverError.network_unreachable;
    switch (handle.state) {
        .ready, .cached => {
            handle.state = ResolverState.ready;
            return ResolverError.none;
        },
        .querying, .failed => return ResolverError.network_unreachable,
    }
}
