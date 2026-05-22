# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-pop3 protocol (POP3 (RFC 1939) server).
#
# Wraps the C-ABI functions from protocols/proven-pop3/ffi/zig/src/pop3.zig
# via ccall into libproven_pop3.so.

module Pop3

using ..ProvenServers: check_status, check_slot, SlotId

export POP3_PORT,
       POP3S_PORT,
       Pop3Command,
       Pop3State,
       Pop3Response,
       Pop3Error,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_pop3"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""POP3_PORT: protocol constant."""
const POP3_PORT = UInt16(110)

"""POP3S_PORT: protocol constant."""
const POP3S_PORT = UInt16(995)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""POP3 protocol commands."""
@enum Pop3Command::UInt8 begin
    CMD_USER = 0
    CMD_PASS = 1
    CMD_STAT = 2
    CMD_LIST = 3
    CMD_RETR = 4
    CMD_DELE = 5
    CMD_NOOP = 6
    CMD_RSET = 7
    CMD_QUIT = 8
    CMD_TOP = 9
    CMD_UIDL = 10
end

"""POP3 session state machine."""
@enum Pop3State::UInt8 begin
    STATE_AUTHORIZATION = 0
    STATE_TRANSACTION = 1
    STATE_UPDATE = 2
end

"""POP3 response indicators."""
@enum Pop3Response::UInt8 begin
    RESP_OK = 0
    RESP_ERR = 1
end

"""POP3 FFI error codes."""
@enum Pop3Error::UInt8 begin
    ERR_OK = 0
    ERR_INVALID_SLOT = 1
    ERR_NOT_ACTIVE = 2
    ERR_INVALID_TRANSITION = 3
    ERR_INVALID_COMMAND = 4
    ERR_AUTH_FAILED = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_pop3."""
function abi_version()::UInt32
    ccall((:pop3_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Pop3 context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:pop3_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Pop3 context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:pop3_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> Pop3State

Get the current Pop3 lifecycle state.
"""
function get_state(slot::SlotId)::Pop3State
    Pop3State(ccall((:pop3_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::Pop3State, to::Pop3State) -> Bool

Check whether a Pop3 state transition is valid.
"""
function can_transition(from::Pop3State, to::Pop3State)::Bool
    ccall((:pop3_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Pop3
