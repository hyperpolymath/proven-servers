-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- ContainerABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/container.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot container instance pool
--   - Lifecycle state machine with valid transition enforcement
--   - Per-container network mode, restart policy, health status
--   - Operation dispatch with state-dependent validation
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching ContainerABI.Types exactly.

module ContainerABI.Foreign

import ContainerABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a container instance.
||| Created by container_create(), destroyed by container_destroy().
export
data ContainerContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match container_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-------------------------------+-------------------------------------------+
-- | Function                      | Signature                                 |
-- +-------------------------------+-------------------------------------------+
-- | container_abi_version         | () -> u32                                 |
-- |                               | Returns ABI version.                      |
-- +-------------------------------+-------------------------------------------+
-- | container_create              | (network: u8, restart: u8)                |
-- |                               |   -> c_int (slot)                         |
-- |                               | Creates a container in Creating state.    |
-- |                               | Returns -1 on failure.                    |
-- +-------------------------------+-------------------------------------------+
-- | container_destroy             | (slot: c_int) -> void                     |
-- |                               | Releases a container slot.                |
-- +-------------------------------+-------------------------------------------+
-- | container_state               | (slot: c_int) -> u8 (ContainerState tag)  |
-- |                               | Returns the current lifecycle state.      |
-- +-------------------------------+-------------------------------------------+
-- | container_apply_op            | (slot: c_int, op: u8) -> u8               |
-- |                               | Apply an operation. Returns 0 on success, |
-- |                               | 1 on invalid state transition.            |
-- +-------------------------------+-------------------------------------------+
-- | container_network_mode        | (slot: c_int) -> u8 (NetworkMode tag)     |
-- |                               | Returns the network mode.                 |
-- +-------------------------------+-------------------------------------------+
-- | container_restart_policy      | (slot: c_int) -> u8 (RestartPolicy tag)   |
-- |                               | Returns the restart policy.               |
-- +-------------------------------+-------------------------------------------+
-- | container_health_status       | (slot: c_int) -> u8 (HealthStatus tag)    |
-- |                               | Returns the current health status.        |
-- +-------------------------------+-------------------------------------------+
-- | container_set_health          | (slot: c_int, status: u8) -> u8           |
-- |                               | Set health status. Returns 0 on success.  |
-- +-------------------------------+-------------------------------------------+
-- | container_restart_count       | (slot: c_int) -> u32                      |
-- |                               | Returns the number of restarts.           |
-- +-------------------------------+-------------------------------------------+
-- | container_is_running          | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                               | Whether the container is in Running state.|
-- +-------------------------------+-------------------------------------------+
-- | container_can_transition      | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                               | Stateless: checks if a state transition   |
-- |                               | is valid.                                 |
-- +-------------------------------+-------------------------------------------+
