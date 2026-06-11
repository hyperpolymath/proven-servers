-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DoTABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/dot.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected server pool
--   - TLS session management per server (max 64 sessions)
--   - DNS query handling over TLS (RFC 7858)
--   - Padding strategy enforcement per session
--   - Connection keepalive tracking
--   - Query statistics tracking
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DoTABI.Types exactly.

module DoTABI.Foreign

import DoTABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a DoT server instance.
||| Created by dot_create(), destroyed by dot_destroy().
export
data DoTContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match dot_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | dot_abi_version                | () -> u32                               |
-- |                                | Returns ABI version (must equal         |
-- |                                | abiVersion).                            |
-- +-------------------------------+-----------------------------------------+
-- | dot_create                     | (port: u16, padding: u8)                |
-- |                                | -> c_int (slot)                         |
-- |                                | Creates server in Bound state.          |
-- |                                | Returns -1 on failure.                  |
-- +-------------------------------+-----------------------------------------+
-- | dot_destroy                    | (slot: c_int) -> void                   |
-- |                                | Releases a server slot.                 |
-- +-------------------------------+-----------------------------------------+
-- | dot_state                      | (slot: c_int) -> u8 (ServerState tag)   |
-- |                                | Returns current server state.           |
-- +-------------------------------+-----------------------------------------+
-- | dot_accept_session             | (slot: c_int)                           |
-- |                                | -> u8 (0=ok, 1=rejected)                |
-- |                                | Accepts a TLS client session.           |
-- |                                | Transitions Bound -> Listening.         |
-- +-------------------------------+-----------------------------------------+
-- | dot_close_session              | (slot: c_int, session_id: u32)          |
-- |                                | -> u8 (0=ok, 1=rejected)                |
-- |                                | Closes a TLS session.                   |
-- |                                | May transition Listening -> Bound.      |
-- +-------------------------------+-----------------------------------------+
-- | dot_session_count              | (slot: c_int) -> u32                    |
-- |                                | Returns number of active TLS sessions.  |
-- +-------------------------------+-----------------------------------------+
-- | dot_handle_query               | (slot: c_int, session_id: u32,          |
-- |                                |  query_ptr: ptr, query_len: u32)        |
-- |                                | -> u8 (ErrorReason tag or 0xFF=success) |
-- |                                | Handles a DNS query over TLS.           |
-- |                                | Transitions Listening -> Processing.    |
-- +-------------------------------+-----------------------------------------+
-- | dot_queries_handled            | (slot: c_int) -> u64                    |
-- |                                | Returns total queries processed.        |
-- +-------------------------------+-----------------------------------------+
-- | dot_can_serve                  | (slot: c_int) -> u8 (1=yes, 0=no)      |
-- +-------------------------------+-----------------------------------------+
-- | dot_shutdown                   | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                                | Transitions to Shutdown state.          |
-- +-------------------------------+-----------------------------------------+
-- | dot_cleanup                    | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                                | Transitions Shutdown -> Idle.           |
-- +-------------------------------+-----------------------------------------+
-- | dot_can_transition             | (from: u8, to: u8) -> u8 (1=yes, 0=no) |
-- |                                | Stateless transition validity check.    |
-- +-------------------------------+-----------------------------------------+
