# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-sdn protocol (SDN (Software-Defined Networking) controller).
#
# Wraps the C-ABI functions from protocols/proven-sdn/ffi/zig/src/sdn.zig
# via ccall into libproven_sdn.so.

module Sdn

using ..ProvenServers: check_status, check_slot, SlotId

export SDN_PORT,
       SdnMessageType,
       FlowAction,
       MatchField,
       PortState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_sdn"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""SDN_PORT: protocol constant."""
const SDN_PORT = UInt16(6653)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""SDN/OpenFlow message types."""
@enum SdnMessageType::UInt8 begin
    MSG_HELLO = 0
    MSG_ERROR = 1
    MSG_ECHO_REQUEST = 2
    MSG_ECHO_REPLY = 3
    MSG_FEATURES_REQUEST = 4
    MSG_FEATURES_REPLY = 5
    MSG_FLOW_MOD = 6
    MSG_PACKET_IN = 7
    MSG_PACKET_OUT = 8
    MSG_PORT_STATUS = 9
    MSG_BARRIER_REQUEST = 10
    MSG_BARRIER_REPLY = 11
end

"""SDN flow actions."""
@enum FlowAction::UInt8 begin
    ACTION_OUTPUT = 0
    ACTION_SET_FIELD = 1
    ACTION_DROP = 2
    ACTION_PUSH_VLAN = 3
    ACTION_POP_VLAN = 4
    ACTION_SET_QUEUE = 5
    ACTION_GROUP = 6
end

"""SDN match fields."""
@enum MatchField::UInt8 begin
    MATCH_IN_PORT = 0
    MATCH_ETH_DST = 1
    MATCH_ETH_SRC = 2
    MATCH_ETH_TYPE = 3
    MATCH_VLAN_ID = 4
    MATCH_IP_SRC = 5
    MATCH_IP_DST = 6
    MATCH_TCP_SRC = 7
    MATCH_TCP_DST = 8
    MATCH_UDP_SRC = 9
    MATCH_UDP_DST = 10
end

"""SDN port states."""
@enum PortState::UInt8 begin
    PORT_UP = 0
    PORT_DOWN = 1
    PORT_BLOCKED = 2
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_sdn."""
function abi_version()::UInt32
    ccall((:sdn_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Sdn context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:sdn_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Sdn context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:sdn_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> PortState

Get the current Sdn lifecycle state.
"""
function get_state(slot::SlotId)::PortState
    PortState(ccall((:sdn_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::PortState, to::PortState) -> Bool

Check whether a Sdn state transition is valid.
"""
function can_transition(from::PortState, to::PortState)::Bool
    ccall((:sdn_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Sdn
