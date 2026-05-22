-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DoQABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/doq.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected server pool
--   - QUIC stream management per server (max 64 streams)
--   - DNS query handling over QUIC streams (RFC 9250)
--   - Error code tracking per stream
--   - Connection draining with grace period
--   - Query statistics tracking
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DoQABI.Types exactly.

module DoQABI.Foreign

import DoQABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a DoQ server instance.
||| Created by doq_create(), destroyed by doq_destroy().
export
data DoQContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match doq_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | doq_abi_version                | () -> u32                               |
-- |                                | Returns ABI version (must equal         |
-- |                                | abiVersion).                            |
-- +-------------------------------+-----------------------------------------+
-- | doq_create                     | (port: u16) -> c_int (slot)             |
-- |                                | Creates server in Bound state.          |
-- |                                | Returns -1 on failure.                  |
-- +-------------------------------+-----------------------------------------+
-- | doq_destroy                    | (slot: c_int) -> void                   |
-- |                                | Releases a server slot.                 |
-- +-------------------------------+-----------------------------------------+
-- | doq_state                      | (slot: c_int) -> u8 (ServerState tag)   |
-- |                                | Returns current server state.           |
-- +-------------------------------+-----------------------------------------+
-- | doq_open_stream                | (slot: c_int, stream_type: u8)          |
-- |                                | -> u8 (0=ok, 1=rejected)                |
-- |                                | Opens a QUIC stream.                    |
-- |                                | Transitions Bound -> Listening.         |
-- +-------------------------------+-----------------------------------------+
-- | doq_close_stream               | (slot: c_int, stream_id: u32)           |
-- |                                | -> u8 (0=ok, 1=rejected)                |
-- |                                | Closes a QUIC stream.                   |
-- |                                | May transition Listening -> Bound.      |
-- +-------------------------------+-----------------------------------------+
-- | doq_stream_count               | (slot: c_int) -> u32                    |
-- |                                | Returns number of open streams.         |
-- +-------------------------------+-----------------------------------------+
-- | doq_handle_query               | (slot: c_int, stream_id: u32,           |
-- |                                |  query_ptr: ptr, query_len: u32)        |
-- |                                | -> u8 (ErrorCode tag)                   |
-- |                                | Handles a DNS query over QUIC.          |
-- |                                | Transitions Listening -> Processing.    |
-- +-------------------------------+-----------------------------------------+
-- | doq_queries_handled            | (slot: c_int) -> u64                    |
-- |                                | Returns total queries processed.        |
-- +-------------------------------+-----------------------------------------+
-- | doq_can_serve                  | (slot: c_int) -> u8 (1=yes, 0=no)      |
-- +-------------------------------+-----------------------------------------+
-- | doq_drain                      | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                                | Begins connection draining.             |
-- |                                | Transitions to Shutdown state.          |
-- +-------------------------------+-----------------------------------------+
-- | doq_cleanup                    | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                                | Transitions Shutdown -> Idle.           |
-- +-------------------------------+-----------------------------------------+
-- | doq_can_transition             | (from: u8, to: u8) -> u8 (1=yes, 0=no) |
-- |                                | Stateless transition validity check.    |
-- +-------------------------------+-----------------------------------------+
