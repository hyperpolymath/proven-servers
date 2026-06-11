-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- SyslogABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/syslog.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected syslog collector pool
--   - Message ingestion with facility/severity tracking
--   - Transport protocol management
--   - Priority calculation (facility * 8 + severity)
--   - Message counters and filtering by severity
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SyslogABI.Types exactly.

module SyslogABI.Foreign

import SyslogABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a syslog collector context.
||| Created by syslog_create(), destroyed by syslog_destroy().
export
data SyslogContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match syslog_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | syslog_abi_version          | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | syslog_create               | (transport: u8) -> c_int                  |
-- |                             | Creates collector with given transport.   |
-- |                             | Returns slot (0-63) or -1 on failure.     |
-- +-----------------------------+-------------------------------------------+
-- | syslog_destroy              | (slot: c_int) -> void                     |
-- |                             | Releases a collector slot.                |
-- +-----------------------------+-------------------------------------------+
-- | syslog_get_transport        | (slot: c_int) -> u8 (Transport tag)       |
-- |                             | Returns transport protocol tag.           |
-- +-----------------------------+-------------------------------------------+
-- | syslog_set_transport        | (slot: c_int, t: u8) -> u8                |
-- |                             | Sets transport. Returns 0=ok, 1=fail.    |
-- +-----------------------------+-------------------------------------------+
-- | syslog_ingest               | (slot: c_int, fac: u8, sev: u8) -> u8    |
-- |                             | Ingests a message with given facility and |
-- |                             | severity. Returns 0=ok or error tag.      |
-- +-----------------------------+-------------------------------------------+
-- | syslog_get_message_count    | (slot: c_int) -> u32                      |
-- |                             | Returns total messages ingested.          |
-- +-----------------------------+-------------------------------------------+
-- | syslog_get_last_facility    | (slot: c_int) -> u8 (Facility tag)        |
-- |                             | Returns last facility tag (255=none).     |
-- +-----------------------------+-------------------------------------------+
-- | syslog_get_last_severity    | (slot: c_int) -> u8 (Severity tag)        |
-- |                             | Returns last severity tag (255=none).     |
-- +-----------------------------+-------------------------------------------+
-- | syslog_get_last_priority    | (slot: c_int) -> u32                      |
-- |                             | Returns last computed priority value      |
-- |                             | (facility * 8 + severity).                |
-- +-----------------------------+-------------------------------------------+
-- | syslog_set_min_severity     | (slot: c_int, sev: u8) -> u8              |
-- |                             | Sets minimum severity filter.             |
-- |                             | Returns 0=ok, 1=fail.                     |
-- +-----------------------------+-------------------------------------------+
-- | syslog_get_min_severity     | (slot: c_int) -> u8 (Severity tag)        |
-- |                             | Returns minimum severity filter tag.      |
-- +-----------------------------+-------------------------------------------+
-- | syslog_get_dropped_count    | (slot: c_int) -> u32                      |
-- |                             | Returns count of messages dropped by      |
-- |                             | severity filter.                          |
-- +-----------------------------+-------------------------------------------+
-- | syslog_compute_priority     | (fac: u8, sev: u8) -> u32                 |
-- |                             | Stateless: computes priority value.       |
-- |                             | Returns 0xFFFFFFFF for invalid inputs.    |
-- +-----------------------------+-------------------------------------------+
