// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-ctlog FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Session lifecycle (create/destroy)
//   - Entry submission (accept/reject/rate-limit)
//   - Merge/Sign lifecycle
//   - Inclusion proof verification
//   - Consistency proof verification
//   - Shutdown / Cleanup
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const ctlog = @import("ctlog");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ctlog.ctlog_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "LogEntryType encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ctlog.LogEntryType.x509_entry));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ctlog.LogEntryType.precert_entry));
}

test "SignatureType encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ctlog.SignatureType.certificate_timestamp));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ctlog.SignatureType.tree_hash));
}

test "MerkleLeafType encoding matches Types.idr (1 tag)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ctlog.MerkleLeafType.timestamped_entry));
}

test "SubmissionStatus encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ctlog.SubmissionStatus.accepted));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ctlog.SubmissionStatus.duplicate));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ctlog.SubmissionStatus.rate_limited));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ctlog.SubmissionStatus.rejected));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ctlog.SubmissionStatus.invalid_chain));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ctlog.SubmissionStatus.unknown_anchor));
}

test "VerificationResult encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ctlog.VerificationResult.valid_proof));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ctlog.VerificationResult.invalid_proof));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ctlog.VerificationResult.inconsistent_tree));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ctlog.VerificationResult.stale_sth));
}

test "ServerState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ctlog.ServerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ctlog.ServerState.active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ctlog.ServerState.merging));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ctlog.ServerState.signing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ctlog.ServerState.shutdown));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Active state" {
    const name = "test-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    try std.testing.expect(slot >= 0);
    defer ctlog.ctlog_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_state(slot)); // Active
}

test "create rejects empty name" {
    const name = "x";
    const slot = ctlog.ctlog_create(name.ptr, 0, 1024);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    ctlog.ctlog_destroy(-1);
    ctlog.ctlog_destroy(999);
}

// =========================================================================
// Entry submission
// =========================================================================

test "submit accepts valid X.509 entry" {
    const name = "submit-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    const cert = "fake-cert-data";
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_submit(slot, 0, cert.ptr, cert.len)); // accepted
    try std.testing.expectEqual(@as(u32, 1), ctlog.ctlog_entry_count(slot));
}

test "submit accepts precert entry" {
    const name = "precert-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    const cert = "fake-precert";
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_submit(slot, 1, cert.ptr, cert.len)); // accepted
}

test "submit rejects invalid entry type" {
    const name = "badtype-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    const cert = "data";
    try std.testing.expectEqual(@as(u8, 3), ctlog.ctlog_submit(slot, 99, cert.ptr, cert.len)); // rejected
}

test "submit rejects when not in Active state" {
    const name = "notactive-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    _ = ctlog.ctlog_begin_merge(slot); // -> Merging
    const cert = "data";
    try std.testing.expectEqual(@as(u8, 3), ctlog.ctlog_submit(slot, 0, cert.ptr, cert.len)); // rejected
}

// =========================================================================
// Merge / Sign lifecycle
// =========================================================================

test "begin_merge transitions Active -> Merging" {
    const name = "merge-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_begin_merge(slot));
    try std.testing.expectEqual(@as(u8, 2), ctlog.ctlog_state(slot)); // Merging
}

test "finish_merge integrates entries and transitions to Signing" {
    const name = "finishmerge-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    // Submit two entries
    const cert = "cert-data";
    _ = ctlog.ctlog_submit(slot, 0, cert.ptr, cert.len);
    _ = ctlog.ctlog_submit(slot, 1, cert.ptr, cert.len);
    try std.testing.expectEqual(@as(u32, 0), ctlog.ctlog_tree_size(slot)); // Not merged yet

    _ = ctlog.ctlog_begin_merge(slot);
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_finish_merge(slot));
    try std.testing.expectEqual(@as(u32, 2), ctlog.ctlog_tree_size(slot)); // Merged
    try std.testing.expectEqual(@as(u8, 3), ctlog.ctlog_state(slot)); // Signing
}

test "sign_sth transitions Signing -> Active" {
    const name = "sign-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    _ = ctlog.ctlog_begin_merge(slot);
    _ = ctlog.ctlog_finish_merge(slot);
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_sign_sth(slot));
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_state(slot)); // Active
}

test "begin_merge rejects from non-Active state" {
    const name = "badmerge-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    _ = ctlog.ctlog_begin_merge(slot); // -> Merging
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_begin_merge(slot)); // rejected
}

test "sign_sth rejects from non-Signing state" {
    const name = "badsign-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_sign_sth(slot)); // rejected (Active != Signing)
}

// =========================================================================
// Verification
// =========================================================================

test "verify_inclusion succeeds for merged entry" {
    const name = "inclusion-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    const cert = "cert";
    _ = ctlog.ctlog_submit(slot, 0, cert.ptr, cert.len);
    _ = ctlog.ctlog_begin_merge(slot);
    _ = ctlog.ctlog_finish_merge(slot);
    _ = ctlog.ctlog_sign_sth(slot);

    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_verify_inclusion(slot, 0)); // valid_proof
}

test "verify_inclusion fails for out-of-range index" {
    const name = "bad-inclusion-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_verify_inclusion(slot, 999)); // invalid_proof
}

test "verify_consistency succeeds for valid range" {
    const name = "consistency-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    const cert = "cert";
    _ = ctlog.ctlog_submit(slot, 0, cert.ptr, cert.len);
    _ = ctlog.ctlog_submit(slot, 0, cert.ptr, cert.len);
    _ = ctlog.ctlog_begin_merge(slot);
    _ = ctlog.ctlog_finish_merge(slot);
    _ = ctlog.ctlog_sign_sth(slot);

    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_verify_consistency(slot, 0, 2)); // valid
}

test "verify_consistency detects inconsistent tree (old > new)" {
    const name = "inconsistent-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    const cert = "cert";
    _ = ctlog.ctlog_submit(slot, 0, cert.ptr, cert.len);
    _ = ctlog.ctlog_begin_merge(slot);
    _ = ctlog.ctlog_finish_merge(slot);
    _ = ctlog.ctlog_sign_sth(slot);

    try std.testing.expectEqual(@as(u8, 2), ctlog.ctlog_verify_consistency(slot, 5, 1)); // inconsistent
}

test "verify_consistency detects stale STH" {
    const name = "stale-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    try std.testing.expectEqual(@as(u8, 3), ctlog.ctlog_verify_consistency(slot, 0, 100)); // stale
}

// =========================================================================
// Shutdown / Cleanup
// =========================================================================

test "shutdown transitions Active -> Shutdown" {
    const name = "shutdown-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_shutdown(slot));
    try std.testing.expectEqual(@as(u8, 4), ctlog.ctlog_state(slot)); // Shutdown
}

test "cleanup transitions Shutdown -> Idle" {
    const name = "cleanup-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    _ = ctlog.ctlog_shutdown(slot);
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_state(slot)); // Idle
}

test "cleanup clears entries and tree size" {
    const name = "clearcleanup-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    const cert = "cert";
    _ = ctlog.ctlog_submit(slot, 0, cert.ptr, cert.len);
    _ = ctlog.ctlog_begin_merge(slot);
    _ = ctlog.ctlog_finish_merge(slot);
    _ = ctlog.ctlog_sign_sth(slot);

    _ = ctlog.ctlog_shutdown(slot);
    _ = ctlog.ctlog_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), ctlog.ctlog_entry_count(slot));
    try std.testing.expectEqual(@as(u32, 0), ctlog.ctlog_tree_size(slot));
}

test "cleanup rejected from non-Shutdown state" {
    const name = "badcleanup-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_cleanup(slot)); // rejected
}

test "shutdown rejected from Idle" {
    const name = "badshutdown-log";
    const slot = ctlog.ctlog_create(name.ptr, name.len, 1024);
    defer ctlog.ctlog_destroy(slot);

    _ = ctlog.ctlog_shutdown(slot);
    _ = ctlog.ctlog_cleanup(slot);
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_shutdown(slot)); // rejected
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "ctlog_can_transition matches Types.idr transitions" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_can_transition(0, 1)); // Idle -> Active
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_can_transition(1, 2)); // Active -> Merging
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_can_transition(2, 1)); // Merging -> Active
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_can_transition(2, 3)); // Merging -> Signing
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_can_transition(3, 1)); // Signing -> Active
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_can_transition(1, 4)); // Active -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_can_transition(2, 4)); // Merging -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_can_transition(3, 4)); // Signing -> Shutdown
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_can_transition(4, 0)); // Shutdown -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_can_transition(0, 2)); // Idle -/-> Merging
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_can_transition(0, 3)); // Idle -/-> Signing
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_can_transition(4, 1)); // Shutdown -/-> Active
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_can_transition(0, 4)); // Idle -/-> Shutdown
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), ctlog.ctlog_state(-1));
    try std.testing.expectEqual(@as(u32, 0), ctlog.ctlog_entry_count(-1));
    try std.testing.expectEqual(@as(u32, 0), ctlog.ctlog_tree_size(-1));
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_shutdown(-1));
    try std.testing.expectEqual(@as(u8, 1), ctlog.ctlog_cleanup(-1));
}
