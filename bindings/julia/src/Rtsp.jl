# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-rtsp protocol (RTSP (RFC 7826) server).
#
# Wraps the C-ABI functions from protocols/proven-rtsp/ffi/zig/src/rtsp.zig
# via ccall into libproven_rtsp.so.

module Rtsp

using ..ProvenServers: check_status, check_slot, SlotId

export RTSP_PORT,
       RTSPS_PORT,
       RtspMethod,
       RtspTransportProtocol,
       RtspSessionState,
       RtspStatusCode,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_rtsp"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""RTSP_PORT: protocol constant."""
const RTSP_PORT = UInt16(554)

"""RTSPS_PORT: protocol constant."""
const RTSPS_PORT = UInt16(322)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""RTSP methods."""
@enum RtspMethod::UInt8 begin
    METHOD_DESCRIBE = 0
    METHOD_SETUP = 1
    METHOD_PLAY = 2
    METHOD_PAUSE = 3
    METHOD_TEARDOWN = 4
    METHOD_GET_PARAMETER = 5
    METHOD_SET_PARAMETER = 6
    METHOD_OPTIONS = 7
    METHOD_ANNOUNCE = 8
    METHOD_RECORD = 9
    METHOD_REDIRECT = 10
end

"""RTSP transport protocols."""
@enum RtspTransportProtocol::UInt8 begin
    TRANSPORT_RTP_AVP_UDP = 0
    TRANSPORT_RTP_AVP_TCP = 1
    TRANSPORT_RTP_AVP_UDP_MULTICAST = 2
end

"""RTSP session states."""
@enum RtspSessionState::UInt8 begin
    STATE_INIT = 0
    STATE_READY = 1
    STATE_PLAYING = 2
    STATE_RECORDING = 3
end

"""RTSP status codes."""
@enum RtspStatusCode::UInt8 begin
    STATUS_OK = 0
    STATUS_MOVED_PERMANENTLY = 1
    STATUS_MOVED_TEMPORARILY = 2
    STATUS_BAD_REQUEST = 3
    STATUS_UNAUTHORIZED = 4
    STATUS_NOT_FOUND = 5
    STATUS_METHOD_NOT_ALLOWED = 6
    STATUS_NOT_ACCEPTABLE = 7
    STATUS_SESSION_NOT_FOUND = 8
    STATUS_INTERNAL_SERVER_ERROR = 9
    STATUS_NOT_IMPLEMENTED = 10
    STATUS_SERVICE_UNAVAILABLE = 11
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_rtsp."""
function abi_version()::UInt32
    ccall((:rtsp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Rtsp context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:rtsp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Rtsp context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:rtsp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> RtspSessionState

Get the current Rtsp lifecycle state.
"""
function get_state(slot::SlotId)::RtspSessionState
    RtspSessionState(ccall((:rtsp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::RtspSessionState, to::RtspSessionState) -> Bool

Check whether a Rtsp state transition is valid.
"""
function can_transition(from::RtspSessionState, to::RtspSessionState)::Bool
    ccall((:rtsp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Rtsp
