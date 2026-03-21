-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- ConfigmgmtABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/configmgmt.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot resource management session pool
--   - Per-session resource type, desired state, and observed state tracking
--   - Drift detection and convergence action computation
--   - Apply mode (enforce/dry-run/audit) enforcement
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching ConfigmgmtABI.Types exactly.

module ConfigmgmtABI.Foreign

import ConfigmgmtABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a configmgmt resource session.
||| Created by configmgmt_create(), destroyed by configmgmt_destroy().
export
data ConfigmgmtContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match configmgmt_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-------------------------------+-------------------------------------------+
-- | Function                      | Signature                                 |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_abi_version        | () -> u32                                 |
-- |                               | Returns ABI version.                      |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_create             | (res_type: u8, desired: u8,               |
-- |                               |  mode: u8) -> c_int (slot)                |
-- |                               | Creates a resource session. Returns -1    |
-- |                               | on failure (no free slots/invalid tags).  |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_destroy            | (slot: c_int) -> void                     |
-- |                               | Releases a session slot.                  |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_resource_type      | (slot: c_int) -> u8 (ResourceType tag)    |
-- |                               | Returns the resource type.                |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_desired_state      | (slot: c_int) -> u8 (ResourceState tag)   |
-- |                               | Returns the desired state.                |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_observed_state     | (slot: c_int) -> u8 (ResourceState tag)   |
-- |                               | Returns the observed state.               |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_set_observed       | (slot: c_int, state: u8) -> u8            |
-- |                               | Set observed state. Returns 0 on success. |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_drift_status       | (slot: c_int) -> u8 (DriftStatus tag)     |
-- |                               | Compute drift by comparing desired vs     |
-- |                               | observed state.                           |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_action             | (slot: c_int) -> u8 (ChangeAction tag)    |
-- |                               | Compute the convergence action needed.    |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_apply_mode         | (slot: c_int) -> u8 (ApplyMode tag)       |
-- |                               | Returns the apply mode for this session.  |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_converge           | (slot: c_int) -> u8                       |
-- |                               | Execute convergence. Returns 0 on success,|
-- |                               | 1 if mode is DryRun/Audit, 2 if invalid.  |
-- +-------------------------------+-------------------------------------------+
-- | configmgmt_converge_count     | (slot: c_int) -> u32                      |
-- |                               | Returns the number of convergences done.  |
-- +-------------------------------+-------------------------------------------+
