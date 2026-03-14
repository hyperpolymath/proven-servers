// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// audit_test.zig — Integration tests for proven-audit FFI.
//
// Tests the C-ABI contract between Idris2 proofs and Zig implementation.
// Every test here has a corresponding formal proof in Transitions.idr.

const std = @import("std");
const audit = @import("audit");

// ═══════════════════════════════════════════════════════════════════════
// ABI version seam
// ═══════════════════════════════════════════════════════════════════════

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), audit.audit_abi_version());
}

// ═══════════════════════════════════════════════════════════════════════
// Enum encoding seams (must match Layout.idr tag assignments)
// ═══════════════════════════════════════════════════════════════════════

test "AuditLevel encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(audit.AuditLevel.none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(audit.AuditLevel.minimal));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(audit.AuditLevel.standard));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(audit.AuditLevel.verbose));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(audit.AuditLevel.full));
}

test "EventCategory encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(audit.EventCategory.state_transition));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(audit.EventCategory.authentication));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(audit.EventCategory.authorization));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(audit.EventCategory.data_access));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(audit.EventCategory.configuration));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(audit.EventCategory.err));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(audit.EventCategory.security));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(audit.EventCategory.lifecycle));
}

test "Integrity encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(audit.Integrity.unsigned_));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(audit.Integrity.hmac));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(audit.Integrity.signed_));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(audit.Integrity.chained));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(audit.Integrity.merkle_proof));
}

test "RetentionPolicy encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(audit.RetentionPolicy.ephemeral));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(audit.RetentionPolicy.session));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(audit.RetentionPolicy.daily));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(audit.RetentionPolicy.indefinite));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(audit.RetentionPolicy.regulatory));
}

test "AuditError encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(audit.AuditError.storage_full));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(audit.AuditError.write_failure));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(audit.AuditError.integrity_violation));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(audit.AuditError.timestamp_error));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(audit.AuditError.chain_broken));
}

test "AuditTrailState encoding matches Transitions.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(audit.AuditTrailState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(audit.AuditTrailState.recording));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(audit.AuditTrailState.sealed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(audit.AuditTrailState.archived));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(audit.AuditTrailState.failed));
}

// ═══════════════════════════════════════════════════════════════════════
// Lifecycle tests
// ═══════════════════════════════════════════════════════════════════════

test "create returns valid slot" {
    const slot = audit.audit_create(2, 0, 1); // standard, unsigned, session
    try std.testing.expect(slot >= 0);
    defer audit.audit_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), audit.audit_state(slot)); // idle
}

test "create stores configuration" {
    const slot = audit.audit_create(3, 2, 4); // verbose, signed, regulatory
    try std.testing.expect(slot >= 0);
    defer audit.audit_destroy(slot);
    try std.testing.expectEqual(@as(u8, 3), audit.audit_level(slot)); // verbose
    try std.testing.expectEqual(@as(u8, 2), audit.audit_integrity(slot)); // signed
    try std.testing.expectEqual(@as(u8, 4), audit.audit_retention(slot)); // regulatory
}

test "create rejects invalid level" {
    try std.testing.expectEqual(@as(c_int, -1), audit.audit_create(99, 0, 0));
}

test "create rejects invalid integrity" {
    try std.testing.expectEqual(@as(c_int, -1), audit.audit_create(0, 99, 0));
}

test "create rejects invalid retention" {
    try std.testing.expectEqual(@as(c_int, -1), audit.audit_create(0, 0, 99));
}

test "destroy makes slot reusable" {
    const slot1 = audit.audit_create(0, 0, 0);
    try std.testing.expect(slot1 >= 0);
    audit.audit_destroy(slot1);

    const slot2 = audit.audit_create(0, 0, 0);
    try std.testing.expect(slot2 >= 0);
    defer audit.audit_destroy(slot2);
    try std.testing.expectEqual(slot1, slot2);
}

test "destroy is safe with invalid slot" {
    audit.audit_destroy(-1);
    audit.audit_destroy(999);
    // No crash = pass
}

// ═══════════════════════════════════════════════════════════════════════
// Valid transition tests (matching Transitions.idr ValidAuditTransition)
// ═══════════════════════════════════════════════════════════════════════

test "Open: Idle -> Recording" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), audit.audit_open(slot)); // accepted
    try std.testing.expectEqual(@as(u8, 1), audit.audit_state(slot)); // recording
}

test "Seal: Recording -> Sealed" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    try std.testing.expectEqual(@as(u8, 0), audit.audit_seal(slot)); // accepted
    try std.testing.expectEqual(@as(u8, 2), audit.audit_state(slot)); // sealed
}

test "Archive: Sealed -> Archived" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    _ = audit.audit_seal(slot);
    try std.testing.expectEqual(@as(u8, 0), audit.audit_archive(slot)); // accepted
    try std.testing.expectEqual(@as(u8, 3), audit.audit_state(slot)); // archived
}

test "FailRecording + ResetFailed" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    try std.testing.expectEqual(@as(u8, 0), audit.audit_fail(slot, 1)); // write_failure
    try std.testing.expectEqual(@as(u8, 4), audit.audit_state(slot)); // failed
    try std.testing.expectEqual(@as(u8, 1), audit.audit_last_error(slot)); // write_failure
    try std.testing.expectEqual(@as(u8, 0), audit.audit_reset(slot)); // accepted
    try std.testing.expectEqual(@as(u8, 0), audit.audit_state(slot)); // idle
}

test "ResetSealed: Sealed -> Idle" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    _ = audit.audit_seal(slot);
    try std.testing.expectEqual(@as(u8, 0), audit.audit_reset(slot)); // accepted
    try std.testing.expectEqual(@as(u8, 0), audit.audit_state(slot)); // idle
}

test "ResetArchived: Archived -> Idle" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    _ = audit.audit_seal(slot);
    _ = audit.audit_archive(slot);
    try std.testing.expectEqual(@as(u8, 0), audit.audit_reset(slot)); // accepted
    try std.testing.expectEqual(@as(u8, 0), audit.audit_state(slot)); // idle
}

// ═══════════════════════════════════════════════════════════════════════
// Invalid transition tests (matching Transitions.idr impossibility proofs)
// ═══════════════════════════════════════════════════════════════════════

test "cannot open a recording trail (recordingCannotReopen)" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_open(slot)); // rejected
}

test "cannot seal an idle trail (idleCannotSeal)" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_seal(slot)); // rejected
}

test "cannot archive a recording trail (recordingCannotArchive)" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_archive(slot)); // rejected
}

test "sealed trail cannot reopen (sealedCannotRecord)" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    _ = audit.audit_seal(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_open(slot)); // rejected
}

test "archived trail cannot reopen (archivedCannotRecord)" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    _ = audit.audit_seal(slot);
    _ = audit.audit_archive(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_open(slot)); // rejected
}

test "cannot fail an idle trail" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_fail(slot, 0)); // rejected
}

test "cannot reset from idle" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_reset(slot)); // rejected
}

test "cannot reset from recording" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_reset(slot)); // rejected
}

test "cannot archive a failed trail (failedCannotArchive)" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    _ = audit.audit_fail(slot, 0);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_archive(slot)); // rejected
}

// ═══════════════════════════════════════════════════════════════════════
// Event recording tests
// ═══════════════════════════════════════════════════════════════════════

test "record events in Recording state" {
    const slot = audit.audit_create(4, 3, 2); // full, chained, daily
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);

    // Record all 8 event categories
    try std.testing.expectEqual(@as(u8, 255), audit.audit_record_event(slot, 0)); // state_transition
    try std.testing.expectEqual(@as(u8, 255), audit.audit_record_event(slot, 1)); // authentication
    try std.testing.expectEqual(@as(u8, 255), audit.audit_record_event(slot, 2)); // authorization
    try std.testing.expectEqual(@as(u8, 255), audit.audit_record_event(slot, 3)); // data_access
    try std.testing.expectEqual(@as(u8, 255), audit.audit_record_event(slot, 4)); // configuration
    try std.testing.expectEqual(@as(u8, 255), audit.audit_record_event(slot, 5)); // error
    try std.testing.expectEqual(@as(u8, 255), audit.audit_record_event(slot, 6)); // security
    try std.testing.expectEqual(@as(u8, 255), audit.audit_record_event(slot, 7)); // lifecycle

    try std.testing.expectEqual(@as(u32, 8), audit.audit_event_count(slot));
}

test "record rejects invalid category" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_record_event(slot, 99)); // write_failure
}

test "cannot record on idle trail" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_record_event(slot, 0)); // write_failure
}

test "cannot record on sealed trail" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    _ = audit.audit_seal(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_record_event(slot, 0)); // write_failure
}

test "cannot record on archived trail" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    _ = audit.audit_seal(slot);
    _ = audit.audit_archive(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_record_event(slot, 0)); // write_failure
}

test "cannot record on failed trail" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    _ = audit.audit_fail(slot, 0);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_record_event(slot, 0)); // write_failure
}

// ═══════════════════════════════════════════════════════════════════════
// Stateless validation (matching Transitions.idr validateAuditTransition)
// ═══════════════════════════════════════════════════════════════════════

test "can_transition matches Transitions.idr validateAuditTransition" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), audit.audit_can_transition(0, 1)); // Idle -> Recording
    try std.testing.expectEqual(@as(u8, 1), audit.audit_can_transition(1, 2)); // Recording -> Sealed
    try std.testing.expectEqual(@as(u8, 1), audit.audit_can_transition(1, 4)); // Recording -> Failed
    try std.testing.expectEqual(@as(u8, 1), audit.audit_can_transition(2, 3)); // Sealed -> Archived
    try std.testing.expectEqual(@as(u8, 1), audit.audit_can_transition(2, 0)); // Sealed -> Idle
    try std.testing.expectEqual(@as(u8, 1), audit.audit_can_transition(3, 0)); // Archived -> Idle
    try std.testing.expectEqual(@as(u8, 1), audit.audit_can_transition(4, 0)); // Failed -> Idle

    // Invalid transitions (impossibility proofs)
    try std.testing.expectEqual(@as(u8, 0), audit.audit_can_transition(2, 1)); // Sealed -/-> Recording
    try std.testing.expectEqual(@as(u8, 0), audit.audit_can_transition(3, 1)); // Archived -/-> Recording
    try std.testing.expectEqual(@as(u8, 0), audit.audit_can_transition(0, 2)); // Idle -/-> Sealed
    try std.testing.expectEqual(@as(u8, 0), audit.audit_can_transition(1, 3)); // Recording -/-> Archived
    try std.testing.expectEqual(@as(u8, 0), audit.audit_can_transition(1, 1)); // Recording -/-> Recording
    try std.testing.expectEqual(@as(u8, 0), audit.audit_can_transition(4, 3)); // Failed -/-> Archived
    try std.testing.expectEqual(@as(u8, 0), audit.audit_can_transition(0, 0)); // Idle -/-> Idle
}

// ═══════════════════════════════════════════════════════════════════════
// Error tracking
// ═══════════════════════════════════════════════════════════════════════

test "last_error is 255 after successful transition" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    try std.testing.expectEqual(@as(u8, 255), audit.audit_last_error(slot));
}

test "last_error records failure cause" {
    const slot = audit.audit_create(2, 0, 0);
    defer audit.audit_destroy(slot);
    _ = audit.audit_open(slot);
    _ = audit.audit_fail(slot, 4); // chain_broken
    try std.testing.expectEqual(@as(u8, 4), audit.audit_last_error(slot));
}

// ═══════════════════════════════════════════════════════════════════════
// Full lifecycle round-trips
// ═══════════════════════════════════════════════════════════════════════

test "full lifecycle: create -> open -> record -> seal -> archive -> destroy" {
    const slot = audit.audit_create(4, 3, 4); // full, chained, regulatory
    try std.testing.expect(slot >= 0);

    // Idle -> Recording
    try std.testing.expectEqual(@as(u8, 0), audit.audit_open(slot));
    try std.testing.expectEqual(@as(u8, 1), audit.audit_state(slot));

    // Record some events
    _ = audit.audit_record_event(slot, 0); // state_transition
    _ = audit.audit_record_event(slot, 1); // authentication
    _ = audit.audit_record_event(slot, 6); // security
    try std.testing.expectEqual(@as(u32, 3), audit.audit_event_count(slot));

    // Recording -> Sealed
    try std.testing.expectEqual(@as(u8, 0), audit.audit_seal(slot));
    try std.testing.expectEqual(@as(u8, 2), audit.audit_state(slot));

    // Events preserved after seal
    try std.testing.expectEqual(@as(u32, 3), audit.audit_event_count(slot));

    // Sealed -> Archived
    try std.testing.expectEqual(@as(u8, 0), audit.audit_archive(slot));
    try std.testing.expectEqual(@as(u8, 3), audit.audit_state(slot));

    audit.audit_destroy(slot);
}

test "fail-reset cycle: create -> open -> fail -> reset -> open -> seal" {
    const slot = audit.audit_create(2, 1, 0); // standard, hmac, ephemeral
    defer audit.audit_destroy(slot);

    _ = audit.audit_open(slot); // Idle -> Recording
    _ = audit.audit_record_event(slot, 3); // data_access
    _ = audit.audit_fail(slot, 2); // integrity_violation
    try std.testing.expectEqual(@as(u8, 4), audit.audit_state(slot)); // Failed

    _ = audit.audit_reset(slot); // Failed -> Idle
    try std.testing.expectEqual(@as(u8, 0), audit.audit_state(slot));

    _ = audit.audit_open(slot); // Idle -> Recording (second time)
    try std.testing.expectEqual(@as(u8, 1), audit.audit_state(slot));
    try std.testing.expectEqual(@as(u32, 0), audit.audit_event_count(slot)); // reset clears count

    _ = audit.audit_record_event(slot, 5); // error
    _ = audit.audit_seal(slot); // Recording -> Sealed
    try std.testing.expectEqual(@as(u8, 2), audit.audit_state(slot));
}

test "sealed-reset-reuse cycle" {
    const slot = audit.audit_create(1, 0, 0); // minimal, unsigned, ephemeral
    defer audit.audit_destroy(slot);

    _ = audit.audit_open(slot);
    _ = audit.audit_record_event(slot, 7); // lifecycle
    _ = audit.audit_seal(slot);
    try std.testing.expectEqual(@as(u8, 2), audit.audit_state(slot));

    _ = audit.audit_reset(slot); // Sealed -> Idle
    try std.testing.expectEqual(@as(u8, 0), audit.audit_state(slot));

    // Reuse: open again
    _ = audit.audit_open(slot);
    try std.testing.expectEqual(@as(u8, 1), audit.audit_state(slot));
    try std.testing.expectEqual(@as(u32, 0), audit.audit_event_count(slot));
}
