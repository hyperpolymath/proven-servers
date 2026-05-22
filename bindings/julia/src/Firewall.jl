# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-firewall protocol (stateful packet filter).
#
# Wraps the C-ABI functions from protocols/proven-firewall/ffi/zig/src/firewall.zig
# via ccall into libproven_firewall.so.

module Firewall

using ..ProvenServers: check_status, check_slot, SlotId

export FirewallAction, PacketState, ConntrackState, Protocol, Chain,
       abi_version, create_context, destroy_context, get_packet_state,
       get_conntrack_state, get_decision, classify_packet, begin_chain,
       add_rule, set_default_action, evaluate_rules, commit,
       begin_tracking, complete_tracking, expire_conn,
       can_transition, can_conntrack_transition

const LIB = "libproven_firewall"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Firewall rule actions."""
@enum FirewallAction::UInt8 begin
    ACTION_ACCEPT     = 0
    ACTION_DROP       = 1
    ACTION_REJECT     = 2
    ACTION_LOG        = 3
    ACTION_REDIRECT   = 4
    ACTION_DNAT       = 5
    ACTION_SNAT       = 6
    ACTION_MASQUERADE = 7
end

"""Packet processing states."""
@enum PacketState::UInt8 begin
    PACKET_NEW              = 0
    PACKET_CLASSIFIED       = 1
    PACKET_CHAIN_PROCESSING = 2
    PACKET_RULE_EVALUATING  = 3
    PACKET_DECISION_MADE    = 4
    PACKET_COMMITTED        = 5
end

"""Connection tracking states."""
@enum ConntrackState::UInt8 begin
    CONN_NONE        = 0
    CONN_NEW         = 1
    CONN_ESTABLISHED = 2
    CONN_RELATED     = 3
    CONN_INVALID     = 4
    CONN_EXPIRED     = 5
end

"""Network protocol types."""
@enum Protocol::UInt8 begin
    PROTO_TCP    = 0
    PROTO_UDP    = 1
    PROTO_ICMP   = 2
    PROTO_ICMPV6 = 3
end

"""Firewall chains."""
@enum Chain::UInt8 begin
    CHAIN_INPUT   = 0
    CHAIN_OUTPUT  = 1
    CHAIN_FORWARD = 2
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_firewall."""
function abi_version()::UInt32
    ccall((:fw_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new firewall context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:fw_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given firewall context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:fw_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_packet_state(slot::SlotId) -> PacketState

Get the current packet processing state.
"""
function get_packet_state(slot::SlotId)::PacketState
    PacketState(ccall((:fw_packet_state, LIB), UInt8, (Cint,), slot))
end

"""
    get_conntrack_state(slot::SlotId) -> ConntrackState

Get the current connection tracking state.
"""
function get_conntrack_state(slot::SlotId)::ConntrackState
    ConntrackState(ccall((:fw_conntrack_state, LIB), UInt8, (Cint,), slot))
end

"""
    get_decision(slot::SlotId) -> FirewallAction

Get the firewall decision for the current packet.
"""
function get_decision(slot::SlotId)::FirewallAction
    FirewallAction(ccall((:fw_get_decision, LIB), UInt8, (Cint,), slot))
end

"""
    classify_packet(slot::SlotId, proto::Protocol, chain::Chain,
                    src_ip::UInt32, dst_ip::UInt32,
                    src_port::UInt16, dst_port::UInt16)

Classify an incoming packet. Throws on invalid state.
"""
function classify_packet(slot::SlotId, proto::Protocol, chain::Chain,
                         src_ip::UInt32, dst_ip::UInt32,
                         src_port::UInt16, dst_port::UInt16)::Nothing
    check_status(ccall((:fw_classify_packet, LIB), UInt8,
                       (Cint, UInt8, UInt8, UInt32, UInt32, UInt16, UInt16),
                       slot, UInt8(proto), UInt8(chain),
                       src_ip, dst_ip, src_port, dst_port))
end

"""
    begin_chain(slot::SlotId)

Begin chain processing. Throws on invalid state.
"""
function begin_chain(slot::SlotId)::Nothing
    check_status(ccall((:fw_begin_chain, LIB), UInt8, (Cint,), slot))
end

"""
    add_rule(slot::SlotId, match_type::UInt8, match_value::UInt32,
             action::FirewallAction, priority::UInt16)

Add a firewall rule to the chain. Throws on invalid state.
"""
function add_rule(slot::SlotId, match_type::UInt8, match_value::UInt32,
                  action::FirewallAction, priority::UInt16)::Nothing
    check_status(ccall((:fw_add_rule, LIB), UInt8,
                       (Cint, UInt8, UInt32, UInt8, UInt16),
                       slot, match_type, match_value, UInt8(action), priority))
end

"""
    set_default_action(slot::SlotId, action::FirewallAction)

Set the default chain action. Throws on invalid state.
"""
function set_default_action(slot::SlotId, action::FirewallAction)::Nothing
    check_status(ccall((:fw_set_default_action, LIB), UInt8,
                       (Cint, UInt8), slot, UInt8(action)))
end

"""
    evaluate_rules(slot::SlotId)

Evaluate rules against the classified packet. Throws on invalid state.
"""
function evaluate_rules(slot::SlotId)::Nothing
    check_status(ccall((:fw_evaluate_rules, LIB), UInt8, (Cint,), slot))
end

"""
    commit(slot::SlotId)

Commit the firewall decision. Throws on invalid state.
"""
function commit(slot::SlotId)::Nothing
    check_status(ccall((:fw_commit, LIB), UInt8, (Cint,), slot))
end

"""
    begin_tracking(slot::SlotId)

Begin connection tracking. Throws on invalid state.
"""
function begin_tracking(slot::SlotId)::Nothing
    check_status(ccall((:fw_begin_tracking, LIB), UInt8, (Cint,), slot))
end

"""
    complete_tracking(slot::SlotId, state::ConntrackState)

Complete connection tracking with the given state. Throws on invalid state.
"""
function complete_tracking(slot::SlotId, state::ConntrackState)::Nothing
    check_status(ccall((:fw_complete_tracking, LIB), UInt8,
                       (Cint, UInt8), slot, UInt8(state)))
end

"""
    expire_conn(slot::SlotId)

Expire a tracked connection. Throws on invalid state.
"""
function expire_conn(slot::SlotId)::Nothing
    check_status(ccall((:fw_expire_conn, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::PacketState, to::PacketState) -> Bool

Check whether a packet state transition is valid.
"""
function can_transition(from::PacketState, to::PacketState)::Bool
    ccall((:fw_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

"""
    can_conntrack_transition(from::ConntrackState, to::ConntrackState) -> Bool

Check whether a connection tracking state transition is valid.
"""
function can_conntrack_transition(from::ConntrackState, to::ConntrackState)::Bool
    ccall((:fw_can_conntrack_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Firewall
