# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-loadbalancer protocol (load balancer).
#
# Wraps the C-ABI functions from protocols/proven-loadbalancer/ffi/zig/src/loadbalancer.zig
# via ccall into libproven_loadbalancer.so.

module Loadbalancer

using ..ProvenServers: check_status, check_slot, SlotId

export Algorithm, HealthCheckType, BackendState, SessionPersistence, LbProtocol,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_loadbalancer"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Load balancing algorithms.  Matches `Algorithm` in `LoadbalancerABI.Types`."""
@enum Algorithm::UInt8 begin
    ROUND_ROBIN = 0
    LEAST_CONNECTIONS = 1
    IP_HASH = 2
    RANDOM = 3
    WEIGHTED_ROUND_ROBIN = 4
    LEAST_RESPONSE_TIME = 5
end


"""Backend health check types.  Matches `HealthCheckType` in `LoadbalancerABI.Types`."""
@enum HealthCheckType::UInt8 begin
    HTTP = 0
    TCP = 1
    GRPC = 2
    SCRIPT = 3
end


"""Backend server states.  Matches `BackendState` in `LoadbalancerABI.Types`."""
@enum BackendState::UInt8 begin
    HEALTHY = 0
    UNHEALTHY = 1
    DRAINING = 2
    DISABLED = 3
end


"""Session persistence strategies.  Matches `SessionPersistence` in `LoadbalancerABI.Types`."""
@enum SessionPersistence::UInt8 begin
    NONE = 0
    COOKIE = 1
    SOURCE_IP = 2
    HEADER = 3
end


"""Load balancer protocols.  Matches `LbProtocol` in `LoadbalancerABI.Types`."""
@enum LbProtocol::UInt8 begin
    HTTP = 0
    HTTPS = 1
    TCP = 2
    UDP = 3
    GRPC = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_loadbalancer."""
function abi_version()::UInt32
    ccall((:loadbalancer_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new load balancer context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:loadbalancer_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given load balancer context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:loadbalancer_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> BackendState

Get the current load balancer lifecycle state.
"""
function get_state(slot::SlotId)::BackendState
    BackendState(ccall((:loadbalancer_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::BackendState, to::BackendState) -> Bool

Check whether a load balancer state transition is valid.
"""
function can_transition(from::BackendState, to::BackendState)::Bool
    ccall((:loadbalancer_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Loadbalancer
