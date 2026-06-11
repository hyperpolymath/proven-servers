// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// integration_test.zig -- Integration tests for proven-mqtt FFI.
//
// Tests cover:
//   - ABI version agreement
//   - Enum tag encoding (Types.idr parity)
//   - Context lifecycle (create/destroy)
//   - Stateless transition table
//   - Invalid slot safety
//   - Impossibility (invalid transitions)

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

test "PacketType encoding matches Types.idr (15 tags)" {
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

test "QoS encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.QoS.at_most_once));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.QoS.at_least_once));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.QoS.exactly_once));
}

test "ConnAckCode encoding matches Types.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.ConnAckCode.connection_accepted));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.ConnAckCode.unacceptable_protocol));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.ConnAckCode.identifier_rejected));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.ConnAckCode.server_unavailable));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mqtt.ConnAckCode.bad_credentials));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(mqtt.ConnAckCode.not_authorised));
}

test "MQTTVersion encoding matches Types.idr (2 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.MQTTVersion.mqtt311));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.MQTTVersion.mqtt50));
}

test "BrokerState encoding matches Types.idr (5 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.BrokerState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.BrokerState.connected));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.BrokerState.subscribed));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.BrokerState.publishing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mqtt.BrokerState.disconnecting));
}

test "QoSDeliveryState encoding matches Types.idr (7 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.QoSDeliveryState.qd_idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.QoSDeliveryState.awaiting_puback));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.QoSDeliveryState.awaiting_pubrec));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.QoSDeliveryState.awaiting_pubrel));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(mqtt.QoSDeliveryState.awaiting_pubcomp));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(mqtt.QoSDeliveryState.qd_complete));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(mqtt.QoSDeliveryState.qd_failed));
}

test "PropertyType encoding matches Types.idr (10 tags)" {
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

test "PacketDirection encoding matches Types.idr (3 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.PacketDirection.client_to_server));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.PacketDirection.server_to_client));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.PacketDirection.bidirectional));
}

test "SubAckCode encoding matches Types.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(mqtt.SubAckCode.granted_qos0));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(mqtt.SubAckCode.granted_qos1));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(mqtt.SubAckCode.granted_qos2));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(mqtt.SubAckCode.sub_failure));
}

// =========================================================================
// Context lifecycle
// =========================================================================

test "create returns valid slot" {
    const slot = mqtt.mqtt_create(0, 0, 0);
    try std.testing.expect(slot >= 0);
    defer mqtt.mqtt_destroy(slot);
    const state = mqtt.mqtt_state(slot);
    _ = state; // Verify no crash
}

test "destroy is safe with invalid slot" {
    mqtt.mqtt_destroy(-1);
    mqtt.mqtt_destroy(999);
}

// =========================================================================
// Stateless transition table
// =========================================================================

test "transition table rejects invalid transitions" {
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(255, 255));
    try std.testing.expectEqual(@as(u8, 0), mqtt.mqtt_can_transition(0, 0)); // self-loop
}

// =========================================================================
// State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    _ = mqtt.mqtt_state(-1);
    _ = mqtt.mqtt_subscription_count(-1);
    _ = mqtt.mqtt_retained_count();
}

