# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-siem protocol (SIEM (Security Information and Event Management)).
#
# Wraps the C-ABI functions from protocols/proven-siem/ffi/zig/src/siem.zig
# via ccall into libproven_siem.so.

module Siem

using ..ProvenServers: check_status, check_slot, SlotId

export EventSeverity,
       EventCategory,
       CorrelationRule,
       SiemAlertState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_siem"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""SIEM event severity levels."""
@enum EventSeverity::UInt8 begin
    SEV_INFO = 0
    SEV_LOW = 1
    SEV_MEDIUM = 2
    SEV_HIGH = 3
    SEV_CRITICAL = 4
end

"""SIEM event categories."""
@enum EventCategory::UInt8 begin
    CAT_AUTHENTICATION = 0
    CAT_NETWORK_TRAFFIC = 1
    CAT_FILE_ACTIVITY = 2
    CAT_PROCESS_EXECUTION = 3
    CAT_POLICY_VIOLATION = 4
    CAT_MALWARE = 5
    CAT_DATA_EXFILTRATION = 6
end

"""SIEM correlation rule types."""
@enum CorrelationRule::UInt8 begin
    RULE_THRESHOLD = 0
    RULE_SEQUENCE = 1
    RULE_AGGREGATION = 2
    RULE_ABSENCE = 3
    RULE_STATISTICAL = 4
end

"""SIEM alert states."""
@enum SiemAlertState::UInt8 begin
    ALERT_NEW = 0
    ALERT_ACKNOWLEDGED = 1
    ALERT_IN_PROGRESS = 2
    ALERT_RESOLVED = 3
    ALERT_FALSE_POSITIVE = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_siem."""
function abi_version()::UInt32
    ccall((:siem_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Siem context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:siem_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Siem context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:siem_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SiemAlertState

Get the current Siem lifecycle state.
"""
function get_state(slot::SlotId)::SiemAlertState
    SiemAlertState(ccall((:siem_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SiemAlertState, to::SiemAlertState) -> Bool

Check whether a Siem state transition is valid.
"""
function can_transition(from::SiemAlertState, to::SiemAlertState)::Bool
    ccall((:siem_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Siem
