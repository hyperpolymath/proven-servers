# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-kerberos protocol (Kerberos (RFC 4120)).
#
# Wraps the C-ABI functions from protocols/proven-kerberos/ffi/zig/src/kerberos.zig
# via ccall into libproven_kerberos.so.

module Kerberos

using ..ProvenServers: check_status, check_slot, SlotId

export MessageType, EncryptionType, PrincipalType, TicketFlag, ErrorCode, AuthState, EncStrength, PreAuthType, NegotiationState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_kerberos"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Kerberos message types (RFC 4120).  Matches `MessageType` in `KerberosABI.Types`."""
@enum MessageType::UInt8 begin
    AS_REQ = 0
    AS_REP = 1
    TGS_REQ = 2
    TGS_REP = 3
    AP_REQ = 4
    AP_REP = 5
    KRB_ERROR = 6
    KRB_SAFE = 7
    KRB_PRIV = 8
    KRB_CRED = 9
end


"""Kerberos encryption types (RFC 3961).  Matches `EncryptionType` in `KerberosABI.Types`."""
@enum EncryptionType::UInt8 begin
    AES256_CTS_HMAC_SHA1 = 0
    AES128_CTS_HMAC_SHA1 = 1
    AES256_CTS_HMAC_SHA384 = 2
    RC4_HMAC = 3
    DES3_CBC_SHA1 = 4
end


"""Kerberos principal name types (RFC 4120).  Matches `PrincipalType` in `KerberosABI.Types`."""
@enum PrincipalType::UInt8 begin
    NT_UNKNOWN = 0
    NT_PRINCIPAL = 1
    NT_SRV_INST = 2
    NT_SRV_HST = 3
    NT_UID = 4
    NT_X500 = 5
    NT_ENTERPRISE = 6
end


"""Kerberos ticket flags (RFC 4120).  Matches `TicketFlag` in `KerberosABI.Types`."""
@enum TicketFlag::UInt8 begin
    FORWARDABLE = 0
    FORWARDED = 1
    PROXIABLE = 2
    PROXY = 3
    RENEWABLE = 4
    PRE_AUTHENT = 5
    HW_AUTHENT = 6
end


"""Kerberos KDC error codes (RFC 4120).  Matches `ErrorCode` in `KerberosABI.Types`."""
@enum ErrorCode::UInt8 begin
    KDC_ERR_NONE = 0
    KDC_ERR_NAME_EXP = 1
    KDC_ERR_SERVICE_EXP = 2
    KDC_ERR_BAD_PVNO = 3
    KDC_ERR_C_OLD_MAST_KVNO = 4
    KDC_ERR_S_OLD_MAST_KVNO = 5
    KDC_ERR_C_PRINCIPAL_UNKNOWN = 6
    KDC_ERR_S_PRINCIPAL_UNKNOWN = 7
    KDC_ERR_PREAUTH_FAILED = 8
    KDC_ERR_PREAUTH_REQUIRED = 9
end


"""Kerberos authentication state machine.  Matches `AuthState` in `KerberosABI.Types`."""
@enum AuthState::UInt8 begin
    INITIAL = 0
    TGT_OBTAINED = 1
    SERVICE_TICKET_OBTAINED = 2
    AUTHENTICATED = 3
    AUTH_FAILED = 4
end


"""Encryption strength classification.  Matches `EncStrength` in `KerberosABI.Types`."""
@enum EncStrength::UInt8 begin
    STRONG = 0
    MEDIUM = 1
    WEAK = 2
end


"""Kerberos pre-authentication types.  Matches `PreAuthType` in `KerberosABI.Types`."""
@enum PreAuthType::UInt8 begin
    PA_ENC_TIMESTAMP = 0
    PA_ETYPE_INFO2 = 1
    PA_FX_FAST = 2
    PA_FX_COOKIE = 3
end


"""Kerberos encryption negotiation state.  Matches `NegotiationState` in `KerberosABI.Types`."""
@enum NegotiationState::UInt8 begin
    NEG_IDLE = 0
    PROPOSED = 1
    SELECTED = 2
    NEG_FAILED = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_kerberos."""
function abi_version()::UInt32
    ccall((:kerberos_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Kerberos (RFC 4120) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:kerberos_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Kerberos (RFC 4120) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:kerberos_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> AuthState

Get the current Kerberos (RFC 4120) lifecycle state.
"""
function get_state(slot::SlotId)::AuthState
    AuthState(ccall((:kerberos_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::AuthState, to::AuthState) -> Bool

Check whether a Kerberos (RFC 4120) state transition is valid.
"""
function can_transition(from::AuthState, to::AuthState)::Bool
    ccall((:kerberos_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Kerberos
