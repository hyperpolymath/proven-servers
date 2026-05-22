# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ids protocol (intrusion detection system).
#
# Wraps the C-ABI functions from protocols/proven-ids/ffi/zig/src/ids.zig
# via ccall into libproven_ids.so.

module Ids

using ..ProvenServers: check_status, check_slot, SlotId

export AlertSeverity, DetectionMethod, IdsProtocol, IdsAction, Direction, ThreatLevel,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_ids"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Alert severity levels.  Matches `AlertSeverity` in `IdsABI.Types`."""
@enum AlertSeverity::UInt8 begin
    LOW = 0
    MEDIUM = 1
    HIGH = 2
    CRITICAL = 3
end


"""Intrusion detection methods.  Matches `DetectionMethod` in `IdsABI.Types`."""
@enum DetectionMethod::UInt8 begin
    SIGNATURE = 0
    ANOMALY = 1
    STATEFUL = 2
    HEURISTIC = 3
end


"""Monitored network protocols.  Matches `IdsProtocol` in `IdsABI.Types`."""
@enum IdsProtocol::UInt8 begin
    TCP = 0
    UDP = 1
    ICMP = 2
    DNS = 3
    HTTP = 4
    TLS = 5
    SSH = 6
end


"""IDS response actions.  Matches `IdsAction` in `IdsABI.Types`."""
@enum IdsAction::UInt8 begin
    ALERT = 0
    DROP = 1
    LOG = 2
    BLOCK = 3
    PASS = 4
end


"""Traffic direction.  Matches `Direction` in `IdsABI.Types`."""
@enum Direction::UInt8 begin
    INBOUND = 0
    OUTBOUND = 1
    BOTH = 2
end


"""Threat assessment levels.  Matches `ThreatLevel` in `IdsABI.Types`."""
@enum ThreatLevel::UInt8 begin
    INFO = 0
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    CRITICAL = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ids."""
function abi_version()::UInt32
    ccall((:ids_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new intrusion detection system context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ids_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given intrusion detection system context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ids_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> AlertSeverity

Get the current intrusion detection system lifecycle state.
"""
function get_state(slot::SlotId)::AlertSeverity
    AlertSeverity(ccall((:ids_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::AlertSeverity, to::AlertSeverity) -> Bool

Check whether a intrusion detection system state transition is valid.
"""
function can_transition(from::AlertSeverity, to::AlertSeverity)::Bool
    ccall((:ids_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Ids
