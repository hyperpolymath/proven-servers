# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-doh protocol (DNS over HTTPS (RFC 8484)).
#
# Wraps the C-ABI functions from protocols/proven-doh/ffi/zig/src/doh.zig
# via ccall into libproven_doh.so.

module Doh

using ..ProvenServers: check_status, check_slot, SlotId

export ContentType, RequestMethod, WireFormat, ErrorReason, SessionState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_doh"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""DoH content types.  Matches `ContentType` in `DohABI.Types`."""
@enum ContentType::UInt8 begin
    DNS_MESSAGE = 0
    DNS_JSON = 1
end


"""DoH HTTP request methods.  Matches `RequestMethod` in `DohABI.Types`."""
@enum RequestMethod::UInt8 begin
    GET = 0
    POST = 1
end


"""DNS wire format.  Matches `WireFormat` in `DohABI.Types`."""
@enum WireFormat::UInt8 begin
    BINARY = 0
    JSON = 1
end


"""DoH-specific error reasons.  Matches `ErrorReason` in `DohABI.Types`."""
@enum ErrorReason::UInt8 begin
    BAD_CONTENT_TYPE = 0
    BAD_METHOD = 1
    PAYLOAD_TOO_LARGE = 2
    UPSTREAM_TIMEOUT = 3
    UPSTREAM_ERROR = 4
end


"""DoH session lifecycle states.  Matches `SessionState` in `DohABI.Types`."""
@enum SessionState::UInt8 begin
    IDLE = 0
    BOUND = 1
    SERVING = 2
    RESOLVING = 3
    SHUTDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_doh."""
function abi_version()::UInt32
    ccall((:doh_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new DNS over HTTPS (RFC 8484) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:doh_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given DNS over HTTPS (RFC 8484) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:doh_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SessionState

Get the current DNS over HTTPS (RFC 8484) lifecycle state.
"""
function get_state(slot::SlotId)::SessionState
    SessionState(ccall((:doh_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SessionState, to::SessionState) -> Bool

Check whether a DNS over HTTPS (RFC 8484) state transition is valid.
"""
function can_transition(from::SessionState, to::SessionState)::Bool
    ccall((:doh_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Doh
