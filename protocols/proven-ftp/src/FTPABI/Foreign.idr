-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FTPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module FTPABI.Foreign

import FTP.Session
import FTP.Transfer
import FTP.Reply
import FTPABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an FTP session.
||| Created by ftp_create(), destroyed by ftp_destroy().
export
data FtpHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ftp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function               | Signature                                    |
-- +------------------------+----------------------------------------------+
-- | ftp_abi_version        | () -> Bits32                                 |
-- +------------------------+----------------------------------------------+
-- | ftp_create             | () -> c_int (slot, -1 on failure)            |
-- |                        | Creates session in Connected state.          |
-- +------------------------+----------------------------------------------+
-- | ftp_destroy            | (slot: c_int) -> ()                          |
-- +------------------------+----------------------------------------------+
-- | ftp_state              | (slot: c_int) -> u8 (SessionState tag)       |
-- +------------------------+----------------------------------------------+
-- | ftp_transfer_type      | (slot: c_int) -> u8 (TransferType tag)       |
-- +------------------------+----------------------------------------------+
-- | ftp_data_mode          | (slot: c_int) -> u8 (DataModeTag, 255=none)  |
-- +------------------------+----------------------------------------------+
-- | ftp_transfer_state     | (slot: c_int) -> u8 (TransferStateTag)       |
-- +------------------------+----------------------------------------------+
-- | ftp_bytes_transferred  | (slot: c_int) -> u64                         |
-- +------------------------+----------------------------------------------+
-- | ftp_file_count         | (slot: c_int) -> u32                         |
-- +------------------------+----------------------------------------------+
-- | ftp_cwd               | (slot: c_int, buf: *u8, len: u32) -> u32     |
-- |                        | Writes CWD into buf, returns bytes written.  |
-- +------------------------+----------------------------------------------+
-- | ftp_user               | (slot: c_int, name: *const u8, len: u32)     |
-- |                        | -> u8 (0=ok, 1=rejected)                     |
-- |                        | USER command: Connected -> UserOk.           |
-- +------------------------+----------------------------------------------+
-- | ftp_pass               | (slot: c_int, pw: *const u8, len: u32)       |
-- |                        | -> u8 (0=ok, 1=rejected)                     |
-- |                        | PASS command: UserOk -> Authenticated.       |
-- +------------------------+----------------------------------------------+
-- | ftp_quit               | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | QUIT command: any non-Quit -> Quit.          |
-- +------------------------+----------------------------------------------+
-- | ftp_cwd_cmd            | (slot: c_int, path: *const u8, len: u32)     |
-- |                        | -> u8 (0=ok, 1=rejected, 2=bad path)         |
-- |                        | CWD: requires Authenticated.                 |
-- +------------------------+----------------------------------------------+
-- | ftp_cdup               | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | CDUP: requires Authenticated.                |
-- +------------------------+----------------------------------------------+
-- | ftp_set_type           | (slot: c_int, type_tag: u8) -> u8            |
-- |                        | TYPE: set transfer type (0=ASCII, 1=Binary). |
-- +------------------------+----------------------------------------------+
-- | ftp_set_passive        | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | PASV: enter passive mode.                    |
-- +------------------------+----------------------------------------------+
-- | ftp_set_active         | (slot: c_int, port: u16) -> u8               |
-- |                        | PORT: enter active mode.                     |
-- +------------------------+----------------------------------------------+
-- | ftp_begin_transfer     | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | Start data transfer (RETR/STOR/LIST/NLST).   |
-- |                        | Requires Authenticated + data mode set.      |
-- +------------------------+----------------------------------------------+
-- | ftp_add_bytes          | (slot: c_int, count: u64) -> u8              |
-- |                        | Record bytes transferred.                    |
-- +------------------------+----------------------------------------------+
-- | ftp_complete_transfer  | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | Complete the current transfer.               |
-- +------------------------+----------------------------------------------+
-- | ftp_abort_transfer     | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | Abort the current transfer.                  |
-- +------------------------+----------------------------------------------+
-- | ftp_begin_rename       | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | RNFR: Authenticated -> Renaming.             |
-- +------------------------+----------------------------------------------+
-- | ftp_complete_rename    | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | RNTO: Renaming -> Authenticated.             |
-- +------------------------+----------------------------------------------+
-- | ftp_can_transfer       | (state: u8) -> u8 (1=yes, 0=no)              |
-- |                        | Stateless: whether state allows transfers.   |
-- +------------------------+----------------------------------------------+
-- | ftp_can_transition     | (from: u8, to: u8) -> u8 (1=yes, 0=no)       |
-- |                        | Stateless: whether transition is valid.      |
-- +------------------------+----------------------------------------------+
-- | ftp_last_reply_code    | (slot: c_int) -> u16                         |
-- |                        | Last reply code sent (0 if none).            |
-- +------------------------+----------------------------------------------+
