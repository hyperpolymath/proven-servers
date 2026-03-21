// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// Firewall protocol bindings for proven-servers.
//
// Wraps the C-ABI functions from protocols/proven-firewall/ffi/zig/src/firewall.zig.
// Lifecycle: create -> classify -> begin_chain -> add_rules -> evaluate -> commit.
package proven

/*
#cgo LDFLAGS: -lproven_firewall
#include <stdint.h>

extern uint32_t fw_abi_version();
extern int fw_create_context();
extern void fw_destroy_context(int slot);
extern uint8_t fw_packet_state(int slot);
extern uint8_t fw_conntrack_state(int slot);
extern uint8_t fw_get_decision(int slot);
extern uint16_t fw_rule_count(int slot);
extern uint8_t fw_packet_proto(int slot);
extern uint8_t fw_packet_chain(int slot);
extern uint32_t fw_packet_src_ip(int slot);
extern uint32_t fw_packet_dst_ip(int slot);
extern uint16_t fw_packet_src_port(int slot);
extern uint16_t fw_packet_dst_port(int slot);
extern uint8_t fw_conn_state(int slot);
extern uint8_t fw_classify_packet(int slot, uint8_t proto, uint8_t chain, uint32_t src_ip, uint32_t dst_ip, uint16_t src_port, uint16_t dst_port);
extern uint8_t fw_begin_chain(int slot);
extern uint8_t fw_add_rule(int slot, uint8_t match_type, uint32_t match_value, uint8_t action, uint16_t priority);
extern uint8_t fw_set_default_action(int slot, uint8_t action);
extern uint8_t fw_evaluate_rules(int slot);
extern uint8_t fw_commit(int slot);
extern uint8_t fw_begin_tracking(int slot);
extern uint8_t fw_complete_tracking(int slot, uint8_t conn_state_tag);
extern uint8_t fw_expire_conn(int slot);
extern uint8_t fw_can_transition(uint8_t from, uint8_t to);
extern uint8_t fw_can_conntrack_transition(uint8_t from, uint8_t to);
*/
import "C"

// FirewallAction represents a firewall rule action.
// Tags match Action in firewall.zig.
type FirewallAction uint8

const (
	FwAccept     FirewallAction = iota // Accept the packet
	FwDrop                             // Silently drop the packet
	FwReject                           // Reject with ICMP error
	FwLog                              // Log and continue processing
	FwRedirect                         // Redirect to different destination
	FwDnat                             // Destination NAT
	FwSnat                             // Source NAT
	FwMasquerade                       // IP masquerading
)

// PacketState represents the firewall packet lifecycle state.
type PacketState uint8

const (
	PktIdle       PacketState = iota // No packet classified yet
	PktClassified                    // Packet classified
	PktEvaluating                    // Chain evaluation in progress
	PktDecided                       // Decision made
	PktCommitted                     // Committed (final)
)

// ConntrackState represents connection tracking states.
type ConntrackState uint8

const (
	ConnNone        ConntrackState = iota // No connection tracking
	ConnTracking                          // Tracking in progress
	ConnEstablished                       // Connection established
	ConnRelated                           // Related connection
	ConnExpired                           // Connection expired
)

// FirewallContext wraps a slot in the proven-firewall context pool.
type FirewallContext struct {
	slot C.int
}

// FirewallABIVersion returns the ABI version.
func FirewallABIVersion() uint32 {
	return uint32(C.fw_abi_version())
}

// FirewallCreateContext allocates a new firewall context.
func FirewallCreateContext() (*FirewallContext, error) {
	slot := C.fw_create_context()
	s, err := slotError(slot)
	if err != nil {
		return nil, err
	}
	return &FirewallContext{slot: C.int(s)}, nil
}

// Close releases the firewall context slot.
func (ctx *FirewallContext) Close() {
	C.fw_destroy_context(ctx.slot)
}

// PacketState returns the current packet lifecycle state.
func (ctx *FirewallContext) PacketState() (PacketState, bool) {
	tag := C.fw_packet_state(ctx.slot)
	if tag > 4 {
		return 0, false
	}
	return PacketState(tag), true
}

// ConntrackState returns the current connection tracking state.
func (ctx *FirewallContext) ConntrackState() (ConntrackState, bool) {
	tag := C.fw_conntrack_state(ctx.slot)
	if tag > 4 {
		return 0, false
	}
	return ConntrackState(tag), true
}

// GetDecision returns the decision action (meaningful after evaluation).
func (ctx *FirewallContext) GetDecision() (FirewallAction, bool) {
	tag := C.fw_get_decision(ctx.slot)
	if tag > 7 {
		return 0, false
	}
	return FirewallAction(tag), true
}

// RuleCount returns the number of rules in the chain.
func (ctx *FirewallContext) RuleCount() uint16 {
	return uint16(C.fw_rule_count(ctx.slot))
}

// PacketProto returns the classified packet protocol tag.
func (ctx *FirewallContext) PacketProto() uint8 {
	return uint8(C.fw_packet_proto(ctx.slot))
}

// PacketChain returns the classified packet chain tag.
func (ctx *FirewallContext) PacketChain() uint8 {
	return uint8(C.fw_packet_chain(ctx.slot))
}

// PacketSrcIP returns the source IP (raw u32 in network order).
func (ctx *FirewallContext) PacketSrcIP() uint32 {
	return uint32(C.fw_packet_src_ip(ctx.slot))
}

// PacketDstIP returns the destination IP.
func (ctx *FirewallContext) PacketDstIP() uint32 {
	return uint32(C.fw_packet_dst_ip(ctx.slot))
}

// PacketSrcPort returns the source port.
func (ctx *FirewallContext) PacketSrcPort() uint16 {
	return uint16(C.fw_packet_src_port(ctx.slot))
}

// PacketDstPort returns the destination port.
func (ctx *FirewallContext) PacketDstPort() uint16 {
	return uint16(C.fw_packet_dst_port(ctx.slot))
}

// ClassifyPacket sets protocol, chain, IPs, and ports. Transitions Idle -> Classified.
func (ctx *FirewallContext) ClassifyPacket(proto, chain uint8, srcIP, dstIP uint32, srcPort, dstPort uint16) error {
	return statusError(C.fw_classify_packet(
		ctx.slot, C.uint8_t(proto), C.uint8_t(chain),
		C.uint32_t(srcIP), C.uint32_t(dstIP),
		C.uint16_t(srcPort), C.uint16_t(dstPort),
	))
}

// BeginChain begins chain evaluation. Transitions Classified -> Evaluating.
func (ctx *FirewallContext) BeginChain() error {
	return statusError(C.fw_begin_chain(ctx.slot))
}

// AddRule adds a rule to the evaluation chain.
func (ctx *FirewallContext) AddRule(matchType uint8, matchValue uint32, action FirewallAction, priority uint16) error {
	return statusError(C.fw_add_rule(ctx.slot, C.uint8_t(matchType), C.uint32_t(matchValue), C.uint8_t(action), C.uint16_t(priority)))
}

// SetDefaultAction sets the default action when no rules match.
func (ctx *FirewallContext) SetDefaultAction(action FirewallAction) error {
	return statusError(C.fw_set_default_action(ctx.slot, C.uint8_t(action)))
}

// EvaluateRules evaluates rules against the packet. Transitions Evaluating -> Decided.
func (ctx *FirewallContext) EvaluateRules() error {
	return statusError(C.fw_evaluate_rules(ctx.slot))
}

// Commit commits the decision. Transitions Decided -> Committed.
func (ctx *FirewallContext) Commit() error {
	return statusError(C.fw_commit(ctx.slot))
}

// BeginTracking starts connection tracking. Transitions None -> Tracking.
func (ctx *FirewallContext) BeginTracking() error {
	return statusError(C.fw_begin_tracking(ctx.slot))
}

// CompleteTracking completes connection tracking with a state.
func (ctx *FirewallContext) CompleteTracking(connState ConntrackState) error {
	return statusError(C.fw_complete_tracking(ctx.slot, C.uint8_t(connState)))
}

// ExpireConn expires a connection. Transitions Established/Related -> Expired.
func (ctx *FirewallContext) ExpireConn() error {
	return statusError(C.fw_expire_conn(ctx.slot))
}

// FwCanTransition checks whether a packet state transition is valid.
func FwCanTransition(from, to PacketState) bool {
	return C.fw_can_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}

// FwConntrackCanTransition checks whether a conntrack state transition is valid.
func FwConntrackCanTransition(from, to ConntrackState) bool {
	return C.fw_can_conntrack_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}
