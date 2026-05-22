# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-appserver protocol (application server).
#
# Wraps the C-ABI functions from protocols/proven-appserver/ffi/zig/src/appserver.zig
# via ccall into libproven_appserver.so.

module Appserver

using ..ProvenServers: check_status, check_slot, SlotId

export RequestType, LifecycleState, HealthCheck, DeployStrategy, ErrorCategory,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_appserver"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Request protocol types.  Matches `RequestType` in `AppserverABI.Types`."""
@enum RequestType::UInt8 begin
    HTTP = 0
    WEB_SOCKET = 1
    GRPC = 2
    GRAPH_QL = 3
end


"""Application lifecycle states.  Matches `LifecycleState` in `AppserverABI.Types`."""
@enum LifecycleState::UInt8 begin
    INITIALIZING = 0
    STARTING = 1
    RUNNING = 2
    DRAINING = 3
    STOPPING = 4
    STOPPED = 5
end


"""Health check types.  Matches `HealthCheck` in `AppserverABI.Types`."""
@enum HealthCheck::UInt8 begin
    LIVENESS = 0
    READINESS = 1
    STARTUP = 2
end


"""Deployment strategies.  Matches `DeployStrategy` in `AppserverABI.Types`."""
@enum DeployStrategy::UInt8 begin
    ROLLING_UPDATE = 0
    BLUE_GREEN = 1
    CANARY = 2
    RECREATE = 3
end


"""Application error categories.  Matches `ErrorCategory` in `AppserverABI.Types`."""
@enum ErrorCategory::UInt8 begin
    CLIENT_ERROR = 0
    SERVER_ERROR = 1
    TIMEOUT = 2
    CIRCUIT_OPEN = 3
    RATE_LIMITED = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_appserver."""
function abi_version()::UInt32
    ccall((:appserver_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new application server context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:appserver_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given application server context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:appserver_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> LifecycleState

Get the current application server lifecycle state.
"""
function get_state(slot::SlotId)::LifecycleState
    LifecycleState(ccall((:appserver_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::LifecycleState, to::LifecycleState) -> Bool

Check whether a application server state transition is valid.
"""
function can_transition(from::LifecycleState, to::LifecycleState)::Bool
    ccall((:appserver_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Appserver
