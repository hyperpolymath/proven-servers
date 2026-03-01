// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// queueconn_test.zig — Integration tests for proven-queueconn FFI.

const std = @import("std");
const testing = std.testing;
const queueconn = @import("queueconn");

test "ABI version returns 1" {
    try testing.expectEqual(@as(u32, 1), queueconn.queueconn_abi_version());
}

test "connect returns valid handle" {
    var err: queueconn.QueueError = .none;
    const h = queueconn.queueconn_connect(null, 5672, .at_least_once, &err);
    try testing.expect(h != null);
    try testing.expectEqual(queueconn.QueueError.none, err);
    try testing.expectEqual(queueconn.QueueState.connected, queueconn.queueconn_state(h));
    _ = queueconn.queueconn_disconnect(h);
}

test "subscribe: connected -> consuming" {
    var err: queueconn.QueueError = .none;
    const h = queueconn.queueconn_connect(null, 5672, .at_least_once, &err).?;
    const result = queueconn.queueconn_subscribe(h, null, 0);
    try testing.expectEqual(queueconn.QueueError.none, result);
    try testing.expectEqual(queueconn.QueueState.consuming, queueconn.queueconn_state(h));
    _ = queueconn.queueconn_disconnect(h);
}

test "unsubscribe: consuming -> connected" {
    var err: queueconn.QueueError = .none;
    const h = queueconn.queueconn_connect(null, 5672, .at_least_once, &err).?;
    _ = queueconn.queueconn_subscribe(h, null, 0);
    const result = queueconn.queueconn_unsubscribe(h);
    try testing.expectEqual(queueconn.QueueError.none, result);
    try testing.expectEqual(queueconn.QueueState.connected, queueconn.queueconn_state(h));
    _ = queueconn.queueconn_disconnect(h);
}

test "publish from connected succeeds" {
    var err: queueconn.QueueError = .none;
    const h = queueconn.queueconn_connect(null, 5672, .at_least_once, &err).?;
    const result = queueconn.queueconn_publish(h, null, 0, null, 100);
    try testing.expectEqual(queueconn.QueueError.none, result);
    _ = queueconn.queueconn_disconnect(h);
}

test "publish rejects oversized messages" {
    var err: queueconn.QueueError = .none;
    const h = queueconn.queueconn_connect(null, 5672, .at_least_once, &err).?;
    const result = queueconn.queueconn_publish(h, null, 0, null, queueconn.MAX_MESSAGE_SIZE + 1);
    try testing.expectEqual(queueconn.QueueError.message_too_large, result);
    _ = queueconn.queueconn_disconnect(h);
}

test "receive and acknowledge message" {
    var err: queueconn.QueueError = .none;
    const h = queueconn.queueconn_connect(null, 5672, .at_least_once, &err).?;
    _ = queueconn.queueconn_subscribe(h, null, 0);

    const msg = queueconn.queueconn_receive(h, &err);
    try testing.expect(msg != null);
    try testing.expectEqual(queueconn.MessageState.delivered, queueconn.queueconn_message_state(msg));

    const ack_result = queueconn.queueconn_acknowledge(msg);
    try testing.expectEqual(queueconn.QueueError.none, ack_result);
    try testing.expectEqual(queueconn.MessageState.acknowledged, queueconn.queueconn_message_state(msg));

    queueconn.queueconn_message_free(msg);
    _ = queueconn.queueconn_disconnect(h);
}

test "receive and reject message" {
    var err: queueconn.QueueError = .none;
    const h = queueconn.queueconn_connect(null, 5672, .at_least_once, &err).?;
    _ = queueconn.queueconn_subscribe(h, null, 0);

    const msg = queueconn.queueconn_receive(h, &err);
    try testing.expect(msg != null);

    const reject_result = queueconn.queueconn_reject(msg, 1);
    try testing.expectEqual(queueconn.QueueError.none, reject_result);
    try testing.expectEqual(queueconn.MessageState.rejected, queueconn.queueconn_message_state(msg));

    queueconn.queueconn_message_free(msg);
    _ = queueconn.queueconn_disconnect(h);
}

test "cannot receive when not consuming" {
    var err: queueconn.QueueError = .none;
    const h = queueconn.queueconn_connect(null, 5672, .at_least_once, &err).?;
    const msg = queueconn.queueconn_receive(h, &err);
    try testing.expect(msg == null);
    try testing.expect(err != queueconn.QueueError.none);
    _ = queueconn.queueconn_disconnect(h);
}

test "NULL handle safety" {
    try testing.expectEqual(queueconn.QueueState.disconnected, queueconn.queueconn_state(null));
    try testing.expect(queueconn.queueconn_disconnect(null) != queueconn.QueueError.none);
    try testing.expect(queueconn.queueconn_subscribe(null, null, 0) != queueconn.QueueError.none);
    try testing.expect(queueconn.queueconn_publish(null, null, 0, null, 0) != queueconn.QueueError.none);
    try testing.expectEqual(queueconn.MessageState.expired, queueconn.queueconn_message_state(null));
    queueconn.queueconn_message_free(null); // must not crash
}

test "QueueOp enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(queueconn.QueueOp.publish));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(queueconn.QueueOp.subscribe));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(queueconn.QueueOp.acknowledge));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(queueconn.QueueOp.reject));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(queueconn.QueueOp.peek));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(queueconn.QueueOp.purge));
}

test "QueueState enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(queueconn.QueueState.disconnected));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(queueconn.QueueState.connected));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(queueconn.QueueState.consuming));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(queueconn.QueueState.producing));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(queueconn.QueueState.failed));
}

test "DeliveryGuarantee enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(queueconn.DeliveryGuarantee.at_most_once));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(queueconn.DeliveryGuarantee.at_least_once));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(queueconn.DeliveryGuarantee.exactly_once));
}

test "MessageState enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(queueconn.MessageState.pending));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(queueconn.MessageState.delivered));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(queueconn.MessageState.acknowledged));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(queueconn.MessageState.rejected));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(queueconn.MessageState.dead_lettered));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(queueconn.MessageState.expired));
}

test "QueueError enum tags match C header" {
    try testing.expectEqual(@as(u8, 0), @intFromEnum(queueconn.QueueError.none));
    try testing.expectEqual(@as(u8, 1), @intFromEnum(queueconn.QueueError.connection_lost));
    try testing.expectEqual(@as(u8, 2), @intFromEnum(queueconn.QueueError.queue_not_found));
    try testing.expectEqual(@as(u8, 3), @intFromEnum(queueconn.QueueError.message_too_large));
    try testing.expectEqual(@as(u8, 4), @intFromEnum(queueconn.QueueError.quota_exceeded));
    try testing.expectEqual(@as(u8, 5), @intFromEnum(queueconn.QueueError.ack_timeout));
    try testing.expectEqual(@as(u8, 6), @intFromEnum(queueconn.QueueError.unauthorized));
    try testing.expectEqual(@as(u8, 7), @intFromEnum(queueconn.QueueError.serialization_error));
}
