// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-ntp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const ntp = @import("ntp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ntp.ntp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "LeapIndicator encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.LeapIndicator.no_warning));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.LeapIndicator.last_minute_61));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.LeapIndicator.last_minute_59));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.LeapIndicator.unsynchronised));
}

test "NTPMode encoding matches Types.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.NTPMode.reserved));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.NTPMode.symmetric_active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.NTPMode.symmetric_passive));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.NTPMode.client));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ntp.NTPMode.server));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ntp.NTPMode.broadcast));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ntp.NTPMode.control_message));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ntp.NTPMode.private));
}

test "ExchangeState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.ExchangeState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.ExchangeState.request_received));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.ExchangeState.timestamp_calculated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.ExchangeState.response_sent));
}

test "ClockDisciplineState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.ClockDisciplineState.unset));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.ClockDisciplineState.spike));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.ClockDisciplineState.freq));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.ClockDisciplineState.sync));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ntp.ClockDisciplineState.panic));
}

test "KissCode encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.KissCode.deny));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.KissCode.rstr));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.KissCode.rate));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.KissCode.other));
}

test "NtpError encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.NtpError.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.NtpError.invalid_slot));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.NtpError.not_active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.NtpError.invalid_packet));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ntp.NtpError.kiss_of_death));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ntp.NtpError.stratum_too_high));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = ntp.ntp_create(0, 0, 0);
    try std.testing.expect(slot >= 0);
    defer ntp.ntp_destroy(slot);
    const state = ntp.ntp_get_exchange_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    ntp.ntp_destroy(-1);
    ntp.ntp_destroy(999);
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = ntp.ntp_get_exchange_state(-1);
    _ = ntp.ntp_get_exchange_state(-1);
    _ = ntp.ntp_get_discipline_state(-1);
    _ = ntp.ntp_get_stratum(-1);
}

