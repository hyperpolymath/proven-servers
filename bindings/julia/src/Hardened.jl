# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-hardened protocol (hardened server).
#
# Wraps the C-ABI functions from protocols/proven-hardened/ffi/zig/src/hardened.zig
# via ccall into libproven_hardened.so.

module Hardened

using ..ProvenServers: check_status, check_slot, SlotId

export HardeningLevel, SecurityControl, ComplianceStandard, AuditEvent, HardenedHealthStatus, ServerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_hardened"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""System hardening levels.  Matches `HardeningLevel` in `HardenedABI.Types`."""
@enum HardeningLevel::UInt8 begin
    MINIMAL = 0
    STANDARD = 1
    HIGH = 2
    MAXIMUM = 3
end


"""Security controls.  Matches `SecurityControl` in `HardenedABI.Types`."""
@enum SecurityControl::UInt8 begin
    ASLR = 0
    DEP = 1
    STACK_CANARY = 2
    CFI = 3
    SANDBOXING = 4
    SECURE_BOOT = 5
    AUDIT_LOG = 6
end


"""Security compliance standards.  Matches `ComplianceStandard` in `HardenedABI.Types`."""
@enum ComplianceStandard::UInt8 begin
    CIS = 0
    STIG = 1
    NIST80053 = 2
    PCI_DSS = 3
    FIPS140 = 4
end


"""Audit event types.  Matches `AuditEvent` in `HardenedABI.Types`."""
@enum AuditEvent::UInt8 begin
    PROCESS_START = 0
    FILE_ACCESS = 1
    NETWORK_CONN = 2
    PRIVILEGE_ESCALATION = 3
    CONFIG_CHANGE = 4
    AUTH_ATTEMPT = 5
end


"""Hardened system health.  Matches `HardenedHealthStatus` in `HardenedABI.Types`."""
@enum HardenedHealthStatus::UInt8 begin
    HEALTHY = 0
    DEGRADED = 1
    COMPROMISED = 2
    UNRESPONSIVE = 3
end


"""Hardened server states.  Matches `ServerState` in `HardenedABI.Types`."""
@enum ServerState::UInt8 begin
    IDLE = 0
    HARDENING = 1
    ACTIVE = 2
    AUDITING = 3
    SHUTDOWN = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_hardened."""
function abi_version()::UInt32
    ccall((:hardened_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new hardened server context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:hardened_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given hardened server context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:hardened_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ServerState

Get the current hardened server lifecycle state.
"""
function get_state(slot::SlotId)::ServerState
    ServerState(ccall((:hardened_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ServerState, to::ServerState) -> Bool

Check whether a hardened server state transition is valid.
"""
function can_transition(from::ServerState, to::ServerState)::Bool
    ccall((:hardened_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Hardened
