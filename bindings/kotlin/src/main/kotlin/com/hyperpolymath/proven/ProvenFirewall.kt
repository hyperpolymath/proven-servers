// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kotlin/JNI bindings for the proven-firewall protocol.
// Wraps the C-ABI functions from protocols/proven-firewall/ffi/zig/src/firewall.zig.
// Enum classes match Idris2 ABI tags exactly (FirewallABI.Layout).

package com.hyperpolymath.proven

/**
 * Kotlin bindings for the proven firewall protocol.
 *
 * Packet lifecycle: Idle -> Classified -> Evaluating -> Decided -> Committed.
 * Conntrack lifecycle: None -> Tracking -> Established/Related -> Expired.
 *
 * @author Jonathan D.A. Jewell
 */
public class ProvenFirewall private constructor(private val slot: Int) : AutoCloseable {

    /** Firewall rule actions (tags 0-7). */
    public enum class Action(public val tag: Int) {
        ACCEPT(0), DROP(1), REJECT(2), LOG(3),
        REDIRECT(4), DNAT(5), SNAT(6), MASQUERADE(7);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): Action? = entries.find { it.tag == tag }
        }
    }

    /** Firewall packet lifecycle states (tags 0-4). */
    public enum class PacketState(public val tag: Int) {
        IDLE(0), CLASSIFIED(1), EVALUATING(2), DECIDED(3), COMMITTED(4);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): PacketState? = entries.find { it.tag == tag }
        }
    }

    /** Connection tracking states (tags 0-4). */
    public enum class ConntrackState(public val tag: Int) {
        NONE(0), TRACKING(1), ESTABLISHED(2), RELATED(3), EXPIRED(4);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): ConntrackState? = entries.find { it.tag == tag }
        }
    }

    private companion object {
        @JvmStatic external fun fw_abi_version(): Int
        @JvmStatic external fun fw_create_context(): Int
        @JvmStatic external fun fw_destroy_context(slot: Int)
        @JvmStatic external fun fw_packet_state(slot: Int): Int
        @JvmStatic external fun fw_conntrack_state(slot: Int): Int
        @JvmStatic external fun fw_get_decision(slot: Int): Int
        @JvmStatic external fun fw_rule_count(slot: Int): Int
        @JvmStatic external fun fw_packet_proto(slot: Int): Int
        @JvmStatic external fun fw_packet_chain(slot: Int): Int
        @JvmStatic external fun fw_packet_src_ip(slot: Int): Int
        @JvmStatic external fun fw_packet_dst_ip(slot: Int): Int
        @JvmStatic external fun fw_packet_src_port(slot: Int): Int
        @JvmStatic external fun fw_packet_dst_port(slot: Int): Int
        @JvmStatic external fun fw_classify_packet(slot: Int, proto: Int, chain: Int, srcIp: Int, dstIp: Int, srcPort: Int, dstPort: Int): Int
        @JvmStatic external fun fw_begin_chain(slot: Int): Int
        @JvmStatic external fun fw_add_rule(slot: Int, matchType: Int, matchValue: Int, action: Int, priority: Int): Int
        @JvmStatic external fun fw_set_default_action(slot: Int, action: Int): Int
        @JvmStatic external fun fw_evaluate_rules(slot: Int): Int
        @JvmStatic external fun fw_commit(slot: Int): Int
        @JvmStatic external fun fw_begin_tracking(slot: Int): Int
        @JvmStatic external fun fw_complete_tracking(slot: Int, connStateTag: Int): Int
        @JvmStatic external fun fw_expire_conn(slot: Int): Int
        @JvmStatic external fun fw_can_transition(from: Int, to: Int): Int
        @JvmStatic external fun fw_can_conntrack_transition(from: Int, to: Int): Int
    }

    override fun close() { fw_destroy_context(slot) }

    public val packetState: PacketState? get() = PacketState.fromTag(fw_packet_state(slot))
    public val conntrackState: ConntrackState? get() = ConntrackState.fromTag(fw_conntrack_state(slot))
    public val decision: Action? get() = Action.fromTag(fw_get_decision(slot))
    public val ruleCount: Int get() = fw_rule_count(slot)
    public val packetProto: Int get() = fw_packet_proto(slot)
    public val packetChain: Int get() = fw_packet_chain(slot)
    public val packetSrcIp: Int get() = fw_packet_src_ip(slot)
    public val packetDstIp: Int get() = fw_packet_dst_ip(slot)
    public val packetSrcPort: Int get() = fw_packet_src_port(slot)
    public val packetDstPort: Int get() = fw_packet_dst_port(slot)

    /** Classify a packet. Transitions Idle -> Classified. */
    public fun classifyPacket(proto: Int, chain: Int, srcIp: Int, dstIp: Int, srcPort: Int, dstPort: Int): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(fw_classify_packet(slot, proto, chain, srcIp, dstIp, srcPort, dstPort))
    }

    public fun beginChain(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(fw_begin_chain(slot)) }

    /** Add a rule to the evaluation chain. */
    public fun addRule(matchType: Int, matchValue: Int, action: Action, priority: Int): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(fw_add_rule(slot, matchType, matchValue, action.tag, priority))
    }

    public fun setDefaultAction(action: Action): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(fw_set_default_action(slot, action.tag))
    }

    public fun evaluateRules(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(fw_evaluate_rules(slot)) }
    public fun commit(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(fw_commit(slot)) }
    public fun beginTracking(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(fw_begin_tracking(slot)) }

    public fun completeTracking(connState: ConntrackState): Result<Unit> = ProvenError.runCatching {
        ProvenError.checkStatus(fw_complete_tracking(slot, connState.tag))
    }

    public fun expireConnection(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(fw_expire_conn(slot)) }

    public companion object {
        @JvmStatic public fun create(): Result<ProvenFirewall> = ProvenError.runCatching {
            ProvenFirewall(ProvenError.checkSlot(fw_create_context()))
        }

        @JvmStatic public fun abiVersion(): Int = fw_abi_version()

        @JvmStatic public fun canTransition(from: PacketState, to: PacketState): Boolean =
            fw_can_transition(from.tag, to.tag) == 1

        @JvmStatic public fun canConntrackTransition(from: ConntrackState, to: ConntrackState): Boolean =
            fw_can_conntrack_transition(from.tag, to.tag) == 1
    }
}
