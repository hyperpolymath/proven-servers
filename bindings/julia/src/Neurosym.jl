# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-neurosym protocol (Neurosymbolic integration engine).
#
# Wraps the C-ABI functions from protocols/proven-neurosym/ffi/zig/src/neurosym.zig
# via ccall into libproven_neurosym.so.

module Neurosym

using ..ProvenServers: check_status, check_slot, SlotId

export InferenceMode,
       SymbolicOp,
       NeuralOp,
       FusionStrategy,
       ConfidenceLevel,
       KnowledgeType,
       NeurosymState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_neurosym"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Neurosymbolic inference modes."""
@enum InferenceMode::UInt8 begin
    MODE_NEURAL = 0
    MODE_SYMBOLIC = 1
    MODE_HYBRID = 2
    MODE_CASCADE = 3
end

"""Symbolic reasoning operations."""
@enum SymbolicOp::UInt8 begin
    SOP_UNIFY = 0
    SOP_RESOLVE = 1
    SOP_REWRITE = 2
    SOP_PROVE = 3
    SOP_SEARCH = 4
    SOP_CONSTRAIN = 5
end

"""Neural inference operations."""
@enum NeuralOp::UInt8 begin
    NOP_EMBED = 0
    NOP_CLASSIFY = 1
    NOP_GENERATE = 2
    NOP_ATTEND = 3
    NOP_RETRIEVE = 4
    NOP_FINETUNE = 5
end

"""Neural-symbolic fusion strategies."""
@enum FusionStrategy::UInt8 begin
    FUSE_NEURAL_THEN_SYMBOLIC = 0
    FUSE_SYMBOLIC_THEN_NEURAL = 1
    FUSE_PARALLEL = 2
    FUSE_ITERATIVE = 3
    FUSE_GATED = 4
end

"""Inference confidence levels."""
@enum ConfidenceLevel::UInt8 begin
    CL_PROVEN = 0
    CL_HIGH = 1
    CL_MODERATE = 2
    CL_LOW = 3
    CL_UNCERTAIN = 4
    CL_CONTRADICTED = 5
end

"""Knowledge entry types."""
@enum KnowledgeType::UInt8 begin
    KT_AXIOM = 0
    KT_LEARNED = 1
    KT_INFERRED = 2
    KT_GROUNDED = 3
    KT_HYPOTHETICAL = 4
    KT_RETRACTED = 5
end

"""Neurosymbolic engine states."""
@enum NeurosymState::UInt8 begin
    STATE_IDLE = 0
    STATE_READY = 1
    STATE_INFERRING = 2
    STATE_REASONING = 3
    STATE_FUSING = 4
    STATE_SHUTDOWN = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_neurosym."""
function abi_version()::UInt32
    ccall((:neurosym_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Neurosym context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:neurosym_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Neurosym context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:neurosym_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> NeurosymState

Get the current Neurosym lifecycle state.
"""
function get_state(slot::SlotId)::NeurosymState
    NeurosymState(ccall((:neurosym_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::NeurosymState, to::NeurosymState) -> Bool

Check whether a Neurosym state transition is valid.
"""
function can_transition(from::NeurosymState, to::NeurosymState)::Bool
    ccall((:neurosym_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Neurosym
