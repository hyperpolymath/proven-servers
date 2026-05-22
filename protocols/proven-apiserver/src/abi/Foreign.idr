-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ApiserverABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/apiserver.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected API endpoint pool
--   - Route registration per endpoint (max 128 routes)
--   - Per-route auth scheme and rate limiting configuration
--   - Request routing with version resolution
--   - Rate limit token tracking
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching ApiserverABI.Types exactly.

module ApiserverABI.Foreign

import ApiserverABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an API server gateway context.
||| Created by apiserver_create(), destroyed by apiserver_destroy().
export
data ApiserverContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match apiserver_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_abi_version       | () -> u32                                 |
-- |                             | Returns ABI version.                      |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_create            | (port: u16) -> c_int (slot)               |
-- |                             | Creates gateway in Ready state.           |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_destroy           | (slot: c_int) -> void                     |
-- |                             | Releases a gateway slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_state             | (slot: c_int) -> u8 (GatewayState tag)    |
-- |                             | Returns current gateway state.            |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_register_route    | (slot: c_int,                             |
-- |                             |  path_ptr: ptr, path_len: u32,            |
-- |                             |  version: u8, auth: u8, format: u8)       |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Register an API route.                    |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_unregister_route  | (slot: c_int,                             |
-- |                             |  path_ptr: ptr, path_len: u32)            |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Unregister an API route.                  |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_route_count       | (slot: c_int) -> u32                      |
-- |                             | Returns number of registered routes.      |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_handle_request    | (slot: c_int,                             |
-- |                             |  path_ptr: ptr, path_len: u32,            |
-- |                             |  version: u8, auth: u8)                   |
-- |                             | -> u8 (GatewayError tag or 255=ok)        |
-- |                             | Process a request through the gateway.    |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_set_rate_limit    | (slot: c_int, strategy: u8,               |
-- |                             |  max_requests: u32) -> u8 (0=ok)          |
-- |                             | Set rate limiting for the gateway.        |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_check_rate_limit  | (slot: c_int) -> u8 (1=allowed, 0=deny)  |
-- |                             | Check if a request is within rate limit.  |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_request_count     | (slot: c_int) -> u64                      |
-- |                             | Returns total requests handled.           |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_shutdown          | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Draining state.            |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_cleanup           | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Draining -> Stopped.          |
-- +-----------------------------+-------------------------------------------+
-- | apiserver_can_transition    | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks gateway state           |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
