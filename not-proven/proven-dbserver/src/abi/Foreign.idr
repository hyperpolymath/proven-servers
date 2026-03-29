-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DbserverABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/dbserver.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected database session pool
--   - Transaction lifecycle per session
--   - Query execution tracking
--   - Isolation level management
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DbserverABI.Types exactly.

module DbserverABI.Foreign

import DbserverABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a database session.
||| Created by db_create(), destroyed by db_destroy().
export
data DbContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match db_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | db_abi_version                | () -> u32                               |
-- +-------------------------------+-----------------------------------------+
-- | db_create                     | (name_ptr: ptr, name_len: u32,          |
-- |                               |  isolation: u8) -> c_int (slot)         |
-- +-------------------------------+-----------------------------------------+
-- | db_destroy                    | (slot: c_int) -> void                   |
-- +-------------------------------+-----------------------------------------+
-- | db_state                      | (slot: c_int) -> u8 (SessionState tag)  |
-- +-------------------------------+-----------------------------------------+
-- | db_execute                    | (slot: c_int, query_type: u8,           |
-- |                               |  sql_ptr: ptr, sql_len: u32)            |
-- |                               |  -> u8 (0=ok, ErrorCode+10 on error)    |
-- +-------------------------------+-----------------------------------------+
-- | db_begin_tx                   | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | db_commit                     | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | db_rollback                   | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | db_in_transaction             | (slot: c_int) -> u8 (1=yes, 0=no)      |
-- +-------------------------------+-----------------------------------------+
-- | db_query_count                | (slot: c_int) -> u32                    |
-- +-------------------------------+-----------------------------------------+
-- | db_isolation_level            | (slot: c_int) -> u8 (IsolationLevel)    |
-- +-------------------------------+-----------------------------------------+
-- | db_disconnect                 | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | db_cleanup                    | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | db_can_transition             | (from: u8, to: u8) -> u8 (1/0)         |
-- +-------------------------------+-----------------------------------------+
