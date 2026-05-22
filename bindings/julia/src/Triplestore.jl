# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-triplestore protocol (RDF Triplestore server).
#
# Wraps the C-ABI functions from protocols/proven-triplestore/ffi/zig/src/triplestore.zig
# via ccall into libproven_triplestore.so.

module Triplestore

using ..ProvenServers: check_status, check_slot, SlotId

export Statement,
       IndexOrder,
       StorageBackend,
       ImportFormat,
       TransactionIsolation,
       StoreState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_triplestore"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Triplestore statement types."""
@enum Statement::UInt8 begin
    STMT_TRIPLE = 0
    STMT_QUAD = 1
end

"""Triplestore index orders."""
@enum IndexOrder::UInt8 begin
    IDX_SPO = 0
    IDX_POS = 1
    IDX_OSP = 2
    IDX_GSPO = 3
    IDX_GPOS = 4
    IDX_GOSP = 5
end

"""Triplestore storage backends."""
@enum StorageBackend::UInt8 begin
    STORE_IN_MEMORY = 0
    STORE_BTREE = 1
    STORE_LSM = 2
    STORE_PERSISTENT = 3
end

"""Triplestore import formats."""
@enum ImportFormat::UInt8 begin
    FMT_NTRIPLES = 0
    FMT_TURTLE = 1
    FMT_RDF_XML = 2
    FMT_JSONLD = 3
    FMT_NQUADS = 4
    FMT_TRIG = 5
end

"""Triplestore transaction isolation levels."""
@enum TransactionIsolation::UInt8 begin
    ISO_READ_COMMITTED = 0
    ISO_SERIALIZABLE = 1
    ISO_SNAPSHOT = 2
end

"""Triplestore lifecycle states."""
@enum StoreState::UInt8 begin
    STATE_IDLE = 0
    STATE_READY = 1
    STATE_IN_TRANSACTION = 2
    STATE_IMPORTING = 3
    STATE_CLOSING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_triplestore."""
function abi_version()::UInt32
    ccall((:triplestore_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Triplestore context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:triplestore_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Triplestore context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:triplestore_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> StoreState

Get the current Triplestore lifecycle state.
"""
function get_state(slot::SlotId)::StoreState
    StoreState(ccall((:triplestore_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::StoreState, to::StoreState) -> Bool

Check whether a Triplestore state transition is valid.
"""
function can_transition(from::StoreState, to::StoreState)::Bool
    ccall((:triplestore_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Triplestore
