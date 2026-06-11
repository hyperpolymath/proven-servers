-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DoHABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/doh.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected proxy pool
--   - Upstream resolver configuration per proxy
--   - Request path registration (max 8 paths per proxy)
--   - Query handling with content type and method validation (RFC 8484)
--   - Wire format selection (binary/JSON)
--   - Request statistics tracking
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DoHABI.Types exactly.

module DoHABI.Foreign

import DoHABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a DoH proxy server instance.
||| Created by doh_create(), destroyed by doh_destroy().
export
data DoHContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match doh_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | doh_abi_version                | () -> u32                               |
-- |                                | Returns ABI version (must equal         |
-- |                                | abiVersion).                            |
-- +-------------------------------+-----------------------------------------+
-- | doh_create                     | (port: u16) -> c_int (slot)             |
-- |                                | Creates proxy in Bound state.           |
-- |                                | Returns -1 on failure.                  |
-- +-------------------------------+-----------------------------------------+
-- | doh_destroy                    | (slot: c_int) -> void                   |
-- |                                | Releases a proxy slot.                  |
-- +-------------------------------+-----------------------------------------+
-- | doh_state                      | (slot: c_int) -> u8 (SessionState tag)  |
-- |                                | Returns current proxy state.            |
-- +-------------------------------+-----------------------------------------+
-- | doh_add_path                   | (slot: c_int,                           |
-- |                                |  path_ptr: ptr, path_len: u32,          |
-- |                                |  wire_format: u8) -> u8 (0=ok, 1=rej)  |
-- |                                | Registers a DoH request path.           |
-- |                                | Transitions Bound -> Serving.           |
-- +-------------------------------+-----------------------------------------+
-- | doh_remove_path                | (slot: c_int,                           |
-- |                                |  path_ptr: ptr, path_len: u32)          |
-- |                                | -> u8 (0=ok, 1=rejected)                |
-- |                                | May transition Serving -> Bound.        |
-- +-------------------------------+-----------------------------------------+
-- | doh_path_count                 | (slot: c_int) -> u32                    |
-- |                                | Returns number of registered paths.     |
-- +-------------------------------+-----------------------------------------+
-- | doh_handle_query               | (slot: c_int,                           |
-- |                                |  path_ptr: ptr, path_len: u32,          |
-- |                                |  method: u8, content_type: u8,          |
-- |                                |  body_ptr: ptr, body_len: u32)          |
-- |                                | -> u8 (ErrorReason tag or 0xFF=success) |
-- |                                | Handles a DNS-over-HTTPS query.         |
-- +-------------------------------+-----------------------------------------+
-- | doh_queries_handled            | (slot: c_int) -> u64                    |
-- |                                | Returns total queries processed.        |
-- +-------------------------------+-----------------------------------------+
-- | doh_can_serve                  | (slot: c_int) -> u8 (1=yes, 0=no)      |
-- +-------------------------------+-----------------------------------------+
-- | doh_shutdown                   | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                                | Transitions to Shutdown state.          |
-- +-------------------------------+-----------------------------------------+
-- | doh_cleanup                    | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- |                                | Transitions Shutdown -> Idle.           |
-- +-------------------------------+-----------------------------------------+
-- | doh_can_transition             | (from: u8, to: u8) -> u8 (1=yes, 0=no) |
-- |                                | Stateless transition validity check.    |
-- +-------------------------------+-----------------------------------------+
