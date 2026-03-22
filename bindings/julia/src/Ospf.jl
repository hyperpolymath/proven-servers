# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ospf protocol (OSPF (RFC 2328) routing protocol).
#
# Wraps the C-ABI functions from protocols/proven-ospf/ffi/zig/src/ospf.zig
# via ccall into libproven_ospf.so.

module Ospf

using ..ProvenServers: check_status, check_slot, SlotId

export PacketType,
       NeighborState,
       LsaType,
       AreaType,
       OspfError,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_ospf"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""OSPF packet types."""
@enum PacketType::UInt8 begin
    PKT_HELLO = 0
    PKT_DATABASE_DESCRIPTION = 1
    PKT_LINK_STATE_REQUEST = 2
    PKT_LINK_STATE_UPDATE = 3
    PKT_LINK_STATE_ACK = 4
end

"""OSPF neighbor state machine."""
@enum NeighborState::UInt8 begin
    NBR_DOWN = 0
    NBR_ATTEMPT = 1
    NBR_INIT = 2
    NBR_TWO_WAY = 3
    NBR_EX_START = 4
    NBR_EXCHANGE = 5
    NBR_LOADING = 6
    NBR_FULL = 7
end

"""OSPF LSA types."""
@enum LsaType::UInt8 begin
    LSA_ROUTER = 0
    LSA_NETWORK = 1
    LSA_SUMMARY = 2
    LSA_ASBR_SUMMARY = 3
    LSA_AS_EXTERNAL = 4
end

"""OSPF area types."""
@enum AreaType::UInt8 begin
    AREA_NORMAL = 0
    AREA_STUB = 1
    AREA_TOTALLY_STUB = 2
    AREA_NSSA = 3
end

"""OSPF FFI error codes."""
@enum OspfError::UInt8 begin
    ERR_OK = 0
    ERR_INVALID_SLOT = 1
    ERR_NOT_ACTIVE = 2
    ERR_INVALID_TRANSITION = 3
    ERR_INVALID_PACKET = 4
    ERR_AREA_ERROR = 5
    ERR_FLOOD_LIMIT = 6
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ospf."""
function abi_version()::UInt32
    ccall((:ospf_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Ospf context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ospf_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Ospf context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ospf_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> NeighborState

Get the current Ospf lifecycle state.
"""
function get_state(slot::SlotId)::NeighborState
    NeighborState(ccall((:ospf_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::NeighborState, to::NeighborState) -> Bool

Check whether a Ospf state transition is valid.
"""
function can_transition(from::NeighborState, to::NeighborState)::Bool
    ccall((:ospf_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Ospf
