# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-deception protocol (cyber deception platform).
#
# Wraps the C-ABI functions from protocols/proven-deception/ffi/zig/src/deception.zig
# via ccall into libproven_deception.so.

module Deception

using ..ProvenServers: check_status, check_slot, SlotId

export DecoyType, TriggerEvent, AlertPriority, DecoyState, ResponseAction, ServerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_deception"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Deception decoy types.  Matches `DecoyType` in `DeceptionABI.Types`."""
@enum DecoyType::UInt8 begin
    SERVICE = 0
    CREDENTIAL = 1
    FILE = 2
    NETWORK = 3
    TOKEN = 4
    BREADCRUMB = 5
end


"""Decoy trigger events.  Matches `TriggerEvent` in `DeceptionABI.Types`."""
@enum TriggerEvent::UInt8 begin
    ACCESS = 0
    LOGIN = 1
    READ = 2
    WRITE = 3
    EXECUTE = 4
    SCAN = 5
end


"""Deception alert priority.  Matches `AlertPriority` in `DeceptionABI.Types`."""
@enum AlertPriority::UInt8 begin
    LOW = 0
    MEDIUM = 1
    HIGH = 2
    CRITICAL = 3
end


"""Decoy lifecycle states.  Matches `DecoyState` in `DeceptionABI.Types`."""
@enum DecoyState::UInt8 begin
    ACTIVE = 0
    TRIGGERED = 1
    DISABLED = 2
    EXPIRED = 3
end


"""Deception response actions.  Matches `ResponseAction` in `DeceptionABI.Types`."""
@enum ResponseAction::UInt8 begin
    ALERT = 0
    REDIRECT = 1
    DELAY = 2
    FINGERPRINT = 3
    ISOLATE = 4
end


"""Deception server states.  Matches `ServerState` in `DeceptionABI.Types`."""
@enum ServerState::UInt8 begin
    IDLE = 0
    CONFIGURED = 1
    MONITORING = 2
    RESPONDING = 3
    SHUTDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_deception."""
function abi_version()::UInt32
    ccall((:deception_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new cyber deception platform context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:deception_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given cyber deception platform context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:deception_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ServerState

Get the current cyber deception platform lifecycle state.
"""
function get_state(slot::SlotId)::ServerState
    ServerState(ccall((:deception_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ServerState, to::ServerState) -> Bool

Check whether a cyber deception platform state transition is valid.
"""
function can_transition(from::ServerState, to::ServerState)::Bool
    ccall((:deception_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Deception
