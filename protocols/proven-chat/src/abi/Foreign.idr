-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ChatABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/chat.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot chat room pool
--   - Per-room type, user count, and message counter
--   - Presence tracking per session
--   - Event dispatch with permission checks
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching ChatABI.Types exactly.

module ChatABI.Foreign

import ChatABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a chat room session.
||| Created by chat_create_room(), destroyed by chat_destroy_room().
export
data ChatContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match chat_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +---------------------------+-----------------------------------------------+
-- | Function                  | Signature                                     |
-- +---------------------------+-----------------------------------------------+
-- | chat_abi_version          | () -> u32                                     |
-- |                           | Returns ABI version (must equal abiVersion).  |
-- +---------------------------+-----------------------------------------------+
-- | chat_create_room          | (room_type: u8, max_users: u16)               |
-- |                           |   -> c_int (slot)                             |
-- |                           | Creates a room. Returns -1 on failure.        |
-- +---------------------------+-----------------------------------------------+
-- | chat_destroy_room         | (slot: c_int) -> void                         |
-- |                           | Releases a room slot.                         |
-- +---------------------------+-----------------------------------------------+
-- | chat_room_type            | (slot: c_int) -> u8 (RoomType tag)            |
-- |                           | Returns the room type for this slot.          |
-- +---------------------------+-----------------------------------------------+
-- | chat_send_message         | (slot: c_int, msg_type: u8) -> u8             |
-- |                           | Send a message. Returns 0 on success,         |
-- |                           | 1 on invalid slot/type.                       |
-- +---------------------------+-----------------------------------------------+
-- | chat_message_count        | (slot: c_int) -> u32                          |
-- |                           | Returns the total messages sent in room.      |
-- +---------------------------+-----------------------------------------------+
-- | chat_join_user            | (slot: c_int) -> u8 (0=ok, 1=full/invalid)    |
-- |                           | Add a user to the room.                       |
-- +---------------------------+-----------------------------------------------+
-- | chat_leave_user           | (slot: c_int) -> u8 (0=ok, 1=empty/invalid)   |
-- |                           | Remove a user from the room.                  |
-- +---------------------------+-----------------------------------------------+
-- | chat_user_count           | (slot: c_int) -> u16                          |
-- |                           | Returns the current user count in the room.   |
-- +---------------------------+-----------------------------------------------+
-- | chat_max_users            | (slot: c_int) -> u16                          |
-- |                           | Returns the max user capacity for the room.   |
-- +---------------------------+-----------------------------------------------+
-- | chat_set_presence         | (slot: c_int, status: u8) -> u8               |
-- |                           | Set presence status. Returns 0 on success.    |
-- +---------------------------+-----------------------------------------------+
-- | chat_get_presence         | (slot: c_int) -> u8 (PresenceStatus tag)      |
-- |                           | Returns the current presence status.          |
-- +---------------------------+-----------------------------------------------+
-- | chat_has_permission       | (slot: c_int, perm: u8) -> u8 (1=yes, 0=no)  |
-- |                           | Whether the room has a given permission set.  |
-- +---------------------------+-----------------------------------------------+
-- | chat_grant_permission     | (slot: c_int, perm: u8) -> u8                 |
-- |                           | Grant a permission. Returns 0 on success.     |
-- +---------------------------+-----------------------------------------------+
