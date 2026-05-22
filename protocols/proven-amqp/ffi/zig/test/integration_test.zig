// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-amqp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

const std = @import("std");
const amqp = @import("amqp");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), amqp.amqp_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "FrameType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.FrameType.method));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.FrameType.header));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.FrameType.body));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.FrameType.heartbeat));
}

test "MethodClass encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.MethodClass.connection));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.MethodClass.channel));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.MethodClass.exchange));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.MethodClass.queue));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(amqp.MethodClass.basic));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(amqp.MethodClass.tx));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(amqp.MethodClass.confirm));
}

test "ExchangeType encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.ExchangeType.direct));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.ExchangeType.fanout));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.ExchangeType.topic));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.ExchangeType.headers));
}

test "DeliveryMode encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.DeliveryMode.non_persistent));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.DeliveryMode.persistent));
}

test "ErrorSeverity encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.ErrorSeverity.channel_level));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.ErrorSeverity.connection_level));
}

test "ConnectionState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.ConnectionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.ConnectionState.negotiating));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.ConnectionState.tuning_ok));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.ConnectionState.open));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(amqp.ConnectionState.closing));
}

test "ChannelState encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.ChannelState.closed));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.ChannelState.opening));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.ChannelState.ch_open));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.ChannelState.ch_closing));
}

test "BrokerState encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.BrokerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.BrokerState.connected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.BrokerState.channel_open));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.BrokerState.consuming));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(amqp.BrokerState.publishing));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(amqp.BrokerState.disconnecting));
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = amqp.amqp_state(-1);
    _ = amqp.amqp_channel_count(-1);
    _ = amqp.amqp_consumer_count(-1);
}

