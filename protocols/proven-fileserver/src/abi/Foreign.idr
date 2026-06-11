-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- FileserverABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/fileserver.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected file server session pool
--   - File operation tracking per session
--   - Lock management per session
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching FileserverABI.Types exactly.

module FileserverABI.Foreign

import FileserverABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a file server session.
||| Created by fs_create(), destroyed by fs_destroy().
export
data FsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match fs_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | fs_abi_version                | () -> u32                               |
-- +-------------------------------+-----------------------------------------+
-- | fs_create                     | (root_ptr: ptr, root_len: u32)          |
-- |                               |  -> c_int (slot)                        |
-- +-------------------------------+-----------------------------------------+
-- | fs_destroy                    | (slot: c_int) -> void                   |
-- +-------------------------------+-----------------------------------------+
-- | fs_state                      | (slot: c_int) -> u8 (SessionState tag)  |
-- +-------------------------------+-----------------------------------------+
-- | fs_execute_op                 | (slot: c_int, operation: u8,            |
-- |                               |  path_ptr: ptr, path_len: u32)          |
-- |                               |  -> u8 (0=ok, ErrorCode+10 on error)    |
-- +-------------------------------+-----------------------------------------+
-- | fs_op_count                   | (slot: c_int) -> u32                    |
-- +-------------------------------+-----------------------------------------+
-- | fs_acquire_lock               | (slot: c_int, lock_type: u8,            |
-- |                               |  path_ptr: ptr, path_len: u32)          |
-- |                               |  -> u8 (0=ok, 1=rejected)               |
-- +-------------------------------+-----------------------------------------+
-- | fs_release_lock               | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | fs_is_locked                  | (slot: c_int) -> u8 (1=yes, 0=no)      |
-- +-------------------------------+-----------------------------------------+
-- | fs_lock_type                  | (slot: c_int) -> u8 (LockType tag)      |
-- +-------------------------------+-----------------------------------------+
-- | fs_disconnect                 | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | fs_cleanup                    | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | fs_can_transition             | (from: u8, to: u8) -> u8 (1/0)         |
-- +-------------------------------+-----------------------------------------+
