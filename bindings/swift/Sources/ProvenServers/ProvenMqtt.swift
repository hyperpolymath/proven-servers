// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Swift bindings for the proven-mqtt protocol.
// Wraps the C-ABI functions from protocols/proven-mqtt/ffi/zig/src/mqtt.zig.
// Enums match Idris2 ABI tags exactly (MqttABI.Types).

import Foundation

// MARK: - C interop declarations

@_silgen_name("mqtt_abi_version")       private func mqtt_abi_version() -> UInt32
@_silgen_name("mqtt_create")            private func mqtt_create(_ version: UInt8, _ cleanSession: UInt8, _ keepAlive: UInt16) -> Int32
@_silgen_name("mqtt_destroy")           private func mqtt_destroy(_ slot: Int32)
@_silgen_name("mqtt_state")             private func mqtt_state(_ slot: Int32) -> UInt8
@_silgen_name("mqtt_version")           private func mqtt_version(_ slot: Int32) -> UInt8
@_silgen_name("mqtt_can_publish")       private func mqtt_can_publish(_ slot: Int32) -> UInt8
@_silgen_name("mqtt_can_subscribe")     private func mqtt_can_subscribe(_ slot: Int32) -> UInt8
@_silgen_name("mqtt_subscription_count") private func mqtt_subscription_count(_ slot: Int32) -> UInt32
@_silgen_name("mqtt_subscribe")         private func mqtt_subscribe(_ slot: Int32, _ topicPtr: UnsafePointer<UInt8>, _ topicLen: UInt32, _ qos: UInt8) -> UInt8
@_silgen_name("mqtt_unsubscribe")       private func mqtt_unsubscribe(_ slot: Int32, _ topicPtr: UnsafePointer<UInt8>, _ topicLen: UInt32) -> UInt8
@_silgen_name("mqtt_publish")           private func mqtt_publish(_ slot: Int32, _ topicPtr: UnsafePointer<UInt8>, _ topicLen: UInt32, _ payloadPtr: UnsafePointer<UInt8>, _ payloadLen: UInt32, _ qos: UInt8, _ retain: UInt8, _ packetId: UInt16) -> UInt8
@_silgen_name("mqtt_puback")            private func mqtt_puback(_ slot: Int32, _ packetId: UInt16) -> UInt8
@_silgen_name("mqtt_pubrec")            private func mqtt_pubrec(_ slot: Int32, _ packetId: UInt16) -> UInt8
@_silgen_name("mqtt_pubrel")            private func mqtt_pubrel(_ slot: Int32, _ packetId: UInt16) -> UInt8
@_silgen_name("mqtt_pubcomp")           private func mqtt_pubcomp(_ slot: Int32, _ packetId: UInt16) -> UInt8
@_silgen_name("mqtt_qos_state")         private func mqtt_qos_state(_ slot: Int32, _ packetId: UInt16) -> UInt8
@_silgen_name("mqtt_disconnect")        private func mqtt_disconnect(_ slot: Int32) -> UInt8
@_silgen_name("mqtt_cleanup")           private func mqtt_cleanup(_ slot: Int32) -> UInt8
@_silgen_name("mqtt_retained_count")    private func mqtt_retained_count() -> UInt32
@_silgen_name("mqtt_can_transition")    private func mqtt_can_transition(_ from: UInt8, _ to: UInt8) -> UInt8
@_silgen_name("mqtt_qos_can_transition") private func mqtt_qos_can_transition(_ qosLevel: UInt8, _ from: UInt8, _ to: UInt8) -> UInt8
@_silgen_name("mqtt_topic_matches")     private func mqtt_topic_matches(_ filterPtr: UnsafePointer<UInt8>, _ filterLen: UInt32, _ topicPtr: UnsafePointer<UInt8>, _ topicLen: UInt32) -> UInt8

// MARK: - Enums matching Idris2 ABI tags

/// MQTT broker session states (tags 0-2).
public enum MqttSessionState: Int, CaseIterable, Sendable {
    /// Client connected, CONNECT not yet received.
    case idle = 0
    /// CONNECT received, session active.
    case connected = 1
    /// Client disconnected cleanly.
    case disconnected = 2

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// MQTT Quality of Service levels (tags 0-2).
public enum MqttQoS: Int, CaseIterable, Sendable {
    /// At most once delivery (fire and forget).
    case atMostOnce = 0
    /// At least once delivery (PUBACK required).
    case atLeastOnce = 1
    /// Exactly once delivery (PUBREC/PUBREL/PUBCOMP handshake).
    case exactlyOnce = 2

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

// MARK: - Swift-idiomatic wrapper

/// Swift wrapper for the proven MQTT broker protocol FFI.
///
/// Manages an opaque MQTT session context slot. The context is
/// automatically destroyed when this object is deallocated.
public final class ProvenMqtt: @unchecked Sendable {

    private let slot: Int32

    /// Create a new MQTT session.
    ///
    /// - Parameters:
    ///   - version: 0 = MQTT 3.1.1, 1 = MQTT 5.0.
    ///   - cleanSession: Whether to start a clean session.
    ///   - keepAlive: Keep-alive interval in seconds.
    /// - Throws: ``ProvenError/poolExhausted`` if all 64 slots are in use.
    public init(version: UInt8 = 0, cleanSession: Bool = true, keepAlive: UInt16 = 60) throws {
        self.slot = try ProvenError.checkSlot(mqtt_create(version, cleanSession ? 1 : 0, keepAlive))
    }

    deinit { mqtt_destroy(slot) }

    /// The ABI version.
    public static var abiVersion: UInt32 { mqtt_abi_version() }

    /// The current session state.
    public var state: MqttSessionState? { MqttSessionState(tag: mqtt_state(slot)) }

    /// The MQTT protocol version tag.
    public var protocolVersion: UInt8 { mqtt_version(slot) }

    /// Whether the session can publish messages.
    public var canPublish: Bool { mqtt_can_publish(slot) == 1 }

    /// Whether the session can subscribe to topics.
    public var canSubscribe: Bool { mqtt_can_subscribe(slot) == 1 }

    /// The number of active subscriptions.
    public var subscriptionCount: UInt32 { mqtt_subscription_count(slot) }

    /// Subscribe to a topic with the given QoS level.
    ///
    /// - Parameters:
    ///   - topic: The topic filter string.
    ///   - qos: The QoS level for this subscription.
    /// - Throws: ``ProvenError`` on invalid state or capacity exceeded.
    public func subscribe(topic: String, qos: MqttQoS) throws {
        let result = topic.withCString { cStr in
            mqtt_subscribe(slot, UnsafePointer<UInt8>(OpaquePointer(cStr)), UInt32(topic.utf8.count), qos.tag)
        }
        try ProvenError.checkStatus(result)
    }

    /// Unsubscribe from a topic.
    ///
    /// - Parameter topic: The topic filter to unsubscribe from.
    public func unsubscribe(topic: String) throws {
        let result = topic.withCString { cStr in
            mqtt_unsubscribe(slot, UnsafePointer<UInt8>(OpaquePointer(cStr)), UInt32(topic.utf8.count))
        }
        try ProvenError.checkStatus(result)
    }

    /// Publish a message to a topic.
    ///
    /// - Parameters:
    ///   - topic: The topic to publish to.
    ///   - payload: The message payload bytes.
    ///   - qos: The QoS level.
    ///   - retain: Whether the broker should retain the message.
    ///   - packetId: The MQTT packet identifier (required for QoS > 0).
    public func publish(topic: String, payload: Data, qos: MqttQoS, retain: Bool = false, packetId: UInt16 = 0) throws {
        let result = topic.withCString { cTopic in
            payload.withUnsafeBytes { payloadBuf -> UInt8 in
                let pPtr = payloadBuf.baseAddress!.assumingMemoryBound(to: UInt8.self)
                return mqtt_publish(
                    slot,
                    UnsafePointer<UInt8>(OpaquePointer(cTopic)), UInt32(topic.utf8.count),
                    pPtr, UInt32(payloadBuf.count),
                    qos.tag, retain ? 1 : 0, packetId
                )
            }
        }
        try ProvenError.checkStatus(result)
    }

    /// Acknowledge a QoS 1 publish (PUBACK).
    public func puback(packetId: UInt16) throws {
        try ProvenError.checkStatus(mqtt_puback(slot, packetId))
    }

    /// QoS 2 step 1: publish received (PUBREC).
    public func pubrec(packetId: UInt16) throws {
        try ProvenError.checkStatus(mqtt_pubrec(slot, packetId))
    }

    /// QoS 2 step 2: publish release (PUBREL).
    public func pubrel(packetId: UInt16) throws {
        try ProvenError.checkStatus(mqtt_pubrel(slot, packetId))
    }

    /// QoS 2 step 3: publish complete (PUBCOMP).
    public func pubcomp(packetId: UInt16) throws {
        try ProvenError.checkStatus(mqtt_pubcomp(slot, packetId))
    }

    /// Get the QoS delivery state for a packet ID.
    public func qosState(packetId: UInt16) -> UInt8 {
        mqtt_qos_state(slot, packetId)
    }

    /// Disconnect the session cleanly.
    public func disconnect() throws {
        try ProvenError.checkStatus(mqtt_disconnect(slot))
    }

    /// Clean up session resources (subscriptions, QoS state).
    public func cleanup() throws {
        try ProvenError.checkStatus(mqtt_cleanup(slot))
    }

    /// The global retained message count.
    public static var retainedCount: UInt32 { mqtt_retained_count() }

    /// Stateless query: check whether a session state transition is valid.
    public static func canTransition(from: MqttSessionState, to: MqttSessionState) -> Bool {
        mqtt_can_transition(from.tag, to.tag) == 1
    }

    /// Stateless query: check whether a QoS delivery state transition is valid.
    public static func qosCanTransition(qos: MqttQoS, from: UInt8, to: UInt8) -> Bool {
        mqtt_qos_can_transition(qos.tag, from, to) == 1
    }

    /// Stateless query: check if a topic matches a subscription filter.
    ///
    /// Supports MQTT wildcards: `+` (single level), `#` (multi level).
    public static func topicMatches(filter: String, topic: String) -> Bool {
        filter.withCString { cFilter in
            topic.withCString { cTopic in
                mqtt_topic_matches(
                    UnsafePointer<UInt8>(OpaquePointer(cFilter)), UInt32(filter.utf8.count),
                    UnsafePointer<UInt8>(OpaquePointer(cTopic)), UInt32(topic.utf8.count)
                ) == 1
            }
        }
    }
}
