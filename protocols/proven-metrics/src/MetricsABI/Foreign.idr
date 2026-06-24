-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- MetricsABI.Foreign: Foreign function declarations for the Metrics C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/metrics.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected collector session pool
--   - Per-session scrape target tracking (max 32 targets)
--   - Per-session metric family registry (max 64 families)
--   - Per-session alert rule evaluation (max 16 rules)
--   - Scrape lifecycle and result tracking
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching MetricsABI.Types exactly.

module MetricsABI.Foreign

import MetricsABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a metrics collector session.
||| Created by metrics_create(), destroyed by metrics_destroy().
export
data MetricsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match metrics_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (18 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | metrics_abi_version         | () -> u32                                 |
-- +-----------------------------+-------------------------------------------+
-- | metrics_create              | (interval_ms: u32) -> c_int (slot)        |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | metrics_destroy             | (slot: c_int) -> void                     |
-- +-----------------------------+-------------------------------------------+
-- | metrics_state               | (slot: c_int) -> u8 (CollectorState tag)  |
-- +-----------------------------+-------------------------------------------+
-- | metrics_add_target          | (slot: c_int, url_ptr: ptr,               |
-- |                             |  url_len: u32) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Idle -> Configured.           |
-- +-----------------------------+-------------------------------------------+
-- | metrics_remove_target       | (slot: c_int, url_ptr: ptr,               |
-- |                             |  url_len: u32) -> u8 (0=ok, 1=rejected)   |
-- +-----------------------------+-------------------------------------------+
-- | metrics_target_count        | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | metrics_start_scraping      | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Configured -> Scraping.       |
-- +-----------------------------+-------------------------------------------+
-- | metrics_record_scrape       | (slot: c_int, target_idx: u32,            |
-- |                             |  result: u8) -> u8 (0=ok, 1=rejected)     |
-- +-----------------------------+-------------------------------------------+
-- | metrics_register_metric     | (slot: c_int, name_ptr: ptr,              |
-- |                             |  name_len: u32, mtype: u8)                |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | metrics_metric_count        | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | metrics_add_alert           | (slot: c_int, name_ptr: ptr,              |
-- |                             |  name_len: u32) -> u8 (0=ok, 1=rejected)  |
-- +-----------------------------+-------------------------------------------+
-- | metrics_set_alert_state     | (slot: c_int, alert_idx: u32,             |
-- |                             |  state: u8) -> u8 (0=ok, 1=rejected)      |
-- +-----------------------------+-------------------------------------------+
-- | metrics_alert_count         | (slot: c_int) -> u32                      |
-- +-----------------------------+-------------------------------------------+
-- | metrics_start_alerting      | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Scraping -> Alerting.         |
-- +-----------------------------+-------------------------------------------+
-- | metrics_stop                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Stopping.                  |
-- +-----------------------------+-------------------------------------------+
-- | metrics_cleanup             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Stopping -> Idle.             |
-- +-----------------------------+-------------------------------------------+
-- | metrics_can_transition      | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- +-----------------------------+-------------------------------------------+
