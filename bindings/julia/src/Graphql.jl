# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-graphql protocol (GraphQL server).
#
# Wraps the C-ABI functions from protocols/proven-graphql/ffi/zig/src/graphql.zig
# via ccall into libproven_graphql.so.

module Graphql

using ..ProvenServers: check_status, check_slot, SlotId

export GraphqlPhase, OperationType, ErrorCategory, SubPhase,
       abi_version, create, destroy, get_phase, get_operation_type,
       advance, abort_op, set_query_depth, get_query_depth,
       set_complexity, get_complexity, resolve_field, fields_resolved,
       sub_create, sub_advance, sub_emit_event, sub_abort,
       check_depth, check_complexity, can_transition

const LIB = "libproven_graphql"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""GraphQL request lifecycle phases."""
@enum GraphqlPhase::UInt8 begin
    PHASE_RECEIVED  = 0
    PHASE_PARSED    = 1
    PHASE_EXECUTING = 2
    PHASE_COMPLETE  = 3
    PHASE_ERROR     = 4
end

"""GraphQL operation types."""
@enum OperationType::UInt8 begin
    OP_QUERY        = 0
    OP_MUTATION     = 1
    OP_SUBSCRIPTION = 2
end

"""GraphQL error categories."""
@enum ErrorCategory::UInt8 begin
    ERR_NONE       = 0
    ERR_PARSE      = 1
    ERR_VALIDATION = 2
    ERR_EXECUTION  = 3
    ERR_INTERNAL   = 4
end

"""Subscription lifecycle phases."""
@enum SubPhase::UInt8 begin
    SUB_INITIALIZING = 0
    SUB_ACTIVE       = 1
    SUB_EMITTING     = 2
    SUB_COMPLETED    = 3
    SUB_ABORTED      = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_graphql."""
function abi_version()::UInt32
    ccall((:graphql_abi_version, LIB), UInt32, ())
end

"""
    create(op::OperationType) -> SlotId

Create a new GraphQL request context. Throws on pool exhaustion.
"""
function create(op::OperationType)::SlotId
    check_slot(ccall((:graphql_create, LIB), Cint, (UInt8,), UInt8(op)))
end

"""
    destroy(slot::SlotId)

Release the given GraphQL context slot.
"""
function destroy(slot::SlotId)::Nothing
    ccall((:graphql_destroy, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_phase(slot::SlotId) -> GraphqlPhase

Get the current request lifecycle phase.
"""
function get_phase(slot::SlotId)::GraphqlPhase
    GraphqlPhase(ccall((:graphql_phase, LIB), UInt8, (Cint,), slot))
end

"""
    get_operation_type(slot::SlotId) -> OperationType

Get the GraphQL operation type.
"""
function get_operation_type(slot::SlotId)::OperationType
    OperationType(ccall((:graphql_operation_type, LIB), UInt8, (Cint,), slot))
end

"""
    advance(slot::SlotId)

Advance to the next lifecycle phase. Throws on invalid state.
"""
function advance(slot::SlotId)::Nothing
    check_status(ccall((:graphql_advance, LIB), UInt8, (Cint,), slot))
end

"""
    abort_op(slot::SlotId, err::ErrorCategory)

Abort with the given error category. Throws on invalid state.
"""
function abort_op(slot::SlotId, err::ErrorCategory)::Nothing
    check_status(ccall((:graphql_abort, LIB), UInt8,
                       (Cint, UInt8), slot, UInt8(err)))
end

"""
    set_query_depth(slot::SlotId, depth::UInt16)

Set the query nesting depth. Throws on invalid state.
"""
function set_query_depth(slot::SlotId, depth::UInt16)::Nothing
    check_status(ccall((:graphql_set_query_depth, LIB), UInt8,
                       (Cint, UInt16), slot, depth))
end

"""
    get_query_depth(slot::SlotId) -> UInt16

Get the current query nesting depth.
"""
function get_query_depth(slot::SlotId)::UInt16
    ccall((:graphql_query_depth, LIB), UInt16, (Cint,), slot)
end

"""
    set_complexity(slot::SlotId, score::UInt16)

Set the query complexity score. Throws on invalid state.
"""
function set_complexity(slot::SlotId, score::UInt16)::Nothing
    check_status(ccall((:graphql_set_complexity, LIB), UInt8,
                       (Cint, UInt16), slot, score))
end

"""
    get_complexity(slot::SlotId) -> UInt16

Get the current query complexity score.
"""
function get_complexity(slot::SlotId)::UInt16
    ccall((:graphql_complexity, LIB), UInt16, (Cint,), slot)
end

"""
    resolve_field(slot::SlotId, type_kind::UInt8, scalar_kind::UInt8)

Resolve a field. Throws on invalid state.
"""
function resolve_field(slot::SlotId, type_kind::UInt8, scalar_kind::UInt8)::Nothing
    check_status(ccall((:graphql_resolve_field, LIB), UInt8,
                       (Cint, UInt8, UInt8), slot, type_kind, scalar_kind))
end

"""
    fields_resolved(slot::SlotId) -> UInt16

Get the number of fields resolved so far.
"""
function fields_resolved(slot::SlotId)::UInt16
    ccall((:graphql_fields_resolved, LIB), UInt16, (Cint,), slot)
end

"""
    sub_create(slot::SlotId) -> SlotId

Create a subscription context. Throws on pool exhaustion.
"""
function sub_create(slot::SlotId)::SlotId
    check_slot(ccall((:graphql_sub_create, LIB), Cint, (Cint,), slot))
end

"""
    sub_advance(slot::SlotId)

Advance subscription lifecycle. Throws on invalid state.
"""
function sub_advance(slot::SlotId)::Nothing
    check_status(ccall((:graphql_sub_advance, LIB), UInt8, (Cint,), slot))
end

"""
    sub_emit_event(slot::SlotId)

Emit a subscription event. Throws on invalid state.
"""
function sub_emit_event(slot::SlotId)::Nothing
    check_status(ccall((:graphql_sub_emit_event, LIB), UInt8, (Cint,), slot))
end

"""
    sub_abort(slot::SlotId)

Abort a subscription. Throws on invalid state.
"""
function sub_abort(slot::SlotId)::Nothing
    check_status(ccall((:graphql_sub_abort, LIB), UInt8, (Cint,), slot))
end

"""
    check_depth(depth::UInt16, max_depth::UInt16) -> Bool

Stateless: check if depth is within the limit.
"""
function check_depth(depth::UInt16, max_depth::UInt16)::Bool
    ccall((:graphql_check_depth, LIB), UInt8,
          (UInt16, UInt16), depth, max_depth) == 0x00
end

"""
    check_complexity(score::UInt16, max_complexity::UInt16) -> Bool

Stateless: check if complexity score is within the limit.
"""
function check_complexity(score::UInt16, max_complexity::UInt16)::Bool
    ccall((:graphql_check_complexity, LIB), UInt8,
          (UInt16, UInt16), score, max_complexity) == 0x00
end

"""
    can_transition(from::GraphqlPhase, to::GraphqlPhase) -> Bool

Check whether a GraphQL phase transition is valid.
"""
function can_transition(from::GraphqlPhase, to::GraphqlPhase)::Bool
    ccall((:graphql_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Graphql
