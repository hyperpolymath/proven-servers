// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// amqp_test.zig -- Integration tests for proven-amqp FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Layout.idr parity)
//   - Session lifecycle (create/destroy)
//   - Channel management (open/close/count)
//   - Exchange declarations
//   - Queue declarations (including exclusive+durable rejection)
//   - Queue bindings
//   - Basic.Publish / Basic.Consume / Basic.Cancel
//   - Basic.Ack / Basic.Nack / Basic.Reject
//   - Basic.Qos
//   - Disconnect / Cleanup
//   - Stateless broker transition table
//   - Routing key matching (direct, fanout, topic)
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

test "FrameType encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.FrameType.method));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.FrameType.header));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.FrameType.body));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.FrameType.heartbeat));
}

test "MethodClass encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.MethodClass.connection));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.MethodClass.channel));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.MethodClass.exchange));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.MethodClass.queue));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(amqp.MethodClass.basic));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(amqp.MethodClass.tx));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(amqp.MethodClass.confirm));
}

test "ExchangeType encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.ExchangeType.direct));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.ExchangeType.fanout));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.ExchangeType.topic));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.ExchangeType.headers));
}

test "DeliveryMode encoding matches Layout.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.DeliveryMode.non_persistent));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.DeliveryMode.persistent));
}

test "ErrorSeverity encoding matches Layout.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.ErrorSeverity.channel_level));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.ErrorSeverity.connection_level));
}

test "BrokerState encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.BrokerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.BrokerState.connected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.BrokerState.channel_open));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.BrokerState.consuming));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(amqp.BrokerState.publishing));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(amqp.BrokerState.disconnecting));
}

test "ConnectionState encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.ConnectionState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.ConnectionState.negotiating));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.ConnectionState.tuning_ok));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.ConnectionState.open));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(amqp.ConnectionState.closing));
}

test "ChannelState encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(amqp.ChannelState.closed));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(amqp.ChannelState.opening));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(amqp.ChannelState.ch_open));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(amqp.ChannelState.ch_closing));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Connected state" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    try std.testing.expect(slot >= 0);
    defer amqp.amqp_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_state(slot)); // Connected
}

test "create rejects empty vhost" {
    const vhost = "x";
    const slot = amqp.amqp_create(vhost.ptr, 0, 131072, 16, 60);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    amqp.amqp_destroy(-1);
    amqp.amqp_destroy(999);
}

// =========================================================================
// Channel management
// =========================================================================

test "channel_open transitions Connected -> ChannelOpen" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_channel_open(slot, 1));
    try std.testing.expectEqual(@as(u8, 2), amqp.amqp_state(slot)); // ChannelOpen
    try std.testing.expectEqual(@as(u16, 1), amqp.amqp_channel_count(slot));
}

test "multiple channels stay in ChannelOpen" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_channel_open(slot, 1));
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_channel_open(slot, 2));
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_channel_open(slot, 3));
    try std.testing.expectEqual(@as(u8, 2), amqp.amqp_state(slot));
    try std.testing.expectEqual(@as(u16, 3), amqp.amqp_channel_count(slot));
}

test "channel_close last channel transitions ChannelOpen -> Connected" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_channel_open(slot, 1));
    try std.testing.expectEqual(@as(u8, 2), amqp.amqp_state(slot));

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_channel_close(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_state(slot)); // Connected
    try std.testing.expectEqual(@as(u16, 0), amqp.amqp_channel_count(slot));
}

test "channel_open rejects channel 0" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_channel_open(slot, 0));
}

test "channel_open rejects duplicate channel number" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_channel_open(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_channel_open(slot, 1));
}

// =========================================================================
// Exchange declarations
// =========================================================================

test "exchange_declare creates exchange on open channel" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    const name = "test.exchange";
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_exchange_declare(
        slot, 1, name.ptr, name.len, 0, 1, 0, 0,
    ));
}

test "exchange_declare rejects invalid exchange type" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    const name = "bad.exchange";
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_exchange_declare(
        slot, 1, name.ptr, name.len, 99, 0, 0, 0,
    ));
}

// =========================================================================
// Queue declarations (including exclusive+durable proof)
// =========================================================================

test "queue_declare creates durable queue" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    const name = "orders";
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_queue_declare(
        slot, 1, name.ptr, name.len, 1, 0, 0,
    ));
}

test "queue_declare rejects exclusive+durable combination" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    const name = "bad-queue";
    // exclusive=1, durable=1 should be rejected (matches Idris2 proof)
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_queue_declare(
        slot, 1, name.ptr, name.len, 1, 1, 0,
    ));
}

test "queue_declare allows exclusive non-durable" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    const name = "reply-to";
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_queue_declare(
        slot, 1, name.ptr, name.len, 0, 1, 1,
    ));
}

// =========================================================================
// Queue bindings
// =========================================================================

test "queue_bind creates binding" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    const queue_n = "orders";
    _ = amqp.amqp_queue_declare(slot, 1, queue_n.ptr, queue_n.len, 1, 0, 0);

    const exch = "amq.direct";
    _ = amqp.amqp_exchange_declare(slot, 1, exch.ptr, exch.len, 0, 1, 0, 0);

    const rk = "order.created";
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_queue_bind(
        slot, 1, queue_n.ptr, queue_n.len, exch.ptr, exch.len, rk.ptr, rk.len,
    ));
}

// =========================================================================
// Basic.Publish
// =========================================================================

test "basic_publish succeeds from ChannelOpen" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    const exch = "";
    const rk = "my.queue";
    const body = "hello world";
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_basic_publish(
        slot, 1, exch.ptr, exch.len, rk.ptr, rk.len,
        body.ptr, body.len, 1, 0, 0,
    ));
    try std.testing.expectEqual(@as(u8, 4), amqp.amqp_state(slot)); // Publishing
}

test "basic_publish rejects invalid priority > 9" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    const exch = "";
    const rk = "q";
    const body = "x";
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_basic_publish(
        slot, 1, exch.ptr, exch.len, rk.ptr, rk.len,
        body.ptr, body.len, 0, 10, 0,
    ));
}

// =========================================================================
// Basic.Consume / Basic.Cancel
// =========================================================================

test "basic_consume transitions ChannelOpen -> Consuming" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    const queue_n = "events";
    _ = amqp.amqp_queue_declare(slot, 1, queue_n.ptr, queue_n.len, 0, 0, 0);

    const tag = "ctag-1";
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_basic_consume(
        slot, 1, queue_n.ptr, queue_n.len, tag.ptr, tag.len, 0, 0,
    ));
    try std.testing.expectEqual(@as(u8, 3), amqp.amqp_state(slot)); // Consuming
    try std.testing.expectEqual(@as(u32, 1), amqp.amqp_consumer_count(slot));
}

test "basic_cancel last consumer transitions Consuming -> ChannelOpen" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    const queue_n = "events";
    _ = amqp.amqp_queue_declare(slot, 1, queue_n.ptr, queue_n.len, 0, 0, 0);

    const tag = "ctag-1";
    _ = amqp.amqp_basic_consume(slot, 1, queue_n.ptr, queue_n.len, tag.ptr, tag.len, 0, 0);
    try std.testing.expectEqual(@as(u8, 3), amqp.amqp_state(slot));

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_basic_cancel(slot, 1, tag.ptr, tag.len));
    try std.testing.expectEqual(@as(u8, 2), amqp.amqp_state(slot)); // ChannelOpen
    try std.testing.expectEqual(@as(u32, 0), amqp.amqp_consumer_count(slot));
}

test "can_publish and can_consume from ChannelOpen" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_publish(slot));
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_consume(slot));
}

// =========================================================================
// Basic.Ack / Basic.Nack / Basic.Reject
// =========================================================================

test "basic_ack succeeds from ChannelOpen" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_basic_ack(slot, 1, 1, 0));
}

test "basic_nack succeeds from ChannelOpen" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_basic_nack(slot, 1, 1, 0, 1));
}

test "basic_reject succeeds from ChannelOpen" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_basic_reject(slot, 1, 1, 1));
}

// =========================================================================
// Basic.Qos
// =========================================================================

test "basic_qos sets prefetch on channel" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_basic_qos(slot, 1, 10, 0, 0));
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Connected -> Disconnecting" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 5), amqp.amqp_state(slot)); // Disconnecting
}

test "disconnect from ChannelOpen transitions to Disconnecting" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);

    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 5), amqp.amqp_state(slot));
}

test "cleanup transitions Disconnecting -> Idle" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    _ = amqp.amqp_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_state(slot)); // Idle
}

test "cleanup clears channels and consumers" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    _ = amqp.amqp_channel_open(slot, 1);
    try std.testing.expectEqual(@as(u16, 1), amqp.amqp_channel_count(slot));

    _ = amqp.amqp_disconnect(slot);
    _ = amqp.amqp_cleanup(slot);
    try std.testing.expectEqual(@as(u16, 0), amqp.amqp_channel_count(slot));
    try std.testing.expectEqual(@as(u32, 0), amqp.amqp_consumer_count(slot));
}

test "cleanup rejected from non-Disconnecting state" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_cleanup(slot));
}

test "disconnect rejected from Idle" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    _ = amqp.amqp_disconnect(slot);
    _ = amqp.amqp_cleanup(slot);
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_disconnect(slot));
}

// =========================================================================
// Impossibility tests (invalid transitions)
// =========================================================================

test "cannot open channel from Idle" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    _ = amqp.amqp_disconnect(slot);
    _ = amqp.amqp_cleanup(slot);
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_channel_open(slot, 1));
}

test "cannot publish from Connected (no channel)" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    const exch = "";
    const rk = "q";
    const body = "x";
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_basic_publish(
        slot, 1, exch.ptr, exch.len, rk.ptr, rk.len,
        body.ptr, body.len, 0, 0, 0,
    ));
}

test "cannot consume from Disconnecting" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);

    _ = amqp.amqp_disconnect(slot);
    const queue_n = "q";
    const tag = "t";
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_basic_consume(
        slot, 1, queue_n.ptr, queue_n.len, tag.ptr, tag.len, 0, 0,
    ));
}

// =========================================================================
// Stateless broker transition table
// =========================================================================

test "amqp_can_transition matches Transitions.idr" {
    // Forward lifecycle
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(0, 1)); // Idle -> Connected
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(1, 2)); // Connected -> ChannelOpen
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(2, 2)); // ChannelOpen -> ChannelOpen
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(2, 1)); // ChannelOpen -> Connected
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(2, 3)); // ChannelOpen -> Consuming
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(3, 3)); // Consuming -> Consuming
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(3, 2)); // Consuming -> ChannelOpen
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(2, 4)); // ChannelOpen -> Publishing
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(3, 4)); // Consuming -> Publishing
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(4, 2)); // Publishing -> ChannelOpen
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(4, 3)); // Publishing -> Consuming

    // Disconnect edges
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(1, 5)); // Connected -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(2, 5)); // ChannelOpen -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(3, 5)); // Consuming -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(4, 5)); // Publishing -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_can_transition(5, 0)); // Disconnecting -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_can_transition(0, 2)); // Idle -/-> ChannelOpen
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_can_transition(0, 3)); // Idle -/-> Consuming
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_can_transition(5, 1)); // Disconnecting -/-> Connected
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_can_transition(0, 5)); // Idle -/-> Disconnecting
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_can_transition(5, 2)); // Disconnecting -/-> ChannelOpen
}

// =========================================================================
// Routing key matching (stateless)
// =========================================================================

test "direct routing: exact match" {
    const rk = "order.created";
    const pat = "order.created";
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_routing_match(
        rk.ptr, rk.len, pat.ptr, pat.len, 0,
    ));
}

test "direct routing: no match on different key" {
    const rk = "order.created";
    const pat = "order.updated";
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_routing_match(
        rk.ptr, rk.len, pat.ptr, pat.len, 0,
    ));
}

test "fanout routing: always matches" {
    const rk = "anything";
    const pat = "ignored";
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_routing_match(
        rk.ptr, rk.len, pat.ptr, pat.len, 1,
    ));
}

test "topic routing: exact match" {
    const rk = "stock.usd.nyse";
    const pat = "stock.usd.nyse";
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_routing_match(
        rk.ptr, rk.len, pat.ptr, pat.len, 2,
    ));
}

test "topic routing: star wildcard" {
    const rk = "stock.usd.nyse";
    const pat = "stock.*.nyse";
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_routing_match(
        rk.ptr, rk.len, pat.ptr, pat.len, 2,
    ));
}

test "topic routing: hash wildcard" {
    const rk = "stock.usd.nyse";
    const pat = "stock.#";
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_routing_match(
        rk.ptr, rk.len, pat.ptr, pat.len, 2,
    ));
}

test "topic routing: hash matches everything" {
    const rk = "any.routing.key.at.all";
    const pat = "#";
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_routing_match(
        rk.ptr, rk.len, pat.ptr, pat.len, 2,
    ));
}

test "topic routing: no match on different prefix" {
    const rk = "stock.usd.nyse";
    const pat = "bond.*.nyse";
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_routing_match(
        rk.ptr, rk.len, pat.ptr, pat.len, 2,
    ));
}

test "topic routing: star does not span levels" {
    const rk = "stock.usd.sub.nyse";
    const pat = "stock.*.nyse";
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_routing_match(
        rk.ptr, rk.len, pat.ptr, pat.len, 2,
    ));
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_state(-1));
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_can_publish(-1));
    try std.testing.expectEqual(@as(u8, 0), amqp.amqp_can_consume(-1));
    try std.testing.expectEqual(@as(u16, 0), amqp.amqp_channel_count(-1));
    try std.testing.expectEqual(@as(u32, 0), amqp.amqp_consumer_count(-1));
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), amqp.amqp_cleanup(-1));
}

// =========================================================================
// Channel close cancels consumers
// =========================================================================

test "channel_close cancels all consumers on that channel" {
    const vhost = "/";
    const slot = amqp.amqp_create(vhost.ptr, vhost.len, 131072, 16, 60);
    defer amqp.amqp_destroy(slot);
    _ = amqp.amqp_channel_open(slot, 1);
    _ = amqp.amqp_channel_open(slot, 2);

    const queue_n = "events";
    _ = amqp.amqp_queue_declare(slot, 1, queue_n.ptr, queue_n.len, 0, 0, 0);

    const tag1 = "ctag-ch1";
    const tag2 = "ctag-ch2";
    _ = amqp.amqp_basic_consume(slot, 1, queue_n.ptr, queue_n.len, tag1.ptr, tag1.len, 0, 0);
    _ = amqp.amqp_basic_consume(slot, 2, queue_n.ptr, queue_n.len, tag2.ptr, tag2.len, 0, 0);
    try std.testing.expectEqual(@as(u32, 2), amqp.amqp_consumer_count(slot));

    // Close channel 1 — should cancel ctag-ch1 but leave ctag-ch2
    _ = amqp.amqp_channel_close(slot, 1);
    try std.testing.expectEqual(@as(u32, 1), amqp.amqp_consumer_count(slot));
    try std.testing.expectEqual(@as(u8, 3), amqp.amqp_state(slot)); // Still Consuming
}
