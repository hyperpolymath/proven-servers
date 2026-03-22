# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ca protocol (Certificate Authority (PKI/CA)).
#
# Wraps the C-ABI functions from protocols/proven-ca/ffi/zig/src/ca.zig
# via ccall into libproven_ca.so.

module Ca

using ..ProvenServers: check_status, check_slot, SlotId

export CertType, KeyAlgorithm, SignatureAlgorithm, CertState, RevocationReason, CrlStatus, OcspStatus, Extension, KeyUsageBit,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_ca"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""X.509 certificate types.  Matches `CertType` in `CaABI.Types`."""
@enum CertType::UInt8 begin
    ROOT = 0
    INTERMEDIATE = 1
    END_ENTITY = 2
    CROSS_SIGNED = 3
    CODE_SIGNING = 4
    EMAIL_PROTECTION = 5
    OCSP_SIGNING = 6
end


"""Cryptographic key algorithms.  Matches `KeyAlgorithm` in `CaABI.Types`."""
@enum KeyAlgorithm::UInt8 begin
    RSA2048 = 0
    RSA4096 = 1
    ECDSA_P256 = 2
    ECDSA_P384 = 3
    ED25519 = 4
    ED448 = 5
end


"""Cryptographic signature algorithms.  Matches `SignatureAlgorithm` in `CaABI.Types`."""
@enum SignatureAlgorithm::UInt8 begin
    SHA256_WITH_RSA = 0
    SHA384_WITH_RSA = 1
    SHA512_WITH_RSA = 2
    SHA256_WITH_ECDSA = 3
    SHA384_WITH_ECDSA = 4
    PURE_ED25519 = 5
    PURE_ED448 = 6
end


"""Certificate lifecycle states.  Matches `CertState` in `CaABI.Types`."""
@enum CertState::UInt8 begin
    PENDING = 0
    ACTIVE = 1
    REVOKED = 2
    EXPIRED = 3
    SUSPENDED = 4
end


"""Certificate revocation reasons (RFC 5280).  Matches `RevocationReason` in `CaABI.Types`."""
@enum RevocationReason::UInt8 begin
    UNSPECIFIED = 0
    KEY_COMPROMISE = 1
    CA_COMPROMISE = 2
    AFFILIATION_CHANGED = 3
    SUPERSEDED = 4
    CESSATION_OF_OPERATION = 5
    CERTIFICATE_HOLD = 6
end


"""CRL status.  Matches `CrlStatus` in `CaABI.Types`."""
@enum CrlStatus::UInt8 begin
    CURRENT = 0
    CRL_EXPIRED = 1
    CRL_PENDING = 2
    CRL_ERROR = 3
end


"""OCSP response status.  Matches `OcspStatus` in `CaABI.Types`."""
@enum OcspStatus::UInt8 begin
    GOOD = 0
    OCSP_REVOKED = 1
    UNKNOWN = 2
    UNAVAILABLE = 3
end


"""X.509 extension types.  Matches `Extension` in `CaABI.Types`."""
@enum Extension::UInt8 begin
    BASIC_CONSTRAINTS = 0
    KEY_USAGE = 1
    EXT_KEY_USAGE = 2
    SUBJECT_ALT_NAME = 3
    AUTHORITY_INFO_ACCESS = 4
    CRL_DISTRIBUTION_POINTS = 5
end


"""Key usage bit flags (RFC 5280).  Matches `KeyUsageBit` in `CaABI.Types`."""
@enum KeyUsageBit::UInt8 begin
    DIGITAL_SIGNATURE = 0
    NON_REPUDIATION = 1
    KEY_ENCIPHERMENT = 2
    DATA_ENCIPHERMENT = 3
    KEY_AGREEMENT = 4
    KEY_CERT_SIGN = 5
    CRL_SIGN = 6
    ENCIPHER_ONLY = 7
    DECIPHER_ONLY = 8
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ca."""
function abi_version()::UInt32
    ccall((:ca_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Certificate Authority (PKI/CA) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ca_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Certificate Authority (PKI/CA) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ca_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> CertState

Get the current Certificate Authority (PKI/CA) lifecycle state.
"""
function get_state(slot::SlotId)::CertState
    CertState(ccall((:ca_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::CertState, to::CertState) -> Bool

Check whether a Certificate Authority (PKI/CA) state transition is valid.
"""
function can_transition(from::CertState, to::CertState)::Bool
    ccall((:ca_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Ca
