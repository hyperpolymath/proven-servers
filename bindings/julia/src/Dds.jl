# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-dds protocol (DDS (Data Distribution Service)).
#
# Wraps the C-ABI functions from protocols/proven-dds/ffi/zig/src/dds.zig
# via ccall into libproven_dds.so.

module Dds

using ..ProvenServers: check_status, check_slot, SlotId

export ReliabilityKind, DurabilityKind, HistoryKind, OwnershipKind, EntityType, ParticipantState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_dds"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""DDS reliability QoS.  Matches `ReliabilityKind` in `DdsABI.Types`."""
@enum ReliabilityKind::UInt8 begin
    BEST_EFFORT = 0
    RELIABLE = 1
end


"""DDS durability QoS.  Matches `DurabilityKind` in `DdsABI.Types`."""
@enum DurabilityKind::UInt8 begin
    TRANSIENT_LOCAL = 1
    TRANSIENT = 2
    PERSISTENT = 3
end


"""DDS history QoS.  Matches `HistoryKind` in `DdsABI.Types`."""
@enum HistoryKind::UInt8 begin
    KEEP_LAST = 0
    KEEP_ALL = 1
end


"""DDS ownership QoS.  Matches `OwnershipKind` in `DdsABI.Types`."""
@enum OwnershipKind::UInt8 begin
    SHARED = 0
    EXCLUSIVE = 1
end


"""DDS entity types.  Matches `EntityType` in `DdsABI.Types`."""
@enum EntityType::UInt8 begin
    PARTICIPANT = 0
    PUBLISHER = 1
    SUBSCRIBER = 2
    TOPIC = 3
    DATA_WRITER = 4
    DATA_READER = 5
end


"""DDS participant states.  Matches `ParticipantState` in `DdsABI.Types`."""
@enum ParticipantState::UInt8 begin
    IDLE = 0
    JOINED = 1
    PUBLISHING = 2
    SUBSCRIBING = 3
    LEAVING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_dds."""
function abi_version()::UInt32
    ccall((:dds_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new DDS (Data Distribution Service) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:dds_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given DDS (Data Distribution Service) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:dds_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ParticipantState

Get the current DDS (Data Distribution Service) lifecycle state.
"""
function get_state(slot::SlotId)::ParticipantState
    ParticipantState(ccall((:dds_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ParticipantState, to::ParticipantState) -> Bool

Check whether a DDS (Data Distribution Service) state transition is valid.
"""
function can_transition(from::ParticipantState, to::ParticipantState)::Bool
    ccall((:dds_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Dds
