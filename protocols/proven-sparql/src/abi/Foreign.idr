-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SparqlABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/sparql.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected SPARQL endpoint pool
--   - Query execution with type and format tracking
--   - Update operation tracking
--   - Error state management
--   - Query and update counters
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SparqlABI.Types exactly.

module SparqlABI.Foreign

import SparqlABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a SPARQL endpoint context.
||| Created by sparql_create(), destroyed by sparql_destroy().
export
data SparqlContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match sparql_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | sparql_abi_version          | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | sparql_create               | (format: u8) -> c_int                     |
-- |                             | Creates endpoint with default result      |
-- |                             | format. Returns slot or -1 on failure.    |
-- +-----------------------------+-------------------------------------------+
-- | sparql_destroy              | (slot: c_int) -> void                     |
-- |                             | Releases an endpoint slot.                |
-- +-----------------------------+-------------------------------------------+
-- | sparql_get_format           | (slot: c_int) -> u8 (ResultFormat tag)    |
-- |                             | Returns default result format tag.        |
-- +-----------------------------+-------------------------------------------+
-- | sparql_set_format           | (slot: c_int, fmt: u8) -> u8              |
-- |                             | Sets result format. Returns 0=ok, 1=fail. |
-- +-----------------------------+-------------------------------------------+
-- | sparql_execute_query        | (slot: c_int, qtype: u8) -> u8            |
-- |                             | Executes a query of given type.           |
-- |                             | Returns 0=ok or error tag.                |
-- +-----------------------------+-------------------------------------------+
-- | sparql_execute_update       | (slot: c_int, utype: u8) -> u8            |
-- |                             | Executes an update of given type.         |
-- |                             | Returns 0=ok or error tag.                |
-- +-----------------------------+-------------------------------------------+
-- | sparql_get_query_count      | (slot: c_int) -> u32                      |
-- |                             | Returns number of queries executed.       |
-- +-----------------------------+-------------------------------------------+
-- | sparql_get_update_count     | (slot: c_int) -> u32                      |
-- |                             | Returns number of updates executed.       |
-- +-----------------------------+-------------------------------------------+
-- | sparql_get_last_query_type  | (slot: c_int) -> u8 (QueryType tag)       |
-- |                             | Returns last query type tag (255=none).   |
-- +-----------------------------+-------------------------------------------+
-- | sparql_get_last_update_type | (slot: c_int) -> u8 (UpdateType tag)      |
-- |                             | Returns last update type tag (255=none).  |
-- +-----------------------------+-------------------------------------------+
-- | sparql_get_error            | (slot: c_int) -> u8 (ErrorType tag)       |
-- |                             | Returns last error tag (255=no error).    |
-- +-----------------------------+-------------------------------------------+
-- | sparql_set_error            | (slot: c_int, err: u8) -> u8              |
-- |                             | Sets error state. Returns 0=ok, 1=fail.  |
-- +-----------------------------+-------------------------------------------+
-- | sparql_clear_error          | (slot: c_int) -> void                     |
-- |                             | Clears the error state.                   |
-- +-----------------------------+-------------------------------------------+
