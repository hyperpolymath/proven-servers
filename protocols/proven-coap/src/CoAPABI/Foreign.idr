-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CoAPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/coap.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected endpoint pool
--   - Resource registration per endpoint (max 32 resources)
--   - Observation tracking per resource (RFC 7641)
--   - Message ID and token generation
--   - Retransmission tracking for CON messages
--   - Block-wise transfer state (RFC 7959)
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching CoAPABI.Types exactly.

module CoAPABI.Foreign

import CoAPABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a CoAP server endpoint.
||| Created by coap_create(), destroyed by coap_destroy().
export
data CoapContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match coap_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | coap_abi_version            | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | coap_create                 | (port: u16) -> c_int (slot)               |
-- |                             | Creates endpoint in Bound state.          |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | coap_destroy                | (slot: c_int) -> void                     |
-- |                             | Releases an endpoint slot.                |
-- +-----------------------------+-------------------------------------------+
-- | coap_state                  | (slot: c_int) -> u8 (SessionState tag)    |
-- |                             | Returns current endpoint state.           |
-- +-----------------------------+-------------------------------------------+
-- | coap_register_resource      | (slot: c_int,                             |
-- |                             |  path_ptr: ptr, path_len: u32,            |
-- |                             |  methods: u8) -> u8 (0=ok, 1=rejected)   |
-- |                             | Register a resource at a URI path.        |
-- |                             | methods is a bitmask: bit0=GET,           |
-- |                             | bit1=POST, bit2=PUT, bit3=DELETE.         |
-- |                             | Transitions Bound -> Serving.             |
-- +-----------------------------+-------------------------------------------+
-- | coap_unregister_resource    | (slot: c_int,                             |
-- |                             |  path_ptr: ptr, path_len: u32)            |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Unregister a resource. May transition     |
-- |                             | Serving -> Bound if last resource.        |
-- +-----------------------------+-------------------------------------------+
-- | coap_resource_count         | (slot: c_int) -> u32                      |
-- |                             | Returns number of registered resources.   |
-- +-----------------------------+-------------------------------------------+
-- | coap_handle_request         | (slot: c_int,                             |
-- |                             |  method: u8, msg_type: u8,                |
-- |                             |  msg_id: u16, token_len: u8,              |
-- |                             |  path_ptr: ptr, path_len: u32,            |
-- |                             |  payload_ptr: ptr, payload_len: u32)      |
-- |                             | -> u8 (response code class tag)           |
-- |                             | Process an incoming request. Returns      |
-- |                             | ResponseClass tag.                        |
-- +-----------------------------+-------------------------------------------+
-- | coap_add_observer           | (slot: c_int,                             |
-- |                             |  path_ptr: ptr, path_len: u32,            |
-- |                             |  token: u64) -> u8 (0=ok, 1=rejected)    |
-- |                             | Add an observer for a resource.           |
-- |                             | Transitions Serving -> Observing.         |
-- +-----------------------------+-------------------------------------------+
-- | coap_remove_observer        | (slot: c_int,                             |
-- |                             |  path_ptr: ptr, path_len: u32,            |
-- |                             |  token: u64) -> u8 (0=ok, 1=rejected)    |
-- |                             | Remove an observer. May transition        |
-- |                             | Observing -> Serving if last observer.    |
-- +-----------------------------+-------------------------------------------+
-- | coap_observer_count         | (slot: c_int) -> u32                      |
-- |                             | Returns total active observers.           |
-- +-----------------------------+-------------------------------------------+
-- | coap_notify_observers       | (slot: c_int,                             |
-- |                             |  path_ptr: ptr, path_len: u32)            |
-- |                             | -> u32 (number notified)                  |
-- |                             | Send notifications to all observers of    |
-- |                             | a resource.                               |
-- +-----------------------------+-------------------------------------------+
-- | coap_shutdown               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Shutdown state.            |
-- +-----------------------------+-------------------------------------------+
-- | coap_cleanup                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Shutdown -> Idle.             |
-- +-----------------------------+-------------------------------------------+
-- | coap_can_serve              | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                             | Whether the endpoint can serve requests.  |
-- +-----------------------------+-------------------------------------------+
-- | coap_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks endpoint state          |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
