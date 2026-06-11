// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-lpd FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const lpd = @import("lpd");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), lpd.lpd_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "CommandCode encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(lpd.CommandCode.print_job));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(lpd.CommandCode.receive_job));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(lpd.CommandCode.short_queue));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(lpd.CommandCode.long_queue));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(lpd.CommandCode.remove_jobs));
}

test "SubCommandCode encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(lpd.SubCommandCode.abort_job));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(lpd.SubCommandCode.control_file));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(lpd.SubCommandCode.data_file));
}

test "JobStatusTag encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(lpd.JobStatusTag.pending));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(lpd.JobStatusTag.printing));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(lpd.JobStatusTag.complete));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(lpd.JobStatusTag.failed));
}

test "LPDError encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(lpd.LPDError.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(lpd.LPDError.invalid_slot));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(lpd.LPDError.not_active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(lpd.LPDError.queue_full));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(lpd.LPDError.not_accepting));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(lpd.LPDError.job_not_found));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(lpd.LPDError.invalid_param));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = lpd.lpd_create(0, 0);
    try std.testing.expect(slot >= 0);
    defer lpd.lpd_destroy(slot);
}

test "destroy is safe with invalid slot" {
    lpd.lpd_destroy(-1);
    lpd.lpd_destroy(999);
}

