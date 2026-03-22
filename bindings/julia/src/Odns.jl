# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-odns protocol (Oblivious DNS (ODNS) server).
#
# Wraps the C-ABI functions from protocols/proven-odns/ffi/zig/src/odns.zig
# via ccall into libproven_odns.so.

module Odns

using ..ProvenServers: check_status, check_slot, SlotId

export OdnsRole,
       OdnsMessageType,
       OdnsErrorReason,
       EncapsulationFormat,
       OdnsSessionState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_odns"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""ODNS participant roles."""
@enum OdnsRole::UInt8 begin
    ROLE_CLIENT = 0
    ROLE_PROXY = 1
    ROLE_TARGET = 2
end

"""ODNS message types."""
@enum OdnsMessageType::UInt8 begin
    MSG_QUERY = 0
    MSG_RESPONSE = 1
end

"""ODNS error reasons."""
@enum OdnsErrorReason::UInt8 begin
    ERR_PROXY = 0
    ERR_TARGET = 1
    ERR_DECRYPTION_FAILED = 2
    ERR_INVALID_CONFIG = 3
    ERR_PAYLOAD_TOO_LARGE = 4
end

"""ODNS encapsulation formats."""
@enum EncapsulationFormat::UInt8 begin
    FMT_HPKE = 0
end

"""ODNS session states."""
@enum OdnsSessionState::UInt8 begin
    STATE_IDLE = 0
    STATE_KEY_EXCHANGE = 1
    STATE_READY = 2
    STATE_PROCESSING = 3
    STATE_CLOSING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_odns."""
function abi_version()::UInt32
    ccall((:odns_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Odns context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:odns_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Odns context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:odns_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> OdnsSessionState

Get the current Odns lifecycle state.
"""
function get_state(slot::SlotId)::OdnsSessionState
    OdnsSessionState(ccall((:odns_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::OdnsSessionState, to::OdnsSessionState) -> Bool

Check whether a Odns state transition is valid.
"""
function can_transition(from::OdnsSessionState, to::OdnsSessionState)::Bool
    ccall((:odns_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Odns
