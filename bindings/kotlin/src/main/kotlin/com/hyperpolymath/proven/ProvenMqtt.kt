// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kotlin/JNI bindings for the proven-mqtt protocol.
// Wraps the C-ABI functions from protocols/proven-mqtt/ffi/zig/src/mqtt.zig.
// Enum classes match Idris2 ABI tags exactly (MqttABI.Types).

package com.hyperpolymath.proven

/**
 * Kotlin bindings for the proven MQTT broker protocol.
 *
 * @author Jonathan D.A. Jewell
 */
public class ProvenMqtt private constructor(private val slot: Int) : AutoCloseable {

    /** MQTT broker session states (tags 0-2). */
    public enum class SessionState(public val tag: Int) {
        IDLE(0), CONNECTED(1), DISCONNECTED(2);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): SessionState? = entries.find { it.tag == tag }
        }
    }

    /** MQTT Quality of Service levels (tags 0-2). */
    public enum class QoS(public val tag: Int) {
        AT_MOST_ONCE(0), AT_LEAST_ONCE(1), EXACTLY_ONCE(2);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): QoS? = entries.find { it.tag == tag }
        }
    }

    private companion object {
        @JvmStatic external fun mqtt_abi_version(): Int
        @JvmStatic external fun mqtt_create(version: Int, cleanSession: Int, keepAlive: Int): Int
        @JvmStatic external fun mqtt_destroy(slot: Int)
        @JvmStatic external fun mqtt_state(slot: Int): Int
        @JvmStatic external fun mqtt_version(slot: Int): Int
        @JvmStatic external fun mqtt_can_publish(slot: Int): Int
        @JvmStatic external fun mqtt_can_subscribe(slot: Int): Int
        @JvmStatic external fun mqtt_subscription_count(slot: Int): Int
        @JvmStatic external fun mqtt_subscribe(slot: Int, topic: ByteArray, topicLen: Int, qos: Int): Int
        @JvmStatic external fun mqtt_unsubscribe(slot: Int, topic: ByteArray, topicLen: Int): Int
        @JvmStatic external fun mqtt_publish(slot: Int, topic: ByteArray, topicLen: Int, payload: ByteArray, payloadLen: Int, qos: Int, retain: Int, packetId: Int): Int
        @JvmStatic external fun mqtt_puback(slot: Int, packetId: Int): Int
        @JvmStatic external fun mqtt_pubrec(slot: Int, packetId: Int): Int
        @JvmStatic external fun mqtt_pubrel(slot: Int, packetId: Int): Int
        @JvmStatic external fun mqtt_pubcomp(slot: Int, packetId: Int): Int
        @JvmStatic external fun mqtt_qos_state(slot: Int, packetId: Int): Int
        @JvmStatic external fun mqtt_disconnect(slot: Int): Int
        @JvmStatic external fun mqtt_cleanup(slot: Int): Int
        @JvmStatic external fun mqtt_retained_count(): Int
        @JvmStatic external fun mqtt_can_transition(from: Int, to: Int): Int
        @JvmStatic external fun mqtt_qos_can_transition(qosLevel: Int, from: Int, to: Int): Int
        @JvmStatic external fun mqtt_topic_matches(filter: ByteArray, filterLen: Int, topic: ByteArray, topicLen: Int): Int
    }

    override fun close() { mqtt_destroy(slot) }

    public val state: SessionState? get() = SessionState.fromTag(mqtt_state(slot))
    public val protocolVersion: Int get() = mqtt_version(slot)
    public val canPublish: Boolean get() = mqtt_can_publish(slot) == 1
    public val canSubscribe: Boolean get() = mqtt_can_subscribe(slot) == 1
    public val subscriptionCount: Int get() = mqtt_subscription_count(slot)

    /** Subscribe to a topic with the given QoS level. */
    public fun subscribe(topic: String, qos: QoS): Result<Unit> = ProvenError.runCatching {
        val bytes = topic.toByteArray()
        ProvenError.checkStatus(mqtt_subscribe(slot, bytes, bytes.size, qos.tag))
    }

    /** Unsubscribe from a topic. */
    public fun unsubscribe(topic: String): Result<Unit> = ProvenError.runCatching {
        val bytes = topic.toByteArray()
        ProvenError.checkStatus(mqtt_unsubscribe(slot, bytes, bytes.size))
    }

    /** Publish a message to a topic. */
    public fun publish(
        topic: String,
        payload: ByteArray,
        qos: QoS,
        retain: Boolean = false,
        packetId: Int = 0
    ): Result<Unit> = ProvenError.runCatching {
        val topicBytes = topic.toByteArray()
        ProvenError.checkStatus(mqtt_publish(
            slot, topicBytes, topicBytes.size,
            payload, payload.size,
            qos.tag, if (retain) 1 else 0, packetId
        ))
    }

    public fun puback(packetId: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(mqtt_puback(slot, packetId)) }
    public fun pubrec(packetId: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(mqtt_pubrec(slot, packetId)) }
    public fun pubrel(packetId: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(mqtt_pubrel(slot, packetId)) }
    public fun pubcomp(packetId: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(mqtt_pubcomp(slot, packetId)) }
    public fun qosState(packetId: Int): Int = mqtt_qos_state(slot, packetId)
    public fun disconnect(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(mqtt_disconnect(slot)) }
    public fun cleanup(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(mqtt_cleanup(slot)) }

    public companion object {
        @JvmStatic public fun create(version: Int = 0, cleanSession: Boolean = true, keepAlive: Int = 60): Result<ProvenMqtt> = ProvenError.runCatching {
            ProvenMqtt(ProvenError.checkSlot(mqtt_create(version, if (cleanSession) 1 else 0, keepAlive)))
        }

        @JvmStatic public fun abiVersion(): Int = mqtt_abi_version()
        @JvmStatic public fun retainedCount(): Int = mqtt_retained_count()

        @JvmStatic public fun canTransition(from: SessionState, to: SessionState): Boolean =
            mqtt_can_transition(from.tag, to.tag) == 1

        @JvmStatic public fun qosCanTransition(qos: QoS, from: Int, to: Int): Boolean =
            mqtt_qos_can_transition(qos.tag, from, to) == 1

        /** Check if a topic matches a subscription filter. */
        @JvmStatic public fun topicMatches(filter: String, topic: String): Boolean {
            val fb = filter.toByteArray()
            val tb = topic.toByteArray()
            return mqtt_topic_matches(fb, fb.size, tb, tb.size) == 1
        }
    }
}
