# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ldap protocol (LDAP (RFC 4511)).
#
# Wraps the C-ABI functions from protocols/proven-ldap/ffi/zig/src/ldap.zig
# via ccall into libproven_ldap.so.

module Ldap

using ..ProvenServers: check_status, check_slot, SlotId

export SessionState, Operation, SearchScope, ResultCode,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_ldap"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""LDAP session state machine.  Matches `SessionState` in `LdapABI.Types`."""
@enum SessionState::UInt8 begin
    ANONYMOUS = 0
    BOUND = 1
    CLOSED = 2
    BINDING = 3
end


"""LDAP protocol operations (RFC 4511).  Matches `Operation` in `LdapABI.Types`."""
@enum Operation::UInt8 begin
    BIND = 0
    UNBIND = 1
    SEARCH = 2
    MODIFY = 3
    ADD = 4
    DELETE = 5
    MOD_DN = 6
    COMPARE = 7
    ABANDON = 8
    EXTENDED = 9
end


"""LDAP search scope levels (RFC 4511 Section 4.5.1.2).  Matches `SearchScope` in `LdapABI.Types`."""
@enum SearchScope::UInt8 begin
    BASE_OBJECT = 0
    SINGLE_LEVEL = 1
    WHOLE_SUBTREE = 2
end


"""LDAP result codes (RFC 4511 Appendix A).  Matches `ResultCode` in `LdapABI.Types`."""
@enum ResultCode::UInt8 begin
    SUCCESS = 0
    OPERATIONS_ERROR = 1
    PROTOCOL_ERROR = 2
    TIME_LIMIT_EXCEEDED = 3
    SIZE_LIMIT_EXCEEDED = 4
    AUTH_METHOD_NOT_SUPPORTED = 5
    NO_SUCH_OBJECT = 6
    INVALID_CREDENTIALS = 7
    INSUFFICIENT_ACCESS_RIGHTS = 8
    BUSY = 9
    UNAVAILABLE = 10
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ldap."""
function abi_version()::UInt32
    ccall((:ldap_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new LDAP (RFC 4511) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ldap_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given LDAP (RFC 4511) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ldap_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SessionState

Get the current LDAP (RFC 4511) lifecycle state.
"""
function get_state(slot::SlotId)::SessionState
    SessionState(ccall((:ldap_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SessionState, to::SessionState) -> Bool

Check whether a LDAP (RFC 4511) state transition is valid.
"""
function can_transition(from::SessionState, to::SessionState)::Bool
    ccall((:ldap_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Ldap
