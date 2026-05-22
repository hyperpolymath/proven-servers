-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- STUNABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/stun.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected STUN/TURN session pool
--   - Message sending with type validation
--   - Transport protocol tracking
--   - Error code management
--   - Transaction ID tracking
--   - Message send/receive counters
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching STUNABI.Types exactly.

module STUNABI.Foreign

import STUNABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a STUN/TURN session context.
||| Created by stun_create(), destroyed by stun_destroy().
export
data STUNContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match stun_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | stun_abi_version            | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | stun_create                 | (transport: u8) -> c_int                  |
-- |                             | Creates session with given transport.     |
-- |                             | Returns slot (0-63) or -1 on failure.     |
-- +-----------------------------+-------------------------------------------+
-- | stun_destroy                | (slot: c_int) -> void                     |
-- |                             | Releases a session slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | stun_get_transport          | (slot: c_int) -> u8 (TransportProtocol)   |
-- |                             | Returns transport protocol tag.           |
-- +-----------------------------+-------------------------------------------+
-- | stun_get_error              | (slot: c_int) -> u8 (ErrorCode tag)       |
-- |                             | Returns last error code (255=none).       |
-- +-----------------------------+-------------------------------------------+
-- | stun_set_error              | (slot: c_int, err: u8) -> u8              |
-- |                             | Sets error code. Returns 0=ok, 1=fail.   |
-- +-----------------------------+-------------------------------------------+
-- | stun_clear_error            | (slot: c_int) -> void                     |
-- |                             | Clears the error state.                   |
-- +-----------------------------+-------------------------------------------+
-- | stun_send_message           | (slot: c_int, msg: u8) -> u8              |
-- |                             | Sends a message of given type.            |
-- |                             | Returns 0=ok or error tag.                |
-- +-----------------------------+-------------------------------------------+
-- | stun_get_send_count         | (slot: c_int) -> u32                      |
-- |                             | Returns number of messages sent.          |
-- +-----------------------------+-------------------------------------------+
-- | stun_get_recv_count         | (slot: c_int) -> u32                      |
-- |                             | Returns number of messages received.      |
-- +-----------------------------+-------------------------------------------+
-- | stun_receive_message        | (slot: c_int, msg: u8) -> u8              |
-- |                             | Records a received message.               |
-- |                             | Returns 0=ok or error tag.                |
-- +-----------------------------+-------------------------------------------+
-- | stun_get_last_sent          | (slot: c_int) -> u8 (MessageType tag)     |
-- |                             | Returns last sent message type (255=none).|
-- +-----------------------------+-------------------------------------------+
-- | stun_get_last_recv          | (slot: c_int) -> u8 (MessageType tag)     |
-- |                             | Returns last received msg type (255=none).|
-- +-----------------------------+-------------------------------------------+
-- | stun_set_transport          | (slot: c_int, t: u8) -> u8                |
-- |                             | Changes transport protocol.               |
-- |                             | Returns 0=ok, 1=fail.                     |
-- +-----------------------------+-------------------------------------------+
