-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LoadbalancerABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/loadbalancer.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching LoadbalancerABI.Types exactly.

module LoadbalancerABI.Foreign

import LoadbalancerABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Loadbalancer context.
||| Created by loadbalancer_create*(), destroyed by loadbalancer_destroy*().
export
data LoadbalancerContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match loadbalancer_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | lb_abi_version                    | () -> u32                                   |
-- | lb_create                         | (algorithm: u8, protocol: u8, persistenc... |
-- | lb_destroy                        | (slot: c_int) -> void                       |
-- | lb_get_algorithm                  | (slot: c_int) -> u8                         |
-- | lb_get_protocol                   | (slot: c_int) -> u8                         |
-- | lb_get_persistence                | (slot: c_int) -> u8                         |
-- | lb_get_health_check_type          | (slot: c_int) -> u8                         |
-- | lb_get_backend_count              | (slot: c_int) -> u32                        |
-- | lb_get_healthy_count              | (slot: c_int) -> u32                        |
-- | lb_get_total_requests             | (slot: c_int) -> u32                        |
-- | lb_get_last_error                 | (slot: c_int) -> u8                         |
-- | lb_add_backend                    | (slot: c_int, weight: u32) -> u8            |
-- | lb_set_backend_state              | (slot: c_int, backend: u32, state: u8) -... |
-- | lb_get_backend_state              | (slot: c_int, backend: u32) -> u8           |
-- | lb_route_request                  | (slot: c_int) -> c_int                      |
-- | lb_set_algorithm                  | (slot: c_int, algorithm: u8) -> u8          |
-- +───────────────────────────────────+─────────────────────────────────────────────+
