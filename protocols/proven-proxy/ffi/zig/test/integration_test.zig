// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig — Integration tests for the proven-proxy FFI.
//
// Tests cover:
//   - ABI version check
//   - Proxy lifecycle (create, destroy, mode queries)
//   - Forward and Reverse mode creation
//   - Cache directive management
//   - Hop-by-hop header stripping validation
//   - Request and cache hit tracking
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const proxy = @import("proxy");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), proxy.proxy_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create forward proxy returns valid slot" {
    const slot = proxy.proxy_create(0); // Forward
    try expect(slot >= 0);
    proxy.proxy_destroy(slot);
}

test "create reverse proxy returns valid slot" {
    const slot = proxy.proxy_create(1); // Reverse
    try expect(slot >= 0);
    proxy.proxy_destroy(slot);
}

test "create with invalid mode returns -1" {
    const slot = proxy.proxy_create(99);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    proxy.proxy_destroy(-1);
    proxy.proxy_destroy(999);
}

test "double destroy is safe" {
    const slot = proxy.proxy_create(0);
    proxy.proxy_destroy(slot);
    proxy.proxy_destroy(slot);
}

// ── State Queries on Fresh Proxy ────────────────────────────────────────

test "fresh forward proxy has Forward mode" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 0), proxy.proxy_get_mode(slot)); // Forward
}

test "fresh reverse proxy has Reverse mode" {
    const slot = proxy.proxy_create(1);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 1), proxy.proxy_get_mode(slot)); // Reverse
}

test "fresh proxy has NoCache directive" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 0), proxy.proxy_get_cache_directive(slot)); // NoCache
}

test "fresh proxy has zero request count" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u32, 0), proxy.proxy_get_request_count(slot));
}

test "fresh proxy has zero cache hits" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u32, 0), proxy.proxy_get_cache_hits(slot));
}

test "fresh proxy has no error (255)" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 255), proxy.proxy_get_last_error(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_mode on invalid slot returns Forward" {
    try expectEqual(@as(u8, 0), proxy.proxy_get_mode(-1));
}

test "get_last_error on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), proxy.proxy_get_last_error(-1));
}

// ── Cache Directive Management ──────────────────────────────────────────

test "set cache directive to MaxAge" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 0), proxy.proxy_set_cache_directive(slot, 2)); // MaxAge
    try expectEqual(@as(u8, 2), proxy.proxy_get_cache_directive(slot));
}

test "set cache directive to Public" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 0), proxy.proxy_set_cache_directive(slot, 3)); // Public
    try expectEqual(@as(u8, 3), proxy.proxy_get_cache_directive(slot));
}

test "set cache directive to MustRevalidate" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 0), proxy.proxy_set_cache_directive(slot, 5)); // MustRevalidate
    try expectEqual(@as(u8, 5), proxy.proxy_get_cache_directive(slot));
}

test "set cache directive with invalid value fails" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 4), proxy.proxy_set_cache_directive(slot, 99)); // CacheError
}

test "set cache directive on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), proxy.proxy_set_cache_directive(-1, 0));
}

// ── Hop-by-hop Header Checking ──────────────────────────────────────────

test "Connection header must be stripped" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 1), proxy.proxy_check_hop_header(slot, 0)); // Connection
}

test "KeepAlive header must be stripped" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 1), proxy.proxy_check_hop_header(slot, 1)); // KeepAlive
}

test "Transfer-Encoding header must be stripped" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 1), proxy.proxy_check_hop_header(slot, 6)); // TransferEncoding
}

test "Upgrade header must be stripped" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 1), proxy.proxy_check_hop_header(slot, 7)); // Upgrade
}

test "all 8 hop-by-hop headers must be stripped" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    var i: u8 = 0;
    while (i <= 7) : (i += 1) {
        try expectEqual(@as(u8, 1), proxy.proxy_check_hop_header(slot, i));
    }
}

test "non-hop-by-hop header passes through" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 0), proxy.proxy_check_hop_header(slot, 8)); // Not a hop-by-hop header
    try expectEqual(@as(u8, 0), proxy.proxy_check_hop_header(slot, 255));
}

// ── Request and Cache Hit Tracking ──────────────────────────────────────

test "record request increments count" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 0), proxy.proxy_record_request(slot));
    try expectEqual(@as(u32, 1), proxy.proxy_get_request_count(slot));
    try expectEqual(@as(u8, 0), proxy.proxy_record_request(slot));
    try expectEqual(@as(u32, 2), proxy.proxy_get_request_count(slot));
}

test "record cache hit increments count" {
    const slot = proxy.proxy_create(0);
    defer proxy.proxy_destroy(slot);
    try expectEqual(@as(u8, 0), proxy.proxy_record_cache_hit(slot));
    try expectEqual(@as(u32, 1), proxy.proxy_get_cache_hits(slot));
}

test "record request on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), proxy.proxy_record_request(-1));
}

test "record cache hit on invalid slot returns InvalidSlot" {
    try expectEqual(@as(u8, 1), proxy.proxy_record_cache_hit(-1));
}

// ── Full Proxy Lifecycle ────────────────────────────────────────────────

test "full lifecycle: create, configure, proxy requests, cache hits" {
    const slot = proxy.proxy_create(1); // Reverse proxy
    defer proxy.proxy_destroy(slot);

    // Configure cache
    try expectEqual(@as(u8, 0), proxy.proxy_set_cache_directive(slot, 3)); // Public

    // Proxy some requests
    _ = proxy.proxy_record_request(slot);
    _ = proxy.proxy_record_request(slot);
    _ = proxy.proxy_record_request(slot);

    // Record cache hits
    _ = proxy.proxy_record_cache_hit(slot);
    _ = proxy.proxy_record_cache_hit(slot);

    try expectEqual(@as(u32, 3), proxy.proxy_get_request_count(slot));
    try expectEqual(@as(u32, 2), proxy.proxy_get_cache_hits(slot));
    try expectEqual(@as(u8, 1), proxy.proxy_get_mode(slot)); // Still Reverse
}
