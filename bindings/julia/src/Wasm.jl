# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-wasm protocol (WebAssembly runtime).
#
# Wraps the C-ABI functions from protocols/proven-wasm/ffi/zig/src/wasm.zig
# via ccall into libproven_wasm.so.

module Wasm

using ..ProvenServers: check_status, check_slot, SlotId

export ValType,
       ExternKind,
       WasmMutability,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_wasm"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""WASM value types."""
@enum ValType::UInt8 begin
    VAL_I32 = 0
    VAL_I64 = 1
    VAL_F32 = 2
    VAL_F64 = 3
    VAL_V128 = 4
    VAL_FUNC_REF = 5
    VAL_EXTERN_REF = 6
end

"""WASM external kinds."""
@enum ExternKind::UInt8 begin
    EXTERN_FUNC = 0
    EXTERN_TABLE = 1
    EXTERN_MEM = 2
    EXTERN_GLOBAL = 3
end

"""WASM global mutability."""
@enum WasmMutability::UInt8 begin
    MUT_IMMUTABLE = 0
    MUT_MUTABLE = 1
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_wasm."""
function abi_version()::UInt32
    ccall((:wasm_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Wasm context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:wasm_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Wasm context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:wasm_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ValType

Get the current Wasm lifecycle state.
"""
function get_state(slot::SlotId)::ValType
    ValType(ccall((:wasm_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ValType, to::ValType) -> Bool

Check whether a Wasm state transition is valid.
"""
function can_transition(from::ValType, to::ValType)::Bool
    ccall((:wasm_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Wasm
