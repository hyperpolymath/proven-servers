// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Java JNI bindings for the proven-mqtt protocol.
// Wraps the C-ABI functions from protocols/proven-mqtt/ffi/zig/src/mqtt.zig.

package com.hyperpolymath.proven;

/**
 * Java bindings for the proven MQTT broker protocol.
 *
 * <p>Session lifecycle: Idle -&gt; Connected -&gt; Disconnected.
 * Supports QoS 0/1/2 delivery, topic subscriptions, and wildcard matching.</p>
 *
 * @author Jonathan D.A. Jewell
 */
public final class ProvenMqtt {

    private ProvenMqtt() {}

    // -----------------------------------------------------------------------
    // Enums
    // -----------------------------------------------------------------------

    /** MQTT session states (tags 0-2). */
    public enum SessionState {
        IDLE(0), CONNECTED(1), DISCONNECTED(2);

        private final int tag;
        SessionState(int tag) { this.tag = tag; }
        public int tag() { return tag; }

        public static SessionState fromTag(int tag) {
            for (SessionState s : values()) {
                if (s.tag == tag) return s;
            }
            return null;
        }
    }

    /** MQTT Quality of Service levels. */
    public enum QoS {
        AT_MOST_ONCE(0), AT_LEAST_ONCE(1), EXACTLY_ONCE(2);

        private final int code;
        QoS(int code) { this.code = code; }
        public int code() { return code; }

        public static QoS fromCode(int code) {
            for (QoS q : values()) {
                if (q.code == code) return q;
            }
            return null;
        }
    }

    // -----------------------------------------------------------------------
    // JNI native methods
    // -----------------------------------------------------------------------

    private static native int nativeAbiVersion();
    private static native int nativeCreate(int version, int cleanSession, int keepAlive);
    private static native void nativeDestroy(int slot);
    private static native int nativeState(int slot);
    private static native int nativeVersion(int slot);
    private static native int nativeCanPublish(int slot);
    private static native int nativeCanSubscribe(int slot);
    private static native int nativeSubscriptionCount(int slot);
    private static native int nativeSubscribe(int slot, byte[] topic, int topicLen, int qos);
    private static native int nativeUnsubscribe(int slot, byte[] topic, int topicLen);
    private static native int nativePublish(int slot, byte[] topic, int topicLen,
                                             byte[] payload, int payloadLen,
                                             int qos, int retain, int packetId);
    private static native int nativePuback(int slot, int packetId);
    private static native int nativePubrec(int slot, int packetId);
    private static native int nativePubrel(int slot, int packetId);
    private static native int nativePubcomp(int slot, int packetId);
    private static native int nativeQosState(int slot, int packetId);
    private static native int nativeDisconnect(int slot);
    private static native int nativeCleanup(int slot);
    private static native int nativeRetainedCount();
    private static native int nativeCanTransition(int from, int to);
    private static native int nativeQosCanTransition(int qosLevel, int from, int to);
    private static native int nativeTopicMatches(byte[] filter, int filterLen, byte[] topic, int topicLen);

    // -----------------------------------------------------------------------
    // Safe wrappers
    // -----------------------------------------------------------------------

    public static int abiVersion() { return nativeAbiVersion(); }

    /**
     * Create a new MQTT session.
     *
     * @param version      0 = MQTT 3.1.1, 1 = MQTT 5.0
     * @param cleanSession whether to start a clean session
     * @param keepAlive    keep-alive interval in seconds
     * @return context slot index
     * @throws ProvenError if pool exhausted
     */
    public static int create(int version, boolean cleanSession, int keepAlive) throws ProvenError {
        return ProvenError.checkSlot(nativeCreate(version, cleanSession ? 1 : 0, keepAlive));
    }

    public static void destroy(int slot) { nativeDestroy(slot); }

    public static SessionState state(int slot) { return SessionState.fromTag(nativeState(slot)); }

    public static int version(int slot) { return nativeVersion(slot); }

    public static boolean canPublish(int slot) { return nativeCanPublish(slot) == 1; }

    public static boolean canSubscribe(int slot) { return nativeCanSubscribe(slot) == 1; }

    public static int subscriptionCount(int slot) { return nativeSubscriptionCount(slot); }

    /** Subscribe to a topic with the given QoS level. */
    public static void subscribe(int slot, String topic, QoS qos) throws ProvenError {
        byte[] topicBytes = topic.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        ProvenError.checkStatus(nativeSubscribe(slot, topicBytes, topicBytes.length, qos.code()));
    }

    /** Unsubscribe from a topic. */
    public static void unsubscribe(int slot, String topic) throws ProvenError {
        byte[] topicBytes = topic.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        ProvenError.checkStatus(nativeUnsubscribe(slot, topicBytes, topicBytes.length));
    }

    /** Publish a message to a topic. */
    public static void publish(int slot, String topic, byte[] payload,
                                QoS qos, boolean retain, int packetId) throws ProvenError {
        byte[] topicBytes = topic.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        ProvenError.checkStatus(nativePublish(slot, topicBytes, topicBytes.length,
                                               payload, payload.length,
                                               qos.code(), retain ? 1 : 0, packetId));
    }

    /** PUBACK (QoS 1). */
    public static void puback(int slot, int packetId) throws ProvenError {
        ProvenError.checkStatus(nativePuback(slot, packetId));
    }

    /** PUBREC (QoS 2, step 1). */
    public static void pubrec(int slot, int packetId) throws ProvenError {
        ProvenError.checkStatus(nativePubrec(slot, packetId));
    }

    /** PUBREL (QoS 2, step 2). */
    public static void pubrel(int slot, int packetId) throws ProvenError {
        ProvenError.checkStatus(nativePubrel(slot, packetId));
    }

    /** PUBCOMP (QoS 2, step 3). */
    public static void pubcomp(int slot, int packetId) throws ProvenError {
        ProvenError.checkStatus(nativePubcomp(slot, packetId));
    }

    /** Get the QoS delivery state for a packet ID. */
    public static int qosState(int slot, int packetId) { return nativeQosState(slot, packetId); }

    /** Disconnect the session cleanly. */
    public static void disconnect(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeDisconnect(slot));
    }

    /** Clean up session resources. */
    public static void cleanup(int slot) throws ProvenError {
        ProvenError.checkStatus(nativeCleanup(slot));
    }

    /** Get the global retained message count. */
    public static int retainedCount() { return nativeRetainedCount(); }

    public static boolean canTransition(SessionState from, SessionState to) {
        return nativeCanTransition(from.tag(), to.tag()) == 1;
    }

    /** Check whether a QoS delivery state transition is valid. */
    public static boolean qosCanTransition(QoS qosLevel, int from, int to) {
        return nativeQosCanTransition(qosLevel.code(), from, to) == 1;
    }

    /**
     * Stateless: check if a topic matches a subscription filter.
     * Supports MQTT wildcards: {@code +} (single level), {@code #} (multi level).
     */
    public static boolean topicMatches(String filter, String topic) {
        byte[] filterBytes = filter.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        byte[] topicBytes = topic.getBytes(java.nio.charset.StandardCharsets.UTF_8);
        return nativeTopicMatches(filterBytes, filterBytes.length, topicBytes, topicBytes.length) == 1;
    }
}
