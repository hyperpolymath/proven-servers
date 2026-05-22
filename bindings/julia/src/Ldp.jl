# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ldp protocol (Linked Data Platform (W3C LDP)).
#
# Wraps the C-ABI functions from protocols/proven-ldp/ffi/zig/src/ldp.zig
# via ccall into libproven_ldp.so.

module Ldp

using ..ProvenServers: check_status, check_slot, SlotId

export ContainerType, LdpResourceType, Preference, InteractionModel, ConstraintViolation,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_ldp"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""LDP container types.  Matches `ContainerType` in `LdpABI.Types`."""
@enum ContainerType::UInt8 begin
    BASIC = 0
    DIRECT = 1
    INDIRECT = 2
end


"""LDP resource types.  Matches `LdpResourceType` in `LdpABI.Types`."""
@enum LdpResourceType::UInt8 begin
    RDF_SOURCE = 0
    NON_RDF_SOURCE = 1
    CONTAINER = 2
end


"""LDP prefer header values.  Matches `Preference` in `LdpABI.Types`."""
@enum Preference::UInt8 begin
    MINIMAL_CONTAINER = 0
    INCLUDE_CONTAINMENT = 1
    INCLUDE_MEMBERSHIP = 2
    OMIT_CONTAINMENT = 3
    OMIT_MEMBERSHIP = 4
end


"""LDP interaction models.  Matches `InteractionModel` in `LdpABI.Types`."""
@enum InteractionModel::UInt8 begin
    LDPR = 0
    LDPC = 1
    LDP_BASIC_CONTAINER = 2
    LDP_DIRECT_CONTAINER = 3
    LDP_INDIRECT_CONTAINER = 4
end


"""LDP constraint violations.  Matches `ConstraintViolation` in `LdpABI.Types`."""
@enum ConstraintViolation::UInt8 begin
    MEMBERSHIP_CONSTANT = 0
    CONTAINS_TRIPLES_MODIFIED = 1
    SERVER_MANAGED = 2
    TYPE_CONFLICT = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ldp."""
function abi_version()::UInt32
    ccall((:ldp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Linked Data Platform (W3C LDP) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ldp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Linked Data Platform (W3C LDP) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ldp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ContainerType

Get the current Linked Data Platform (W3C LDP) lifecycle state.
"""
function get_state(slot::SlotId)::ContainerType
    ContainerType(ccall((:ldp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ContainerType, to::ContainerType) -> Bool

Check whether a Linked Data Platform (W3C LDP) state transition is valid.
"""
function can_transition(from::ContainerType, to::ContainerType)::Bool
    ccall((:ldp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Ldp
