// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// resolverconn_test.zig — Integration tests for proven-resolverconn FFI.

const std = @import("std");
const testing = std.testing;
const resolverconn = @import("resolverconn");

test "ABI version returns 1" {
    try testing.expectEqual(@as(u32, 1), resolverconn.resolverconn_abi_version());
}

test "create returns handle in ready state" {
    var err: resolverconn.ResolverError = .none;
    const h = resolverconn.resolverconn_create(null, 53, &err);
    try testing.expect(h != null);
    try testing.expectEqual(resolverconn.ResolverError.none, err);
    try testing.expectEqual(resolverconn.ResolverState.ready, resolverconn.resolverconn_state(h));
    resolverconn.resolverconn_destroy(h);
}

test "resolve A record succeeds from ready state" {
    var err: resolverconn.ResolverError = .none;
    const h = resolverconn.resolverconn_create(null, 53, &err).?;
    var buf_len: u32 = 0;
    var dnssec: resolverconn.DNSSECStatus = .indeterminate;
    const result = resolverconn.resolverconn_resolve(h, null, 0, .a, .use_cache, null, 0, &buf_len, &dnssec);
    try testing.expectEqual(resolverconn.ResolverError.none, result);
    try testing.expectEqual(resolverconn.ResolverState.ready, resolverconn.resolverconn_state(h));
    resolverconn.resolverconn_destroy(h);
}

test "cache_only returns nxdomain when cache empty" {
    var err: resolverconn.ResolverError = .none;
    const h = resolverconn.resolverconn_create(null, 53, &err).?;
    const result = resolverconn.resolverconn_resolve(h, null, 0, .aaaa, .cache_only, null, 0, null, null);
    try testing.expectEqual(resolverconn.ResolverError.nxdomain, result);
    resolverconn.resolverconn_destroy(h);
}

test "cache_flush from ready succeeds" {
    var err: resolverconn.ResolverError = .none;
    const h = resolverconn.resolverconn_create(null, 53, &err).?;
    const result = resolverconn.resolverconn_cache_flush(h);
    try testing.expectEqual(resolverconn.ResolverError.none, result);
    resolverconn.resolverconn_destroy(h);
}

test "NULL handle safety" {
    try testing.expectEqual(resolverconn.ResolverState.failed, resolverconn.resolverconn_state(null));
    try testing.expect(resolverconn.resolverconn_resolve(null, null, 0, .a, .use_cache, null, 0, null, null) != resolverconn.ResolverError.none);
    try testing.expect(resolverconn.resolverconn_reset(null) != resolverconn.ResolverError.none);
    try testing.expect(resolverconn.resolverconn_cache_flush(null) != resolverconn.ResolverError.none);
    resolverconn.resolverconn_destroy(null); // must not crash
}

test "RecordType enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(resolverconn.RecordType.a));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(resolverconn.RecordType.aaaa));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(resolverconn.RecordType.cname));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(resolverconn.RecordType.mx));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(resolverconn.RecordType.txt));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(resolverconn.RecordType.srv));
    try testing.expectEqual(@as(u8, 6), @intFromEnum(resolverconn.RecordType.ns));
    try testing.expectEqual(@as(u8, 7), @intFromEnum(resolverconn.RecordType.soa));
    try testing.expectEqual(@as(u8, 8), @intFromEnum(resolverconn.RecordType.ptr));
    try testing.expectEqual(@as(u8, 9), @intFromEnum(resolverconn.RecordType.caa));
    try testing.expectEqual(@as(u8, 10), @intFromEnum(resolverconn.RecordType.tlsa));
    try testing.expectEqual(@as(u8, 11), @intFromEnum(resolverconn.RecordType.svcb));
    try testing.expectEqual(@as(u8, 12), @intFromEnum(resolverconn.RecordType.https));
}

test "ResolverState enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(resolverconn.ResolverState.ready));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(resolverconn.ResolverState.querying));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(resolverconn.ResolverState.cached));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(resolverconn.ResolverState.failed));
}

test "DNSSECStatus enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(resolverconn.DNSSECStatus.secure));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(resolverconn.DNSSECStatus.insecure));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(resolverconn.DNSSECStatus.bogus));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(resolverconn.DNSSECStatus.indeterminate));
}

test "ResolverError enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(resolverconn.ResolverError.none));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(resolverconn.ResolverError.nxdomain));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(resolverconn.ResolverError.server_failure));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(resolverconn.ResolverError.refused));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(resolverconn.ResolverError.timeout));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(resolverconn.ResolverError.dnssec_validation_failed));
    try testing.expectEqual(@as(u8, 6), @intFromEnum(resolverconn.ResolverError.network_unreachable));
    try testing.expectEqual(@as(u8, 7), @intFromEnum(resolverconn.ResolverError.truncated_response));
}

test "CachePolicy enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(resolverconn.CachePolicy.use_cache));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(resolverconn.CachePolicy.bypass_cache));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(resolverconn.CachePolicy.cache_only));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(resolverconn.CachePolicy.refresh_cache));
}
