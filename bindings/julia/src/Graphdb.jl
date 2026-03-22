# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-graphdb protocol (graph database).
#
# Wraps the C-ABI functions from protocols/proven-graphdb/ffi/zig/src/graphdb.zig
# via ccall into libproven_graphdb.so.

module Graphdb

using ..ProvenServers: check_status, check_slot, SlotId

export ElementType, QueryLanguage, TraversalStrategy, Consistency, ErrorCode, SessionState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_graphdb"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Graph element types.  Matches `ElementType` in `GraphdbABI.Types`."""
@enum ElementType::UInt8 begin
    NODE = 0
    EDGE = 1
    PROPERTY = 2
    LABEL = 3
    INDEX = 4
end


"""Graph query languages.  Matches `QueryLanguage` in `GraphdbABI.Types`."""
@enum QueryLanguage::UInt8 begin
    CYPHER = 0
    GREMLIN = 1
    SPARQL = 2
    GRAPH_QL = 3
end


"""Graph traversal strategies.  Matches `TraversalStrategy` in `GraphdbABI.Types`."""
@enum TraversalStrategy::UInt8 begin
    BFS = 0
    DFS = 1
    DIJKSTRA = 2
    A_STAR = 3
    RANDOM = 4
end


"""Consistency levels.  Matches `Consistency` in `GraphdbABI.Types`."""
@enum Consistency::UInt8 begin
    STRONG = 0
    EVENTUAL = 1
    SESSION = 2
    CAUSAL = 3
end


"""Graph database error codes.  Matches `ErrorCode` in `GraphdbABI.Types`."""
@enum ErrorCode::UInt8 begin
    SYNTAX_ERROR = 0
    NODE_NOT_FOUND = 1
    EDGE_NOT_FOUND = 2
    CONSTRAINT_VIOLATION = 3
    INDEX_EXISTS = 4
    TRANSACTION_CONFLICT = 5
    OUT_OF_MEMORY = 6
end


"""Graph database session states.  Matches `SessionState` in `GraphdbABI.Types`."""
@enum SessionState::UInt8 begin
    IDLE = 0
    CONNECTED = 1
    QUERYING = 2
    TRAVERSING = 3
    DISCONNECTING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_graphdb."""
function abi_version()::UInt32
    ccall((:graphdb_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new graph database context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:graphdb_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given graph database context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:graphdb_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SessionState

Get the current graph database lifecycle state.
"""
function get_state(slot::SlotId)::SessionState
    SessionState(ccall((:graphdb_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SessionState, to::SessionState) -> Bool

Check whether a graph database state transition is valid.
"""
function can_transition(from::SessionState, to::SessionState)::Bool
    ccall((:graphdb_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Graphdb
