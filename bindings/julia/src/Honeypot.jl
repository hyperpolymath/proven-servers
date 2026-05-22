# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-honeypot protocol (honeypot).
#
# Wraps the C-ABI functions from protocols/proven-honeypot/ffi/zig/src/honeypot.zig
# via ccall into libproven_honeypot.so.

module Honeypot

using ..ProvenServers: check_status, check_slot, SlotId

export ServiceEmulation, InteractionLevel, HoneypotAlertSeverity, AttackerAction, ServerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_honeypot"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Emulated service types.  Matches `ServiceEmulation` in `HoneypotABI.Types`."""
@enum ServiceEmulation::UInt8 begin
    SSH = 0
    HTTP = 1
    FTP = 2
    SMTP = 3
    TELNET = 4
    MYSQL = 5
    RDP = 6
end


"""Honeypot interaction levels.  Matches `InteractionLevel` in `HoneypotABI.Types`."""
@enum InteractionLevel::UInt8 begin
    LOW = 0
    MEDIUM = 1
    HIGH = 2
end


"""Honeypot alert severity levels.  Matches `HoneypotAlertSeverity` in `HoneypotABI.Types`."""
@enum HoneypotAlertSeverity::UInt8 begin
    INFO = 0
    AS_LOW = 1
    AS_MEDIUM = 2
    AS_HIGH = 3
    CRITICAL = 4
end


"""Observed attacker actions.  Matches `AttackerAction` in `HoneypotABI.Types`."""
@enum AttackerAction::UInt8 begin
    SCAN = 0
    BRUTE_FORCE = 1
    EXPLOIT = 2
    PAYLOAD = 3
    LATERAL = 4
    EXFILTRATION = 5
end


"""Honeypot server states.  Matches `ServerState` in `HoneypotABI.Types`."""
@enum ServerState::UInt8 begin
    IDLE = 0
    DEPLOYED = 1
    ENGAGED = 2
    SHUTDOWN = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_honeypot."""
function abi_version()::UInt32
    ccall((:honeypot_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new honeypot context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:honeypot_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given honeypot context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:honeypot_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ServerState

Get the current honeypot lifecycle state.
"""
function get_state(slot::SlotId)::ServerState
    ServerState(ccall((:honeypot_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ServerState, to::ServerState) -> Bool

Check whether a honeypot state transition is valid.
"""
function can_transition(from::ServerState, to::ServerState)::Bool
    ccall((:honeypot_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Honeypot
