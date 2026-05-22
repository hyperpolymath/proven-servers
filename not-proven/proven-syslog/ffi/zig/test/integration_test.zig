// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig — Integration tests for the proven-syslog FFI.
//
// Tests cover:
//   - ABI version check
//   - Collector lifecycle (create, destroy, state queries)
//   - Transport protocol management
//   - Message ingestion with facility/severity tracking
//   - Priority computation (facility * 8 + severity)
//   - Severity-based message filtering
//   - Drop counting
//   - Stateless priority computation
//   - Edge cases (invalid slots, double destroy, etc.)

const std = @import("std");
const syslog = @import("syslog");
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;

// ── ABI Version ─────────────────────────────────────────────────────────

test "abi version returns 1" {
    try expectEqual(@as(u32, 1), syslog.syslog_abi_version());
}

// ── Create and Destroy ──────────────────────────────────────────────────

test "create returns valid slot" {
    const slot = syslog.syslog_create(0); // UDP/514
    try expect(slot >= 0);
    syslog.syslog_destroy(slot);
}

test "create with invalid transport returns -1" {
    const slot = syslog.syslog_create(99);
    try expectEqual(@as(c_int, -1), slot);
}

test "destroy invalid slot is safe" {
    syslog.syslog_destroy(-1);
    syslog.syslog_destroy(999);
}

test "double destroy is safe" {
    const slot = syslog.syslog_create(0);
    syslog.syslog_destroy(slot);
    syslog.syslog_destroy(slot);
}

// ── State Queries on Fresh Collector ────────────────────────────────────

test "fresh collector has specified transport" {
    const slot = syslog.syslog_create(2); // TLS/6514
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 2), syslog.syslog_get_transport(slot));
}

test "fresh collector has zero message count" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u32, 0), syslog.syslog_get_message_count(slot));
}

test "fresh collector has no last facility (255)" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 255), syslog.syslog_get_last_facility(slot));
}

test "fresh collector has no last severity (255)" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 255), syslog.syslog_get_last_severity(slot));
}

test "fresh collector has invalid priority (0xFFFFFFFF)" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u32, 0xFFFFFFFF), syslog.syslog_get_last_priority(slot));
}

test "fresh collector has Debug min severity (7)" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 7), syslog.syslog_get_min_severity(slot));
}

test "fresh collector has zero dropped count" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u32, 0), syslog.syslog_get_dropped_count(slot));
}

// ── Queries on Invalid Slot ─────────────────────────────────────────────

test "get_transport on invalid slot returns 0" {
    try expectEqual(@as(u8, 0), syslog.syslog_get_transport(-1));
}

test "get_message_count on invalid slot returns 0" {
    try expectEqual(@as(u32, 0), syslog.syslog_get_message_count(-1));
}

test "get_last_facility on invalid slot returns 255" {
    try expectEqual(@as(u8, 255), syslog.syslog_get_last_facility(-1));
}

test "get_last_priority on invalid slot returns 0xFFFFFFFF" {
    try expectEqual(@as(u32, 0xFFFFFFFF), syslog.syslog_get_last_priority(-1));
}

// ── Transport Management ────────────────────────────────────────────────

test "set transport succeeds" {
    const slot = syslog.syslog_create(0); // UDP/514
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 0), syslog.syslog_set_transport(slot, 2)); // TLS/6514
    try expectEqual(@as(u8, 2), syslog.syslog_get_transport(slot));
}

test "set invalid transport fails" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 5), syslog.syslog_set_transport(slot, 99)); // InvalidTransport
}

test "set transport on invalid slot fails" {
    try expectEqual(@as(u8, 1), syslog.syslog_set_transport(-1, 0)); // InvalidSlot
}

// ── Message Ingestion ───────────────────────────────────────────────────

test "ingest message tracks facility and severity" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 0), syslog.syslog_ingest(slot, 3, 2)); // daemon.crit
    try expectEqual(@as(u8, 3), syslog.syslog_get_last_facility(slot)); // Daemon
    try expectEqual(@as(u8, 2), syslog.syslog_get_last_severity(slot)); // Critical
    try expectEqual(@as(u32, 1), syslog.syslog_get_message_count(slot));
}

test "ingest computes correct priority" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    // kern.emergency = 0*8+0 = 0
    _ = syslog.syslog_ingest(slot, 0, 0);
    try expectEqual(@as(u32, 0), syslog.syslog_get_last_priority(slot));
    // local7.debug = 23*8+7 = 191
    _ = syslog.syslog_ingest(slot, 23, 7);
    try expectEqual(@as(u32, 191), syslog.syslog_get_last_priority(slot));
    // auth.warning = 4*8+4 = 36
    _ = syslog.syslog_ingest(slot, 4, 4);
    try expectEqual(@as(u32, 36), syslog.syslog_get_last_priority(slot));
}

test "ingest invalid facility fails" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 3), syslog.syslog_ingest(slot, 99, 0)); // InvalidFacility
}

test "ingest invalid severity fails" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 4), syslog.syslog_ingest(slot, 0, 99)); // InvalidSeverity
}

test "ingest on invalid slot fails" {
    try expectEqual(@as(u8, 1), syslog.syslog_ingest(-1, 0, 0)); // InvalidSlot
}

test "multiple ingestions increment count" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    _ = syslog.syslog_ingest(slot, 0, 0);
    _ = syslog.syslog_ingest(slot, 1, 1);
    _ = syslog.syslog_ingest(slot, 2, 2);
    try expectEqual(@as(u32, 3), syslog.syslog_get_message_count(slot));
}

// ── Severity Filtering ──────────────────────────────────────────────────

test "set min severity succeeds" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 0), syslog.syslog_set_min_severity(slot, 3)); // Error
    try expectEqual(@as(u8, 3), syslog.syslog_get_min_severity(slot));
}

test "set invalid min severity fails" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    try expectEqual(@as(u8, 4), syslog.syslog_set_min_severity(slot, 99)); // InvalidSeverity
}

test "filter drops messages less severe than threshold" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    _ = syslog.syslog_set_min_severity(slot, 3); // Only Error and above

    // Emergency (0) passes
    try expectEqual(@as(u8, 0), syslog.syslog_ingest(slot, 0, 0));
    // Error (3) passes
    try expectEqual(@as(u8, 0), syslog.syslog_ingest(slot, 0, 3));
    // Warning (4) filtered
    try expectEqual(@as(u8, 6), syslog.syslog_ingest(slot, 0, 4)); // Filtered
    // Debug (7) filtered
    try expectEqual(@as(u8, 6), syslog.syslog_ingest(slot, 0, 7)); // Filtered

    try expectEqual(@as(u32, 4), syslog.syslog_get_message_count(slot)); // All counted
    try expectEqual(@as(u32, 2), syslog.syslog_get_dropped_count(slot)); // 2 dropped
}

test "filter set to Emergency only passes Emergency" {
    const slot = syslog.syslog_create(0);
    defer syslog.syslog_destroy(slot);
    _ = syslog.syslog_set_min_severity(slot, 0); // Emergency only

    try expectEqual(@as(u8, 0), syslog.syslog_ingest(slot, 0, 0)); // Passes
    try expectEqual(@as(u8, 6), syslog.syslog_ingest(slot, 0, 1)); // Alert filtered
    try expectEqual(@as(u8, 6), syslog.syslog_ingest(slot, 0, 7)); // Debug filtered

    try expectEqual(@as(u32, 2), syslog.syslog_get_dropped_count(slot));
}

// ── Stateless Priority Computation ──────────────────────────────────────

test "compute_priority: kern.emergency = 0" {
    try expectEqual(@as(u32, 0), syslog.syslog_compute_priority(0, 0));
}

test "compute_priority: local7.debug = 191" {
    try expectEqual(@as(u32, 191), syslog.syslog_compute_priority(23, 7));
}

test "compute_priority: auth.warning = 36" {
    try expectEqual(@as(u32, 36), syslog.syslog_compute_priority(4, 4));
}

test "compute_priority: mail.info = 22" {
    try expectEqual(@as(u32, 22), syslog.syslog_compute_priority(2, 6));
}

test "compute_priority: invalid facility returns 0xFFFFFFFF" {
    try expectEqual(@as(u32, 0xFFFFFFFF), syslog.syslog_compute_priority(24, 0));
    try expectEqual(@as(u32, 0xFFFFFFFF), syslog.syslog_compute_priority(99, 0));
}

test "compute_priority: invalid severity returns 0xFFFFFFFF" {
    try expectEqual(@as(u32, 0xFFFFFFFF), syslog.syslog_compute_priority(0, 8));
    try expectEqual(@as(u32, 0xFFFFFFFF), syslog.syslog_compute_priority(0, 99));
}

// ── Full Lifecycle ──────────────────────────────────────────────────────

test "full collector lifecycle: create, configure, ingest, filter, destroy" {
    const slot = syslog.syslog_create(1); // TCP/514
    defer syslog.syslog_destroy(slot);

    // Configure: only Warning and above
    try expectEqual(@as(u8, 0), syslog.syslog_set_min_severity(slot, 4));

    // Ingest messages
    try expectEqual(@as(u8, 0), syslog.syslog_ingest(slot, 4, 0)); // auth.emerg -> passes
    try expectEqual(@as(u8, 0), syslog.syslog_ingest(slot, 3, 4)); // daemon.warning -> passes
    try expectEqual(@as(u8, 6), syslog.syslog_ingest(slot, 1, 6)); // user.info -> filtered
    try expectEqual(@as(u8, 6), syslog.syslog_ingest(slot, 0, 7)); // kern.debug -> filtered

    try expectEqual(@as(u32, 4), syslog.syslog_get_message_count(slot));
    try expectEqual(@as(u32, 2), syslog.syslog_get_dropped_count(slot));

    // Upgrade transport to TLS
    try expectEqual(@as(u8, 0), syslog.syslog_set_transport(slot, 2));
    try expectEqual(@as(u8, 2), syslog.syslog_get_transport(slot));

    // Verify last message info
    try expectEqual(@as(u8, 0), syslog.syslog_get_last_facility(slot)); // Kern
    try expectEqual(@as(u8, 7), syslog.syslog_get_last_severity(slot)); // Debug
    // kern.debug priority = 0*8+7 = 7
    try expectEqual(@as(u32, 7), syslog.syslog_get_last_priority(slot));
}
