# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-agentic protocol (agentic AI orchestration).
#
# Wraps the C-ABI functions from protocols/proven-agentic/ffi/zig/src/agentic.zig
# via ccall into libproven_agentic.so.

module Agentic

using ..ProvenServers: check_status, check_slot, SlotId

export AgentState, ToolCall, PlanStep, Coordination, SafetyCheck,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_agentic"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""AI agent lifecycle states.  Matches `AgentState` in `AgenticABI.Types`."""
@enum AgentState::UInt8 begin
    IDLE = 0
    PLANNING = 1
    ACTING = 2
    OBSERVING = 3
    REFLECTING = 4
    BLOCKED = 5
    TERMINATED = 6
end


"""Agent tool call types.  Matches `ToolCall` in `AgenticABI.Types`."""
@enum ToolCall::UInt8 begin
    EXECUTE = 0
    QUERY = 1
    TRANSFORM = 2
    COMMUNICATE = 3
    DELEGATE = 4
    ESCALATE = 5
end


"""Agent plan step types.  Matches `PlanStep` in `AgenticABI.Types`."""
@enum PlanStep::UInt8 begin
    ACTION = 0
    CONDITION = 1
    LOOP = 2
    BRANCH = 3
    PARALLEL = 4
    CHECKPOINT = 5
    ROLLBACK = 6
end


"""Multi-agent coordination modes.  Matches `Coordination` in `AgenticABI.Types`."""
@enum Coordination::UInt8 begin
    SOLO = 0
    COLLABORATIVE = 1
    COMPETITIVE = 2
    HIERARCHICAL = 3
    SWARM = 4
    CONSENSUS = 5
end


"""Agent safety check results.  Matches `SafetyCheck` in `AgenticABI.Types`."""
@enum SafetyCheck::UInt8 begin
    APPROVED = 0
    DENIED = 1
    ESCALATED = 2
    TIMEOUT = 3
    SANDBOXED = 4
    HUMAN_REQUIRED = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_agentic."""
function abi_version()::UInt32
    ccall((:agentic_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new agentic AI orchestration context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:agentic_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given agentic AI orchestration context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:agentic_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> AgentState

Get the current agentic AI orchestration lifecycle state.
"""
function get_state(slot::SlotId)::AgentState
    AgentState(ccall((:agentic_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::AgentState, to::AgentState) -> Bool

Check whether a agentic AI orchestration state transition is valid.
"""
function can_transition(from::AgentState, to::AgentState)::Bool
    ccall((:agentic_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Agentic
