-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CoapABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/coap.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching CoapABI.Types exactly.

module CoapABI.Foreign

import CoapABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Coap context.
||| Created by coap_create*(), destroyed by coap_destroy*().
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
-- FFI function contract (10 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | coap_abi_version                  | () -> u32                                   |
-- | coap_create                       | (port: u16) -> c_int                        |
-- | coap_destroy                      | (slot: c_int) -> void                       |
-- | coap_state                        | (slot: c_int) -> u8                         |
-- | coap_can_serve                    | (slot: c_int) -> u8                         |
-- | coap_resource_count               | (slot: c_int) -> u32                        |
-- | coap_observer_count               | (slot: c_int) -> u32                        |
-- | coap_shutdown                     | (slot: c_int) -> u8                         |
-- | coap_cleanup                      | (slot: c_int) -> u8                         |
-- | coap_can_transition               | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
