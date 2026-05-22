# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-configmgmt protocol (configuration management).
#
# Wraps the C-ABI functions from protocols/proven-configmgmt/ffi/zig/src/configmgmt.zig
# via ccall into libproven_configmgmt.so.

module Configmgmt

using ..ProvenServers: check_status, check_slot, SlotId

export ResourceType, ResourceState, ChangeAction, DriftStatus, ApplyMode,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_configmgmt"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Managed resource types.  Matches `ResourceType` in `ConfigmgmtABI.Types`."""
@enum ResourceType::UInt8 begin
    FILE = 0
    PACKAGE = 1
    SERVICE = 2
    USER = 3
    GROUP = 4
    CRON = 5
    MOUNT = 6
    FIREWALL = 7
    REGISTRY = 8
end


"""Desired resource states.  Matches `ResourceState` in `ConfigmgmtABI.Types`."""
@enum ResourceState::UInt8 begin
    PRESENT = 0
    ABSENT = 1
    RUNNING = 2
    STOPPED = 3
    ENABLED = 4
    DISABLED = 5
end


"""Configuration change actions.  Matches `ChangeAction` in `ConfigmgmtABI.Types`."""
@enum ChangeAction::UInt8 begin
    CREATE = 0
    MODIFY = 1
    DELETE = 2
    RESTART = 3
    RELOAD = 4
    SKIP = 5
end


"""Configuration drift status.  Matches `DriftStatus` in `ConfigmgmtABI.Types`."""
@enum DriftStatus::UInt8 begin
    IN_SYNC = 0
    DRIFTED = 1
    D_UNKNOWN = 2
    UNMANAGED = 3
end


"""Configuration apply modes.  Matches `ApplyMode` in `ConfigmgmtABI.Types`."""
@enum ApplyMode::UInt8 begin
    ENFORCE = 0
    DRY_RUN = 1
    AUDIT = 2
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_configmgmt."""
function abi_version()::UInt32
    ccall((:configmgmt_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new configuration management context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:configmgmt_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given configuration management context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:configmgmt_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> DriftStatus

Get the current configuration management lifecycle state.
"""
function get_state(slot::SlotId)::DriftStatus
    DriftStatus(ccall((:configmgmt_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::DriftStatus, to::DriftStatus) -> Bool

Check whether a configuration management state transition is valid.
"""
function can_transition(from::DriftStatus, to::DriftStatus)::Bool
    ccall((:configmgmt_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Configmgmt
