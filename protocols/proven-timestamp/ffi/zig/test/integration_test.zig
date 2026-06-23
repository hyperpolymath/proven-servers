// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-timestamp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (TimestampABI.Types parity)
//   - Hashing consistency + known-answer vectors (SHA3-256)
//   - Receipt creation (known receipt_hash)
//   - Hash-chain linking (previous_receipt_hash + whole-chain verify)
//   - Chain tamper detection
//   - Content verification success / failure
//   - Lifecycle state machine + stateless transition table
//   - Invalid slot safety

const std = @import("std");
const ts = @import("timestamp");

// Fixed SHA3-256 vectors (shared with src/Main.idr).
const CH_HELLO = "3338be694f50c5f338814986cdf0686453a888b84f424d792af4b9202398f392";
const CH_WORLD = "420baf620e3fcd9b3715b42b92506e9304d56e02d3a103499a3a292560cb66b2";
const RH0 = "f943110b734fe3ff9ac100ecf2bc5cd883e14ec5a4c220b61ebaa25cbd64ca84";
const RH1 = "876a1edc5fe50cefd7dbde74bea4552d5f120f8510a14e2f3dfd3fd79d09a9ef";
const GENESIS = "0000000000000000000000000000000000000000000000000000000000000000";

const SHA3: u8 = 2;

// =========================================================================
// ABI version + enum encodings
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ts.ts_abi_version());
}

test "HashAlgo encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ts.HashAlgo.sha256));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ts.HashAlgo.sha512_256));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ts.HashAlgo.sha3_256));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ts.HashAlgo.shake256));
}

test "TimestampSource encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ts.TimestampSource.internal));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ts.TimestampSource.rfc3161));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ts.TimestampSource.anchored));
}

test "VerificationResult encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ts.VerificationResult.verified));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ts.VerificationResult.content_mismatch));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ts.VerificationResult.chain_broken));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ts.VerificationResult.not_found));
}

test "ServerState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ts.ServerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ts.ServerState.active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ts.ServerState.sealed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ts.ServerState.shutdown));
}

// =========================================================================
// Hashing consistency
// =========================================================================

test "ts_hash is deterministic and matches the SHA3-256 vector" {
    var a: [64]u8 = undefined;
    var b: [64]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 64), ts.ts_hash(SHA3, "hello", 5, &a, 64));
    try std.testing.expectEqual(@as(i32, 64), ts.ts_hash(SHA3, "hello", 5, &b, 64));
    try std.testing.expectEqualStrings(CH_HELLO, &a);
    try std.testing.expectEqualStrings(&a, &b);
}

test "ts_hash rejects a too-small output buffer" {
    var small: [10]u8 = undefined;
    try std.testing.expectEqual(@as(i32, -1), ts.ts_hash(SHA3, "hello", 5, &small, small.len));
}

test "different algorithms give different digests" {
    var a: [64]u8 = undefined;
    var b: [64]u8 = undefined;
    _ = ts.ts_hash(0, "hello", 5, &a, 64); // sha-256
    _ = ts.ts_hash(2, "hello", 5, &b, 64); // sha3-256
    try std.testing.expect(!std.mem.eql(u8, &a, &b));
}

// =========================================================================
// Receipt creation + chain linking (known-answer)
// =========================================================================

fn appendReceipt(
    slot: c_int,
    content_hash: []const u8,
    created: []const u8,
    label: []const u8,
    reference: []const u8,
    out_id: *u64,
    out_hex: *[64]u8,
) u8 {
    return ts.ts_append(
        slot,
        SHA3,
        content_hash.ptr,
        @intCast(content_hash.len),
        created.ptr,
        @intCast(created.len),
        label.ptr,
        @intCast(label.len),
        reference.ptr,
        @intCast(reference.len),
        out_id,
        out_hex,
        64,
    );
}

test "ts_append creates the genesis receipt with the known receipt_hash" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);
    try std.testing.expect(slot >= 0);

    var id: u64 = 99;
    var rh: [64]u8 = undefined;
    const st = appendReceipt(slot, CH_HELLO, "2026-06-23T00:00:00Z", "", "", &id, &rh);
    try std.testing.expectEqual(@as(u8, 0), st); // ok
    try std.testing.expectEqual(@as(u64, 0), id);
    try std.testing.expectEqualStrings(RH0, &rh);
    try std.testing.expectEqual(@as(u32, 1), ts.ts_count(slot));
}

test "second receipt links to the first (known receipt_hash + prev pointer)" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);

    var id: u64 = 0;
    var rh0: [64]u8 = undefined;
    var rh1: [64]u8 = undefined;
    _ = appendReceipt(slot, CH_HELLO, "2026-06-23T00:00:00Z", "", "", &id, &rh0);
    const st = appendReceipt(slot, CH_WORLD, "2026-06-23T00:00:01Z", "minutes", "case-42", &id, &rh1);

    try std.testing.expectEqual(@as(u8, 0), st);
    try std.testing.expectEqual(@as(u64, 1), id);
    try std.testing.expectEqualStrings(RH1, &rh1);

    // previous_receipt_hash of receipt 1 must equal receipt 0's hash.
    var prev: [64]u8 = undefined;
    try std.testing.expectEqual(@as(i32, 64), ts.ts_get_prev_hash(slot, 1, &prev, 64));
    try std.testing.expectEqualStrings(RH0, &prev);

    // genesis receipt's previous pointer is the genesis constant.
    var prev0: [64]u8 = undefined;
    _ = ts.ts_get_prev_hash(slot, 0, &prev0, 64);
    try std.testing.expectEqualStrings(GENESIS, &prev0);
}

test "ts_verify_chain accepts a well-formed chain" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);

    var id: u64 = 0;
    var rh: [64]u8 = undefined;
    _ = appendReceipt(slot, CH_HELLO, "2026-06-23T00:00:00Z", "", "", &id, &rh);
    _ = appendReceipt(slot, CH_WORLD, "2026-06-23T00:00:01Z", "minutes", "case-42", &id, &rh);

    try std.testing.expectEqual(
        @intFromEnum(ts.VerificationResult.verified),
        ts.ts_verify_chain(slot),
    );
}

test "ts_verify_chain detects tampering with a stored receipt" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);

    var id: u64 = 0;
    var rh: [64]u8 = undefined;
    _ = appendReceipt(slot, CH_HELLO, "2026-06-23T00:00:00Z", "", "", &id, &rh);
    _ = appendReceipt(slot, CH_WORLD, "2026-06-23T00:00:01Z", "minutes", "case-42", &id, &rh);

    ts.testTamperContentHash(slot, 0); // corrupt the genesis receipt
    try std.testing.expectEqual(
        @intFromEnum(ts.VerificationResult.chain_broken),
        ts.ts_verify_chain(slot),
    );
}

test "ts_append is rejected when the content hash is the wrong length" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);
    var id: u64 = 0;
    var rh: [64]u8 = undefined;
    const st = appendReceipt(slot, "deadbeef", "2026-06-23T00:00:00Z", "", "", &id, &rh);
    try std.testing.expectEqual(@as(u8, 1), st); // rejected
}

test "ts_append is rejected when the log is not Active (sealed)" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ts.ts_seal(slot));
    var id: u64 = 0;
    var rh: [64]u8 = undefined;
    const st = appendReceipt(slot, CH_HELLO, "2026-06-23T00:00:00Z", "", "", &id, &rh);
    try std.testing.expectEqual(@as(u8, 1), st); // rejected
}

// =========================================================================
// Content verification
// =========================================================================

test "ts_verify_content succeeds for the original content" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);
    var id: u64 = 0;
    var rh: [64]u8 = undefined;
    _ = appendReceipt(slot, CH_HELLO, "2026-06-23T00:00:00Z", "", "", &id, &rh);

    try std.testing.expectEqual(
        @intFromEnum(ts.VerificationResult.verified),
        ts.ts_verify_content(slot, 0, SHA3, "hello", 5),
    );
}

test "ts_verify_content fails when the content changes" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);
    var id: u64 = 0;
    var rh: [64]u8 = undefined;
    _ = appendReceipt(slot, CH_HELLO, "2026-06-23T00:00:00Z", "", "", &id, &rh);

    try std.testing.expectEqual(
        @intFromEnum(ts.VerificationResult.content_mismatch),
        ts.ts_verify_content(slot, 0, SHA3, "HELLO", 5),
    );
}

test "ts_verify_content reports not_found for an unknown index" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);
    try std.testing.expectEqual(
        @intFromEnum(ts.VerificationResult.not_found),
        ts.ts_verify_content(slot, 7, SHA3, "hello", 5),
    );
}

// =========================================================================
// Lifecycle state machine
// =========================================================================

test "create starts Active; seal/reopen/shutdown/cleanup walk the FSM" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ts.ts_state(slot)); // Active
    try std.testing.expectEqual(@as(u8, 0), ts.ts_seal(slot));
    try std.testing.expectEqual(@as(u8, 2), ts.ts_state(slot)); // Sealed
    try std.testing.expectEqual(@as(u8, 0), ts.ts_reopen(slot));
    try std.testing.expectEqual(@as(u8, 1), ts.ts_state(slot)); // Active
    try std.testing.expectEqual(@as(u8, 0), ts.ts_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 3), ts.ts_state(slot)); // Shutdown
    try std.testing.expectEqual(@as(u8, 0), ts.ts_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), ts.ts_state(slot)); // Idle
}

test "cleanup clears the log" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);
    var id: u64 = 0;
    var rh: [64]u8 = undefined;
    _ = appendReceipt(slot, CH_HELLO, "2026-06-23T00:00:00Z", "", "", &id, &rh);
    _ = ts.ts_shutdown(slot);
    _ = ts.ts_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), ts.ts_count(slot));
}

test "reopen rejected from non-Sealed; shutdown rejected from Idle" {
    const slot = ts.ts_create("evidence", 8);
    defer ts.ts_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ts.ts_reopen(slot)); // Active, not Sealed
    _ = ts.ts_shutdown(slot);
    _ = ts.ts_cleanup(slot); // -> Idle
    try std.testing.expectEqual(@as(u8, 1), ts.ts_shutdown(slot)); // Idle can't shutdown
}

test "ts_can_transition matches Types.idr transitions" {
    try std.testing.expectEqual(@as(u8, 1), ts.ts_can_transition(0, 1)); // Idle -> Active
    try std.testing.expectEqual(@as(u8, 1), ts.ts_can_transition(1, 2)); // Active -> Sealed
    try std.testing.expectEqual(@as(u8, 1), ts.ts_can_transition(2, 1)); // Sealed -> Active
    try std.testing.expectEqual(@as(u8, 1), ts.ts_can_transition(1, 3)); // Active -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), ts.ts_can_transition(2, 3)); // Sealed -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), ts.ts_can_transition(3, 0)); // Shutdown -> Idle

    try std.testing.expectEqual(@as(u8, 0), ts.ts_can_transition(0, 3)); // Idle -/-> Shutdown
    try std.testing.expectEqual(@as(u8, 0), ts.ts_can_transition(3, 1)); // Shutdown -/-> Active
    try std.testing.expectEqual(@as(u8, 0), ts.ts_can_transition(0, 2)); // Idle -/-> Sealed
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "operations are safe on invalid slots" {
    try std.testing.expectEqual(@as(u8, 0), ts.ts_state(-1)); // idle fallback
    try std.testing.expectEqual(@as(u32, 0), ts.ts_count(-1));
    try std.testing.expectEqual(@as(u8, 1), ts.ts_seal(999));
    try std.testing.expectEqual(@as(i32, -1), ts.ts_get_receipt_hash(-1, 0, undefined, 0));
    try std.testing.expectEqual(
        @intFromEnum(ts.VerificationResult.not_found),
        ts.ts_verify_chain(-1),
    );
}

test "create rejects an empty name" {
    try std.testing.expectEqual(@as(c_int, -1), ts.ts_create("x", 0));
}
