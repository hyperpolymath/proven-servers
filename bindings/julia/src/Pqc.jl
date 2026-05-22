# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-pqc protocol (Post-Quantum Cryptography server).
#
# Wraps the C-ABI functions from protocols/proven-pqc/ffi/zig/src/pqc.zig
# via ccall into libproven_pqc.so.

module Pqc

using ..ProvenServers: check_status, check_slot, SlotId

export PqcAlgorithm,
       NistLevel,
       PqcOperation,
       HybridMode,
       AlgorithmCategory,
       KeyState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_pqc"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Post-quantum cryptographic algorithms."""
@enum PqcAlgorithm::UInt8 begin
    ALG_CRYSTALS_KYBER = 0
    ALG_CRYSTALS_DILITHIUM = 1
    ALG_FALCON = 2
    ALG_SPHINCS_PLUS = 3
    ALG_CLASSIC_MCELIECE = 4
    ALG_BIKE = 5
    ALG_HQC = 6
    ALG_FRODOKEM = 7
end

"""NIST security levels."""
@enum NistLevel::UInt8 begin
    NIST_1 = 0
    NIST_2 = 1
    NIST_3 = 2
    NIST_4 = 3
    NIST_5 = 4
end

"""PQC cryptographic operations."""
@enum PqcOperation::UInt8 begin
    OP_KEYGEN = 0
    OP_ENCAPSULATE = 1
    OP_DECAPSULATE = 2
    OP_SIGN = 3
    OP_VERIFY = 4
end

"""Classical/PQC hybrid modes."""
@enum HybridMode::UInt8 begin
    MODE_CLASSICAL_ONLY = 0
    MODE_PQC_ONLY = 1
    MODE_HYBRID = 2
end

"""PQC algorithm categories."""
@enum AlgorithmCategory::UInt8 begin
    CAT_KEM = 0
    CAT_SIGNATURE = 1
end

"""PQC key lifecycle states."""
@enum KeyState::UInt8 begin
    KEY_EMPTY = 0
    KEY_GENERATING = 1
    KEY_GENERATED = 2
    KEY_ACTIVE = 3
    KEY_EXPIRED = 4
    KEY_COMPROMISED = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_pqc."""
function abi_version()::UInt32
    ccall((:pqc_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Pqc context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:pqc_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Pqc context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:pqc_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> KeyState

Get the current Pqc lifecycle state.
"""
function get_state(slot::SlotId)::KeyState
    KeyState(ccall((:pqc_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::KeyState, to::KeyState) -> Bool

Check whether a Pqc state transition is valid.
"""
function can_transition(from::KeyState, to::KeyState)::Bool
    ccall((:pqc_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Pqc
