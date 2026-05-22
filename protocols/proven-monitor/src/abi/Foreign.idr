-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- MonitorABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/monitor.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Check registration per session (max 32 checks)
--   - Alert channel configuration per session
--   - Check execution state tracking
--   - Severity escalation logic
--   - Lifecycle state machine transitions

module MonitorABI.Foreign

import MonitorABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a monitoring session.
||| Created by monitor_create(), destroyed by monitor_destroy().
export
data MonitorContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match monitor_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | monitor_abi_version         | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | monitor_create              | (name_ptr: ptr, name_len: u32,            |
-- |                             |  interval_ms: u32) -> c_int (slot)        |
-- |                             | Creates session in Configured state.      |
-- +-----------------------------+-------------------------------------------+
-- | monitor_destroy             | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | monitor_state               | (slot: c_int) -> u8 (MonitorState tag)    |
-- +-----------------------------+-------------------------------------------+
-- | monitor_add_check           | (slot: c_int, check_type: u8,             |
-- |                             |  target_ptr: ptr, target_len: u32,        |
-- |                             |  severity: u8) -> u8 (0=ok, 1=rejected)   |
-- +-----------------------------+-------------------------------------------+
-- | monitor_remove_check        | (slot: c_int, index: u32)                 |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | monitor_check_count         | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | monitor_start               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Configured -> Running.                    |
-- +-----------------------------+-------------------------------------------+
-- | monitor_pause               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Running -> Paused.                        |
-- +-----------------------------+-------------------------------------------+
-- | monitor_resume              | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Paused -> Running.                        |
-- +-----------------------------+-------------------------------------------+
-- | monitor_run_check           | (slot: c_int, index: u32)                 |
-- |                             |  -> u8 (CheckState tag)                   |
-- +-----------------------------+-------------------------------------------+
-- | monitor_check_status        | (slot: c_int, index: u32)                 |
-- |                             |  -> u8 (Status tag)                       |
-- +-----------------------------+-------------------------------------------+
-- | monitor_fire_alert          | (slot: c_int, channel: u8,                |
-- |                             |  severity: u8, msg_ptr: ptr,              |
-- |                             |  msg_len: u32) -> u8 (0=ok, 1=rejected)   |
-- +-----------------------------+-------------------------------------------+
-- | monitor_shutdown            | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Any non-Idle -> Shutdown.                 |
-- +-----------------------------+-------------------------------------------+
-- | monitor_cleanup             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Shutdown -> Idle.                         |
-- +-----------------------------+-------------------------------------------+
-- | monitor_can_transition      | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
