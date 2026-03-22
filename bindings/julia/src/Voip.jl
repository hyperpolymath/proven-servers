# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-voip protocol (VoIP/SIP (RFC 3261) server).
#
# Wraps the C-ABI functions from protocols/proven-voip/ffi/zig/src/voip.zig
# via ccall into libproven_voip.so.

module Voip

using ..ProvenServers: check_status, check_slot, SlotId

export SIP_PORT,
       SIPS_PORT,
       SipMethod,
       SipResponseCode,
       DialogState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_voip"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""SIP_PORT: protocol constant."""
const SIP_PORT = UInt16(5060)

"""SIPS_PORT: protocol constant."""
const SIPS_PORT = UInt16(5061)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""SIP methods."""
@enum SipMethod::UInt8 begin
    METHOD_INVITE = 0
    METHOD_ACK = 1
    METHOD_BYE = 2
    METHOD_CANCEL = 3
    METHOD_REGISTER = 4
    METHOD_OPTIONS = 5
    METHOD_INFO = 6
    METHOD_UPDATE = 7
    METHOD_SUBSCRIBE = 8
    METHOD_NOTIFY = 9
    METHOD_REFER = 10
    METHOD_MESSAGE = 11
    METHOD_PRACK = 12
end

"""SIP response codes."""
@enum SipResponseCode::UInt8 begin
    RESP_TRYING = 0
    RESP_RINGING = 1
    RESP_SESSION_PROGRESS = 2
    RESP_OK = 3
    RESP_MULTIPLE_CHOICES = 4
    RESP_MOVED_PERMANENTLY = 5
    RESP_MOVED_TEMPORARILY = 6
    RESP_BAD_REQUEST = 7
    RESP_UNAUTHORIZED = 8
    RESP_FORBIDDEN = 9
    RESP_NOT_FOUND = 10
    RESP_METHOD_NOT_ALLOWED = 11
    RESP_REQUEST_TIMEOUT = 12
    RESP_BUSY_HERE = 13
    RESP_DECLINE = 14
    RESP_SERVER_INTERNAL_ERROR = 15
    RESP_SERVICE_UNAVAILABLE = 16
end

"""SIP dialog states."""
@enum DialogState::UInt8 begin
    DIALOG_EARLY = 0
    DIALOG_CONFIRMED = 1
    DIALOG_TERMINATED = 2
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_voip."""
function abi_version()::UInt32
    ccall((:voip_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Voip context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:voip_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Voip context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:voip_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> DialogState

Get the current Voip lifecycle state.
"""
function get_state(slot::SlotId)::DialogState
    DialogState(ccall((:voip_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::DialogState, to::DialogState) -> Bool

Check whether a Voip state transition is valid.
"""
function can_transition(from::DialogState, to::DialogState)::Bool
    ccall((:voip_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Voip
