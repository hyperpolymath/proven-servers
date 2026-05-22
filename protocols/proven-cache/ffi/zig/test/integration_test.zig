// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-cache FFI.
//
// Verifies that the Zig implementation matches the Idris2 formal
// specification in CacheABI.Types.

const std = @import("std");
const cache = @import("cache");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), cache.cache_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "Command encoding matches Types.idr (13 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cache.Command.get));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cache.Command.set));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cache.Command.delete));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cache.Command.exists));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(cache.Command.expire));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(cache.Command.ttl));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(cache.Command.keys));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(cache.Command.flush));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(cache.Command.incr));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(cache.Command.decr));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(cache.Command.append));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(cache.Command.prepend));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(cache.Command.cas));
}

test "EvictionPolicy encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cache.EvictionPolicy.lru));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cache.EvictionPolicy.lfu));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cache.EvictionPolicy.random));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cache.EvictionPolicy.evict_ttl));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(cache.EvictionPolicy.no_eviction));
}

test "DataType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cache.DataType.string_val));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cache.DataType.int_val));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cache.DataType.list_val));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cache.DataType.set_val));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(cache.DataType.hash_val));
}

test "ErrorCode encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cache.ErrorCode.not_found));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cache.ErrorCode.type_mismatch));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cache.ErrorCode.out_of_memory));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cache.ErrorCode.key_too_long));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(cache.ErrorCode.value_too_large));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(cache.ErrorCode.cas_conflict));
}

test "ReplicationMode encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(cache.ReplicationMode.none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(cache.ReplicationMode.primary));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(cache.ReplicationMode.replica));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(cache.ReplicationMode.sentinel));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot with correct config" {
    const slot = cache.cache_create(0, 1, 1000); // LRU, Primary, 1000 max keys
    try std.testing.expect(slot >= 0);
    defer cache.cache_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), cache.cache_eviction_policy(slot)); // LRU
    try std.testing.expectEqual(@as(u8, 1), cache.cache_replication_mode(slot)); // Primary
    try std.testing.expectEqual(@as(u32, 1000), cache.cache_max_keys(slot));
    try std.testing.expectEqual(@as(u32, 0), cache.cache_key_count(slot));
}

test "create rejects invalid eviction policy tag" {
    const slot = cache.cache_create(99, 0, 100);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid replication mode tag" {
    const slot = cache.cache_create(0, 99, 100);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    cache.cache_destroy(-1);
    cache.cache_destroy(999);
}

// =========================================================================
// Command execution
// =========================================================================

test "set increments key count" {
    const slot = cache.cache_create(0, 0, 0);
    defer cache.cache_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cache.cache_execute(slot, 1)); // Set
    try std.testing.expectEqual(@as(u8, 0), cache.cache_execute(slot, 1)); // Set
    try std.testing.expectEqual(@as(u32, 2), cache.cache_key_count(slot));
}

test "get on populated cache increments hits" {
    const slot = cache.cache_create(0, 0, 0);
    defer cache.cache_destroy(slot);

    _ = cache.cache_execute(slot, 1); // Set a key
    _ = cache.cache_execute(slot, 0); // Get
    try std.testing.expectEqual(@as(u32, 1), cache.cache_hits(slot));
    try std.testing.expectEqual(@as(u32, 0), cache.cache_misses(slot));
}

test "get on empty cache increments misses" {
    const slot = cache.cache_create(0, 0, 0);
    defer cache.cache_destroy(slot);

    _ = cache.cache_execute(slot, 0); // Get (empty)
    try std.testing.expectEqual(@as(u32, 0), cache.cache_hits(slot));
    try std.testing.expectEqual(@as(u32, 1), cache.cache_misses(slot));
}

test "delete decrements key count" {
    const slot = cache.cache_create(0, 0, 0);
    defer cache.cache_destroy(slot);

    _ = cache.cache_execute(slot, 1); // Set
    _ = cache.cache_execute(slot, 1); // Set
    try std.testing.expectEqual(@as(u8, 0), cache.cache_execute(slot, 2)); // Delete
    try std.testing.expectEqual(@as(u32, 1), cache.cache_key_count(slot));
}

test "delete on empty cache returns not_found error" {
    const slot = cache.cache_create(0, 0, 0);
    defer cache.cache_destroy(slot);

    const result = cache.cache_execute(slot, 2); // Delete
    try std.testing.expect(result > 0); // Error
}

test "flush clears all keys" {
    const slot = cache.cache_create(0, 0, 0);
    defer cache.cache_destroy(slot);

    _ = cache.cache_execute(slot, 1); // Set
    _ = cache.cache_execute(slot, 1); // Set
    _ = cache.cache_execute(slot, 1); // Set
    try std.testing.expectEqual(@as(u8, 0), cache.cache_execute(slot, 7)); // Flush
    try std.testing.expectEqual(@as(u32, 0), cache.cache_key_count(slot));
}

test "set rejects when no_eviction and full" {
    const slot = cache.cache_create(4, 0, 2); // NoEviction, max 2
    defer cache.cache_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cache.cache_execute(slot, 1)); // Set
    try std.testing.expectEqual(@as(u8, 0), cache.cache_execute(slot, 1)); // Set
    const result = cache.cache_execute(slot, 1); // Set (should fail)
    try std.testing.expect(result > 0); // out_of_memory error
}

test "invalid command tag rejected" {
    const slot = cache.cache_create(0, 0, 0);
    defer cache.cache_destroy(slot);

    try std.testing.expect(cache.cache_execute(slot, 99) > 0);
}

// =========================================================================
// Eviction policy changes
// =========================================================================

test "set_eviction changes policy" {
    const slot = cache.cache_create(0, 0, 0); // LRU
    defer cache.cache_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cache.cache_set_eviction(slot, 1)); // LFU
    try std.testing.expectEqual(@as(u8, 1), cache.cache_eviction_policy(slot));
}

test "set_eviction rejects invalid tag" {
    const slot = cache.cache_create(0, 0, 0);
    defer cache.cache_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), cache.cache_set_eviction(slot, 99));
}

// =========================================================================
// Capacity checks
// =========================================================================

test "is_full reports correctly" {
    const slot = cache.cache_create(0, 0, 2); // max 2 keys
    defer cache.cache_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), cache.cache_is_full(slot));
    _ = cache.cache_execute(slot, 1); // Set
    _ = cache.cache_execute(slot, 1); // Set
    try std.testing.expectEqual(@as(u8, 1), cache.cache_is_full(slot));
}

test "is_full returns 0 for unlimited cache" {
    const slot = cache.cache_create(0, 0, 0); // max_keys=0 => unlimited
    defer cache.cache_destroy(slot);

    _ = cache.cache_execute(slot, 1); // Set
    try std.testing.expectEqual(@as(u8, 0), cache.cache_is_full(slot));
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), cache.cache_eviction_policy(-1));
    try std.testing.expectEqual(@as(u8, 0), cache.cache_replication_mode(-1));
    try std.testing.expectEqual(@as(u32, 0), cache.cache_key_count(-1));
    try std.testing.expectEqual(@as(u32, 0), cache.cache_max_keys(-1));
    try std.testing.expectEqual(@as(u32, 0), cache.cache_hits(-1));
    try std.testing.expectEqual(@as(u32, 0), cache.cache_misses(-1));
    try std.testing.expectEqual(@as(u8, 0), cache.cache_is_full(-1));
}

// =========================================================================
// Incr/Decr/Append/Prepend/CAS on empty cache
// =========================================================================

test "incr on empty cache returns error" {
    const slot = cache.cache_create(0, 0, 0);
    defer cache.cache_destroy(slot);
    try std.testing.expect(cache.cache_execute(slot, 8) > 0); // Incr
}

test "cas on empty cache returns error" {
    const slot = cache.cache_create(0, 0, 0);
    defer cache.cache_destroy(slot);
    try std.testing.expect(cache.cache_execute(slot, 12) > 0); // CAS
}
