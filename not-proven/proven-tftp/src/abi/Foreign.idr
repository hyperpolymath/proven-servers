-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- TFTPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/tftp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected transfer session pool
--   - Read/write transfer state machines per session
--   - Block number tracking and retry counting
--   - Error code propagation
--   - Transfer mode validation
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching TFTPABI.Types exactly.

module TFTPABI.Foreign

import TFTPABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a TFTP transfer session.
||| Created by tftp_create(), destroyed by tftp_destroy().
export
data TftpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match tftp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (15 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | tftp_abi_version            | () -> u32                                 |
-- |                             | Returns ABI version.                      |
-- +-----------------------------+-------------------------------------------+
-- | tftp_create                 | (filename_ptr: ptr, filename_len: u32,    |
-- |                             |  mode: u8, is_read: u8) -> c_int (slot)   |
-- |                             | Creates transfer session.                 |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | tftp_destroy                | (slot: c_int) -> void                     |
-- |                             | Releases a session slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | tftp_state                  | (slot: c_int) -> u8 (TransferState tag)   |
-- |                             | Returns current transfer state.           |
-- +-----------------------------+-------------------------------------------+
-- | tftp_recv_data              | (slot: c_int, block_num: u16,             |
-- |                             |  data_len: u32, is_last: u8)              |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Records receipt of a DATA block.          |
-- +-----------------------------+-------------------------------------------+
-- | tftp_recv_ack               | (slot: c_int, block_num: u16)             |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Records receipt of an ACK.                |
-- +-----------------------------+-------------------------------------------+
-- | tftp_recv_error             | (slot: c_int, error_code: u8)             |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Records receipt of an ERROR.              |
-- |                             | Transitions to InError.                   |
-- +-----------------------------+-------------------------------------------+
-- | tftp_retry                  | (slot: c_int) -> u8                       |
-- |                             | (0=retry ok, 1=exhausted, 2=rejected)     |
-- |                             | Increments retry counter.                 |
-- +-----------------------------+-------------------------------------------+
-- | tftp_current_block          | (slot: c_int) -> u16                      |
-- |                             | Returns current block number.             |
-- +-----------------------------+-------------------------------------------+
-- | tftp_bytes_transferred      | (slot: c_int) -> u32                      |
-- |                             | Returns total bytes transferred.          |
-- +-----------------------------+-------------------------------------------+
-- | tftp_last_error             | (slot: c_int) -> u8 (TFTPError tag or 255)|
-- |                             | Returns last error code (255 = no error). |
-- +-----------------------------+-------------------------------------------+
-- | tftp_mode                   | (slot: c_int) -> u8 (TransferMode tag)    |
-- |                             | Returns transfer mode.                    |
-- +-----------------------------+-------------------------------------------+
-- | tftp_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks transfer state          |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
-- | tftp_is_terminal            | (state: u8) -> u8 (1=yes, 0=no)          |
-- |                             | Stateless: checks if state is terminal.   |
-- +-----------------------------+-------------------------------------------+
-- | tftp_session_count          | () -> u32                                 |
-- |                             | Returns number of active sessions.        |
-- +-----------------------------+-------------------------------------------+
