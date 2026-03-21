# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Shared error types for proven-servers Julia bindings.
#
# Maps the unified error model from the Zig FFI slot-based context pool
# pattern. Every protocol uses the same error codes:
#   0 = success, 1 = invalid state, 2 = validation failed,
#   -1 = pool exhausted (for slot-returning calls).

export ProvenError, ProvenPoolExhaustedError, ProvenInvalidStateError,
       ProvenValidationError, ProvenUnknownError,
       check_status, check_slot, SlotId

"""
    SlotId

Type alias for context slot identifiers. Valid slots are in range [0, 63].
"""
const SlotId = Cint

"""
    ProvenError <: Exception

Base error type for all proven-servers FFI failures.
"""
abstract type ProvenError <: Exception end

"""
    ProvenPoolExhaustedError()

Raised when all 64 context slots are in use.
"""
struct ProvenPoolExhaustedError <: ProvenError end

"""
    ProvenInvalidStateError()

Raised when an operation is rejected because the context is in the
wrong lifecycle state for the requested transition.
"""
struct ProvenInvalidStateError <: ProvenError end

"""
    ProvenValidationError()

Raised when input validation fails (e.g. path traversal, oversized name).
"""
struct ProvenValidationError <: ProvenError end

"""
    ProvenUnknownError(code::Int)

Raised when the FFI returns an undocumented error code.
"""
struct ProvenUnknownError <: ProvenError
    code::Int
end

"""
    check_status(raw::UInt8) -> Nothing

Interpret a status-returning FFI call (0 = success, 1 = invalid state,
2 = validation failed). Throws on non-zero.
"""
function check_status(raw::UInt8)::Nothing
    raw == 0x00 && return nothing
    raw == 0x01 && throw(ProvenInvalidStateError())
    raw == 0x02 && throw(ProvenValidationError())
    throw(ProvenUnknownError(Int(raw)))
end

"""
    check_slot(raw::Cint) -> SlotId

Interpret a slot-returning FFI call. Returns the slot on success (>= 0),
throws `ProvenPoolExhaustedError` on -1.
"""
function check_slot(raw::Cint)::SlotId
    raw >= 0 && return raw
    throw(ProvenPoolExhaustedError())
end
