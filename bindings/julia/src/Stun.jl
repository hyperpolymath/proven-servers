# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-stun protocol (STUN (RFC 5389) / TURN server).
#
# Wraps the C-ABI functions from protocols/proven-stun/ffi/zig/src/stun.zig
# via ccall into libproven_stun.so.

module Stun

using ..ProvenServers: check_status, check_slot, SlotId

export STUN_PORT,
       STUN_TLS_PORT,
       StunMessageType,
       StunTransportProtocol,
       StunErrorCode,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_stun"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""STUN_PORT: protocol constant."""
const STUN_PORT = UInt16(3478)

"""STUN_TLS_PORT: protocol constant."""
const STUN_TLS_PORT = UInt16(5349)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""STUN/TURN message types."""
@enum StunMessageType::UInt8 begin
    MSG_BINDING_REQUEST = 0
    MSG_BINDING_RESPONSE = 1
    MSG_BINDING_ERROR = 2
    MSG_ALLOCATE_REQUEST = 3
    MSG_ALLOCATE_RESPONSE = 4
    MSG_ALLOCATE_ERROR = 5
    MSG_REFRESH_REQUEST = 6
    MSG_REFRESH_RESPONSE = 7
    MSG_SEND_INDICATION = 8
    MSG_DATA_INDICATION = 9
    MSG_CREATE_PERMISSION = 10
    MSG_CHANNEL_BIND = 11
end

"""STUN transport protocols."""
@enum StunTransportProtocol::UInt8 begin
    TRANSPORT_UDP = 0
    TRANSPORT_TCP = 1
    TRANSPORT_TLS = 2
    TRANSPORT_DTLS = 3
end

"""STUN error codes."""
@enum StunErrorCode::UInt8 begin
    ERR_TRY_ALTERNATE = 0
    ERR_BAD_REQUEST = 1
    ERR_UNAUTHORIZED = 2
    ERR_FORBIDDEN = 3
    ERR_MOBILITY_FORBIDDEN = 4
    ERR_STALE_NONCE = 5
    ERR_SERVER_ERROR = 6
    ERR_INSUFFICIENT_CAPACITY = 7
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_stun."""
function abi_version()::UInt32
    ccall((:stun_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Stun context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:stun_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Stun context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:stun_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> StunErrorCode

Get the current Stun lifecycle state.
"""
function get_state(slot::SlotId)::StunErrorCode
    StunErrorCode(ccall((:stun_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::StunErrorCode, to::StunErrorCode) -> Bool

Check whether a Stun state transition is valid.
"""
function can_transition(from::StunErrorCode, to::StunErrorCode)::Bool
    ccall((:stun_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Stun
