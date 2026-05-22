-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SMBABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/smb.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected SMB session pool
--   - Dialect negotiation and session authentication tracking
--   - Tree connection management (max 16 per session)
--   - File handle tracking (max 64 per session)
--   - Command validation against current session state
--   - Session lifecycle state transitions
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SMBABI.Types exactly.

module SMBABI.Foreign

import SMBABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an SMB session.
||| Created by smb_create(), destroyed by smb_destroy().
export
data SmbContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match smb_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (20 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-------------------------------------------+
-- | Function                      | Signature                                 |
-- +-------------------------------+-------------------------------------------+
-- | smb_abi_version               | () -> u32                                 |
-- +-------------------------------+-------------------------------------------+
-- | smb_create                    | (dialect: u8) -> c_int (slot)             |
-- |                               | Creates session with dialect.             |
-- |                               | Returns -1 on failure.                    |
-- |                               | State: Idle -> Negotiated.               |
-- +-------------------------------+-------------------------------------------+
-- | smb_destroy                   | (slot: c_int) -> void                     |
-- +-------------------------------+-------------------------------------------+
-- | smb_state                     | (slot: c_int) -> u8 (SessionState tag)    |
-- +-------------------------------+-------------------------------------------+
-- | smb_authenticate              | (slot: c_int,                             |
-- |                               |  user_ptr: ptr, user_len: u32)           |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- |                               | Transitions Negotiated -> Authenticated. |
-- +-------------------------------+-------------------------------------------+
-- | smb_tree_connect              | (slot: c_int,                             |
-- |                               |  share_ptr: ptr, share_len: u32,         |
-- |                               |  share_type: u8)                          |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- |                               | Transitions Authenticated ->             |
-- |                               | TreeConnected.                           |
-- +-------------------------------+-------------------------------------------+
-- | smb_tree_disconnect           | (slot: c_int, tree_id: u16)              |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- +-------------------------------+-------------------------------------------+
-- | smb_tree_count                | (slot: c_int) -> u16                      |
-- +-------------------------------+-------------------------------------------+
-- | smb_file_open                 | (slot: c_int, tree_id: u16,              |
-- |                               |  name_ptr: ptr, name_len: u32)           |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- |                               | Transitions TreeConnected -> FileOpen.   |
-- +-------------------------------+-------------------------------------------+
-- | smb_file_close                | (slot: c_int, file_id: u16)              |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- +-------------------------------+-------------------------------------------+
-- | smb_file_count                | (slot: c_int) -> u16                      |
-- +-------------------------------+-------------------------------------------+
-- | smb_file_read                 | (slot: c_int, file_id: u16,              |
-- |                               |  offset: u64, length: u32)               |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- +-------------------------------+-------------------------------------------+
-- | smb_file_write                | (slot: c_int, file_id: u16,              |
-- |                               |  offset: u64, length: u32)               |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- +-------------------------------+-------------------------------------------+
-- | smb_dialect                   | (slot: c_int) -> u8 (Dialect tag)         |
-- +-------------------------------+-------------------------------------------+
-- | smb_can_command               | (slot: c_int, cmd: u8) -> u8             |
-- |                               | Returns 1 if command is valid in current |
-- |                               | state, 0 otherwise.                      |
-- +-------------------------------+-------------------------------------------+
-- | smb_disconnect                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions any active ->                |
-- |                               | Disconnecting.                           |
-- +-------------------------------+-------------------------------------------+
-- | smb_cleanup                   | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions Disconnecting -> Idle.       |
-- +-------------------------------+-------------------------------------------+
-- | smb_can_transition            | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-------------------------------+-------------------------------------------+
-- | smb_active_count              | () -> u32                                 |
-- +-------------------------------+-------------------------------------------+
-- | smb_encryption_required       | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                               | Returns 1 if dialect >= SMB 3.0          |
-- |                               | (encryption capable).                    |
-- +-------------------------------+-------------------------------------------+
