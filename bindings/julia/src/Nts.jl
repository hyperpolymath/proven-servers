# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-nts protocol (Network Time Security (RFC 8915) server).
#
# Wraps the C-ABI functions from protocols/proven-nts/ffi/zig/src/nts.zig
# via ccall into libproven_nts.so.

module Nts

using ..ProvenServers: check_status, check_slot, SlotId

export NTS_KE_PORT,
       NtsRecordType,
       NtsErrorCode,
       AeadAlgorithm,
       HandshakeState,
       NtsSessionState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_nts"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""NTS_KE_PORT: protocol constant."""
const NTS_KE_PORT = UInt16(4460)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""NTS-KE record types."""
@enum NtsRecordType::UInt8 begin
    REC_END_OF_MESSAGE = 0
    REC_NEXT_PROTOCOL = 1
    REC_ERROR = 2
    REC_WARNING = 3
    REC_AEAD_ALGORITHM = 4
    REC_COOKIE = 5
    REC_COOKIE_PLACEHOLDER = 6
    REC_NTSKE_SERVER = 7
    REC_NTSKE_PORT = 8
end

"""NTS error codes."""
@enum NtsErrorCode::UInt8 begin
    ERR_UNRECOGNIZED_CRITICAL = 0
    ERR_BAD_REQUEST = 1
    ERR_INTERNAL_ERROR = 2
end

"""AEAD algorithms for NTS."""
@enum AeadAlgorithm::UInt8 begin
    AEAD_AES_128_GCM = 0
    AEAD_AES_256_GCM = 1
    AEAD_AES_SIV_CMAC_256 = 2
end

"""NTS handshake states."""
@enum HandshakeState::UInt8 begin
    HS_INITIAL = 0
    HS_NEGOTIATING = 1
    HS_ESTABLISHED = 2
    HS_FAILED = 3
end

"""NTS session lifecycle states."""
@enum NtsSessionState::UInt8 begin
    STATE_IDLE = 0
    STATE_HANDSHAKING = 1
    STATE_NEGOTIATING = 2
    STATE_ESTABLISHED = 3
    STATE_CLOSING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_nts."""
function abi_version()::UInt32
    ccall((:nts_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Nts context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:nts_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Nts context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:nts_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> NtsSessionState

Get the current Nts lifecycle state.
"""
function get_state(slot::SlotId)::NtsSessionState
    NtsSessionState(ccall((:nts_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::NtsSessionState, to::NtsSessionState) -> Bool

Check whether a Nts state transition is valid.
"""
function can_transition(from::NtsSessionState, to::NtsSessionState)::Bool
    ccall((:nts_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Nts
