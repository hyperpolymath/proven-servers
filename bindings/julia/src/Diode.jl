# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-diode protocol (data diode (unidirectional network)).
#
# Wraps the C-ABI functions from protocols/proven-diode/ffi/zig/src/diode.zig
# via ccall into libproven_diode.so.

module Diode

using ..ProvenServers: check_status, check_slot, SlotId

export Direction, DiodeProtocol, TransferState, ValidationResult, IntegrityCheck, GatewayState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_diode"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Diode data flow direction.  Matches `Direction` in `DiodeABI.Types`."""
@enum Direction::UInt8 begin
    HIGH_TO_LOW = 0
    LOW_TO_HIGH = 1
end


"""Diode transfer protocols.  Matches `DiodeProtocol` in `DiodeABI.Types`."""
@enum DiodeProtocol::UInt8 begin
    UDP = 0
    TCP = 1
    FILE_TRANSFER = 2
    SYSLOG = 3
    SNMP = 4
end


"""Diode transfer states.  Matches `TransferState` in `DiodeABI.Types`."""
@enum TransferState::UInt8 begin
    QUEUED = 0
    SENDING = 1
    CONFIRMING = 2
    COMPLETE = 3
    FAILED = 4
end


"""Data validation results.  Matches `ValidationResult` in `DiodeABI.Types`."""
@enum ValidationResult::UInt8 begin
    PASSED = 0
    FORMAT_ERROR = 1
    SIZE_EXCEEDED = 2
    POLICY_BLOCKED = 3
end


"""Integrity verification methods.  Matches `IntegrityCheck` in `DiodeABI.Types`."""
@enum IntegrityCheck::UInt8 begin
    CRC32 = 0
    SHA256 = 1
    HMAC = 2
end


"""Diode gateway states.  Matches `GatewayState` in `DiodeABI.Types`."""
@enum GatewayState::UInt8 begin
    IDLE = 0
    CONFIGURED = 1
    TRANSFERRING = 2
    VALIDATING = 3
    SHUTDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_diode."""
function abi_version()::UInt32
    ccall((:diode_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new data diode (unidirectional network) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:diode_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given data diode (unidirectional network) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:diode_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> GatewayState

Get the current data diode (unidirectional network) lifecycle state.
"""
function get_state(slot::SlotId)::GatewayState
    GatewayState(ccall((:diode_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::GatewayState, to::GatewayState) -> Bool

Check whether a data diode (unidirectional network) state transition is valid.
"""
function can_transition(from::GatewayState, to::GatewayState)::Bool
    ccall((:diode_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Diode
