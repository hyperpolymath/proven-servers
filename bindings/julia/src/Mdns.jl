# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-mdns protocol (mDNS (multicast DNS, RFC 6762) server).
#
# Wraps the C-ABI functions from protocols/proven-mdns/ffi/zig/src/mdns.zig
# via ccall into libproven_mdns.so.

module Mdns

using ..ProvenServers: check_status, check_slot, SlotId

export MDNS_PORT,
       MdnsRecordType,
       QueryType,
       ConflictAction,
       ServiceFlag,
       ResponderState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_mdns"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""MDNS_PORT: protocol constant."""
const MDNS_PORT = UInt16(5353)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""mDNS record types."""
@enum MdnsRecordType::UInt8 begin
    RTYPE_A = 0
    RTYPE_AAAA = 1
    RTYPE_PTR = 2
    RTYPE_SRV = 3
    RTYPE_TXT = 4
end

"""mDNS query types."""
@enum QueryType::UInt8 begin
    QUERY_STANDARD = 0
    QUERY_ONESHOT = 1
    QUERY_CONTINUOUS = 2
end

"""mDNS conflict resolution actions."""
@enum ConflictAction::UInt8 begin
    CONFLICT_PROBE = 0
    CONFLICT_DEFEND = 1
    CONFLICT_WITHDRAW = 2
end

"""mDNS service flags."""
@enum ServiceFlag::UInt8 begin
    FLAG_UNIQUE = 0
    FLAG_SHARED = 1
end

"""mDNS responder states."""
@enum ResponderState::UInt8 begin
    STATE_IDLE = 0
    STATE_PROBING = 1
    STATE_ANNOUNCING = 2
    STATE_RUNNING = 3
    STATE_SHUTTING_DOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_mdns."""
function abi_version()::UInt32
    ccall((:mdns_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Mdns context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:mdns_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Mdns context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:mdns_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ResponderState

Get the current Mdns lifecycle state.
"""
function get_state(slot::SlotId)::ResponderState
    ResponderState(ccall((:mdns_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ResponderState, to::ResponderState) -> Bool

Check whether a Mdns state transition is valid.
"""
function can_transition(from::ResponderState, to::ResponderState)::Bool
    ccall((:mdns_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Mdns
