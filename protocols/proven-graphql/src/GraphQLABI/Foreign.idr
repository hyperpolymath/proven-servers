-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GraphQLABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.  The Zig side manages a 64-slot
-- pool of GraphQL contexts, each tracking request lifecycle phase,
-- operation type, error category, query parser state, field resolution,
-- and subscription management.

module GraphQLABI.Foreign

import GraphQL.Types
import GraphQLABI.Layout
import GraphQLABI.Transitions

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a GraphQL execution context.
||| Created by graphql_create(), destroyed by graphql_destroy().
export
data GraphqlContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match graphql_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function                 | Signature                                  |
-- +--------------------------+--------------------------------------------+
-- | graphql_abi_version      | () -> Bits32                               |
-- +--------------------------+--------------------------------------------+
-- | graphql_create           | (op_type: u8) -> c_int (slot)              |
-- |                          | Creates context in Parse phase.            |
-- +--------------------------+--------------------------------------------+
-- | graphql_destroy          | (slot: c_int) -> ()                        |
-- +--------------------------+--------------------------------------------+
-- | graphql_phase            | (slot: c_int) -> u8 (RequestPhase tag)     |
-- +--------------------------+--------------------------------------------+
-- | graphql_operation_type   | (slot: c_int) -> u8 (OperationType tag)    |
-- +--------------------------+--------------------------------------------+
-- | graphql_advance          | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                          | Advances to the next valid request phase.  |
-- +--------------------------+--------------------------------------------+
-- | graphql_abort            | (slot: c_int, err_cat: u8) -> u8           |
-- |                          | Transitions to Failed with error category. |
-- +--------------------------+--------------------------------------------+
-- | graphql_error_category   | (slot: c_int) -> u8 (ErrorCategory tag)    |
-- +--------------------------+--------------------------------------------+
-- | graphql_set_query_depth  | (slot: c_int, depth: u16) -> u8            |
-- |                          | Records query nesting depth after parse.   |
-- +--------------------------+--------------------------------------------+
-- | graphql_query_depth      | (slot: c_int) -> u16                       |
-- +--------------------------+--------------------------------------------+
-- | graphql_set_complexity   | (slot: c_int, score: u16) -> u8            |
-- |                          | Records query complexity score.            |
-- +--------------------------+--------------------------------------------+
-- | graphql_complexity       | (slot: c_int) -> u16                       |
-- +--------------------------+--------------------------------------------+
-- | graphql_resolve_field    | (slot: c_int, type_kind: u8,               |
-- |                          |  scalar_kind: u8) -> u8                    |
-- |                          | Records a field resolution event.          |
-- +--------------------------+--------------------------------------------+
-- | graphql_fields_resolved  | (slot: c_int) -> u16                       |
-- |                          | Count of fields resolved so far.           |
-- +--------------------------+--------------------------------------------+
-- | graphql_can_transition   | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                          | Stateless: request phase transition check. |
-- +--------------------------+--------------------------------------------+
-- | graphql_sub_create       | (slot: c_int) -> c_int (sub_id)           |
-- |                          | Creates subscription on existing context.  |
-- +--------------------------+--------------------------------------------+
-- | graphql_sub_phase        | (slot: c_int) -> u8 (SubscriptionPhase)   |
-- +--------------------------+--------------------------------------------+
-- | graphql_sub_advance      | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                          | Advances subscription to next phase.       |
-- +--------------------------+--------------------------------------------+
-- | graphql_sub_emit_event   | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                          | Delivers event in Active phase             |
-- |                          | (Active -> Active transition).             |
-- +--------------------------+--------------------------------------------+
-- | graphql_sub_abort        | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                          | Transitions subscription to SubFailed.     |
-- +--------------------------+--------------------------------------------+
-- | graphql_sub_event_count  | (slot: c_int) -> u32                      |
-- |                          | Number of events delivered to subscription.|
-- +--------------------------+--------------------------------------------+
-- | graphql_sub_can_transition | (from: u8, to: u8) -> u8 (1=yes, 0=no) |
-- |                          | Stateless: subscription transition check.  |
-- +--------------------------+--------------------------------------------+
