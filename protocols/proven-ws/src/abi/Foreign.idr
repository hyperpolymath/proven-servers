-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- WSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ws.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected WebSocket connection pool
--   - Frame send/receive with opcode tracking
--   - Message fragmentation state machine
--   - Close handshake protocol
--   - Ping/pong heartbeat tracking
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching WSABI.Types exactly.

module WSABI.Foreign

import WSABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a WebSocket connection context.
||| Created by ws_create(), destroyed by ws_destroy().
export
data WSContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ws_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | ws_abi_version              | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | ws_create                   | () -> c_int                               |
-- |                             | Creates connection in Connecting state.   |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | ws_destroy                  | (slot: c_int) -> void                     |
-- |                             | Releases a connection slot.               |
-- +-----------------------------+-------------------------------------------+
-- | ws_state                    | (slot: c_int) -> u8 (ConnState tag)       |
-- |                             | Returns current connection state.         |
-- +-----------------------------+-------------------------------------------+
-- | ws_open                     | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Connecting -> Open.           |
-- +-----------------------------+-------------------------------------------+
-- | ws_send_frame               | (slot: c_int, opcode: u8, fin: u8,       |
-- |                             |  payload_len: u32)                        |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Sends a frame with given opcode.          |
-- +-----------------------------+-------------------------------------------+
-- | ws_recv_frame               | (slot: c_int, opcode: u8, fin: u8,       |
-- |                             |  payload_len: u32)                        |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Receives a frame with given opcode.       |
-- +-----------------------------+-------------------------------------------+
-- | ws_send_ping                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Sends a Ping frame.                       |
-- +-----------------------------+-------------------------------------------+
-- | ws_recv_pong                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Receives a Pong frame.                    |
-- +-----------------------------+-------------------------------------------+
-- | ws_close                    | (slot: c_int, code: u8)                   |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Initiates close with CloseCode tag.       |
-- +-----------------------------+-------------------------------------------+
-- | ws_recv_close               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Receives close frame (completes           |
-- |                             | handshake).                               |
-- +-----------------------------+-------------------------------------------+
-- | ws_is_closing               | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                             | Returns whether connection is closing.    |
-- +-----------------------------+-------------------------------------------+
-- | ws_frames_sent              | (slot: c_int) -> u32                     |
-- |                             | Returns total frames sent.               |
-- +-----------------------------+-------------------------------------------+
-- | ws_frames_received          | (slot: c_int) -> u32                     |
-- |                             | Returns total frames received.           |
-- +-----------------------------+-------------------------------------------+
-- | ws_ping_count               | (slot: c_int) -> u32                     |
-- |                             | Returns total pings sent.                |
-- +-----------------------------+-------------------------------------------+
-- | ws_can_transition           | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks connection state        |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
