-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- GraphqlABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/graphql.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching GraphqlABI.Types exactly.

module GraphqlABI.Foreign

import GraphqlABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Graphql context.
||| Created by graphql_create*(), destroyed by graphql_destroy*().
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
-- FFI function contract (31 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | graphql_abi_version               | () -> u32                                   |
-- | graphql_create                    | (op_type: u8) -> c_int                      |
-- | graphql_destroy                   | (slot: c_int) -> void                       |
-- | graphql_phase                     | (slot: c_int) -> u8                         |
-- | graphql_operation_type            | (slot: c_int) -> u8                         |
-- | graphql_error_category            | (slot: c_int) -> u8                         |
-- | graphql_advance                   | (slot: c_int) -> u8                         |
-- | graphql_abort                     | (slot: c_int, err_cat: u8) -> u8            |
-- | graphql_set_query_depth           | (slot: c_int, depth: u16) -> u8             |
-- | graphql_query_depth               | (slot: c_int) -> u16                        |
-- | graphql_set_complexity            | (slot: c_int, score: u16) -> u8             |
-- | graphql_complexity                | (slot: c_int) -> u16                        |
-- | graphql_resolve_field             | (slot: c_int, type_kind: u8, scalar_kind... |
-- | graphql_fields_resolved           | (slot: c_int) -> u16                        |
-- | graphql_can_transition            | (from: u8, to: u8) -> u8                    |
-- | graphql_sub_create                | (slot: c_int) -> c_int                      |
-- | graphql_sub_phase                 | (slot: c_int) -> u8                         |
-- | graphql_sub_advance               | (slot: c_int) -> u8                         |
-- | graphql_sub_emit_event            | (slot: c_int) -> u8                         |
-- | graphql_sub_abort                 | (slot: c_int) -> u8                         |
-- | graphql_sub_event_count           | (slot: c_int) -> u32                        |
-- | graphql_sub_can_transition        | (from: u8, to: u8) -> u8                    |
-- | graphql_introspection_query       | (slot: c_int, intro_field: u8) -> u8        |
-- | graphql_batch_create              | (count: u8) -> c_int                        |
-- | graphql_batch_set_op              | (batch_id: c_int, index: u8, op_type: u8... |
-- | graphql_batch_status              | (batch_id: c_int) -> u8                     |
-- | graphql_batch_query_status        | (batch_id: c_int, index: u8) -> u8          |
-- | graphql_batch_advance             | (batch_id: c_int) -> u8                     |
-- | graphql_batch_destroy             | (batch_id: c_int) -> void                   |
-- | graphql_check_depth               | (depth: u16, max_depth: u16) -> u8          |
-- | graphql_check_complexity          | (score: u16, max_complexity: u16) -> u8     |
-- +───────────────────────────────────+─────────────────────────────────────────────+
