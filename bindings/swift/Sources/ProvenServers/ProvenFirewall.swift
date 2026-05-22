// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Swift bindings for the proven-firewall protocol.
// Wraps the C-ABI functions from protocols/proven-firewall/ffi/zig/src/firewall.zig.
// Enums match Idris2 ABI tags exactly (FirewallABI.Layout).

import Foundation

// MARK: - C interop declarations

@_silgen_name("fw_abi_version")          private func fw_abi_version() -> UInt32
@_silgen_name("fw_create_context")       private func fw_create_context() -> Int32
@_silgen_name("fw_destroy_context")      private func fw_destroy_context(_ slot: Int32)
@_silgen_name("fw_packet_state")         private func fw_packet_state(_ slot: Int32) -> UInt8
@_silgen_name("fw_conntrack_state")      private func fw_conntrack_state(_ slot: Int32) -> UInt8
@_silgen_name("fw_get_decision")         private func fw_get_decision(_ slot: Int32) -> UInt8
@_silgen_name("fw_rule_count")           private func fw_rule_count(_ slot: Int32) -> UInt16
@_silgen_name("fw_packet_proto")         private func fw_packet_proto(_ slot: Int32) -> UInt8
@_silgen_name("fw_packet_chain")         private func fw_packet_chain(_ slot: Int32) -> UInt8
@_silgen_name("fw_packet_src_ip")        private func fw_packet_src_ip(_ slot: Int32) -> UInt32
@_silgen_name("fw_packet_dst_ip")        private func fw_packet_dst_ip(_ slot: Int32) -> UInt32
@_silgen_name("fw_packet_src_port")      private func fw_packet_src_port(_ slot: Int32) -> UInt16
@_silgen_name("fw_packet_dst_port")      private func fw_packet_dst_port(_ slot: Int32) -> UInt16
@_silgen_name("fw_classify_packet")      private func fw_classify_packet(_ slot: Int32, _ proto: UInt8, _ chain: UInt8, _ srcIp: UInt32, _ dstIp: UInt32, _ srcPort: UInt16, _ dstPort: UInt16) -> UInt8
@_silgen_name("fw_begin_chain")          private func fw_begin_chain(_ slot: Int32) -> UInt8
@_silgen_name("fw_add_rule")             private func fw_add_rule(_ slot: Int32, _ matchType: UInt8, _ matchValue: UInt32, _ action: UInt8, _ priority: UInt16) -> UInt8
@_silgen_name("fw_set_default_action")   private func fw_set_default_action(_ slot: Int32, _ action: UInt8) -> UInt8
@_silgen_name("fw_evaluate_rules")       private func fw_evaluate_rules(_ slot: Int32) -> UInt8
@_silgen_name("fw_commit")              private func fw_commit(_ slot: Int32) -> UInt8
@_silgen_name("fw_begin_tracking")       private func fw_begin_tracking(_ slot: Int32) -> UInt8
@_silgen_name("fw_complete_tracking")    private func fw_complete_tracking(_ slot: Int32, _ connStateTag: UInt8) -> UInt8
@_silgen_name("fw_expire_conn")          private func fw_expire_conn(_ slot: Int32) -> UInt8
@_silgen_name("fw_can_transition")       private func fw_can_transition(_ from: UInt8, _ to: UInt8) -> UInt8
@_silgen_name("fw_can_conntrack_transition") private func fw_can_conntrack_transition(_ from: UInt8, _ to: UInt8) -> UInt8

// MARK: - Enums matching Idris2 ABI tags

/// Firewall rule actions (tags 0-7).
public enum FirewallAction: Int, CaseIterable, Sendable {
    /// Accept the packet.
    case accept = 0
    /// Silently drop the packet.
    case drop = 1
    /// Reject with ICMP error.
    case reject = 2
    /// Log and continue processing.
    case log = 3
    /// Redirect to a different destination.
    case redirect = 4
    /// Destination NAT.
    case dnat = 5
    /// Source NAT.
    case snat = 6
    /// IP masquerading.
    case masquerade = 7

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// Firewall packet lifecycle states (tags 0-4).
public enum FirewallPacketState: Int, CaseIterable, Sendable {
    /// No packet classified yet.
    case idle = 0
    /// Packet classified (protocol, IPs, ports set).
    case classified = 1
    /// Chain evaluation in progress.
    case evaluating = 2
    /// Decision made.
    case decided = 3
    /// Committed (final).
    case committed = 4

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// Connection tracking states (tags 0-4).
public enum FirewallConntrackState: Int, CaseIterable, Sendable {
    /// No connection tracking.
    case none = 0
    /// Tracking in progress.
    case tracking = 1
    /// Connection established.
    case established = 2
    /// Related connection.
    case related = 3
    /// Connection expired.
    case expired = 4

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

// MARK: - Swift-idiomatic wrapper

/// Swift wrapper for the proven firewall protocol FFI.
///
/// Manages an opaque firewall context slot. The context is
/// automatically destroyed when this object is deallocated.
///
/// Packet lifecycle: Idle -> Classified -> Evaluating -> Decided -> Committed.
/// Conntrack lifecycle: None -> Tracking -> Established/Related -> Expired.
public final class ProvenFirewall: @unchecked Sendable {

    private let slot: Int32

    /// Create a new firewall context.
    ///
    /// - Throws: ``ProvenError/poolExhausted`` if all 64 slots are in use.
    public init() throws {
        self.slot = try ProvenError.checkSlot(fw_create_context())
    }

    deinit { fw_destroy_context(slot) }

    /// The ABI version.
    public static var abiVersion: UInt32 { fw_abi_version() }

    /// The current packet lifecycle state.
    public var packetState: FirewallPacketState? {
        FirewallPacketState(tag: fw_packet_state(slot))
    }

    /// The current connection tracking state.
    public var conntrackState: FirewallConntrackState? {
        FirewallConntrackState(tag: fw_conntrack_state(slot))
    }

    /// The decision action (only meaningful after evaluation).
    public var decision: FirewallAction? {
        FirewallAction(tag: fw_get_decision(slot))
    }

    /// The number of rules in the chain.
    public var ruleCount: UInt16 { fw_rule_count(slot) }

    /// The classified packet protocol tag.
    public var packetProto: UInt8 { fw_packet_proto(slot) }

    /// The classified packet chain tag.
    public var packetChain: UInt8 { fw_packet_chain(slot) }

    /// The source IP (raw u32 in network order).
    public var packetSrcIp: UInt32 { fw_packet_src_ip(slot) }

    /// The destination IP.
    public var packetDstIp: UInt32 { fw_packet_dst_ip(slot) }

    /// The source port.
    public var packetSrcPort: UInt16 { fw_packet_src_port(slot) }

    /// The destination port.
    public var packetDstPort: UInt16 { fw_packet_dst_port(slot) }

    /// Classify a packet. Transitions Idle -> Classified.
    ///
    /// - Parameters:
    ///   - proto: Protocol tag.
    ///   - chain: Chain tag.
    ///   - srcIp: Source IP (network order).
    ///   - dstIp: Destination IP (network order).
    ///   - srcPort: Source port.
    ///   - dstPort: Destination port.
    public func classifyPacket(proto: UInt8, chain: UInt8, srcIp: UInt32, dstIp: UInt32, srcPort: UInt16, dstPort: UInt16) throws {
        try ProvenError.checkStatus(fw_classify_packet(slot, proto, chain, srcIp, dstIp, srcPort, dstPort))
    }

    /// Begin chain evaluation. Transitions Classified -> Evaluating.
    public func beginChain() throws {
        try ProvenError.checkStatus(fw_begin_chain(slot))
    }

    /// Add a rule to the evaluation chain.
    ///
    /// - Parameters:
    ///   - matchType: Match type tag.
    ///   - matchValue: Match value.
    ///   - action: The action to take if matched.
    ///   - priority: Rule priority.
    public func addRule(matchType: UInt8, matchValue: UInt32, action: FirewallAction, priority: UInt16) throws {
        try ProvenError.checkStatus(fw_add_rule(slot, matchType, matchValue, action.tag, priority))
    }

    /// Set the default action (applied when no rules match).
    public func setDefaultAction(_ action: FirewallAction) throws {
        try ProvenError.checkStatus(fw_set_default_action(slot, action.tag))
    }

    /// Evaluate rules against the classified packet. Transitions Evaluating -> Decided.
    public func evaluateRules() throws {
        try ProvenError.checkStatus(fw_evaluate_rules(slot))
    }

    /// Commit the decision. Transitions Decided -> Committed.
    public func commit() throws {
        try ProvenError.checkStatus(fw_commit(slot))
    }

    /// Begin connection tracking. Transitions None -> Tracking.
    public func beginTracking() throws {
        try ProvenError.checkStatus(fw_begin_tracking(slot))
    }

    /// Complete connection tracking. Transitions Tracking -> specified state.
    public func completeTracking(connState: FirewallConntrackState) throws {
        try ProvenError.checkStatus(fw_complete_tracking(slot, connState.tag))
    }

    /// Expire a connection. Transitions Established/Related -> Expired.
    public func expireConnection() throws {
        try ProvenError.checkStatus(fw_expire_conn(slot))
    }

    /// Stateless query: check whether a packet state transition is valid.
    public static func canTransition(from: FirewallPacketState, to: FirewallPacketState) -> Bool {
        fw_can_transition(from.tag, to.tag) == 1
    }

    /// Stateless query: check whether a conntrack state transition is valid.
    public static func canConntrackTransition(from: FirewallConntrackState, to: FirewallConntrackState) -> Bool {
        fw_can_conntrack_transition(from.tag, to.tag) == 1
    }
}
