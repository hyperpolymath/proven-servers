# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ocsp protocol (OCSP (RFC 6960) responder).
#
# Wraps the C-ABI functions from protocols/proven-ocsp/ffi/zig/src/ocsp.zig
# via ccall into libproven_ocsp.so.

module Ocsp

using ..ProvenServers: check_status, check_slot, SlotId

export OCSP_PORT,
       CertStatus,
       ResponseStatus,
       OcspHashAlgorithm,
       OcspResponderState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_ocsp"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""OCSP_PORT: protocol constant."""
const OCSP_PORT = UInt16(80)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Certificate status in OCSP response."""
@enum CertStatus::UInt8 begin
    CERT_GOOD = 0
    CERT_REVOKED = 1
    CERT_UNKNOWN = 2
end

"""OCSP response status."""
@enum ResponseStatus::UInt8 begin
    RESP_SUCCESSFUL = 0
    RESP_MALFORMED_REQUEST = 1
    RESP_INTERNAL_ERROR = 2
    RESP_TRY_LATER = 3
    RESP_SIG_REQUIRED = 4
    RESP_UNAUTHORIZED = 5
end

"""OCSP hash algorithms."""
@enum OcspHashAlgorithm::UInt8 begin
    HASH_SHA1 = 0
    HASH_SHA256 = 1
    HASH_SHA384 = 2
    HASH_SHA512 = 3
end

"""OCSP responder states."""
@enum OcspResponderState::UInt8 begin
    STATE_IDLE = 0
    STATE_READY = 1
    STATE_PROCESSING = 2
    STATE_SIGNING = 3
    STATE_CLOSING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ocsp."""
function abi_version()::UInt32
    ccall((:ocsp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Ocsp context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ocsp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Ocsp context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ocsp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> OcspResponderState

Get the current Ocsp lifecycle state.
"""
function get_state(slot::SlotId)::OcspResponderState
    OcspResponderState(ccall((:ocsp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::OcspResponderState, to::OcspResponderState) -> Bool

Check whether a Ocsp state transition is valid.
"""
function can_transition(from::OcspResponderState, to::OcspResponderState)::Bool
    ccall((:ocsp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Ocsp
