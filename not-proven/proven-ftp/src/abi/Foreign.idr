-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FtpABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ftp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching FtpABI.Types exactly.

module FtpABI.Foreign

import FtpABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Ftp context.
||| Created by ftp_create*(), destroyed by ftp_destroy*().
export
data FtpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ftp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (27 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | ftp_abi_version                   | () -> u32                                   |
-- | ftp_create                        | () -> c_int                                 |
-- | ftp_destroy                       | (slot: c_int) -> void                       |
-- | ftp_state                         | (slot: c_int) -> u8                         |
-- | ftp_transfer_type                 | (slot: c_int) -> u8                         |
-- | ftp_data_mode                     | (slot: c_int) -> u8                         |
-- | ftp_transfer_state                | (slot: c_int) -> u8                         |
-- | ftp_bytes_transferred             | (slot: c_int) -> u64                        |
-- | ftp_file_count                    | (slot: c_int) -> u32                        |
-- | ftp_last_reply_code               | (slot: c_int) -> u16                        |
-- | ftp_cwd                           | (slot: c_int, buf: ptr, buf_len: u32) ->... |
-- | ftp_user                          | (slot: c_int, _: ptr, _: u32) -> u8         |
-- | ftp_pass                          | (slot: c_int, _: ptr, _: u32) -> u8         |
-- | ftp_quit                          | (slot: c_int) -> u8                         |
-- | ftp_cwd_cmd                       | (slot: c_int, path: ptr, path_len: u32) ... |
-- | ftp_cdup                          | (slot: c_int) -> u8                         |
-- | ftp_set_type                      | (slot: c_int, type_tag: u8) -> u8           |
-- | ftp_set_passive                   | (slot: c_int) -> u8                         |
-- | ftp_set_active                    | (slot: c_int, port: u16) -> u8              |
-- | ftp_begin_transfer                | (slot: c_int) -> u8                         |
-- | ftp_add_bytes                     | (slot: c_int, count: u64) -> u8             |
-- | ftp_complete_transfer             | (slot: c_int) -> u8                         |
-- | ftp_abort_transfer                | (slot: c_int) -> u8                         |
-- | ftp_begin_rename                  | (slot: c_int) -> u8                         |
-- | ftp_complete_rename               | (slot: c_int) -> u8                         |
-- | ftp_can_transfer                  | (state_tag: u8) -> u8                       |
-- | ftp_can_transition                | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
