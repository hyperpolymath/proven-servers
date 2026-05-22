# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-bfd protocol (BFD (Bidirectional Forwarding Detection, RFC 5880)).
#
# Wraps the C-ABI functions from protocols/proven-bfd/ffi/zig/src/bfd.zig
# via ccall into libproven_bfd.so.

module Bfd

using ..ProvenServers: check_status, check_slot, SlotId

export BfdState, Diagnostic, SessionMode, SessionState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_bfd"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""BFD session states (RFC 5880 Section 4.1).  Matches `BfdState` in `BfdABI.Types`."""
@enum BfdState::UInt8 begin
    ADMIN_DOWN = 0
    DOWN = 1
    INIT = 2
    UP = 3
end


"""BFD diagnostic codes (RFC 5880 Section 4.1).  Matches `Diagnostic` in `BfdABI.Types`."""
@enum Diagnostic::UInt8 begin
    NO_DIAGNOSTIC = 0
    CONTROL_DETECTION_TIME_EXPIRED = 1
    ECHO_FUNCTION_FAILED = 2
    NEIGHBOR_SIGNALED_SESSION_DOWN = 3
    FORWARDING_PLANE_RESET = 4
    PATH_DOWN = 5
    CONCATENATED_PATH_DOWN = 6
    ADMINISTRATIVELY_DOWN = 7
    REVERSE_CONCATENATED_PATH_DOWN = 8
end


"""BFD session modes.  Matches `SessionMode` in `BfdABI.Types`."""
@enum SessionMode::UInt8 begin
    ASYNC_MODE = 0
    DEMAND_MODE = 1
end


"""BFD session lifecycle states.  Matches `SessionState` in `BfdABI.Types`."""
@enum SessionState::UInt8 begin
    IDLE = 0
    SS_DOWN = 1
    NEGOTIATING = 2
    ESTABLISHED = 3
    TEARDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_bfd."""
function abi_version()::UInt32
    ccall((:bfd_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new BFD (Bidirectional Forwarding Detection, RFC 5880) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:bfd_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given BFD (Bidirectional Forwarding Detection, RFC 5880) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:bfd_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SessionState

Get the current BFD (Bidirectional Forwarding Detection, RFC 5880) lifecycle state.
"""
function get_state(slot::SlotId)::SessionState
    SessionState(ccall((:bfd_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SessionState, to::SessionState) -> Bool

Check whether a BFD (Bidirectional Forwarding Detection, RFC 5880) state transition is valid.
"""
function can_transition(from::SessionState, to::SessionState)::Bool
    ccall((:bfd_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Bfd
