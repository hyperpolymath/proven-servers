-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- NFSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/nfs.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - File handle tracking (max 32 open files per session)
--   - Byte-range lock tracking
--   - Read/write operation state
--   - NFSv4 compound operation execution
--   - Lifecycle state machine transitions

module NFSABI.Foreign

import NFSABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an NFS session.
||| Created by nfs_create(), destroyed by nfs_destroy().
export
data NFSContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match nfs_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | nfs_abi_version             | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | nfs_create                  | (server_ptr: ptr, server_len: u32,        |
-- |                             |  export_ptr: ptr, export_len: u32)        |
-- |                             |  -> c_int (slot)                          |
-- |                             | Creates session in Mounted state.         |
-- +-----------------------------+-------------------------------------------+
-- | nfs_destroy                 | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | nfs_state                   | (slot: c_int) -> u8 (NFSState tag)        |
-- +-----------------------------+-------------------------------------------+
-- | nfs_open                    | (slot: c_int, path_ptr: ptr,              |
-- |                             |  path_len: u32, file_type: u8)            |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Mounted -> FileOpen.                      |
-- +-----------------------------+-------------------------------------------+
-- | nfs_close                   | (slot: c_int, handle: u32)                |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | FileOpen -> Mounted (if last handle).     |
-- +-----------------------------+-------------------------------------------+
-- | nfs_read                    | (slot: c_int, handle: u32,                |
-- |                             |  offset: u64, length: u32)                |
-- |                             |  -> u8 (Status tag)                       |
-- +-----------------------------+-------------------------------------------+
-- | nfs_write                   | (slot: c_int, handle: u32,                |
-- |                             |  offset: u64, length: u32)                |
-- |                             |  -> u8 (Status tag)                       |
-- +-----------------------------+-------------------------------------------+
-- | nfs_lock                    | (slot: c_int, handle: u32,                |
-- |                             |  offset: u64, length: u64)                |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | FileOpen -> Locked.                       |
-- +-----------------------------+-------------------------------------------+
-- | nfs_unlock                  | (slot: c_int, handle: u32)                |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Locked -> FileOpen.                       |
-- +-----------------------------+-------------------------------------------+
-- | nfs_lookup                  | (slot: c_int, path_ptr: ptr,              |
-- |                             |  path_len: u32)                           |
-- |                             |  -> u8 (Status tag)                       |
-- +-----------------------------+-------------------------------------------+
-- | nfs_getattr                 | (slot: c_int, handle: u32)                |
-- |                             |  -> u8 (FileType tag on success, 255 err) |
-- +-----------------------------+-------------------------------------------+
-- | nfs_open_count              | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | nfs_unmount                 | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                             | Any non-Idle -> Unmounting.               |
-- +-----------------------------+-------------------------------------------+
-- | nfs_cleanup                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Unmounting -> Idle.                       |
-- +-----------------------------+-------------------------------------------+
-- | nfs_can_transition          | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
