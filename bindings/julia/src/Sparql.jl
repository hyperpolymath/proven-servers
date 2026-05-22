# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-sparql protocol (SPARQL endpoint server).
#
# Wraps the C-ABI functions from protocols/proven-sparql/ffi/zig/src/sparql.zig
# via ccall into libproven_sparql.so.

module Sparql

using ..ProvenServers: check_status, check_slot, SlotId

export SparqlQueryType,
       SparqlUpdateType,
       ResultFormat,
       SparqlErrorType,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_sparql"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""SPARQL query types."""
@enum SparqlQueryType::UInt8 begin
    QUERY_SELECT = 0
    QUERY_CONSTRUCT = 1
    QUERY_ASK = 2
    QUERY_DESCRIBE = 3
end

"""SPARQL update types."""
@enum SparqlUpdateType::UInt8 begin
    UPDATE_INSERT = 0
    UPDATE_DELETE = 1
    UPDATE_LOAD = 2
    UPDATE_CLEAR = 3
    UPDATE_CREATE = 4
    UPDATE_DROP = 5
end

"""SPARQL result formats."""
@enum ResultFormat::UInt8 begin
    FMT_XML = 0
    FMT_JSON = 1
    FMT_CSV = 2
    FMT_TSV = 3
end

"""SPARQL error types."""
@enum SparqlErrorType::UInt8 begin
    ERR_PARSE_ERROR = 0
    ERR_QUERY_TIMEOUT = 1
    ERR_RESULTS_TOO_LARGE = 2
    ERR_UNKNOWN_GRAPH = 3
    ERR_ACCESS_DENIED = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_sparql."""
function abi_version()::UInt32
    ccall((:sparql_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Sparql context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:sparql_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Sparql context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:sparql_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SparqlQueryType

Get the current Sparql lifecycle state.
"""
function get_state(slot::SlotId)::SparqlQueryType
    SparqlQueryType(ccall((:sparql_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SparqlQueryType, to::SparqlQueryType) -> Bool

Check whether a Sparql state transition is valid.
"""
function can_transition(from::SparqlQueryType, to::SparqlQueryType)::Bool
    ccall((:sparql_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Sparql
