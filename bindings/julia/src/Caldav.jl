# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-caldav protocol (CalDAV (RFC 4791)).
#
# Wraps the C-ABI functions from protocols/proven-caldav/ffi/zig/src/caldav.zig
# via ccall into libproven_caldav.so.

module Caldav

using ..ProvenServers: check_status, check_slot, SlotId

export ComponentType, CalMethod, ScheduleStatus, CalError, ServerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_caldav"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""iCalendar component types.  Matches `ComponentType` in `CaldavABI.Types`."""
@enum ComponentType::UInt8 begin
    VEVENT = 0
    VTODO = 1
    VJOURNAL = 2
    VFREEBUSY = 3
end


"""CalDAV methods.  Matches `CalMethod` in `CaldavABI.Types`."""
@enum CalMethod::UInt8 begin
    GET = 0
    PUT = 1
    DELETE = 2
    PROPFIND = 3
    PROPPATCH = 4
    REPORT = 5
    MKCALENDAR = 6
end


"""CalDAV scheduling statuses.  Matches `ScheduleStatus` in `CaldavABI.Types`."""
@enum ScheduleStatus::UInt8 begin
    NEEDS_ACTION = 0
    ACCEPTED = 1
    DECLINED = 2
    TENTATIVE = 3
    DELEGATED = 4
end


"""CalDAV error codes.  Matches `CalError` in `CaldavABI.Types`."""
@enum CalError::UInt8 begin
    VALID_CALENDAR_DATA = 0
    NO_RESOURCE_TYPE_CHANGE = 1
    SUPPORTED_COMPONENT_MISMATCH = 2
    MAX_RESOURCE_SIZE = 3
    UID_CONFLICT = 4
    PRECONDITION_FAILED = 5
end


"""CalDAV server lifecycle states.  Matches `ServerState` in `CaldavABI.Types`."""
@enum ServerState::UInt8 begin
    IDLE = 0
    BOUND = 1
    SERVING = 2
    SCHEDULING = 3
    SHUTDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_caldav."""
function abi_version()::UInt32
    ccall((:caldav_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new CalDAV (RFC 4791) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:caldav_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given CalDAV (RFC 4791) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:caldav_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ServerState

Get the current CalDAV (RFC 4791) lifecycle state.
"""
function get_state(slot::SlotId)::ServerState
    ServerState(ccall((:caldav_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ServerState, to::ServerState) -> Bool

Check whether a CalDAV (RFC 4791) state transition is valid.
"""
function can_transition(from::ServerState, to::ServerState)::Bool
    ccall((:caldav_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Caldav
