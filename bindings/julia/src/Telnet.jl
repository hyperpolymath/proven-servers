# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-telnet protocol (Telnet (RFC 854) server).
#
# Wraps the C-ABI functions from protocols/proven-telnet/ffi/zig/src/telnet.zig
# via ccall into libproven_telnet.so.

module Telnet

using ..ProvenServers: check_status, check_slot, SlotId

export TELNET_PORT,
       TelnetCommand,
       TelnetOption,
       NegotiationState,
       TelnetSessionState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_telnet"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""TELNET_PORT: protocol constant."""
const TELNET_PORT = UInt16(23)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Telnet commands."""
@enum TelnetCommand::UInt8 begin
    CMD_SE = 0
    CMD_NOP = 1
    CMD_DATA_MARK = 2
    CMD_BREAK = 3
    CMD_INTERRUPT_PROCESS = 4
    CMD_ABORT_OUTPUT = 5
    CMD_ARE_YOU_THERE = 6
    CMD_ERASE_CHAR = 7
    CMD_ERASE_LINE = 8
    CMD_GO_AHEAD = 9
    CMD_SB = 10
    CMD_WILL = 11
    CMD_WONT = 12
    CMD_DO = 13
    CMD_DONT = 14
    CMD_IAC = 15
end

"""Telnet options."""
@enum TelnetOption::UInt8 begin
    OPT_ECHO = 0
    OPT_SUPPRESS_GO_AHEAD = 1
    OPT_STATUS = 2
    OPT_TIMING_MARK = 3
    OPT_TERMINAL_TYPE = 4
    OPT_WINDOW_SIZE = 5
    OPT_TERMINAL_SPEED = 6
    OPT_REMOTE_FLOW_CONTROL = 7
    OPT_LINEMODE = 8
    OPT_ENVIRONMENT = 9
end

"""Telnet negotiation states."""
@enum NegotiationState::UInt8 begin
    NEG_INACTIVE = 0
    NEG_WILL_SENT = 1
    NEG_DO_SENT = 2
    NEG_ACTIVE = 3
end

"""Telnet session states."""
@enum TelnetSessionState::UInt8 begin
    STATE_IDLE = 0
    STATE_NEGOTIATING = 1
    STATE_ACTIVE = 2
    STATE_SUBNEG = 3
    STATE_CLOSING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_telnet."""
function abi_version()::UInt32
    ccall((:telnet_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Telnet context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:telnet_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Telnet context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:telnet_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> TelnetSessionState

Get the current Telnet lifecycle state.
"""
function get_state(slot::SlotId)::TelnetSessionState
    TelnetSessionState(ccall((:telnet_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::TelnetSessionState, to::TelnetSessionState) -> Bool

Check whether a Telnet state transition is valid.
"""
function can_transition(from::TelnetSessionState, to::TelnetSessionState)::Bool
    ccall((:telnet_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Telnet
