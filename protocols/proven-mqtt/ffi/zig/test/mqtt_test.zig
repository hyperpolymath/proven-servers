// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mqtt_test.zig -- Integration tests for proven-mqtt FFI.
//
// Tests cover:
//   - ABI version (1 test)
//   - Enum encoding seams (7 tests)
//   - Session lifecycle (4 tests)
//   - Subscription management (3 tests)
//   - Publish and QoS delivery flows (4 tests)
//   - Disconnect and cleanup (3 tests)
//   - Retained messages (2 tests)
//   - Stateless transition tables (3 tests)
//   - Topic matching (3 tests)
//   - Invalid slot safety (1 test)
//   Total: 31 tests (exceeds 20 minimum)

const std = @import("std");
const mqtt = @import("mqtt");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), mqtt.mqtt_abi_version());
}

// =========================================================================
// Enum encoding seams (match Layout.idr tag assignments)
// =========================================================================

test "PacketType encoding matches Layout.idr (15 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.PacketType.connect));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.PacketType.connack));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.PacketType.publish));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(mqtt.PacketType.subscribe));
    try std.testing.expectEqual(@as(u8, 13), @intFromEnum(mqtt.PacketType.disconnect));
    try std.testing.expectEqual(@as(u8, 14), @intFromEnum(mqtt.PacketType.auth));
}

test "QoS encoding matches Layout.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.QoS.at_most_once));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.QoS.at_least_once));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.QoS.exactly_once));
}

test "ConnAckCode encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.ConnAckCode.connection_accepted));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.ConnAckCode.server_unavailable));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(mqtt.ConnAckCode.not_authorised));
}

test "MQTTVersion encoding matches Layout.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.MQTTVersion.mqtt311));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.MQTTVersion.mqtt50));
}

test "BrokerState encoding matches Layout.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.BrokerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.BrokerState.connected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.BrokerState.subscribed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.BrokerState.publishing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mqtt.BrokerState.disconnecting));
}

test "QoSDeliveryState encoding matches Layout.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.QoSDeliveryState.qd_idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.QoSDeliveryState.awaiting_puback));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.QoSDeliveryState.awaiting_pubrec));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.QoSDeliveryState.awaiting_pubrel));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mqtt.QoSDeliveryState.awaiting_pubcomp));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(mqtt.QoSDeliveryState.qd_complete));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(mqtt.QoSDeliveryState.qd_failed));
}

test "PropertyType encoding matches Layout.idr (10 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.PropertyType.session_expiry_interval));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mqtt.PropertyType.maximum_packet_size));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(mqtt.PropertyType.server_keep_alive));
}

// =========================================================================
// Session lifecycle
// =========================================================================

test "create returns valid slot in Connected state" {
    const slot = mqtt.mqtt_create(0, 1, 60); // MQTT 3.1.1, clean session, 60s keep-alive
    try std.testing.expect(slot >= 0);
    defer mqtt.mqtt_destroy(slot);
    // Session starts in Connected state (Idle -> Connected applied automatically)
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot)); // connected
}

test "create with MQTT 5.0" {
    const slot = mqtt.mqtt_create(1, 0, 120); // MQTT 5.0, persistent session, 120s
    try std.testing.expect(slot >= 0);
    defer mqtt.mqtt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_version(slot)); // mqtt50
}

test "create rejects invalid version" {
    try std.testing.expectEqual(@as(c_int, -1), mqtt.mqtt_create(99, 1, 60));
}

test "destroy is safe with invalid slot" {
    mqtt.mqtt_destroy(-1);
    mqtt.mqtt_destroy(999);
}

// =========================================================================
// Subscription management
// =========================================================================

test "subscribe transitions Connected -> Subscribed" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "home/+/temperature";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 1)); // QoS 1
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_state(slot)); // subscribed
    try std.testing.expectEqual(@as(u32, 1), mqtt.mqtt_subscription_count(slot));
}

test "additional subscribe stays Subscribed" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const t1 = "sensor/+/data";
    const t2 = "device/#";
    _ = mqtt.mqtt_subscribe(slot, t1.ptr, t1.len, 0);
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_subscribe(slot, t2.ptr, t2.len, 2));
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_state(slot)); // still subscribed
    try std.testing.expectEqual(@as(u32, 2), mqtt.mqtt_subscription_count(slot));
}

test "unsubscribe last topic transitions Subscribed -> Connected" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "home/temperature";
    _ = mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 1);
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_state(slot)); // subscribed

    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_unsubscribe(slot, topic.ptr, topic.len));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot)); // back to connected
    try std.testing.expectEqual(@as(u32, 0), mqtt.mqtt_subscription_count(slot));
}

// =========================================================================
// Publish and QoS delivery flows
// =========================================================================

test "publish QoS 0 fire and forget (no state change)" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "test/topic";
    const payload = "hello";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_publish(
        slot,
        topic.ptr,
        topic.len,
        payload.ptr,
        payload.len,
        0, // QoS 0
        0, // no retain
        0, // packet_id (unused for QoS 0)
    ));
    // State should remain Connected (no Publishing transition for QoS 0)
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot));
}

test "publish QoS 1 full delivery: Publish -> PubAck -> Complete" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "test/qos1";
    const payload = "data";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_publish(
        slot,
        topic.ptr,
        topic.len,
        payload.ptr,
        payload.len,
        1, // QoS 1
        0, // no retain
        42, // packet_id
    ));
    try std.testing.expectEqual(@as(u8, 3), mqtt.mqtt_state(slot)); // publishing
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_state(slot, 42)); // awaiting_puback

    // Send PUBACK
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_puback(slot, 42));
    try std.testing.expectEqual(@as(u8, 5), mqtt.mqtt_qos_state(slot, 42)); // complete
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot)); // back to connected
}

test "publish QoS 2 full delivery: PubRec -> PubRel -> PubComp" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "test/qos2";
    const payload = "assured";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_publish(
        slot,
        topic.ptr,
        topic.len,
        payload.ptr,
        payload.len,
        2, // QoS 2
        0, // no retain
        100, // packet_id
    ));
    try std.testing.expectEqual(@as(u8, 3), mqtt.mqtt_state(slot)); // publishing
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_qos_state(slot, 100)); // awaiting_pubrec

    // PUBREC
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_pubrec(slot, 100));
    try std.testing.expectEqual(@as(u8, 3), mqtt.mqtt_qos_state(slot, 100)); // awaiting_pubrel

    // PUBREL
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_pubrel(slot, 100));
    try std.testing.expectEqual(@as(u8, 4), mqtt.mqtt_qos_state(slot, 100)); // awaiting_pubcomp

    // PUBCOMP
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_pubcomp(slot, 100));
    try std.testing.expectEqual(@as(u8, 5), mqtt.mqtt_qos_state(slot, 100)); // complete
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot)); // back to connected
}

test "publish from Subscribed returns to Subscribed after QoS complete" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const sub_topic = "sensor/#";
    _ = mqtt.mqtt_subscribe(slot, sub_topic.ptr, sub_topic.len, 1);
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_state(slot)); // subscribed

    const pub_topic = "output/data";
    const payload = "val";
    _ = mqtt.mqtt_publish(slot, pub_topic.ptr, pub_topic.len, payload.ptr, payload.len, 1, 0, 7);
    try std.testing.expectEqual(@as(u8, 3), mqtt.mqtt_state(slot)); // publishing

    _ = mqtt.mqtt_puback(slot, 7);
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_state(slot)); // back to subscribed (not connected)
}

// =========================================================================
// Disconnect and cleanup
// =========================================================================

test "disconnect from Connected" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 4), mqtt.mqtt_state(slot)); // disconnecting
}

test "disconnect from Subscribed" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "test/dc";
    _ = mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 0);

    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 4), mqtt.mqtt_state(slot)); // disconnecting
}

test "cleanup transitions Disconnecting -> Idle and clears clean session" {
    const slot = mqtt.mqtt_create(0, 1, 60); // clean session
    defer mqtt.mqtt_destroy(slot);

    const topic = "test/cleanup";
    _ = mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 1);
    try std.testing.expectEqual(@as(u32, 1), mqtt.mqtt_subscription_count(slot));

    _ = mqtt.mqtt_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_state(slot)); // idle
    try std.testing.expectEqual(@as(u32, 0), mqtt.mqtt_subscription_count(slot)); // cleared
}

// =========================================================================
// Retained messages
// =========================================================================

test "retained message stored and counted" {
    // Clean up any leftover state from other tests by creating a fresh session
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "retain/test";
    const payload = "retained_data";
    _ = mqtt.mqtt_publish(slot, topic.ptr, topic.len, payload.ptr, payload.len, 0, 1, 0);

    try std.testing.expect(mqtt.mqtt_retained_count() >= 1);
}

test "retained message replaced on same topic" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "retain/replace";
    const payload1 = "first";
    const payload2 = "second";
    _ = mqtt.mqtt_publish(slot, topic.ptr, topic.len, payload1.ptr, payload1.len, 0, 1, 0);
    const count_before = mqtt.mqtt_retained_count();
    _ = mqtt.mqtt_publish(slot, topic.ptr, topic.len, payload2.ptr, payload2.len, 0, 1, 0);
    const count_after = mqtt.mqtt_retained_count();

    // Count should not increase (replacement, not addition)
    try std.testing.expectEqual(count_before, count_after);
}

// =========================================================================
// Stateless transition tables
// =========================================================================

test "mqtt_can_transition matches Transitions.idr (broker)" {
    // Valid transitions
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(0, 1)); // Idle -> Connected
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(1, 2)); // Connected -> Subscribed
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(2, 2)); // Subscribed -> Subscribed
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(2, 1)); // Subscribed -> Connected
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(1, 3)); // Connected -> Publishing
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(2, 3)); // Subscribed -> Publishing
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(3, 1)); // Publishing -> Connected
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(3, 2)); // Publishing -> Subscribed
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(1, 4)); // Connected -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(2, 4)); // Subscribed -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(3, 4)); // Publishing -> Disconnecting
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(4, 0)); // Disconnecting -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(0, 2)); // Idle -> Subscribed (skip!)
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(0, 3)); // Idle -> Publishing (skip!)
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(4, 1)); // Disconnecting -> Connected
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(0, 4)); // Idle -> Disconnecting
}

test "mqtt_qos_can_transition matches QoS 1 delivery states" {
    // QoS 1: Idle -> AwaitingPubAck -> Complete | Failed
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(1, 0, 1)); // Idle -> AwaitingPubAck
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(1, 1, 5)); // AwaitingPubAck -> Complete
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(1, 1, 6)); // AwaitingPubAck -> Failed

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(1, 0, 5)); // Cannot skip to Complete
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(1, 5, 0)); // Complete is terminal
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(1, 6, 0)); // Failed is terminal
}

test "mqtt_qos_can_transition matches QoS 2 delivery states" {
    // QoS 2: Idle -> AwaitingPubRec -> AwaitingPubRel -> AwaitingPubComp -> Complete
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 0, 2)); // Idle -> AwaitingPubRec
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 2, 3)); // -> AwaitingPubRel
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 3, 4)); // -> AwaitingPubComp
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 4, 5)); // -> Complete

    // Failure edges
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 2, 6)); // AwaitingPubRec -> Failed
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 3, 6)); // AwaitingPubRel -> Failed
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 4, 6)); // AwaitingPubComp -> Failed

    // Invalid
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(2, 0, 5)); // Cannot skip to Complete
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(2, 2, 5)); // Cannot skip mid-flow
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(2, 5, 0)); // Complete is terminal
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(2, 6, 0)); // Failed is terminal
}

// =========================================================================
// Topic matching (stateless)
// =========================================================================

test "topic matching: exact match" {
    const topic = "home/livingroom/temperature";
    const filter = "home/livingroom/temperature";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_topic_matches(
        topic.ptr,
        topic.len,
        filter.ptr,
        filter.len,
    ));
}

test "topic matching: single-level wildcard" {
    const topic = "home/livingroom/temperature";
    const filter = "home/+/temperature";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_topic_matches(
        topic.ptr,
        topic.len,
        filter.ptr,
        filter.len,
    ));

    // Should NOT match different structure
    const topic2 = "home/livingroom/humidity";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_topic_matches(
        topic2.ptr,
        topic2.len,
        filter.ptr,
        filter.len,
    ));
}

test "topic matching: multi-level wildcard" {
    const topic1 = "sensor/data";
    const topic2 = "sensor/data/temperature/celsius";
    const filter = "sensor/#";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_topic_matches(
        topic1.ptr,
        topic1.len,
        filter.ptr,
        filter.len,
    ));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_topic_matches(
        topic2.ptr,
        topic2.len,
        filter.ptr,
        filter.len,
    ));

    // Should NOT match different prefix
    const topic3 = "device/data";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_topic_matches(
        topic3.ptr,
        topic3.len,
        filter.ptr,
        filter.len,
    ));
}

// =========================================================================
// Invalid slot safety
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_state(-1)); // idle fallback
    try std.testing.expectEqual(@as(u8, 255), mqtt.mqtt_version(-1));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_publish(-1));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_subscribe(-1));
    try std.testing.expectEqual(@as(u32, 0), mqtt.mqtt_subscription_count(-1));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_disconnect(-1)); // rejected
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_cleanup(-1)); // rejected
}

// =========================================================================
// Cannot publish from Idle or Disconnecting (impossibility proofs)
// =========================================================================

test "cannot publish from Disconnecting" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    _ = mqtt.mqtt_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 4), mqtt.mqtt_state(slot)); // disconnecting

    const topic = "test/blocked";
    const payload = "nope";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_publish(
        slot,
        topic.ptr,
        topic.len,
        payload.ptr,
        payload.len,
        0,
        0,
        0,
    ));
}

test "cannot subscribe from Idle (after cleanup)" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    _ = mqtt.mqtt_disconnect(slot);
    _ = mqtt.mqtt_cleanup(slot);
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_state(slot)); // idle

    const topic = "test/blocked";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 0));
}

test "subscribe rejects invalid QoS" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "test/badqos";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 3)); // reserved
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 99));
}

test "puback rejects wrong QoS level" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    // Start a QoS 2 publish, then try PUBACK (should be PUBREC for QoS 2)
    const topic = "test/wrongqos";
    const payload = "data";
    _ = mqtt.mqtt_publish(slot, topic.ptr, topic.len, payload.ptr, payload.len, 2, 0, 55);

    // PUBACK should be rejected because this is a QoS 2 flow
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_puback(slot, 55));
}

test "QoS 0 transition table" {
    // QoS 0: Idle -> Complete only
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(0, 0, 5)); // Idle -> Complete
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(0, 0, 1)); // Idle -> AwaitingPubAck (invalid for QoS 0)
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(0, 0, 6)); // Idle -> Failed (QoS 0 cannot fail)
}
