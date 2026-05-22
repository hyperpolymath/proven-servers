-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LoadbalancerABI.Foreign: Foreign function declarations for the load
-- balancer C bridge.
--
-- This module defines the Idris2 side of the FFI contract.  It declares:
--
--   1. Opaque handle type (BackendPool) that cannot be inspected or
--      forged from Idris2 code -- it exists only as a slot index managed
--      by the Zig implementation.
--
--   2. The ABI version constant, which must match the value returned by
--      the Zig function lb_abi_version().
--
--   3. Documentation of every FFI function signature that the Zig
--      implementation must provide.

module LoadbalancerABI.Foreign

import Loadbalancer.Types
import LoadbalancerABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a load balancer backend pool instance.
export
data BackendPool : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version for compatibility checking.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +--------------------------------------------------------------------------+
-- | Function                      | Signature                                |
-- +-------------------------------+------------------------------------------+
-- | lb_abi_version                | () -> u32                                |
-- +-------------------------------+------------------------------------------+
-- | lb_create                     | (algorithm: u8, protocol: u8,            |
-- |                               |  persistence: u8, hc_type: u8) -> c_int  |
-- +-------------------------------+------------------------------------------+
-- | lb_destroy                    | (slot: c_int) -> void                    |
-- +-------------------------------+------------------------------------------+
-- | lb_get_algorithm              | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lb_get_protocol               | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lb_get_persistence            | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lb_get_health_check_type      | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lb_get_backend_count          | (slot: c_int) -> u32                     |
-- +-------------------------------+------------------------------------------+
-- | lb_get_healthy_count          | (slot: c_int) -> u32                     |
-- +-------------------------------+------------------------------------------+
-- | lb_get_total_requests         | (slot: c_int) -> u32                     |
-- +-------------------------------+------------------------------------------+
-- | lb_get_last_error             | (slot: c_int) -> u8                      |
-- +-------------------------------+------------------------------------------+
-- | lb_add_backend                | (slot: c_int, weight: u32) -> u8         |
-- +-------------------------------+------------------------------------------+
-- | lb_set_backend_state          | (slot: c_int, backend: u32,              |
-- |                               |  state: u8) -> u8                        |
-- +-------------------------------+------------------------------------------+
-- | lb_get_backend_state          | (slot: c_int, backend: u32) -> u8        |
-- +-------------------------------+------------------------------------------+
-- | lb_route_request              | (slot: c_int) -> c_int                   |
-- +-------------------------------+------------------------------------------+
-- | lb_set_algorithm              | (slot: c_int, algorithm: u8) -> u8       |
-- +-------------------------------+------------------------------------------+
