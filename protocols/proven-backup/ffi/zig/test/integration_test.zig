// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-backup FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Job lifecycle (create/destroy)
//   - Job transitions (start/verify/complete/fail/cancel)
//   - Retention policy (set/get)
//   - Progress tracking (bytes_processed)
//   - Reset (complete/failed/cancelled -> idle)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const backup = @import("backup");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), backup.backup_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "BackupType encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(backup.BackupType.full));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(backup.BackupType.incremental));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(backup.BackupType.differential));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(backup.BackupType.snapshot));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(backup.BackupType.mirror));
}

test "ScheduleFreq encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(backup.ScheduleFreq.hourly));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(backup.ScheduleFreq.daily));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(backup.ScheduleFreq.weekly));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(backup.ScheduleFreq.monthly));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(backup.ScheduleFreq.on_demand));
}

test "CompressionAlg encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(backup.CompressionAlg.none));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(backup.CompressionAlg.gzip));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(backup.CompressionAlg.zstd));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(backup.CompressionAlg.lz4));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(backup.CompressionAlg.xz));
}

test "EncryptionAlg encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(backup.EncryptionAlg.no_encryption));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(backup.EncryptionAlg.aes256gcm));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(backup.EncryptionAlg.chacha20poly1305));
}

test "BackupState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(backup.BackupState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(backup.BackupState.running));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(backup.BackupState.verifying));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(backup.BackupState.complete));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(backup.BackupState.failed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(backup.BackupState.cancelled));
}

test "RetentionPolicy encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(backup.RetentionPolicy.keep_all));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(backup.RetentionPolicy.keep_last));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(backup.RetentionPolicy.keep_daily));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(backup.RetentionPolicy.keep_weekly));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(backup.RetentionPolicy.keep_monthly));
}

// =========================================================================
// Job lifecycle
// =========================================================================

test "create returns valid slot in Idle state" {
    const slot = backup.backup_create(0, 4, 0, 0); // Full, OnDemand, None, NoEncryption
    try std.testing.expect(slot >= 0);
    defer backup.backup_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), backup.backup_state(slot)); // Idle
}

test "create rejects invalid backup type" {
    const slot = backup.backup_create(99, 0, 0, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid schedule" {
    const slot = backup.backup_create(0, 99, 0, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid compression" {
    const slot = backup.backup_create(0, 0, 99, 0);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "create rejects invalid encryption" {
    const slot = backup.backup_create(0, 0, 0, 99);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    backup.backup_destroy(-1);
    backup.backup_destroy(999);
}

// =========================================================================
// Job transitions
// =========================================================================

test "start transitions Idle -> Running" {
    const slot = backup.backup_create(0, 4, 2, 1); // Full, OnDemand, Zstd, AES256GCM
    defer backup.backup_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), backup.backup_start(slot));
    try std.testing.expectEqual(@as(u8, 1), backup.backup_state(slot)); // Running
}

test "verify transitions Running -> Verifying" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    try std.testing.expectEqual(@as(u8, 0), backup.backup_verify(slot));
    try std.testing.expectEqual(@as(u8, 2), backup.backup_state(slot)); // Verifying
}

test "complete transitions Verifying -> Complete" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    _ = backup.backup_verify(slot);
    try std.testing.expectEqual(@as(u8, 0), backup.backup_complete(slot));
    try std.testing.expectEqual(@as(u8, 3), backup.backup_state(slot)); // Complete
}

test "fail transitions Running -> Failed" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    try std.testing.expectEqual(@as(u8, 0), backup.backup_fail(slot));
    try std.testing.expectEqual(@as(u8, 4), backup.backup_state(slot)); // Failed
}

test "fail transitions Verifying -> Failed" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    _ = backup.backup_verify(slot);
    try std.testing.expectEqual(@as(u8, 0), backup.backup_fail(slot));
    try std.testing.expectEqual(@as(u8, 4), backup.backup_state(slot)); // Failed
}

test "cancel transitions Running -> Cancelled" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    try std.testing.expectEqual(@as(u8, 0), backup.backup_cancel(slot));
    try std.testing.expectEqual(@as(u8, 5), backup.backup_state(slot)); // Cancelled
}

// =========================================================================
// Retention policy
// =========================================================================

test "set_retention and get retention" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), backup.backup_set_retention(slot, 3)); // KeepWeekly
    try std.testing.expectEqual(@as(u8, 3), backup.backup_retention(slot)); // KeepWeekly
}

test "set_retention rejects invalid policy" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), backup.backup_set_retention(slot, 99));
}

// =========================================================================
// Reset
// =========================================================================

test "reset Complete -> Idle" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    _ = backup.backup_verify(slot);
    _ = backup.backup_complete(slot);
    try std.testing.expectEqual(@as(u8, 0), backup.backup_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), backup.backup_state(slot)); // Idle
}

test "reset Failed -> Idle" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    _ = backup.backup_fail(slot);
    try std.testing.expectEqual(@as(u8, 0), backup.backup_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), backup.backup_state(slot)); // Idle
}

test "reset Cancelled -> Idle" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    _ = backup.backup_cancel(slot);
    try std.testing.expectEqual(@as(u8, 0), backup.backup_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), backup.backup_state(slot)); // Idle
}

test "reset rejected from Running" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    try std.testing.expectEqual(@as(u8, 1), backup.backup_reset(slot));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "backup_can_transition matches expected" {
    try std.testing.expectEqual(@as(u8, 1), backup.backup_can_transition(0, 1)); // Idle -> Running
    try std.testing.expectEqual(@as(u8, 1), backup.backup_can_transition(1, 2)); // Running -> Verifying
    try std.testing.expectEqual(@as(u8, 1), backup.backup_can_transition(2, 3)); // Verifying -> Complete
    try std.testing.expectEqual(@as(u8, 1), backup.backup_can_transition(1, 4)); // Running -> Failed
    try std.testing.expectEqual(@as(u8, 1), backup.backup_can_transition(2, 4)); // Verifying -> Failed
    try std.testing.expectEqual(@as(u8, 1), backup.backup_can_transition(1, 5)); // Running -> Cancelled
    try std.testing.expectEqual(@as(u8, 1), backup.backup_can_transition(3, 0)); // Complete -> Idle
    try std.testing.expectEqual(@as(u8, 1), backup.backup_can_transition(4, 0)); // Failed -> Idle
    try std.testing.expectEqual(@as(u8, 1), backup.backup_can_transition(5, 0)); // Cancelled -> Idle

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), backup.backup_can_transition(0, 3)); // Idle -/-> Complete
    try std.testing.expectEqual(@as(u8, 0), backup.backup_can_transition(2, 5)); // Verifying -/-> Cancelled
    try std.testing.expectEqual(@as(u8, 0), backup.backup_can_transition(3, 1)); // Complete -/-> Running
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), backup.backup_state(-1));
    try std.testing.expectEqual(@as(u8, 0), backup.backup_retention(-1));
    try std.testing.expectEqual(@as(u64, 0), backup.backup_bytes_processed(-1));
    try std.testing.expectEqual(@as(u8, 1), backup.backup_start(-1));
    try std.testing.expectEqual(@as(u8, 1), backup.backup_reset(-1));
}

// =========================================================================
// Impossibility tests
// =========================================================================

test "cannot verify from Idle" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), backup.backup_verify(slot));
}

test "cannot complete from Running" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    try std.testing.expectEqual(@as(u8, 1), backup.backup_complete(slot));
}

test "cannot cancel from Verifying" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    _ = backup.backup_verify(slot);
    try std.testing.expectEqual(@as(u8, 1), backup.backup_cancel(slot));
}

test "cannot start from Running" {
    const slot = backup.backup_create(0, 4, 0, 0);
    defer backup.backup_destroy(slot);

    _ = backup.backup_start(slot);
    try std.testing.expectEqual(@as(u8, 1), backup.backup_start(slot));
}
