# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-radius protocol (RADIUS (RFC 2865) server).
#
# Wraps the C-ABI functions from protocols/proven-radius/ffi/zig/src/radius.zig
# via ccall into libproven_radius.so.

module Radius

using ..ProvenServers: check_status, check_slot, SlotId

export RADIUS_AUTH_PORT,
       RADIUS_ACCT_PORT,
       RadiusPacketType,
       RadiusAuthMethod,
       RadiusSessionState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_radius"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""RADIUS_AUTH_PORT: protocol constant."""
const RADIUS_AUTH_PORT = UInt16(1812)

"""RADIUS_ACCT_PORT: protocol constant."""
const RADIUS_ACCT_PORT = UInt16(1813)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""RADIUS packet types."""
@enum RadiusPacketType::UInt8 begin
    PKT_ACCESS_REQUEST = 1
    PKT_ACCESS_ACCEPT = 2
    PKT_ACCESS_REJECT = 3
    PKT_ACCOUNTING_REQUEST = 4
    PKT_ACCOUNTING_RESPONSE = 5
    PKT_ACCESS_CHALLENGE = 11
end

"""RADIUS authentication methods."""
@enum RadiusAuthMethod::UInt8 begin
    AUTH_PAP = 0
    AUTH_CHAP = 1
    AUTH_MSCHAP = 2
    AUTH_MSCHAPV2 = 3
    AUTH_EAP = 4
end

"""RADIUS session states."""
@enum RadiusSessionState::UInt8 begin
    STATE_IDLE = 0
    STATE_AUTHENTICATING = 1
    STATE_AUTHORIZED = 2
    STATE_REJECTED = 3
    STATE_CHALLENGED = 4
    STATE_ACCOUNTING = 5
    STATE_COMPLETE = 6
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_radius."""
function abi_version()::UInt32
    ccall((:radius_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Radius context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:radius_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Radius context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:radius_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> RadiusSessionState

Get the current Radius lifecycle state.
"""
function get_state(slot::SlotId)::RadiusSessionState
    RadiusSessionState(ccall((:radius_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::RadiusSessionState, to::RadiusSessionState) -> Bool

Check whether a Radius state transition is valid.
"""
function can_transition(from::RadiusSessionState, to::RadiusSessionState)::Bool
    ccall((:radius_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Radius
