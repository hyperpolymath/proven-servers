# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-coap protocol (CoAP (Constrained Application Protocol, RFC 7252)).
#
# Wraps the C-ABI functions from protocols/proven-coap/ffi/zig/src/coap.zig
# via ccall into libproven_coap.so.

module Coap

using ..ProvenServers: check_status, check_slot, SlotId

export Method, MessageType, ContentFormat, ResponseClass, SessionState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_coap"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""CoAP request methods (RFC 7252 Section 5.8).  Matches `Method` in `CoapABI.Types`."""
@enum Method::UInt8 begin
    GET = 0
    POST = 1
    PUT = 2
    DELETE = 3
end


"""CoAP message types (RFC 7252 Section 4.1).  Matches `MessageType` in `CoapABI.Types`."""
@enum MessageType::UInt8 begin
    CONFIRMABLE = 0
    NON_CONFIRMABLE = 1
    ACKNOWLEDGEMENT = 2
    RESET = 3
end


"""CoAP content formats (RFC 7252 Section 12.3).  Matches `ContentFormat` in `CoapABI.Types`."""
@enum ContentFormat::UInt8 begin
    TEXT_PLAIN = 0
    LINK_FORMAT = 1
    XML = 2
    OCTET_STREAM = 3
    EXI = 4
    JSON = 5
    CBOR = 6
end


"""CoAP response class codes (RFC 7252 Section 5.9).  Matches `ResponseClass` in `CoapABI.Types`."""
@enum ResponseClass::UInt8 begin
    SUCCESS = 0
    CLIENT_ERROR = 1
    SERVER_ERROR = 2
    SIGNALING = 3
    EMPTY = 4
end


"""CoAP server lifecycle states for the FFI layer.  Matches `SessionState` in `CoapABI.Types`."""
@enum SessionState::UInt8 begin
    IDLE = 0
    BOUND = 1
    SERVING = 2
    OBSERVING = 3
    SHUTDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_coap."""
function abi_version()::UInt32
    ccall((:coap_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new CoAP (Constrained Application Protocol, RFC 7252) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:coap_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given CoAP (Constrained Application Protocol, RFC 7252) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:coap_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SessionState

Get the current CoAP (Constrained Application Protocol, RFC 7252) lifecycle state.
"""
function get_state(slot::SlotId)::SessionState
    SessionState(ccall((:coap_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SessionState, to::SessionState) -> Bool

Check whether a CoAP (Constrained Application Protocol, RFC 7252) state transition is valid.
"""
function can_transition(from::SessionState, to::SessionState)::Bool
    ccall((:coap_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Coap
