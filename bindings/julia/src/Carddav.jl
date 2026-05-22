# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-carddav protocol (CardDAV (RFC 6352)).
#
# Wraps the C-ABI functions from protocols/proven-carddav/ffi/zig/src/carddav.zig
# via ccall into libproven_carddav.so.

module Carddav

using ..ProvenServers: check_status, check_slot, SlotId

export PropertyType, CardMethod, VCardVersion, CardError, ServerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_carddav"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""vCard property types.  Matches `PropertyType` in `CarddavABI.Types`."""
@enum PropertyType::UInt8 begin
    FN_NAME = 0
    N = 1
    EMAIL = 2
    TEL = 3
    ADR = 4
    ORG = 5
    PHOTO = 6
    URL = 7
    NOTE = 8
end


"""CardDAV methods.  Matches `CardMethod` in `CarddavABI.Types`."""
@enum CardMethod::UInt8 begin
    GET = 0
    PUT = 1
    DELETE = 2
    PROPFIND = 3
    PROPPATCH = 4
    REPORT = 5
    MKCOL = 6
end


"""vCard versions.  Matches `VCardVersion` in `CarddavABI.Types`."""
@enum VCardVersion::UInt8 begin
    VCARD3 = 0
    VCARD4 = 1
end


"""CardDAV error codes.  Matches `CardError` in `CarddavABI.Types`."""
@enum CardError::UInt8 begin
    VALID_ADDRESS_DATA = 0
    NO_RESOURCE_TYPE = 1
    MAX_RESOURCE_SIZE = 2
    UID_CONFLICT = 3
    SUPPORTED_ADDRESS_DATA = 4
    PRECONDITION_FAILED = 5
end


"""CardDAV server lifecycle states.  Matches `ServerState` in `CarddavABI.Types`."""
@enum ServerState::UInt8 begin
    IDLE = 0
    BOUND = 1
    SERVING = 2
    SHUTDOWN = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_carddav."""
function abi_version()::UInt32
    ccall((:carddav_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new CardDAV (RFC 6352) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:carddav_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given CardDAV (RFC 6352) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:carddav_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ServerState

Get the current CardDAV (RFC 6352) lifecycle state.
"""
function get_state(slot::SlotId)::ServerState
    ServerState(ccall((:carddav_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ServerState, to::ServerState) -> Bool

Check whether a CardDAV (RFC 6352) state transition is valid.
"""
function can_transition(from::ServerState, to::ServerState)::Bool
    ccall((:carddav_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Carddav
