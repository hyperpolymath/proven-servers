// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// JavaScript bindings for the proven-mqtt Zig FFI.

import { checkSlot, checkStatus } from "./error.js";
import { loadLibrary } from "./ffi.js";

/** @readonly @enum {number} MQTT session states. */
export const MqttSessionState = Object.freeze({
    IDLE: 0, CONNECTED: 1, DISCONNECTED: 2,
});

/** @readonly @enum {number} MQTT protocol versions. */
export const MqttVersion = Object.freeze({ V3_1_1: 0, V5_0: 1 });

/** @readonly @enum {number} MQTT QoS levels. */
export const QoS = Object.freeze({
    AT_MOST_ONCE: 0, AT_LEAST_ONCE: 1, EXACTLY_ONCE: 2,
});

let _lib = null;

/** @param {object} [options] */
export async function init(options) {
    if (!_lib) _lib = await loadLibrary("mqtt", options);
}

function lib() {
    if (!_lib) throw new Error("mqtt: call init() before using the module");
    return _lib;
}

/**
 * MQTT session context wrapping a Zig FFI slot.
 */
export class MqttContext {
    constructor(slot) { this._slot = slot; this._destroyed = false; }

    /**
     * @param {number} [version=0] - MqttVersion tag.
     * @param {boolean} [cleanSession=true]
     * @param {number} [keepAlive=60]
     */
    static create(version = 0, cleanSession = true, keepAlive = 60) {
        return new MqttContext(checkSlot(
            lib().mqtt_create(version, cleanSession ? 1 : 0, keepAlive),
        ));
    }

    destroy() {
        if (!this._destroyed) { lib().mqtt_destroy(this._slot); this._destroyed = true; }
    }

    /** @returns {number|null} */ state() {
        const tag = lib().mqtt_state(this._slot); return tag <= 2 ? tag : null;
    }
    /** @returns {number} */ version() { return lib().mqtt_version(this._slot); }
    /** @returns {boolean} */ canPublish() { return lib().mqtt_can_publish(this._slot) === 1; }
    /** @returns {boolean} */ canSubscribe() { return lib().mqtt_can_subscribe(this._slot) === 1; }
    /** @returns {number} */ subscriptionCount() { return lib().mqtt_subscription_count(this._slot); }

    /** @param {string} topic @param {number} qos - QoS tag. */
    subscribe(topic, qos) {
        const data = new TextEncoder().encode(topic);
        checkStatus(lib().mqtt_subscribe(this._slot, data, data.length, qos));
    }

    /** @param {string} topic */
    unsubscribe(topic) {
        const data = new TextEncoder().encode(topic);
        checkStatus(lib().mqtt_unsubscribe(this._slot, data, data.length));
    }

    /**
     * @param {string} topic
     * @param {Uint8Array} payload
     * @param {number} qos - QoS tag.
     * @param {boolean} [retain=false]
     * @param {number} [packetId=0]
     */
    publish(topic, payload, qos, retain = false, packetId = 0) {
        const t = new TextEncoder().encode(topic);
        checkStatus(lib().mqtt_publish(
            this._slot, t, t.length, payload, payload.length,
            qos, retain ? 1 : 0, packetId,
        ));
    }

    /** @param {number} packetId */
    puback(packetId) { checkStatus(lib().mqtt_puback(this._slot, packetId)); }
    /** @param {number} packetId */
    pubrec(packetId) { checkStatus(lib().mqtt_pubrec(this._slot, packetId)); }
    /** @param {number} packetId */
    pubrel(packetId) { checkStatus(lib().mqtt_pubrel(this._slot, packetId)); }
    /** @param {number} packetId */
    pubcomp(packetId) { checkStatus(lib().mqtt_pubcomp(this._slot, packetId)); }

    /** @param {number} packetId @returns {number} */
    qosState(packetId) { return lib().mqtt_qos_state(this._slot, packetId); }

    disconnect() { checkStatus(lib().mqtt_disconnect(this._slot)); }
    cleanup() { checkStatus(lib().mqtt_cleanup(this._slot)); }
}

/** @returns {number} */
export function abiVersion() { return lib().mqtt_abi_version(); }

/** @returns {number} */
export function retainedCount() { return lib().mqtt_retained_count(); }

/** @param {number} from @param {number} to @returns {boolean} */
export function canTransition(from, to) {
    return lib().mqtt_can_transition(from, to) === 1;
}

/** @param {number} qosLevel @param {number} from @param {number} to @returns {boolean} */
export function qosCanTransition(qosLevel, from, to) {
    return lib().mqtt_qos_can_transition(qosLevel, from, to) === 1;
}

/**
 * Check if a topic matches a subscription filter (MQTT wildcards).
 * @param {string} filter
 * @param {string} topic
 * @returns {boolean}
 */
export function topicMatches(filter, topic) {
    const f = new TextEncoder().encode(filter);
    const t = new TextEncoder().encode(topic);
    return lib().mqtt_topic_matches(f, f.length, t, t.length) === 1;
}
