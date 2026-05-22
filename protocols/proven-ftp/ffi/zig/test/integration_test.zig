// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-ftp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const ftp = @import("ftp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ftp.ftp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "SessionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.SessionState.connected));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.SessionState.user_ok));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ftp.SessionState.authenticated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ftp.SessionState.renaming));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ftp.SessionState.quit));
}

test "TransferType encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.TransferType.ascii));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.TransferType.binary));
}

test "DataModeTag encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.DataModeTag.active));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.DataModeTag.passive));
}

test "TransferStateTag encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.TransferStateTag.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.TransferStateTag.in_progress));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ftp.TransferStateTag.completed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ftp.TransferStateTag.aborted));
}

test "ReplyCategory encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.ReplyCategory.preliminary));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.ReplyCategory.completion));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ftp.ReplyCategory.intermediate));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ftp.ReplyCategory.transient_neg));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ftp.ReplyCategory.permanent_neg));
}

test "CommandTag encoding matches Types.idr (23 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ftp.CommandTag.user));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ftp.CommandTag.pass));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ftp.CommandTag.acct));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ftp.CommandTag.cwd));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ftp.CommandTag.cdup));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ftp.CommandTag.quit));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ftp.CommandTag.pasv));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ftp.CommandTag.port));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(ftp.CommandTag.type_cmd));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(ftp.CommandTag.retr));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(ftp.CommandTag.stor));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(ftp.CommandTag.dele));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(ftp.CommandTag.rmd));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(ftp.CommandTag.mkd));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(ftp.CommandTag.pwd));
    try std.testing.expectEqual(@as(u8, 15), @intFromEnum(ftp.CommandTag.list));
    try std.testing.expectEqual(@as(u8, 16), @intFromEnum(ftp.CommandTag.nlst));
    try std.testing.expectEqual(@as(u8, 17), @intFromEnum(ftp.CommandTag.syst));
    try std.testing.expectEqual(@as(u8, 18), @intFromEnum(ftp.CommandTag.stat));
    try std.testing.expectEqual(@as(u8, 19), @intFromEnum(ftp.CommandTag.noop));
    try std.testing.expectEqual(@as(u8, 20), @intFromEnum(ftp.CommandTag.rnfr));
    try std.testing.expectEqual(@as(u8, 21), @intFromEnum(ftp.CommandTag.rnto));
    try std.testing.expectEqual(@as(u8, 22), @intFromEnum(ftp.CommandTag.size));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = ftp.ftp_create();
    try std.testing.expect(slot >= 0);
    defer ftp.ftp_destroy(slot);
    const state = ftp.ftp_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    ftp.ftp_destroy(-1);
    ftp.ftp_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), ftp.ftp_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = ftp.ftp_state(-1);
    _ = ftp.ftp_file_count(-1);
}

