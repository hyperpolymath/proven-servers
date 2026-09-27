-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- BackupABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/backup.zig) must provide.
--
-- The Zig FFI manages in-memory job metadata and lifecycle state only. It has
-- no backup-data backend; backup_verify rejects and moves Running jobs to
-- Failed rather than claiming content was verified.
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching BackupABI.Types exactly.

module BackupABI.Foreign

import BackupABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a backup server context.
||| Created by backup_create(), destroyed by backup_destroy().
export
data BackupContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match backup_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (14 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | backup_abi_version          | () -> u32                                 |
-- |                             | Returns ABI version.                      |
-- +-----------------------------+-------------------------------------------+
-- | backup_create               | (backup_type: u8, schedule: u8,           |
-- |                             |  compression: u8, encryption: u8)         |
-- |                             | -> c_int (slot)                           |
-- |                             | Creates backup job in Idle state.         |
-- |                             | Returns -1 on failure.                    |
-- +-----------------------------+-------------------------------------------+
-- | backup_destroy              | (slot: c_int) -> void                     |
-- |                             | Releases a backup job slot.               |
-- +-----------------------------+-------------------------------------------+
-- | backup_state                | (slot: c_int) -> u8 (BackupState tag)     |
-- |                             | Returns current job state.                |
-- +-----------------------------+-------------------------------------------+
-- | backup_start                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Idle -> Running.              |
-- +-----------------------------+-------------------------------------------+
-- | backup_verify               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Fails closed without a data verifier;      |
-- |                             | transitions Running -> Failed and returns 1.|
-- +-----------------------------+-------------------------------------------+
-- | backup_complete             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Requires Verifying; unreachable until a real verifier exists.        |
-- +-----------------------------+-------------------------------------------+
-- | backup_fail                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Running/Verifying -> Failed.  |
-- +-----------------------------+-------------------------------------------+
-- | backup_cancel               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Running -> Cancelled.         |
-- +-----------------------------+-------------------------------------------+
-- | backup_set_retention        | (slot: c_int, policy: u8)                 |
-- |                             | -> u8 (0=ok, 1=rejected)                  |
-- |                             | Set retention policy for the job.         |
-- +-----------------------------+-------------------------------------------+
-- | backup_retention            | (slot: c_int) -> u8 (RetentionPolicy tag) |
-- |                             | Returns current retention policy tag.     |
-- +-----------------------------+-------------------------------------------+
-- | backup_bytes_processed      | (slot: c_int) -> u64                      |
-- |                             | Returns bytes processed so far.           |
-- +-----------------------------+-------------------------------------------+
-- | backup_reset                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Complete/Failed/Cancelled     |
-- |                             | -> Idle.                                  |
-- +-----------------------------+-------------------------------------------+
-- | backup_can_transition       | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks job state               |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
