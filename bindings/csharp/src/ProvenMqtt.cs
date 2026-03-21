// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// C# P/Invoke bindings for the proven-mqtt protocol.
// Wraps the C-ABI functions from protocols/proven-mqtt/ffi/zig/src/mqtt.zig.

using System;
using System.Runtime.InteropServices;
using System.Text;

namespace ProvenServers
{
    /// <summary>MQTT session states (tags 0-2).</summary>
    public enum MqttSessionState : byte
    {
        Idle = 0, Connected = 1, Disconnected = 2
    }

    /// <summary>MQTT Quality of Service levels.</summary>
    public enum MqttQoS : byte
    {
        AtMostOnce = 0, AtLeastOnce = 1, ExactlyOnce = 2
    }

    /// <summary>
    /// C# bindings for the proven MQTT broker protocol.
    /// Session: Idle -> Connected -> Disconnected.
    /// </summary>
    public static class ProvenMqtt
    {
        private const string Lib = "proven_mqtt";

        [DllImport(Lib)] private static extern uint mqtt_abi_version();
        [DllImport(Lib)] private static extern int mqtt_create(byte version, byte cleanSession, ushort keepAlive);
        [DllImport(Lib)] private static extern void mqtt_destroy(int slot);
        [DllImport(Lib)] private static extern byte mqtt_state(int slot);
        [DllImport(Lib)] private static extern byte mqtt_version(int slot);
        [DllImport(Lib)] private static extern byte mqtt_can_publish(int slot);
        [DllImport(Lib)] private static extern byte mqtt_can_subscribe(int slot);
        [DllImport(Lib)] private static extern uint mqtt_subscription_count(int slot);
        [DllImport(Lib)] private static extern byte mqtt_subscribe(int slot, byte[] topicPtr, uint topicLen, byte qos);
        [DllImport(Lib)] private static extern byte mqtt_unsubscribe(int slot, byte[] topicPtr, uint topicLen);
        [DllImport(Lib)] private static extern byte mqtt_publish(int slot, byte[] topicPtr, uint topicLen,
            byte[] payloadPtr, uint payloadLen, byte qos, byte retain, ushort packetId);
        [DllImport(Lib)] private static extern byte mqtt_puback(int slot, ushort packetId);
        [DllImport(Lib)] private static extern byte mqtt_pubrec(int slot, ushort packetId);
        [DllImport(Lib)] private static extern byte mqtt_pubrel(int slot, ushort packetId);
        [DllImport(Lib)] private static extern byte mqtt_pubcomp(int slot, ushort packetId);
        [DllImport(Lib)] private static extern byte mqtt_qos_state(int slot, ushort packetId);
        [DllImport(Lib)] private static extern byte mqtt_disconnect(int slot);
        [DllImport(Lib)] private static extern byte mqtt_cleanup(int slot);
        [DllImport(Lib)] private static extern uint mqtt_retained_count();
        [DllImport(Lib)] private static extern byte mqtt_can_transition(byte from, byte to);
        [DllImport(Lib)] private static extern byte mqtt_qos_can_transition(byte qosLevel, byte from, byte to);
        [DllImport(Lib)] private static extern byte mqtt_topic_matches(byte[] filterPtr, uint filterLen,
            byte[] topicPtr, uint topicLen);

        public static uint AbiVersion() => mqtt_abi_version();

        /// <summary>Create a new MQTT session.</summary>
        /// <param name="version">0 = MQTT 3.1.1, 1 = MQTT 5.0.</param>
        /// <param name="cleanSession">Whether to start a clean session.</param>
        /// <param name="keepAlive">Keep-alive interval in seconds.</param>
        public static int Create(byte version, bool cleanSession, ushort keepAlive) =>
            ProvenError.CheckSlot(mqtt_create(version, (byte)(cleanSession ? 1 : 0), keepAlive));

        public static void Destroy(int slot) => mqtt_destroy(slot);

        public static MqttSessionState? State(int slot)
        {
            byte tag = mqtt_state(slot);
            return tag <= 2 ? (MqttSessionState)tag : null;
        }

        public static byte Version(int slot) => mqtt_version(slot);
        public static bool CanPublish(int slot) => mqtt_can_publish(slot) == 1;
        public static bool CanSubscribe(int slot) => mqtt_can_subscribe(slot) == 1;
        public static uint SubscriptionCount(int slot) => mqtt_subscription_count(slot);

        /// <summary>Subscribe to a topic with the given QoS level.</summary>
        public static void Subscribe(int slot, string topic, MqttQoS qos)
        {
            byte[] topicBytes = Encoding.UTF8.GetBytes(topic);
            ProvenError.CheckStatus(mqtt_subscribe(slot, topicBytes, (uint)topicBytes.Length, (byte)qos));
        }

        /// <summary>Unsubscribe from a topic.</summary>
        public static void Unsubscribe(int slot, string topic)
        {
            byte[] topicBytes = Encoding.UTF8.GetBytes(topic);
            ProvenError.CheckStatus(mqtt_unsubscribe(slot, topicBytes, (uint)topicBytes.Length));
        }

        /// <summary>Publish a message to a topic.</summary>
        public static void Publish(int slot, string topic, byte[] payload,
                                    MqttQoS qos, bool retain, ushort packetId)
        {
            byte[] topicBytes = Encoding.UTF8.GetBytes(topic);
            ProvenError.CheckStatus(mqtt_publish(slot, topicBytes, (uint)topicBytes.Length,
                payload, (uint)payload.Length, (byte)qos, (byte)(retain ? 1 : 0), packetId));
        }

        /// <summary>PUBACK (QoS 1).</summary>
        public static void Puback(int slot, ushort packetId) =>
            ProvenError.CheckStatus(mqtt_puback(slot, packetId));

        /// <summary>PUBREC (QoS 2, step 1).</summary>
        public static void Pubrec(int slot, ushort packetId) =>
            ProvenError.CheckStatus(mqtt_pubrec(slot, packetId));

        /// <summary>PUBREL (QoS 2, step 2).</summary>
        public static void Pubrel(int slot, ushort packetId) =>
            ProvenError.CheckStatus(mqtt_pubrel(slot, packetId));

        /// <summary>PUBCOMP (QoS 2, step 3).</summary>
        public static void Pubcomp(int slot, ushort packetId) =>
            ProvenError.CheckStatus(mqtt_pubcomp(slot, packetId));

        /// <summary>Get QoS delivery state for a packet ID.</summary>
        public static byte QosState(int slot, ushort packetId) =>
            mqtt_qos_state(slot, packetId);

        /// <summary>Disconnect cleanly.</summary>
        public static void Disconnect(int slot) => ProvenError.CheckStatus(mqtt_disconnect(slot));

        /// <summary>Clean up session resources.</summary>
        public static void Cleanup(int slot) => ProvenError.CheckStatus(mqtt_cleanup(slot));

        /// <summary>Get global retained message count.</summary>
        public static uint RetainedCount() => mqtt_retained_count();

        public static bool CanTransition(MqttSessionState from, MqttSessionState to) =>
            mqtt_can_transition((byte)from, (byte)to) == 1;

        public static bool QosCanTransition(MqttQoS qosLevel, byte from, byte to) =>
            mqtt_qos_can_transition((byte)qosLevel, from, to) == 1;

        /// <summary>Check if a topic matches a subscription filter (supports + and # wildcards).</summary>
        public static bool TopicMatches(string filter, string topic)
        {
            byte[] filterBytes = Encoding.UTF8.GetBytes(filter);
            byte[] topicBytes = Encoding.UTF8.GetBytes(topic);
            return mqtt_topic_matches(filterBytes, (uint)filterBytes.Length,
                topicBytes, (uint)topicBytes.Length) == 1;
        }
    }
}
