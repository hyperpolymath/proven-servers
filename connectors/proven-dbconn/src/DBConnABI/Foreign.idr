-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DBConnABI.Foreign: Foreign function declarations for the C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle types (ConnHandle, PoolHandle, StmtHandle) that
--      cannot be inspected or forged from Idris2 code — they exist only
--      as pointers managed by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function dbconn_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.  These are declared here as the
--      specification/contract; actual %foreign annotations are added
--      when the Zig shared library is built and linked.
--
-- The opaque handle pattern ensures that:
--   - Idris2 code cannot construct a ConnHandle out of thin air
--   - Idris2 code cannot inspect the internal representation
--   - Lifetime management is handled entirely by the Zig allocator
--   - The type checker can still track handles through the program

module DBConnABI.Foreign

import DBConn.Types
import DBConnABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle types
---------------------------------------------------------------------------

||| Opaque handle to a database connection.
||| This type has no Idris2-visible constructors — values can only be
||| created by the Zig FFI via dbconn_connect() and destroyed via
||| dbconn_disconnect().  The [external] pragma tells Idris2 that this
||| type's representation is managed externally.
export
data ConnHandle : Type where [external]

||| Opaque handle to a connection pool.
||| Created by dbconn_pool_create(), destroyed by dbconn_pool_destroy().
export
data PoolHandle : Type where [external]

||| Opaque handle to a prepared statement.
||| Created by dbconn_prepare(), freed by dbconn_stmt_free().
||| A StmtHandle is always associated with the ConnHandle that created it
||| and must not outlive that connection.
export
data StmtHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
||| The Zig implementation's dbconn_abi_version() function MUST return
||| this exact value.  Callers should compare the returned value against
||| this constant before using any other FFI function, to detect
||| version mismatches between the Idris2 types and the Zig library.
|||
||| Increment this value whenever:
|||   - A new function is added to the FFI
|||   - An existing function signature changes
|||   - Tag values in Layout.idr change
|||   - Handle semantics change
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- The following documents the complete set of C-ABI functions that the
-- Zig implementation (ffi/zig/src/dbconn.zig) must export.  Each entry
-- specifies the function name, parameter types, return type, and
-- semantic contract.
--
-- These are DECLARATIONS ONLY — no %foreign annotations yet, because
-- the Zig shared library is not linked at Idris2 compile time for now.
-- When the build system is extended to link libproven_dbconn.so, these
-- declarations will gain %foreign "C:dbconn_..." annotations.
--
-- ┌─────────────────────────────────────────────────────────────────────┐
-- │ Function              │ Signature                                  │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_abi_version    │ () -> Bits32                               │
-- │                       │ Must return abiVersion (currently 1).      │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_connect        │ (host: Ptr, port: Bits16,                  │
-- │                       │  tls: Bits8, err: Ptr) -> Ptr ConnHandle   │
-- │                       │ Transitions: _ -> Connected | Failed.      │
-- │                       │ Returns NULL on failure, sets *err.         │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_disconnect     │ (h: Ptr ConnHandle) -> Bits8               │
-- │                       │ Transitions: Connected|InTx -> Disconnected│
-- │                       │ Returns ConnError tag (0 = success).        │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_state          │ (h: Ptr ConnHandle) -> Bits8               │
-- │                       │ Returns the ConnState tag for handle h.     │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_begin_tx       │ (h: Ptr ConnHandle, iso: Bits8) -> Bits8   │
-- │                       │ Transitions: Connected -> InTransaction.    │
-- │                       │ iso is an IsolationLevel tag.               │
-- │                       │ Returns ConnError tag (0 = success).        │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_commit         │ (h: Ptr ConnHandle) -> Bits8               │
-- │                       │ Transitions: InTransaction -> Connected.    │
-- │                       │ Returns ConnError tag (0 = success).        │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_rollback       │ (h: Ptr ConnHandle) -> Bits8               │
-- │                       │ Transitions: InTransaction -> Connected.    │
-- │                       │ Returns ConnError tag (0 = success).        │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_prepare        │ (h: Ptr ConnHandle, sql: Ptr,              │
-- │                       │  len: Bits32, err: Ptr) -> Ptr StmtHandle  │
-- │                       │ Requires: CanQuery state.                   │
-- │                       │ Returns NULL on failure, sets *err.         │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_bind_param     │ (s: Ptr StmtHandle, idx: Bits16,           │
-- │                       │  typ: Bits8, val: Ptr, len: Bits32)        │
-- │                       │  -> Bits8                                   │
-- │                       │ typ is a ParamType tag.                     │
-- │                       │ Returns ConnError tag (0 = success).        │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_execute        │ (s: Ptr StmtHandle, err: Ptr) -> Bits8     │
-- │                       │ Returns QueryResult tag.  Sets *err on      │
-- │                       │ failure.                                     │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_stmt_free      │ (s: Ptr StmtHandle) -> ()                  │
-- │                       │ Frees a prepared statement.                 │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_pool_create    │ (max: Bits16) -> Ptr PoolHandle            │
-- │                       │ Creates a pool.  max is capped at 100.      │
-- │                       │ Returns NULL on allocation failure.         │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_pool_state     │ (p: Ptr PoolHandle) -> Bits8               │
-- │                       │ Returns PoolState tag.                      │
-- ├───────────────────────┼────────────────────────────────────────────┤
-- │ dbconn_pool_destroy   │ (p: Ptr PoolHandle) -> ()                  │
-- │                       │ Drains and destroys a pool.                 │
-- └───────────────────────┴────────────────────────────────────────────┘
