// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// ntp_test.zig — Integration tests for proven-ntp FFI.
//
// Tests the C-ABI contract between Idris2 proofs and Zig implementation.
// Every state transition test here has a corresponding formal proof in
// Transitions.idr.

const std = @import("std");
const ntp = @import("ntp");

// ═══════════════════════════════════════════════════════════════════════
// ABI version seam
// ═══════════════════════════════════════════════════════════════════════

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), ntp.ntp_abi_version());
}

// ═══════════════════════════════════════════════════════════════════════
// Enum encoding seams (must match Layout.idr tag assignments)
// ═══════════════════════════════════════════════════════════════════════

test "LeapIndicator encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.LeapIndicator.no_warning));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.LeapIndicator.last_minute_61));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.LeapIndicator.last_minute_59));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.LeapIndicator.unsynchronised));
}

test "NTPMode encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.NTPMode.reserved));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.NTPMode.symmetric_active));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.NTPMode.symmetric_passive));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.NTPMode.client));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ntp.NTPMode.server));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ntp.NTPMode.broadcast));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(ntp.NTPMode.control_message));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(ntp.NTPMode.private));
}

test "ExchangeState encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.ExchangeState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.ExchangeState.request_received));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.ExchangeState.timestamp_calculated));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.ExchangeState.response_sent));
}

test "ClockDisciplineState encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.ClockDisciplineState.unset));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.ClockDisciplineState.spike));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.ClockDisciplineState.freq));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.ClockDisciplineState.sync));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ntp.ClockDisciplineState.panic));
}

test "KissCode encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.KissCode.deny));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.KissCode.rstr));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.KissCode.rate));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.KissCode.other));
}

test "NtpError encoding matches Layout.idr" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(ntp.NtpError.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(ntp.NtpError.invalid_slot));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(ntp.NtpError.not_active));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(ntp.NtpError.invalid_packet));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(ntp.NtpError.kiss_of_death));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(ntp.NtpError.stratum_too_high));
}

// ═══════════════════════════════════════════════════════════════════════
// NTP Timestamp arithmetic tests
// ═══════════════════════════════════════════════════════════════════════

test "NtpTimestamp zero is null" {
    try std.testing.expect(ntp.NtpTimestamp.zero.isNull());
}

test "NtpTimestamp add with no carry" {
    const a: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 500 };
    const b: ntp.NtpTimestamp = .{ .seconds = 200, .fraction = 300 };
    const result = ntp.NtpTimestamp.add(a, b);
    try std.testing.expectEqual(@as(u32, 300), result.seconds);
    try std.testing.expectEqual(@as(u32, 800), result.fraction);
}

test "NtpTimestamp add with fractional carry" {
    const a: ntp.NtpTimestamp = .{ .seconds = 10, .fraction = 0xFFFF_FFF0 };
    const b: ntp.NtpTimestamp = .{ .seconds = 20, .fraction = 0x0000_0020 };
    const result = ntp.NtpTimestamp.add(a, b);
    try std.testing.expectEqual(@as(u32, 31), result.seconds); // 10 + 20 + 1 carry
    try std.testing.expectEqual(@as(u32, 0x10), result.fraction);
}

test "NtpTimestamp sub with no borrow" {
    const a: ntp.NtpTimestamp = .{ .seconds = 300, .fraction = 800 };
    const b: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 500 };
    const result = ntp.NtpTimestamp.sub(a, b);
    try std.testing.expectEqual(@as(u32, 200), result.seconds);
    try std.testing.expectEqual(@as(u32, 300), result.fraction);
}

test "NtpTimestamp sub underflow clamps to zero" {
    const a: ntp.NtpTimestamp = .{ .seconds = 10, .fraction = 0 };
    const b: ntp.NtpTimestamp = .{ .seconds = 20, .fraction = 0 };
    const result = ntp.NtpTimestamp.sub(a, b);
    try std.testing.expectEqual(@as(u32, 0), result.seconds);
}

test "NtpTimestamp half of even seconds" {
    const ts: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 0x8000_0000 };
    const result = ntp.NtpTimestamp.half(ts);
    try std.testing.expectEqual(@as(u32, 50), result.seconds);
    try std.testing.expectEqual(@as(u32, 0x4000_0000), result.fraction);
}

test "NtpTimestamp half of odd seconds carries into fraction" {
    const ts: ntp.NtpTimestamp = .{ .seconds = 101, .fraction = 0 };
    const result = ntp.NtpTimestamp.half(ts);
    try std.testing.expectEqual(@as(u32, 50), result.seconds);
    try std.testing.expectEqual(@as(u32, 0x8000_0000), result.fraction); // half-second carry
}

test "NtpTimestamp compare equal" {
    const a: ntp.NtpTimestamp = .{ .seconds = 42, .fraction = 100 };
    const b: ntp.NtpTimestamp = .{ .seconds = 42, .fraction = 100 };
    try std.testing.expectEqual(@as(i8, 0), ntp.NtpTimestamp.compare(a, b));
}

test "NtpTimestamp compare less by seconds" {
    const a: ntp.NtpTimestamp = .{ .seconds = 10, .fraction = 999 };
    const b: ntp.NtpTimestamp = .{ .seconds = 20, .fraction = 0 };
    try std.testing.expectEqual(@as(i8, -1), ntp.NtpTimestamp.compare(a, b));
}

test "NtpTimestamp compare less by fraction" {
    const a: ntp.NtpTimestamp = .{ .seconds = 10, .fraction = 100 };
    const b: ntp.NtpTimestamp = .{ .seconds = 10, .fraction = 200 };
    try std.testing.expectEqual(@as(i8, -1), ntp.NtpTimestamp.compare(a, b));
}

test "NtpTimestamp fractionToMillis" {
    // 0x4000_0000 = 2^30 => (2^30 * 1000) / 2^32 = 250ms (approximately)
    const ts: ntp.NtpTimestamp = .{ .seconds = 0, .fraction = 0x4000_0000 };
    const millis = ts.fractionToMillis();
    try std.testing.expectEqual(@as(u32, 250), millis);
}

// ═══════════════════════════════════════════════════════════════════════
// Clock offset and delay calculation
// ═══════════════════════════════════════════════════════════════════════

test "roundTripDelay basic calculation" {
    const t1: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 0 };
    const t2: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 0x0800_0000 }; // +~12ms
    const t3: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 0x0900_0000 }; // +~1ms processing
    const t4: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 0x1A00_0000 }; // ~25ms after t1
    const delay = ntp.roundTripDelay(t1, t2, t3, t4);
    // delay = (t4-t1) - (t3-t2) = 0x1A00_0000 - 0x0100_0000 = 0x1900_0000
    try std.testing.expectEqual(@as(u32, 0), delay.seconds);
    try std.testing.expectEqual(@as(u32, 0x1900_0000), delay.fraction);
}

test "clockOffset basic calculation" {
    const t1: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 0 };
    const t2: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 0x0800_0000 };
    const t3: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 0x0900_0000 };
    const t4: ntp.NtpTimestamp = .{ .seconds = 100, .fraction = 0x1A00_0000 };
    const offset = ntp.clockOffset(t1, t2, t3, t4);
    // offset = ((t2-t1) + (t3-t4)) / 2
    // (t2-t1) = 0x0800_0000
    // (t3-t4) would underflow since t3 < t4, so sub clamps seconds to 0
    // This tests the safe arithmetic path
    try std.testing.expectEqual(@as(u32, 0), offset.seconds);
}

// ═══════════════════════════════════════════════════════════════════════
// Lifecycle tests
// ═══════════════════════════════════════════════════════════════════════

test "create returns valid slot" {
    const slot = ntp.ntp_create(4, 4, 2); // NTPv4, Server mode, Stratum 2
    try std.testing.expect(slot >= 0);
    defer ntp.ntp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_get_exchange_state(slot)); // Idle
}

test "create rejects invalid version" {
    try std.testing.expectEqual(@as(c_int, -1), ntp.ntp_create(5, 4, 2));
    try std.testing.expectEqual(@as(c_int, -1), ntp.ntp_create(0, 4, 2));
    try std.testing.expectEqual(@as(c_int, -1), ntp.ntp_create(2, 4, 2));
}

test "create accepts version 3" {
    const slot = ntp.ntp_create(3, 4, 1);
    try std.testing.expect(slot >= 0);
    defer ntp.ntp_destroy(slot);
}

test "create rejects invalid mode" {
    try std.testing.expectEqual(@as(c_int, -1), ntp.ntp_create(4, 8, 2));
}

test "create rejects invalid stratum" {
    try std.testing.expectEqual(@as(c_int, -1), ntp.ntp_create(4, 4, 17));
}

test "destroy is safe with invalid slot" {
    ntp.ntp_destroy(-1);
    ntp.ntp_destroy(999);
    // No crash = pass
}

test "destroy makes slot reusable" {
    const slot1 = ntp.ntp_create(4, 4, 2);
    try std.testing.expect(slot1 >= 0);
    ntp.ntp_destroy(slot1);

    const slot2 = ntp.ntp_create(4, 4, 2);
    try std.testing.expect(slot2 >= 0);
    defer ntp.ntp_destroy(slot2);
    try std.testing.expectEqual(slot1, slot2);
}

// ═══════════════════════════════════════════════════════════════════════
// State query tests
// ═══════════════════════════════════════════════════════════════════════

test "stratum returns configured value" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 2), ntp.ntp_get_stratum(slot));
}

test "stratum returns 16 for invalid slot" {
    try std.testing.expectEqual(@as(u8, 16), ntp.ntp_get_stratum(-1));
}

test "mode returns configured value" {
    const slot = ntp.ntp_create(4, 4, 2); // mode 4 = Server
    defer ntp.ntp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 4), ntp.ntp_get_mode(slot));
}

test "discipline state starts at Unset" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_get_discipline_state(slot)); // Unset
}

test "last_error is 255 after creation" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 255), ntp.ntp_get_last_error(slot));
}

test "exchange count starts at 0" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    try std.testing.expectEqual(@as(u32, 0), ntp.ntp_get_exchange_count(slot));
}

// ═══════════════════════════════════════════════════════════════════════
// Valid exchange transition tests (matching Transitions.idr)
// ═══════════════════════════════════════════════════════════════════════

test "ReceiveRequest: Idle -> RequestReceived" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    const result = ntp.ntp_receive_request(slot, 100, 0, 100, 0x0800_0000);
    try std.testing.expectEqual(@as(u8, 0), result); // Ok
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_get_exchange_state(slot)); // RequestReceived
}

test "CalculateTimestamps: RequestReceived -> TimestampCalculated" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_receive_request(slot, 100, 0, 100, 0x0800_0000);
    const result = ntp.ntp_calculate(slot, 100, 0x0900_0000);
    try std.testing.expectEqual(@as(u8, 0), result); // Ok
    try std.testing.expectEqual(@as(u8, 2), ntp.ntp_get_exchange_state(slot)); // TimestampCalculated
}

test "SendResponse: TimestampCalculated -> ResponseSent" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_receive_request(slot, 100, 0, 100, 0x0800_0000);
    _ = ntp.ntp_calculate(slot, 100, 0x0900_0000);
    const result = ntp.ntp_send_response(slot);
    try std.testing.expectEqual(@as(u8, 0), result); // Ok
    try std.testing.expectEqual(@as(u8, 3), ntp.ntp_get_exchange_state(slot)); // ResponseSent
}

test "ResetExchange: ResponseSent -> Idle" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_receive_request(slot, 100, 0, 100, 0x0800_0000);
    _ = ntp.ntp_calculate(slot, 100, 0x0900_0000);
    _ = ntp.ntp_send_response(slot);
    const result = ntp.ntp_reset_exchange(slot);
    try std.testing.expectEqual(@as(u8, 0), result); // Ok
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_get_exchange_state(slot)); // Idle
    try std.testing.expectEqual(@as(u32, 1), ntp.ntp_get_exchange_count(slot));
}

// ═══════════════════════════════════════════════════════════════════════
// Invalid exchange transition tests (matching impossibility proofs)
// ═══════════════════════════════════════════════════════════════════════

test "cannot receive request when not idle (cannotReceiveWhileProcessing)" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_receive_request(slot, 100, 0, 100, 0x0800_0000); // Now RequestReceived
    const result = ntp.ntp_receive_request(slot, 200, 0, 200, 0x0800_0000);
    try std.testing.expectEqual(@as(u8, 3), result); // InvalidPacket
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_get_exchange_state(slot)); // Still RequestReceived
}

test "cannot calculate from idle (cannotCalculateWithoutRequest)" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    const result = ntp.ntp_calculate(slot, 100, 0x0900_0000);
    try std.testing.expectEqual(@as(u8, 3), result); // InvalidPacket
}

test "cannot send response from idle (cannotSendFromIdle)" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    const result = ntp.ntp_send_response(slot);
    try std.testing.expectEqual(@as(u8, 3), result); // InvalidPacket
}

test "cannot reset from idle" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    const result = ntp.ntp_reset_exchange(slot);
    try std.testing.expectEqual(@as(u8, 3), result); // InvalidPacket
}

test "cannot skip calculation (cannotSkipCalculation)" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_receive_request(slot, 100, 0, 100, 0x0800_0000); // RequestReceived
    const result = ntp.ntp_send_response(slot); // Try to skip to ResponseSent
    try std.testing.expectEqual(@as(u8, 3), result); // InvalidPacket
}

// ═══════════════════════════════════════════════════════════════════════
// Offset/delay getter tests
// ═══════════════════════════════════════════════════════════════════════

test "get offset after calculation" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_receive_request(slot, 100, 0, 100, 0x0800_0000);
    _ = ntp.ntp_calculate(slot, 100, 0x0900_0000);

    var out_secs: u32 = 0;
    var out_frac: u32 = 0;
    const result = ntp.ntp_get_offset(slot, &out_secs, &out_frac);
    try std.testing.expectEqual(@as(u8, 0), result); // Ok
    // offset = t2 - t1 = (100, 0x0800_0000) - (100, 0) = (0, 0x0800_0000)
    try std.testing.expectEqual(@as(u32, 0), out_secs);
    try std.testing.expectEqual(@as(u32, 0x0800_0000), out_frac);
}

test "get delay after calculation" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_receive_request(slot, 100, 0, 100, 0x0800_0000);
    _ = ntp.ntp_calculate(slot, 100, 0x0900_0000);

    var out_secs: u32 = 0;
    var out_frac: u32 = 0;
    const result = ntp.ntp_get_delay(slot, &out_secs, &out_frac);
    try std.testing.expectEqual(@as(u8, 0), result); // Ok
    // delay = t3 - t2 = (100, 0x0900_0000) - (100, 0x0800_0000) = (0, 0x0100_0000)
    try std.testing.expectEqual(@as(u32, 0), out_secs);
    try std.testing.expectEqual(@as(u32, 0x0100_0000), out_frac);
}

test "get offset from idle fails" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    var out_secs: u32 = 0;
    var out_frac: u32 = 0;
    const result = ntp.ntp_get_offset(slot, &out_secs, &out_frac);
    try std.testing.expectEqual(@as(u8, 3), result); // InvalidPacket
}

// ═══════════════════════════════════════════════════════════════════════
// Leap indicator tests
// ═══════════════════════════════════════════════════════════════════════

test "leap indicator default is no_warning" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_get_leap(slot)); // no_warning
}

test "set and get leap indicator" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_set_leap(slot, 1); // last_minute_61
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_get_leap(slot));
    _ = ntp.ntp_set_leap(slot, 3); // unsynchronised
    try std.testing.expectEqual(@as(u8, 3), ntp.ntp_get_leap(slot));
}

test "set leap rejects invalid value" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    const result = ntp.ntp_set_leap(slot, 4);
    try std.testing.expectEqual(@as(u8, 3), result); // InvalidPacket
}

// ═══════════════════════════════════════════════════════════════════════
// Kiss-o'-Death tests
// ═══════════════════════════════════════════════════════════════════════

test "kiss check returns 255 when no KoD" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 255), ntp.ntp_check_kiss(slot));
}

test "set and check kiss code" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_set_kiss(slot, 0); // DENY
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_check_kiss(slot));
    _ = ntp.ntp_set_kiss(slot, 2); // RATE
    try std.testing.expectEqual(@as(u8, 2), ntp.ntp_check_kiss(slot));
}

test "set kiss rejects invalid value" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    const result = ntp.ntp_set_kiss(slot, 4);
    try std.testing.expectEqual(@as(u8, 3), result); // InvalidPacket
}

// ═══════════════════════════════════════════════════════════════════════
// Stratum management tests
// ═══════════════════════════════════════════════════════════════════════

test "set stratum valid range" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_set_stratum(slot, 1);
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_get_stratum(slot));
    _ = ntp.ntp_set_stratum(slot, 15);
    try std.testing.expectEqual(@as(u8, 15), ntp.ntp_get_stratum(slot));
    _ = ntp.ntp_set_stratum(slot, 0);
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_get_stratum(slot));
}

test "set stratum rejects above 16" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    const result = ntp.ntp_set_stratum(slot, 17);
    try std.testing.expectEqual(@as(u8, 5), result); // StratumTooHigh
}

// ═══════════════════════════════════════════════════════════════════════
// Stateless exchange transition validation
// (matching Transitions.idr validateExchangeTransition)
// ═══════════════════════════════════════════════════════════════════════

test "can_exchange_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_exchange_transition(0, 1)); // Idle -> RequestReceived
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_exchange_transition(1, 2)); // RequestReceived -> TimestampCalculated
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_exchange_transition(2, 3)); // TimestampCalculated -> ResponseSent
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_exchange_transition(3, 0)); // ResponseSent -> Idle

    // Invalid transitions (impossibility proofs)
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_exchange_transition(0, 2)); // Idle -/-> TimestampCalculated
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_exchange_transition(0, 3)); // Idle -/-> ResponseSent
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_exchange_transition(1, 0)); // RequestReceived -/-> Idle
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_exchange_transition(1, 3)); // RequestReceived -/-> ResponseSent
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_exchange_transition(2, 0)); // TimestampCalculated -/-> Idle
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_exchange_transition(2, 1)); // TimestampCalculated -/-> RequestReceived
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_exchange_transition(3, 1)); // ResponseSent -/-> RequestReceived
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_exchange_transition(3, 2)); // ResponseSent -/-> TimestampCalculated
}

// ═══════════════════════════════════════════════════════════════════════
// Stateless discipline transition validation
// (matching Transitions.idr validateDisciplineTransition)
// ═══════════════════════════════════════════════════════════════════════

test "can_discipline_transition matches Transitions.idr" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_discipline_transition(0, 1)); // Unset -> Spike
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_discipline_transition(1, 2)); // Spike -> Freq
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_discipline_transition(2, 3)); // Freq -> Sync
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_discipline_transition(0, 4)); // Unset -> Panic
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_discipline_transition(1, 4)); // Spike -> Panic
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_discipline_transition(2, 4)); // Freq -> Panic
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_discipline_transition(3, 4)); // Sync -> Panic
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_discipline_transition(4, 0)); // Panic -> Unset
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_can_discipline_transition(3, 2)); // Sync -> Freq

    // Invalid transitions (impossibility proofs)
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_discipline_transition(4, 3)); // Panic -/-> Sync
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_discipline_transition(4, 2)); // Panic -/-> Freq
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_discipline_transition(2, 1)); // Freq -/-> Spike
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_discipline_transition(0, 3)); // Unset -/-> Sync
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_discipline_transition(0, 2)); // Unset -/-> Freq
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_discipline_transition(1, 3)); // Spike -/-> Sync
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_discipline_transition(3, 1)); // Sync -/-> Spike
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_can_discipline_transition(4, 1)); // Panic -/-> Spike
}

// ═══════════════════════════════════════════════════════════════════════
// Discipline state advancement tests
// ═══════════════════════════════════════════════════════════════════════

test "advance discipline: Unset -> Spike -> Freq -> Sync" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_advance_discipline(slot, 1)); // Unset -> Spike
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_get_discipline_state(slot));

    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_advance_discipline(slot, 2)); // Spike -> Freq
    try std.testing.expectEqual(@as(u8, 2), ntp.ntp_get_discipline_state(slot));

    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_advance_discipline(slot, 3)); // Freq -> Sync
    try std.testing.expectEqual(@as(u8, 3), ntp.ntp_get_discipline_state(slot));
}

test "advance discipline: Sync -> Panic -> Unset (recovery)" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);

    _ = ntp.ntp_advance_discipline(slot, 1); // Unset -> Spike
    _ = ntp.ntp_advance_discipline(slot, 2); // Spike -> Freq
    _ = ntp.ntp_advance_discipline(slot, 3); // Freq -> Sync

    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_advance_discipline(slot, 4)); // Sync -> Panic
    try std.testing.expectEqual(@as(u8, 4), ntp.ntp_get_discipline_state(slot));

    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_advance_discipline(slot, 0)); // Panic -> Unset
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_get_discipline_state(slot));
}

test "advance discipline: Sync -> Freq (LostLock)" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);

    _ = ntp.ntp_advance_discipline(slot, 1); // Unset -> Spike
    _ = ntp.ntp_advance_discipline(slot, 2); // Spike -> Freq
    _ = ntp.ntp_advance_discipline(slot, 3); // Freq -> Sync

    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_advance_discipline(slot, 2)); // Sync -> Freq
    try std.testing.expectEqual(@as(u8, 2), ntp.ntp_get_discipline_state(slot));
}

test "advance discipline rejects invalid transition" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);

    // Unset -> Sync is not valid (must go through Spike -> Freq first)
    const result = ntp.ntp_advance_discipline(slot, 3);
    try std.testing.expectEqual(@as(u8, 3), result); // InvalidPacket
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_get_discipline_state(slot)); // Still Unset
}

// ═══════════════════════════════════════════════════════════════════════
// Full lifecycle round-trip
// ═══════════════════════════════════════════════════════════════════════

test "full lifecycle: create -> exchange cycle -> destroy" {
    const slot = ntp.ntp_create(4, 4, 2);
    try std.testing.expect(slot >= 0);

    // First exchange
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_receive_request(slot, 100, 0, 100, 0x0C00_0000));
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_calculate(slot, 100, 0x0D00_0000));
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_send_response(slot));
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_reset_exchange(slot));
    try std.testing.expectEqual(@as(u32, 1), ntp.ntp_get_exchange_count(slot));

    // Second exchange
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_receive_request(slot, 200, 0, 200, 0x0C00_0000));
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_calculate(slot, 200, 0x0D00_0000));
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_send_response(slot));
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_reset_exchange(slot));
    try std.testing.expectEqual(@as(u32, 2), ntp.ntp_get_exchange_count(slot));

    ntp.ntp_destroy(slot);
}

test "full lifecycle with discipline and leap changes" {
    const slot = ntp.ntp_create(4, 4, 1);
    defer ntp.ntp_destroy(slot);

    // Advance discipline through normal path
    _ = ntp.ntp_advance_discipline(slot, 1); // Unset -> Spike
    _ = ntp.ntp_advance_discipline(slot, 2); // Spike -> Freq
    _ = ntp.ntp_advance_discipline(slot, 3); // Freq -> Sync
    try std.testing.expectEqual(@as(u8, 3), ntp.ntp_get_discipline_state(slot));

    // Set leap indicator for upcoming leap second
    _ = ntp.ntp_set_leap(slot, 1); // last_minute_61
    try std.testing.expectEqual(@as(u8, 1), ntp.ntp_get_leap(slot));

    // Run an exchange
    _ = ntp.ntp_receive_request(slot, 300, 0, 300, 0x0800_0000);
    _ = ntp.ntp_calculate(slot, 300, 0x0900_0000);
    _ = ntp.ntp_send_response(slot);
    _ = ntp.ntp_reset_exchange(slot);

    // Clear leap after leap second applied
    _ = ntp.ntp_set_leap(slot, 0); // no_warning
    try std.testing.expectEqual(@as(u8, 0), ntp.ntp_get_leap(slot));
}

// ═══════════════════════════════════════════════════════════════════════
// Error tracking
// ═══════════════════════════════════════════════════════════════════════

test "last_error is 255 after successful transition" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_receive_request(slot, 100, 0, 100, 0x0800_0000);
    try std.testing.expectEqual(@as(u8, 255), ntp.ntp_get_last_error(slot));
}

test "last_error is InvalidPacket after failed transition" {
    const slot = ntp.ntp_create(4, 4, 2);
    defer ntp.ntp_destroy(slot);
    _ = ntp.ntp_calculate(slot, 100, 0x0900_0000); // Rejected — Idle can't calculate
    try std.testing.expectEqual(@as(u8, 3), ntp.ntp_get_last_error(slot)); // InvalidPacket
}
