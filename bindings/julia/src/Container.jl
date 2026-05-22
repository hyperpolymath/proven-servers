# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-container protocol (container runtime).
#
# Wraps the C-ABI functions from protocols/proven-container/ffi/zig/src/container.zig
# via ccall into libproven_container.so.

module Container

using ..ProvenServers: check_status, check_slot, SlotId

export ContainerState, ContainerOperation, NetworkMode, VolumeType, RestartPolicy, HealthStatus,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_container"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Container lifecycle states.  Matches `ContainerState` in `ContainerABI.Types`."""
@enum ContainerState::UInt8 begin
    CREATING = 0
    RUNNING = 1
    PAUSED = 2
    RESTARTING = 3
    STOPPED = 4
    REMOVING = 5
    DEAD = 6
end


"""Container operations.  Matches `ContainerOperation` in `ContainerABI.Types`."""
@enum ContainerOperation::UInt8 begin
    CREATE = 0
    START = 1
    STOP = 2
    RESTART = 3
    PAUSE = 4
    UNPAUSE = 5
    KILL = 6
    REMOVE = 7
    EXEC = 8
    LOGS = 9
    INSPECT = 10
end


"""Container network modes.  Matches `NetworkMode` in `ContainerABI.Types`."""
@enum NetworkMode::UInt8 begin
    BRIDGE = 0
    HOST = 1
    NONE = 2
    OVERLAY = 3
    MACVLAN = 4
end


"""Container volume types.  Matches `VolumeType` in `ContainerABI.Types`."""
@enum VolumeType::UInt8 begin
    BIND = 0
    NAMED = 1
    TMPFS = 2
end


"""Container restart policies.  Matches `RestartPolicy` in `ContainerABI.Types`."""
@enum RestartPolicy::UInt8 begin
    NO = 0
    ALWAYS = 1
    ON_FAILURE = 2
    UNLESS_STOPPED = 3
end


"""Container health check status.  Matches `HealthStatus` in `ContainerABI.Types`."""
@enum HealthStatus::UInt8 begin
    STARTING = 0
    HEALTHY = 1
    UNHEALTHY = 2
    NO_CHECK = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_container."""
function abi_version()::UInt32
    ccall((:container_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new container runtime context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:container_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given container runtime context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:container_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ContainerState

Get the current container runtime lifecycle state.
"""
function get_state(slot::SlotId)::ContainerState
    ContainerState(ccall((:container_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ContainerState, to::ContainerState) -> Bool

Check whether a container runtime state transition is valid.
"""
function can_transition(from::ContainerState, to::ContainerState)::Bool
    ccall((:container_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Container
