-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CalDAVABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/caldav.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected server pool
--   - Calendar collection management (max 16 calendars per server)
--   - Calendar resource (event/todo) storage per collection (max 64)
--   - UID uniqueness enforcement per collection
--   - Supported component type filtering
--   - ETag tracking for conditional requests
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching CalDAVABI.Types exactly.

module CalDAVABI.Foreign

import CalDAVABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a CalDAV server instance.
||| Created by caldav_create(), destroyed by caldav_destroy().
export
data CaldavContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match caldav_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-----------------------------------------+
-- | Function                      | Signature                               |
-- +-------------------------------+-----------------------------------------+
-- | caldav_abi_version             | () -> u32                               |
-- +-------------------------------+-----------------------------------------+
-- | caldav_create                  | (port: u16) -> c_int (slot)             |
-- |                                | Creates server in Bound state.          |
-- +-------------------------------+-----------------------------------------+
-- | caldav_destroy                 | (slot: c_int) -> void                   |
-- +-------------------------------+-----------------------------------------+
-- | caldav_state                   | (slot: c_int) -> u8 (ServerState tag)   |
-- +-------------------------------+-----------------------------------------+
-- | caldav_create_calendar         | (slot: c_int,                           |
-- |                                |  path_ptr: ptr, path_len: u32,          |
-- |                                |  supported_components: u8)              |
-- |                                | -> u8 (0=ok, 1=rejected)               |
-- |                                | supported_components bitmask:           |
-- |                                | bit0=VEVENT, bit1=VTODO,               |
-- |                                | bit2=VJOURNAL, bit3=VFREEBUSY.         |
-- |                                | Transitions Bound -> Serving.           |
-- +-------------------------------+-----------------------------------------+
-- | caldav_delete_calendar         | (slot: c_int,                           |
-- |                                |  path_ptr: ptr, path_len: u32)          |
-- |                                | -> u8 (0=ok, 1=rejected)               |
-- +-------------------------------+-----------------------------------------+
-- | caldav_calendar_count          | (slot: c_int) -> u32                    |
-- +-------------------------------+-----------------------------------------+
-- | caldav_put_resource            | (slot: c_int,                           |
-- |                                |  cal_path_ptr: ptr, cal_path_len: u32,  |
-- |                                |  uid_ptr: ptr, uid_len: u32,            |
-- |                                |  component_type: u8,                    |
-- |                                |  etag: u32) -> u8                       |
-- |                                | (0=ok, 1=rejected)                      |
-- +-------------------------------+-----------------------------------------+
-- | caldav_delete_resource         | (slot: c_int,                           |
-- |                                |  cal_path_ptr: ptr, cal_path_len: u32,  |
-- |                                |  uid_ptr: ptr, uid_len: u32)            |
-- |                                | -> u8 (0=ok, 1=rejected)               |
-- +-------------------------------+-----------------------------------------+
-- | caldav_resource_count          | (slot: c_int,                           |
-- |                                |  cal_path_ptr: ptr, cal_path_len: u32)  |
-- |                                | -> u32                                  |
-- +-------------------------------+-----------------------------------------+
-- | caldav_get_etag                | (slot: c_int,                           |
-- |                                |  cal_path_ptr: ptr, cal_path_len: u32,  |
-- |                                |  uid_ptr: ptr, uid_len: u32)            |
-- |                                | -> u32 (0 = not found)                  |
-- +-------------------------------+-----------------------------------------+
-- | caldav_shutdown                | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | caldav_cleanup                 | (slot: c_int) -> u8 (0=ok, 1=rejected) |
-- +-------------------------------+-----------------------------------------+
-- | caldav_can_serve               | (slot: c_int) -> u8 (1=yes, 0=no)      |
-- +-------------------------------+-----------------------------------------+
-- | caldav_can_transition          | (from: u8, to: u8) -> u8               |
-- +-------------------------------+-----------------------------------------+
-- | caldav_total_resources         | (slot: c_int) -> u32                    |
-- |                                | Returns total resources across all      |
-- |                                | calendars.                              |
-- +-------------------------------+-----------------------------------------+
