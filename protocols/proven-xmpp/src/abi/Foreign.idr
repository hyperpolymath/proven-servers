-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- XMPPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/xmpp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected XMPP stream pool
--   - Stanza send/receive with type tracking
--   - Presence state management
--   - IQ request/response correlation
--   - Stream error handling
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching XMPPABI.Types exactly.

module XMPPABI.Foreign

import XMPPABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an XMPP stream context.
||| Created by xmpp_create(), destroyed by xmpp_destroy().
export
data XMPPContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match xmpp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_abi_version            | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_create                 | (jid_ptr: [*]u8, jid_len: u32)           |
-- |                             | -> c_int                                  |
-- |                             | Creates stream in Disconnected state.     |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_destroy                | (slot: c_int) -> void                     |
-- |                             | Releases a stream slot.                   |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_state                  | (slot: c_int) -> u8 (StreamState tag)     |
-- |                             | Returns current stream state.             |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_connect                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Disconnected -> Connected.    |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_authenticate           | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Connected -> Authenticated.   |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_bind                   | (slot: c_int, resource_ptr: [*]u8,       |
-- |                             |  resource_len: u32)                       |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Transitions Authenticated -> Bound.       |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_send_stanza            | (slot: c_int, stanza_type: u8)           |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Sends a stanza of the given type.         |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_recv_stanza            | (slot: c_int, stanza_type: u8)           |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Receives a stanza of the given type.      |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_set_presence           | (slot: c_int, presence: u8)              |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Sets presence state via PresenceType tag. |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_presence               | (slot: c_int) -> u8 (PresenceType tag)   |
-- |                             | Returns current presence state.           |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_stream_error           | (slot: c_int, error: u8)                 |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Transitions to Error state.               |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_disconnect             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Disconnected.              |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_stanzas_sent           | (slot: c_int) -> u32                     |
-- |                             | Returns total stanzas sent.              |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_stanzas_received       | (slot: c_int) -> u32                     |
-- |                             | Returns total stanzas received.          |
-- +-----------------------------+-------------------------------------------+
-- | xmpp_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks stream state            |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
