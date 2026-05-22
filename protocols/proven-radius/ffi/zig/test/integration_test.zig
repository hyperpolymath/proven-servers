// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-radius FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety

const std = @import("std");
const radius = @import("radius");

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), radius.radius_abi_version());
}

test "PacketType encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.PacketType.access_request));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.PacketType.access_accept));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(radius.PacketType.access_reject));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.PacketType.accounting_request));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(radius.PacketType.accounting_response));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(radius.PacketType.access_challenge));
}

test "AttributeType encoding matches Types.idr (9 tags)" {
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.AttributeType.user_name));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.AttributeType.user_password));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.AttributeType.nas_ip_address));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(radius.AttributeType.nas_port));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(radius.AttributeType.service_type));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(radius.AttributeType.framed_protocol));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(radius.AttributeType.framed_ip_address));
    try std.testing.expectEqual(@as(u8, 18), @intFromEnum(radius.AttributeType.reply_message));
    try std.testing.expectEqual(@as(u8, 27), @intFromEnum(radius.AttributeType.session_timeout));
}

test "ServiceType encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.ServiceType.login));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.ServiceType.framed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(radius.ServiceType.callback_login));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.ServiceType.callback_framed));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(radius.ServiceType.outbound));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(radius.ServiceType.administrative));
}

test "AuthMethod encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(radius.AuthMethod.pap));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.AuthMethod.chap));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.AuthMethod.mschap));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(radius.AuthMethod.mschapv2));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.AuthMethod.eap));
}

test "SessionState encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(radius.SessionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.SessionState.authenticating));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.SessionState.authorized));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(radius.SessionState.rejected));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.SessionState.challenged));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(radius.SessionState.accounting));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(radius.SessionState.complete));
}

test "RadiusResult encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(radius.RadiusResult.ok));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(radius.RadiusResult.err));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(radius.RadiusResult.invalid_param));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(radius.RadiusResult.pool_exhausted));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(radius.RadiusResult.bad_secret));
}

test "create returns valid slot" {
    const slot = radius.radius_create(0, 0);
    try std.testing.expect(slot >= 0);
    defer radius.radius_destroy(slot);
}

test "destroy is safe with invalid slot" {
    radius.radius_destroy(-1);
    radius.radius_destroy(999);
}

test "state queries safe on invalid slot" {
    _ = radius.radius_state(-1);
}

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), radius.radius_can_transition(0, 0));
}

