# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-authserver protocol (authentication server).
#
# Wraps the C-ABI functions from protocols/proven-authserver/ffi/zig/src/authserver.zig
# via ccall into libproven_authserver.so.

module Authserver

using ..ProvenServers: check_status, check_slot, SlotId

export AuthMethod, TokenType, AuthResult, MfaMethod, SessionState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_authserver"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Authentication methods.  Matches `AuthMethod` in `AuthserverABI.Types`."""
@enum AuthMethod::UInt8 begin
    PASSWORD = 0
    CERTIFICATE = 1
    O_AUTH2 = 2
    SAML = 3
    FIDO2 = 4
    KERBEROS = 5
    LDAP = 6
    RADIUS = 7
end


"""Authentication token types.  Matches `TokenType` in `AuthserverABI.Types`."""
@enum TokenType::UInt8 begin
    ACCESS = 0
    REFRESH = 1
    ID = 2
    API = 3
end


"""Authentication attempt result codes.  Matches `AuthResult` in `AuthserverABI.Types`."""
@enum AuthResult::UInt8 begin
    SUCCESS = 0
    INVALID_CREDENTIALS = 1
    ACCOUNT_LOCKED = 2
    ACCOUNT_EXPIRED = 3
    MFA_REQUIRED = 4
    IP_BLOCKED = 5
end


"""Multi-factor authentication methods.  Matches `MfaMethod` in `AuthserverABI.Types`."""
@enum MfaMethod::UInt8 begin
    TOTP = 0
    SMS = 1
    PUSH = 2
    FIDO2_MFA = 3
    EMAIL = 4
end


"""Auth session lifecycle states.  Matches `SessionState` in `AuthserverABI.Types`."""
@enum SessionState::UInt8 begin
    ACTIVE = 0
    EXPIRED = 1
    REVOKED = 2
    LOCKED = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_authserver."""
function abi_version()::UInt32
    ccall((:authserver_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new authentication server context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:authserver_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given authentication server context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:authserver_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SessionState

Get the current authentication server lifecycle state.
"""
function get_state(slot::SlotId)::SessionState
    SessionState(ccall((:authserver_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SessionState, to::SessionState) -> Bool

Check whether a authentication server state transition is valid.
"""
function can_transition(from::SessionState, to::SessionState)::Bool
    ccall((:authserver_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Authserver
