# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-airgap protocol (air-gapped transfer).
#
# Wraps the C-ABI functions from protocols/proven-airgap/ffi/zig/src/airgap.zig
# via ccall into libproven_airgap.so.

module Airgap

using ..ProvenServers: check_status, check_slot, SlotId

export TransferDirection, MediaType, ScanResult, TransferState, ValidationCheck,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_airgap"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Air gap transfer direction.  Matches `TransferDirection` in `AirgapABI.Types`."""
@enum TransferDirection::UInt8 begin
    IMPORT = 0
    EXPORT = 1
end


"""Physical transfer media types.  Matches `MediaType` in `AirgapABI.Types`."""
@enum MediaType::UInt8 begin
    USB = 0
    OPTICAL_DISC = 1
    TAPE_CARTRIDGE = 2
    DIODE_LINK = 3
end


"""Content scan results.  Matches `ScanResult` in `AirgapABI.Types`."""
@enum ScanResult::UInt8 begin
    CLEAN = 0
    SUSPICIOUS = 1
    MALICIOUS = 2
    UNSCANNABLE = 3
end


"""Air gap transfer lifecycle.  Matches `TransferState` in `AirgapABI.Types`."""
@enum TransferState::UInt8 begin
    PENDING = 0
    SCANNING = 1
    APPROVED = 2
    REJECTED = 3
    IN_PROGRESS = 4
    COMPLETE = 5
    FAILED = 6
end


"""Validation check types.  Matches `ValidationCheck` in `AirgapABI.Types`."""
@enum ValidationCheck::UInt8 begin
    HASH_VERIFY = 0
    SIGNATURE_VERIFY = 1
    FORMAT_CHECK = 2
    CONTENT_INSPECTION = 3
    MALWARE_SCAN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_airgap."""
function abi_version()::UInt32
    ccall((:airgap_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new air-gapped transfer context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:airgap_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given air-gapped transfer context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:airgap_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> TransferState

Get the current air-gapped transfer lifecycle state.
"""
function get_state(slot::SlotId)::TransferState
    TransferState(ccall((:airgap_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::TransferState, to::TransferState) -> Bool

Check whether a air-gapped transfer state transition is valid.
"""
function can_transition(from::TransferState, to::TransferState)::Bool
    ccall((:airgap_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Airgap
