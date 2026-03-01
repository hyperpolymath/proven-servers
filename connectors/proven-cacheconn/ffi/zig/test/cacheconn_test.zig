// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// cacheconn_test.zig — Integration tests for proven-cacheconn FFI.

const std = @import("std");
const testing = std.testing;
const cacheconn = @import("cacheconn");

// ---------------------------------------------------------------------------
// ABI Version
// ---------------------------------------------------------------------------

test "ABI version returns 1" {
    try testing.expectEqual(@as(u32, 1), cacheconn.cacheconn_abi_version());
}

// ---------------------------------------------------------------------------
// Connection Lifecycle
// ---------------------------------------------------------------------------

test "connect returns valid handle in connected state" {
    var err: cacheconn.CacheError = .none;
    const h = cacheconn.cacheconn_connect(null, 6379, .lru, &err);
    try testing.expect(h != null);
    try testing.expectEqual(cacheconn.CacheError.none, err);
    try testing.expectEqual(cacheconn.CacheState.connected, cacheconn.cacheconn_state(h));
    _ = cacheconn.cacheconn_disconnect(h);
}

test "disconnect from connected succeeds" {
    var err: cacheconn.CacheError = .none;
    const h = cacheconn.cacheconn_connect(null, 6379, .lru, &err).?;
    const result = cacheconn.cacheconn_disconnect(h);
    try testing.expectEqual(cacheconn.CacheError.none, result);
}

// ---------------------------------------------------------------------------
// Cache Operations
// ---------------------------------------------------------------------------

test "get on empty cache returns miss" {
    var err: cacheconn.CacheError = .none;
    const h = cacheconn.cacheconn_connect(null, 6379, .lru, &err).?;
    var val_len: u32 = 0;
    const result = cacheconn.cacheconn_get(h, null, 0, null, 0, &val_len);
    try testing.expectEqual(cacheconn.CacheResult.miss, result);
    _ = cacheconn.cacheconn_disconnect(h);
}

test "set returns stored" {
    var err: cacheconn.CacheError = .none;
    const h = cacheconn.cacheconn_connect(null, 6379, .lru, &err).?;
    const result = cacheconn.cacheconn_set(h, null, 3, null, 5, 3600);
    try testing.expectEqual(cacheconn.CacheResult.stored, result);
    _ = cacheconn.cacheconn_disconnect(h);
}

test "delete returns deleted" {
    var err: cacheconn.CacheError = .none;
    const h = cacheconn.cacheconn_connect(null, 6379, .lru, &err).?;
    const result = cacheconn.cacheconn_delete(h, null, 3);
    try testing.expectEqual(cacheconn.CacheResult.deleted, result);
    _ = cacheconn.cacheconn_disconnect(h);
}

test "flush from connected succeeds" {
    var err: cacheconn.CacheError = .none;
    const h = cacheconn.cacheconn_connect(null, 6379, .lru, &err).?;
    const result = cacheconn.cacheconn_flush(h);
    try testing.expectEqual(cacheconn.CacheError.none, result);
    _ = cacheconn.cacheconn_disconnect(h);
}

test "value too large rejected" {
    var err: cacheconn.CacheError = .none;
    const h = cacheconn.cacheconn_connect(null, 6379, .lru, &err).?;
    // Attempt to set a value larger than MAX_VALUE_SIZE
    const result = cacheconn.cacheconn_set(h, null, 3, null, cacheconn.MAX_VALUE_SIZE + 1, 3600);
    try testing.expectEqual(cacheconn.CacheResult.err, result);
    _ = cacheconn.cacheconn_disconnect(h);
}

// ---------------------------------------------------------------------------
// NULL Handle Safety
// ---------------------------------------------------------------------------

test "NULL handle safety" {
    try testing.expectEqual(cacheconn.CacheState.disconnected, cacheconn.cacheconn_state(null));
    try testing.expect(cacheconn.cacheconn_disconnect(null) != cacheconn.CacheError.none);
    try testing.expectEqual(cacheconn.CacheResult.err, cacheconn.cacheconn_get(null, null, 0, null, 0, null));
    try testing.expectEqual(cacheconn.CacheResult.err, cacheconn.cacheconn_set(null, null, 0, null, 0, 0));
    try testing.expectEqual(cacheconn.CacheResult.err, cacheconn.cacheconn_delete(null, null, 0));
    try testing.expect(cacheconn.cacheconn_flush(null) != cacheconn.CacheError.none);
}

// ---------------------------------------------------------------------------
// Enum Tag Consistency
// ---------------------------------------------------------------------------

test "CacheOp enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(cacheconn.CacheOp.get));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(cacheconn.CacheOp.set));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(cacheconn.CacheOp.delete));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(cacheconn.CacheOp.exists));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(cacheconn.CacheOp.expire));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(cacheconn.CacheOp.increment));
    try testing.expectEqual(@as(u8, 6), @intFromEnum(cacheconn.CacheOp.decrement));
    try testing.expectEqual(@as(u8, 7), @intFromEnum(cacheconn.CacheOp.flush));
}

test "CacheState enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(cacheconn.CacheState.disconnected));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(cacheconn.CacheState.connected));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(cacheconn.CacheState.degraded));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(cacheconn.CacheState.failed));
}

test "CacheResult enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(cacheconn.CacheResult.hit));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(cacheconn.CacheResult.miss));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(cacheconn.CacheResult.stored));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(cacheconn.CacheResult.deleted));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(cacheconn.CacheResult.expired));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(cacheconn.CacheResult.err));
}

test "EvictionPolicy enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(cacheconn.EvictionPolicy.lru));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(cacheconn.EvictionPolicy.lfu));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(cacheconn.EvictionPolicy.fifo));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(cacheconn.EvictionPolicy.ttl_based));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(cacheconn.EvictionPolicy.random));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(cacheconn.EvictionPolicy.no_eviction));
}

test "CacheError enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(cacheconn.CacheError.none));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(cacheconn.CacheError.connection_lost));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(cacheconn.CacheError.key_not_found));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(cacheconn.CacheError.value_too_large));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(cacheconn.CacheError.capacity_exceeded));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(cacheconn.CacheError.serialization_error));
    try testing.expectEqual(@as(u8, 6), @intFromEnum(cacheconn.CacheError.timeout));
}
