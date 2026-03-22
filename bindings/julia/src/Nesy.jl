# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-nesy protocol (Neurosymbolic AI engine).
#
# Wraps the C-ABI functions from protocols/proven-nesy/ffi/zig/src/nesy.zig
# via ccall into libproven_nesy.so.

module Nesy

using ..ProvenServers: check_status, check_slot, SlotId

export ReasoningMode,
       ProofStatus,
       ConstraintKind,
       NeuralBackend,
       Confidence,
       DriftKind,
       NeSyState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_nesy"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Neurosymbolic reasoning modes."""
@enum ReasoningMode::UInt8 begin
    MODE_SYMBOLIC = 0
    MODE_NEURAL = 1
    MODE_SYM_TO_NEURAL = 2
    MODE_NEURAL_TO_SYM = 3
    MODE_ENSEMBLE = 4
    MODE_CASCADE = 5
end

"""Proof verification status."""
@enum ProofStatus::UInt8 begin
    PROOF_PENDING = 0
    PROOF_ATTEMPTING = 1
    PROOF_PROVED = 2
    PROOF_FAILED = 3
    PROOF_ASSUMED = 4
    PROOF_VACUOUS = 5
end

"""Type constraint kinds."""
@enum ConstraintKind::UInt8 begin
    CK_TYPE_EQUALITY = 0
    CK_SUBTYPE = 1
    CK_LINEARITY = 2
    CK_TERMINATION = 3
    CK_TOTALITY = 4
    CK_INVARIANT = 5
    CK_REFINEMENT = 6
    CK_DEPENDENT_INDEX = 7
end

"""Neural inference backend providers."""
@enum NeuralBackend::UInt8 begin
    BACKEND_LOCAL_MODEL = 0
    BACKEND_CLAUDE = 1
    BACKEND_GEMINI = 2
    BACKEND_MISTRAL = 3
    BACKEND_GPT = 4
    BACKEND_CUSTOM = 5
end

"""Inference confidence levels."""
@enum Confidence::UInt8 begin
    CONF_VERIFIED = 0
    CONF_HIGH_NEURAL = 1
    CONF_MEDIUM_NEURAL = 2
    CONF_LOW_NEURAL = 3
    CONF_UNKNOWN = 4
    CONF_CONTRADICTED = 5
end

"""Knowledge drift types."""
@enum DriftKind::UInt8 begin
    DRIFT_NONE = 0
    DRIFT_SEMANTIC = 1
    DRIFT_CONFIDENCE = 2
    DRIFT_FACTUAL = 3
    DRIFT_TEMPORAL = 4
    DRIFT_CATASTROPHIC = 5
end

"""NeSy engine states."""
@enum NeSyState::UInt8 begin
    STATE_IDLE = 0
    STATE_READY = 1
    STATE_REASONING = 2
    STATE_VERIFYING = 3
    STATE_DRIFT = 4
    STATE_SHUTDOWN = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_nesy."""
function abi_version()::UInt32
    ccall((:nesy_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Nesy context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:nesy_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Nesy context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:nesy_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> NeSyState

Get the current Nesy lifecycle state.
"""
function get_state(slot::SlotId)::NeSyState
    NeSyState(ccall((:nesy_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::NeSyState, to::NeSyState) -> Bool

Check whether a Nesy state transition is valid.
"""
function can_transition(from::NeSyState, to::NeSyState)::Bool
    ccall((:nesy_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Nesy
