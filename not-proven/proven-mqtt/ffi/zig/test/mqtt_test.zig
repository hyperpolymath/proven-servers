// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// mqtt_test.zig -- Integration tests for proven-mqtt FFI.

const std = @import("std");
const mqtt = @import("mqtt");

// =========================================================================
// ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), mqtt.mqtt_abi_version());
}

// =========================================================================
// Enum encoding seams
// =========================================================================

test "PacketType encoding matches Layout.idr (15 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.PacketType.connect));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.PacketType.connack));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.PacketType.publish));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.PacketType.puback));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mqtt.PacketType.pubrec));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(mqtt.PacketType.pubrel));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(mqtt.PacketType.pubcomp));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(mqtt.PacketType.subscribe));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(mqtt.PacketType.suback));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(mqtt.PacketType.unsubscribe));
    try std.testing.expectEqual(@as(u8, 10), @intFromEnum(mqtt.PacketType.unsuback));
    try std.testing.expectEqual(@as(u8, 11), @intFromEnum(mqtt.PacketType.pingreq));
    try std.testing.expectEqual(@as(u8, 12), @intFromEnum(mqtt.PacketType.pingresp));
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
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.ConnAckCode.unacceptable_protocol));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.ConnAckCode.identifier_rejected));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.ConnAckCode.server_unavailable));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mqtt.ConnAckCode.bad_credentials));
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
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.PropertyType.receive_maximum));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.PropertyType.maximum_qos));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.PropertyType.retain_available));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mqtt.PropertyType.maximum_packet_size));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(mqtt.PropertyType.topic_alias_maximum));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(mqtt.PropertyType.wildcard_sub_available));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(mqtt.PropertyType.sub_id_available));
    try std.testing.expectEqual(@as(u8, 8), @intFromEnum(mqtt.PropertyType.shared_sub_available));
    try std.testing.expectEqual(@as(u8, 9), @intFromEnum(mqtt.PropertyType.server_keep_alive));
}

test "PacketDirection encoding matches Layout.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.PacketDirection.client_to_server));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.PacketDirection.server_to_client));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.PacketDirection.bidirectional));
}

test "SubAckCode encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.SubAckCode.granted_qos0));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.SubAckCode.granted_qos1));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.SubAckCode.granted_qos2));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.SubAckCode.sub_failure));
}

// =========================================================================
// Lifecycle
// =========================================================================

test "create returns valid slot in Connected state (MQTT 3.1.1)" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    try std.testing.expect(slot >= 0);
    defer mqtt.mqtt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_version(slot));
}

test "create returns valid slot (MQTT 5.0)" {
    const slot = mqtt.mqtt_create(1, 0, 120);
    try std.testing.expect(slot >= 0);
    defer mqtt.mqtt_destroy(slot);
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_version(slot));
}

test "create rejects invalid version" {
    const slot = mqtt.mqtt_create(99, 1, 60);
    try std.testing.expectEqual(@as(c_int, -1), slot);
}

test "destroy is safe with invalid slot" {
    mqtt.mqtt_destroy(-1);
    mqtt.mqtt_destroy(999);
}

// =========================================================================
// Subscribe / Unsubscribe
// =========================================================================

test "subscribe transitions Connected -> Subscribed" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "home/temperature";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 1));
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_state(slot));
    try std.testing.expectEqual(@as(u32, 1), mqtt.mqtt_subscription_count(slot));
}

test "multiple subscriptions stay in Subscribed" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const t1 = "home/temperature";
    const t2 = "home/humidity";
    const t3 = "sensor/#";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_subscribe(slot, t1.ptr, t1.len, 0));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_subscribe(slot, t2.ptr, t2.len, 1));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_subscribe(slot, t3.ptr, t3.len, 2));
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_state(slot));
    try std.testing.expectEqual(@as(u32, 3), mqtt.mqtt_subscription_count(slot));
}

test "unsubscribe last topic transitions Subscribed -> Connected" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "home/temperature";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 1));
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_state(slot));

    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_unsubscribe(slot, topic.ptr, topic.len));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot));
    try std.testing.expectEqual(@as(u32, 0), mqtt.mqtt_subscription_count(slot));
}

test "subscribe rejects invalid QoS" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "test/topic";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 3));
}

test "subscribe rejects empty topic" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "x";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_subscribe(slot, topic.ptr, 0, 0));
}

// =========================================================================
// Publish (QoS 0 -- fire and forget)
// =========================================================================

test "QoS 0 publish succeeds without state change" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "sensor/data";
    const payload = "23.5";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_publish(
        slot, topic.ptr, topic.len, payload.ptr, payload.len, 0, 0, 0,
    ));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot));
}

test "can_publish returns 1 from Connected and Subscribed" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_publish(slot));

    const topic = "test/topic";
    _ = mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 0);
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_publish(slot));
}

test "can_subscribe returns 1 from Connected and Subscribed" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_subscribe(slot));

    const topic = "test/topic";
    _ = mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 0);
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_subscribe(slot));
}

// =========================================================================
// Publish (QoS 1 -- acknowledged delivery)
// =========================================================================

test "QoS 1 publish transitions to Publishing and PUBACK completes" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "sensor/data";
    const payload = "23.5";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_publish(
        slot, topic.ptr, topic.len, payload.ptr, payload.len, 1, 0, 42,
    ));
    try std.testing.expectEqual(@as(u8, 3), mqtt.mqtt_state(slot));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_state(slot, 42));

    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_puback(slot, 42));
    try std.testing.expectEqual(@as(u8, 5), mqtt.mqtt_qos_state(slot, 42));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot));
}

test "QoS 1 from Subscribed returns to Subscribed after PUBACK" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const sub_topic = "home/#";
    _ = mqtt.mqtt_subscribe(slot, sub_topic.ptr, sub_topic.len, 1);
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_state(slot));

    const topic = "sensor/data";
    const payload = "23.5";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_publish(
        slot, topic.ptr, topic.len, payload.ptr, payload.len, 1, 0, 100,
    ));
    try std.testing.expectEqual(@as(u8, 3), mqtt.mqtt_state(slot));

    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_puback(slot, 100));
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_state(slot));
}

// =========================================================================
// Publish (QoS 2 -- exactly once delivery)
// =========================================================================

test "QoS 2 full flow: PUBLISH -> PUBREC -> PUBREL -> PUBCOMP" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "critical/data";
    const payload = "important";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_publish(
        slot, topic.ptr, topic.len, payload.ptr, payload.len, 2, 0, 1,
    ));
    try std.testing.expectEqual(@as(u8, 3), mqtt.mqtt_state(slot));
    try std.testing.expectEqual(@as(u8, 2), mqtt.mqtt_qos_state(slot, 1));

    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_pubrec(slot, 1));
    try std.testing.expectEqual(@as(u8, 3), mqtt.mqtt_qos_state(slot, 1));

    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_pubrel(slot, 1));
    try std.testing.expectEqual(@as(u8, 4), mqtt.mqtt_qos_state(slot, 1));

    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_pubcomp(slot, 1));
    try std.testing.expectEqual(@as(u8, 5), mqtt.mqtt_qos_state(slot, 1));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_state(slot));
}

test "QoS 2 rejects out-of-order acknowledgement" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "critical/data";
    const payload = "important";
    _ = mqtt.mqtt_publish(slot, topic.ptr, topic.len, payload.ptr, payload.len, 2, 0, 5);

    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_pubrel(slot, 5));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_pubcomp(slot, 5));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_puback(slot, 5));
}

// =========================================================================
// Retained messages
// =========================================================================

test "publish with retain stores message" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const initial_count = mqtt.mqtt_retained_count();

    const topic = "retain/test";
    const payload = "retained-value";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_publish(
        slot, topic.ptr, topic.len, payload.ptr, payload.len, 0, 1, 0,
    ));

    try std.testing.expect(mqtt.mqtt_retained_count() > initial_count);
}

test "publish with retain and empty payload deletes retained message" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "retain/delete";
    const payload = "to-delete";
    _ = mqtt.mqtt_publish(slot, topic.ptr, topic.len, payload.ptr, payload.len, 0, 1, 0);
    const count_before = mqtt.mqtt_retained_count();

    const empty = "x";
    _ = mqtt.mqtt_publish(slot, topic.ptr, topic.len, empty.ptr, 0, 0, 1, 0);

    try std.testing.expect(mqtt.mqtt_retained_count() < count_before);
}

// =========================================================================
// Disconnect / Cleanup
// =========================================================================

test "disconnect transitions Connected -> Disconnecting" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 4), mqtt.mqtt_state(slot));
}

test "disconnect from Subscribed transitions to Disconnecting" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "test/topic";
    _ = mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 0);
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_disconnect(slot));
    try std.testing.expectEqual(@as(u8, 4), mqtt.mqtt_state(slot));
}

test "cleanup transitions Disconnecting -> Idle" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    _ = mqtt.mqtt_disconnect(slot);
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_cleanup(slot));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_state(slot));
}

test "cleanup with clean session clears subscriptions" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "persistent/topic";
    _ = mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 1);
    try std.testing.expectEqual(@as(u32, 1), mqtt.mqtt_subscription_count(slot));

    _ = mqtt.mqtt_disconnect(slot);
    _ = mqtt.mqtt_cleanup(slot);
    try std.testing.expectEqual(@as(u32, 0), mqtt.mqtt_subscription_count(slot));
}

test "cleanup rejected from non-Disconnecting state" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_cleanup(slot));
}

test "disconnect rejected from Idle" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    _ = mqtt.mqtt_disconnect(slot);
    _ = mqtt.mqtt_cleanup(slot);
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_disconnect(slot));
}

// =========================================================================
// Impossibility tests (invalid transitions)
// =========================================================================

test "cannot subscribe from Idle" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    _ = mqtt.mqtt_disconnect(slot);
    _ = mqtt.mqtt_cleanup(slot);
    const topic = "test/topic";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_subscribe(slot, topic.ptr, topic.len, 0));
}

test "cannot publish from Idle" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    _ = mqtt.mqtt_disconnect(slot);
    _ = mqtt.mqtt_cleanup(slot);
    const topic = "test/topic";
    const payload = "data";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_publish(
        slot, topic.ptr, topic.len, payload.ptr, payload.len, 0, 0, 0,
    ));
}

test "cannot publish from Disconnecting" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    _ = mqtt.mqtt_disconnect(slot);
    const topic = "test/topic";
    const payload = "data";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_publish(
        slot, topic.ptr, topic.len, payload.ptr, payload.len, 0, 0, 0,
    ));
}

test "cannot subscribe from Publishing" {
    const slot = mqtt.mqtt_create(0, 1, 60);
    defer mqtt.mqtt_destroy(slot);

    const topic = "sensor/data";
    const payload = "23.5";
    _ = mqtt.mqtt_publish(slot, topic.ptr, topic.len, payload.ptr, payload.len, 1, 0, 1);
    try std.testing.expectEqual(@as(u8, 3), mqtt.mqtt_state(slot));

    const sub_topic = "test/#";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_subscribe(slot, sub_topic.ptr, sub_topic.len, 0));
}

// =========================================================================
// Stateless broker transition table
// =========================================================================

test "mqtt_can_transition matches Transitions.idr" {
    // Forward lifecycle
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(0, 1));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(1, 2));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(2, 2));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(2, 1));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(1, 3));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(2, 3));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(3, 1));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(3, 2));

    // Disconnect edges
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(1, 4));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(2, 4));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(3, 4));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_can_transition(4, 0));

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(0, 2));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(0, 3));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(4, 1));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(0, 4));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(4, 2));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(4, 3));
}

// =========================================================================
// Stateless QoS delivery transition table
// =========================================================================

test "mqtt_qos_can_transition matches Transitions.idr" {
    // QoS 0
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(0, 0, 5));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(0, 0, 1));

    // QoS 1
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(1, 0, 1));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(1, 1, 5));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(1, 1, 6));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(1, 0, 5));

    // QoS 2
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 0, 2));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 2, 3));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 3, 4));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 4, 5));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 2, 6));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 3, 6));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_qos_can_transition(2, 4, 6));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(2, 0, 5));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_qos_can_transition(2, 2, 5));
}

// =========================================================================
// Topic matching (stateless)
// =========================================================================

test "topic matching: exact match" {
    const topic = "home/livingroom/temperature";
    const filter = "home/livingroom/temperature";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_topic_matches(
        topic.ptr, topic.len, filter.ptr, filter.len,
    ));
}

test "topic matching: single-level wildcard" {
    const topic = "home/livingroom/temperature";
    const filter = "home/+/temperature";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_topic_matches(
        topic.ptr, topic.len, filter.ptr, filter.len,
    ));
}

test "topic matching: multi-level wildcard" {
    const topic = "home/livingroom/temperature";
    const filter = "home/#";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_topic_matches(
        topic.ptr, topic.len, filter.ptr, filter.len,
    ));
}

test "topic matching: hash matches everything" {
    const topic = "any/topic/at/all";
    const filter = "#";
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_topic_matches(
        topic.ptr, topic.len, filter.ptr, filter.len,
    ));
}

test "topic matching: no match on different path" {
    const topic = "home/livingroom/temperature";
    const filter = "office/+/temperature";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_topic_matches(
        topic.ptr, topic.len, filter.ptr, filter.len,
    ));
}

test "topic matching: plus does not match level separator" {
    const topic = "home/livingroom/sub/temperature";
    const filter = "home/+/temperature";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_topic_matches(
        topic.ptr, topic.len, filter.ptr, filter.len,
    ));
}

test "topic matching: empty topic rejected" {
    const topic = "x";
    const filter = "#";
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_topic_matches(
        topic.ptr, 0, filter.ptr, filter.len,
    ));
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_state(-1));
    try std.testing.expectEqual(@as(u8, 255), mqtt.mqtt_version(-1));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_publish(-1));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_subscribe(-1));
    try std.testing.expectEqual(@as(u32, 0), mqtt.mqtt_subscription_count(-1));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_disconnect(-1));
    try std.testing.expectEqual(@as(u8, 1), mqtt.mqtt_cleanup(-1));
}
