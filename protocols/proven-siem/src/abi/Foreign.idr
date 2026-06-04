-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- SIEMABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/siem.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected SIEM engine pool
--   - Event ingestion with severity and category classification
--   - Correlation rule registration and matching
--   - Alert lifecycle management (New -> Acknowledged -> ... -> Resolved)
--   - Event and alert counting
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SIEMABI.Types exactly.

module SIEMABI.Foreign

import SIEMABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a SIEM engine session.
||| Created by siem_create(), destroyed by siem_destroy().
export
data SiemContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match siem_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (18 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-------------------------------------------+
-- | Function                      | Signature                                 |
-- +-------------------------------+-------------------------------------------+
-- | siem_abi_version              | () -> u32                                 |
-- +-------------------------------+-------------------------------------------+
-- | siem_create                   | (name_ptr: ptr, name_len: u32)            |
-- |                               |  -> c_int (slot)                          |
-- |                               | Creates SIEM engine instance.             |
-- |                               | Returns -1 on failure.                    |
-- +-------------------------------+-------------------------------------------+
-- | siem_destroy                  | (slot: c_int) -> void                     |
-- +-------------------------------+-------------------------------------------+
-- | siem_state                    | (slot: c_int) -> u8 (EngineState tag)     |
-- +-------------------------------+-------------------------------------------+
-- | siem_ingest_event             | (slot: c_int, severity: u8,               |
-- |                               |  category: u8,                            |
-- |                               |  source_ptr: ptr, source_len: u32)       |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- +-------------------------------+-------------------------------------------+
-- | siem_event_count              | (slot: c_int) -> u32                      |
-- +-------------------------------+-------------------------------------------+
-- | siem_add_rule                 | (slot: c_int, rule_type: u8,              |
-- |                               |  threshold: u32,                          |
-- |                               |  category: u8)                            |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- +-------------------------------+-------------------------------------------+
-- | siem_rule_count               | (slot: c_int) -> u32                      |
-- +-------------------------------+-------------------------------------------+
-- | siem_correlate                 | (slot: c_int) -> u32                     |
-- |                               | Runs correlation, returns number of new  |
-- |                               | alerts generated.                         |
-- +-------------------------------+-------------------------------------------+
-- | siem_alert_count              | (slot: c_int) -> u32                      |
-- +-------------------------------+-------------------------------------------+
-- | siem_alert_state              | (slot: c_int, alert_id: u32) -> u8       |
-- |                               | Returns AlertState tag for an alert.     |
-- +-------------------------------+-------------------------------------------+
-- | siem_alert_transition         | (slot: c_int, alert_id: u32,             |
-- |                               |  new_state: u8) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-------------------------------------------+
-- | siem_start                    | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions Idle -> Running.             |
-- +-------------------------------+-------------------------------------------+
-- | siem_pause                    | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions Running -> Paused.           |
-- +-------------------------------+-------------------------------------------+
-- | siem_resume                   | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions Paused -> Running.           |
-- +-------------------------------+-------------------------------------------+
-- | siem_disconnect               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- +-------------------------------+-------------------------------------------+
-- | siem_cleanup                  | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- +-------------------------------+-------------------------------------------+
-- | siem_can_transition           | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-------------------------------+-------------------------------------------+
