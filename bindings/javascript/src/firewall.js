// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// JavaScript bindings for the proven-firewall Zig FFI.

import { checkSlot, checkStatus } from "./error.js";
import { loadLibrary } from "./ffi.js";

/** @readonly @enum {number} Firewall rule actions. */
export const FirewallAction = Object.freeze({
    ACCEPT: 0, DROP: 1, REJECT: 2, LOG: 3, REDIRECT: 4,
    DNAT: 5, SNAT: 6, MASQUERADE: 7,
});

/** @readonly @enum {number} Firewall packet lifecycle states. */
export const PacketState = Object.freeze({
    IDLE: 0, CLASSIFIED: 1, EVALUATING: 2, DECIDED: 3, COMMITTED: 4,
});

/** @readonly @enum {number} Connection tracking states. */
export const ConntrackState = Object.freeze({
    NONE: 0, TRACKING: 1, ESTABLISHED: 2, RELATED: 3, EXPIRED: 4,
});

let _lib = null;

/** @param {object} [options] */
export async function init(options) {
    if (!_lib) _lib = await loadLibrary("firewall", options);
}

function lib() {
    if (!_lib) throw new Error("firewall: call init() before using the module");
    return _lib;
}

/**
 * Firewall packet evaluation context wrapping a Zig FFI slot.
 */
export class FirewallContext {
    constructor(slot) { this._slot = slot; this._destroyed = false; }

    static create() {
        return new FirewallContext(checkSlot(lib().fw_create_context()));
    }

    destroy() {
        if (!this._destroyed) { lib().fw_destroy_context(this._slot); this._destroyed = true; }
    }

    /** @returns {number|null} */ packetState() {
        const tag = lib().fw_packet_state(this._slot); return tag <= 4 ? tag : null;
    }
    /** @returns {number|null} */ conntrackState() {
        const tag = lib().fw_conntrack_state(this._slot); return tag <= 4 ? tag : null;
    }
    /** @returns {number|null} */ getDecision() {
        const tag = lib().fw_get_decision(this._slot); return tag <= 7 ? tag : null;
    }
    /** @returns {number} */ ruleCount() { return lib().fw_rule_count(this._slot); }
    /** @returns {number} */ packetProto() { return lib().fw_packet_proto(this._slot); }
    /** @returns {number} */ packetChain() { return lib().fw_packet_chain(this._slot); }
    /** @returns {number} */ packetSrcIp() { return lib().fw_packet_src_ip(this._slot); }
    /** @returns {number} */ packetDstIp() { return lib().fw_packet_dst_ip(this._slot); }
    /** @returns {number} */ packetSrcPort() { return lib().fw_packet_src_port(this._slot); }
    /** @returns {number} */ packetDstPort() { return lib().fw_packet_dst_port(this._slot); }

    /**
     * Classify a packet. Transitions Idle -> Classified.
     * @param {number} proto @param {number} chain
     * @param {number} srcIp @param {number} dstIp
     * @param {number} srcPort @param {number} dstPort
     */
    classifyPacket(proto, chain, srcIp, dstIp, srcPort, dstPort) {
        checkStatus(lib().fw_classify_packet(
            this._slot, proto, chain, srcIp, dstIp, srcPort, dstPort,
        ));
    }

    beginChain() { checkStatus(lib().fw_begin_chain(this._slot)); }

    /**
     * @param {number} matchType @param {number} matchValue
     * @param {number} action - FirewallAction tag.
     * @param {number} priority
     */
    addRule(matchType, matchValue, action, priority) {
        checkStatus(lib().fw_add_rule(this._slot, matchType, matchValue, action, priority));
    }

    /** @param {number} action - FirewallAction tag. */
    setDefaultAction(action) { checkStatus(lib().fw_set_default_action(this._slot, action)); }

    evaluateRules() { checkStatus(lib().fw_evaluate_rules(this._slot)); }
    commit() { checkStatus(lib().fw_commit(this._slot)); }

    beginTracking() { checkStatus(lib().fw_begin_tracking(this._slot)); }
    /** @param {number} connState - ConntrackState tag. */
    completeTracking(connState) { checkStatus(lib().fw_complete_tracking(this._slot, connState)); }
    expireConn() { checkStatus(lib().fw_expire_conn(this._slot)); }
}

/** @returns {number} */
export function abiVersion() { return lib().fw_abi_version(); }

/** @param {number} from @param {number} to @returns {boolean} */
export function canTransition(from, to) {
    return lib().fw_can_transition(from, to) === 1;
}

/** @param {number} from @param {number} to @returns {boolean} */
export function canConntrackTransition(from, to) {
    return lib().fw_can_conntrack_transition(from, to) === 1;
}
