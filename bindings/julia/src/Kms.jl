# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-kms protocol (Key Management Service (KMIP)).
#
# Wraps the C-ABI functions from protocols/proven-kms/ffi/zig/src/kms.zig
# via ccall into libproven_kms.so.

module Kms

using ..ProvenServers: check_status, check_slot, SlotId

export ObjectType, Operation, KeyState, KmsAlgorithm,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_kms"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Managed cryptographic object types.  Matches `ObjectType` in `KmsABI.Types`."""
@enum ObjectType::UInt8 begin
    SYMMETRIC_KEY = 0
    PUBLIC_KEY = 1
    PRIVATE_KEY = 2
    SECRET_DATA = 3
    CERTIFICATE = 4
    OPAQUE_DATA = 5
end


"""KMS operations.  Matches `Operation` in `KmsABI.Types`."""
@enum Operation::UInt8 begin
    CREATE = 0
    GET = 1
    ACTIVATE = 2
    REVOKE = 3
    DESTROY = 4
    LOCATE = 5
    REGISTER = 6
    REKEY = 7
    ENCRYPT = 8
    DECRYPT = 9
    SIGN = 10
    VERIFY = 11
    WRAP = 12
    UNWRAP = 13
    MAC = 14
end


"""Key lifecycle states (KMIP).  Matches `KeyState` in `KmsABI.Types`."""
@enum KeyState::UInt8 begin
    PRE_ACTIVE = 0
    ACTIVE = 1
    DEACTIVATED = 2
    COMPROMISED = 3
    DESTROYED = 4
    DESTROYED_COMPROMISED = 5
end


"""Cryptographic algorithms.  Matches `KmsAlgorithm` in `KmsABI.Types`."""
@enum KmsAlgorithm::UInt8 begin
    AES128 = 0
    AES256 = 1
    RSA2048 = 2
    RSA4096 = 3
    ECDSA_P256 = 4
    ECDSA_P384 = 5
    ED25519 = 6
    CHACHA20_POLY1305 = 7
    HMAC_SHA256 = 8
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_kms."""
function abi_version()::UInt32
    ccall((:kms_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Key Management Service (KMIP) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:kms_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Key Management Service (KMIP) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:kms_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> KeyState

Get the current Key Management Service (KMIP) lifecycle state.
"""
function get_state(slot::SlotId)::KeyState
    KeyState(ccall((:kms_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::KeyState, to::KeyState) -> Bool

Check whether a Key Management Service (KMIP) state transition is valid.
"""
function can_transition(from::KeyState, to::KeyState)::Bool
    ccall((:kms_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Kms
