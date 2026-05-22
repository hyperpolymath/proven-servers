# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-tacacs protocol (TACACS+ (RFC 8907) server).
#
# Wraps the C-ABI functions from protocols/proven-tacacs/ffi/zig/src/tacacs.zig
# via ccall into libproven_tacacs.so.

module Tacacs

using ..ProvenServers: check_status, check_slot, SlotId

export TACACS_PORT,
       TacacsPacketType,
       AuthenType,
       AuthenAction,
       AuthenStatus,
       AuthorStatus,
       AcctStatus,
       AcctFlag,
       TacacsSessionState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_tacacs"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""TACACS_PORT: protocol constant."""
const TACACS_PORT = UInt16(49)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""TACACS+ packet types."""
@enum TacacsPacketType::UInt8 begin
    PKT_AUTHENTICATION = 0
    PKT_AUTHORIZATION = 1
    PKT_ACCOUNTING = 2
end

"""TACACS+ authentication types."""
@enum AuthenType::UInt8 begin
    AUTHEN_ASCII = 0
    AUTHEN_PAP = 1
    AUTHEN_CHAP = 2
    AUTHEN_MSCHAPV1 = 3
    AUTHEN_MSCHAPV2 = 4
end

"""TACACS+ authentication actions."""
@enum AuthenAction::UInt8 begin
    ACTION_LOGIN = 0
    ACTION_CHANGE_PASS = 1
    ACTION_SEND_AUTH = 2
end

"""TACACS+ authentication status."""
@enum AuthenStatus::UInt8 begin
    AUTHEN_PASS = 0
    AUTHEN_FAIL = 1
    AUTHEN_GET_DATA = 2
    AUTHEN_GET_USER = 3
    AUTHEN_GET_PASS = 4
    AUTHEN_RESTART = 5
    AUTHEN_ERROR = 6
    AUTHEN_FOLLOW = 7
end

"""TACACS+ authorization status."""
@enum AuthorStatus::UInt8 begin
    AUTHOR_PASS_ADD = 0
    AUTHOR_PASS_REPL = 1
    AUTHOR_FAIL = 2
    AUTHOR_ERROR = 3
    AUTHOR_FOLLOW = 4
end

"""TACACS+ accounting status."""
@enum AcctStatus::UInt8 begin
    ACCT_SUCCESS = 0
    ACCT_ERROR = 1
    ACCT_FOLLOW = 2
end

"""TACACS+ accounting flags."""
@enum AcctFlag::UInt8 begin
    FLAG_START = 0
    FLAG_STOP = 1
    FLAG_WATCHDOG = 2
end

"""TACACS+ session states."""
@enum TacacsSessionState::UInt8 begin
    STATE_IDLE = 0
    STATE_AUTHENTICATING = 1
    STATE_AUTHORIZING = 2
    STATE_ACTIVE = 3
    STATE_CLOSING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_tacacs."""
function abi_version()::UInt32
    ccall((:tacacs_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Tacacs context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:tacacs_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Tacacs context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:tacacs_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> TacacsSessionState

Get the current Tacacs lifecycle state.
"""
function get_state(slot::SlotId)::TacacsSessionState
    TacacsSessionState(ccall((:tacacs_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::TacacsSessionState, to::TacacsSessionState) -> Bool

Check whether a Tacacs state transition is valid.
"""
function can_transition(from::TacacsSessionState, to::TacacsSessionState)::Bool
    ccall((:tacacs_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Tacacs
