-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AppserverABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/appserver.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected application server pool
--   - Handler registration per server (max 64 handlers)
--   - Per-handler request type and deploy strategy
--   - Health check probe responses
--   - Server lifecycle state machine
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching AppserverABI.Types exactly.

module AppserverABI.Foreign

import AppserverABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an application server context.
||| Created by appserver_create(), destroyed by appserver_destroy().
export
data AppserverContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match appserver_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | appserver_abi_version       | () -> u32                                 |
-- |                             | Returns ABI version.                      |
-- +-----------------------------+-------------------------------------------+
-- | appserver_create            | (port: u16, strategy: u8) -> c_int        |
-- |                             | Creates server in Initializing state.     |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | appserver_destroy           | (slot: c_int) -> void                     |
-- |                             | Releases a server slot.                   |
-- +-----------------------------+-------------------------------------------+
-- | appserver_state             | (slot: c_int) -> u8 (LifecycleState tag)  |
-- |                             | Returns current server state.             |
-- +-----------------------------+-------------------------------------------+
-- | appserver_start             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Initializing -> Starting.     |
-- +-----------------------------+-------------------------------------------+
-- | appserver_ready             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Starting -> Running.          |
-- +-----------------------------+-------------------------------------------+
-- | appserver_register_handler  | (slot: c_int,                             |
-- |                             |  path_ptr: ptr, path_len: u32,            |
-- |                             |  req_type: u8) -> u8 (0=ok, 1=rejected)  |
-- |                             | Register a request handler.               |
-- +-----------------------------+-------------------------------------------+
-- | appserver_handler_count     | (slot: c_int) -> u32                      |
-- |                             | Returns number of registered handlers.    |
-- +-----------------------------+-------------------------------------------+
-- | appserver_handle_request    | (slot: c_int,                             |
-- |                             |  path_ptr: ptr, path_len: u32,            |
-- |                             |  req_type: u8) -> u8 (ErrorCategory tag   |
-- |                             |  or 255=ok)                               |
-- +-----------------------------+-------------------------------------------+
-- | appserver_health_check      | (slot: c_int, probe: u8) -> u8 (1/0)     |
-- |                             | Returns health check result for probe.    |
-- +-----------------------------+-------------------------------------------+
-- | appserver_drain             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Running -> Draining.          |
-- +-----------------------------+-------------------------------------------+
-- | appserver_stop              | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Draining -> Stopping.         |
-- +-----------------------------+-------------------------------------------+
-- | appserver_cleanup           | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Stopping -> Stopped.          |
-- +-----------------------------+-------------------------------------------+
-- | appserver_can_transition    | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks server state            |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
