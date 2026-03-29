-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- HttpdABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/httpd.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching HttpdABI.Types exactly.

module HttpdABI.Foreign

import HttpdABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Httpd context.
||| Created by httpd_create*(), destroyed by httpd_destroy*().
export
data HttpdContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match httpd_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (17 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | http_abi_version                  | () -> u32                                   |
-- | http_create_context               | () -> c_int                                 |
-- | http_destroy_context              | (slot: c_int) -> void                       |
-- | http_parse_request                | (slot: c_int, data: ptr, len: u32) -> u8    |
-- | http_get_method                   | (slot: c_int) -> u8                         |
-- | http_get_path                     | (slot: c_int, buf: ptr, len: u32) -> u32    |
-- | http_get_header                   | (slot: c_int, key: ptr, klen: u32, buf: ... |
-- | http_get_body                     | (slot: c_int, buf: ptr, len: u32) -> u32    |
-- | http_set_status                   | (slot: c_int, status_tag: u8) -> u8         |
-- | http_set_header                   | (slot: c_int, key: ptr, klen: u32, val: ... |
-- | http_set_body                     | (slot: c_int, data: ptr, len: u32) -> u8    |
-- | http_send_response                | (slot: c_int) -> u8                         |
-- | http_keep_alive_check             | (slot: c_int) -> u8                         |
-- | http_get_phase                    | (slot: c_int) -> u8                         |
-- | http_get_version                  | (slot: c_int) -> u8                         |
-- | http_reset_context                | (slot: c_int) -> u8                         |
-- | http_can_transition               | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
