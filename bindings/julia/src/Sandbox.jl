# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-sandbox protocol (Sandbox execution environment).
#
# Wraps the C-ABI functions from protocols/proven-sandbox/ffi/zig/src/sandbox.zig
# via ccall into libproven_sandbox.so.

module Sandbox

using ..ProvenServers: check_status, check_slot, SlotId

export ExecutionPolicy,
       ResourceLimit,
       SandboxState,
       ExitReason,
       SyscallPolicy,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_sandbox"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Sandbox execution policies."""
@enum ExecutionPolicy::UInt8 begin
    POLICY_UNRESTRICTED = 0
    POLICY_READ_ONLY = 1
    POLICY_NETWORK_DENIED = 2
    POLICY_ISOLATED = 3
    POLICY_EPHEMERAL = 4
end

"""Sandbox resource limits."""
@enum ResourceLimit::UInt8 begin
    LIMIT_CPU_TIME = 0
    LIMIT_MEMORY = 1
    LIMIT_DISK_IO = 2
    LIMIT_NETWORK_IO = 3
    LIMIT_FILE_DESCRIPTORS = 4
    LIMIT_PROCESSES = 5
end

"""Sandbox lifecycle states."""
@enum SandboxState::UInt8 begin
    STATE_CREATING = 0
    STATE_READY = 1
    STATE_RUNNING = 2
    STATE_SUSPENDED = 3
    STATE_TERMINATED = 4
    STATE_DESTROYED = 5
end

"""Sandbox exit reasons."""
@enum ExitReason::UInt8 begin
    EXIT_NORMAL = 0
    EXIT_TIMEOUT = 1
    EXIT_MEMORY_EXCEEDED = 2
    EXIT_POLICY_VIOLATION = 3
    EXIT_KILLED = 4
    EXIT_ERROR = 5
end

"""Sandbox syscall policies."""
@enum SyscallPolicy::UInt8 begin
    SYSCALL_ALLOW = 0
    SYSCALL_DENY = 1
    SYSCALL_LOG = 2
    SYSCALL_TRAP = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_sandbox."""
function abi_version()::UInt32
    ccall((:sandbox_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Sandbox context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:sandbox_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Sandbox context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:sandbox_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SandboxState

Get the current Sandbox lifecycle state.
"""
function get_state(slot::SlotId)::SandboxState
    SandboxState(ccall((:sandbox_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SandboxState, to::SandboxState) -> Bool

Check whether a Sandbox state transition is valid.
"""
function can_transition(from::SandboxState, to::SandboxState)::Bool
    ccall((:sandbox_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Sandbox
