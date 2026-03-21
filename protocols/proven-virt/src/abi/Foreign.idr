-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- VirtABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/virt.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected VM session pool
--   - VM lifecycle state machine with valid transition enforcement
--   - Disk, network, and boot device configuration per VM
--   - Resource allocation tracking (vCPUs, memory)
--   - Operation validation against current VM state
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching VirtABI.Types exactly.

module VirtABI.Foreign

import VirtABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a VM session.
||| Created by virt_create(), destroyed by virt_destroy().
export
data VirtContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match virt_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (18 functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | virt_abi_version            | () -> u32                                 |
-- |                             | Returns ABI version.                      |
-- +-----------------------------+-------------------------------------------+
-- | virt_create                 | (name_ptr: ptr, name_len: u32,            |
-- |                             |  vcpus: u16, memory_mb: u32,              |
-- |                             |  disk_fmt: u8, net_type: u8,              |
-- |                             |  boot_dev: u8) -> c_int (slot)            |
-- |                             | Creates VM. Returns -1 on failure.        |
-- +-----------------------------+-------------------------------------------+
-- | virt_destroy                | (slot: c_int) -> void                     |
-- |                             | Releases a VM slot.                       |
-- +-----------------------------+-------------------------------------------+
-- | virt_state                  | (slot: c_int) -> u8 (VMState tag)         |
-- |                             | Returns current VM state.                 |
-- +-----------------------------+-------------------------------------------+
-- | virt_start                  | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Stopped/Creating -> Running.  |
-- +-----------------------------+-------------------------------------------+
-- | virt_stop                   | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Running -> ShuttingDown ->    |
-- |                             | Stopped.                                  |
-- +-----------------------------+-------------------------------------------+
-- | virt_pause                  | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Running -> Paused.            |
-- +-----------------------------+-------------------------------------------+
-- | virt_resume                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Paused -> Running.            |
-- +-----------------------------+-------------------------------------------+
-- | virt_suspend                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Running -> Suspended.         |
-- +-----------------------------+-------------------------------------------+
-- | virt_restart                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Running -> Running (restart). |
-- +-----------------------------+-------------------------------------------+
-- | virt_migrate_begin          | (slot: c_int, dest_ptr: ptr,              |
-- |                             |  dest_len: u32) -> u8 (0=ok, 1=rejected) |
-- |                             | Transitions Running -> Migrating.         |
-- +-----------------------------+-------------------------------------------+
-- | virt_migrate_complete       | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Migrating -> Running.         |
-- +-----------------------------+-------------------------------------------+
-- | virt_delete                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Deletes VM from Stopped/Crashed.          |
-- +-----------------------------+-------------------------------------------+
-- | virt_can_transition         | (from: u8, op: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks if operation is valid   |
-- |                             | from the given VM state.                  |
-- +-----------------------------+-------------------------------------------+
-- | virt_vcpu_count             | (slot: c_int) -> u16                      |
-- |                             | Returns vCPU count for VM.                |
-- +-----------------------------+-------------------------------------------+
-- | virt_memory_mb              | (slot: c_int) -> u32                      |
-- |                             | Returns memory (MB) for VM.               |
-- +-----------------------------+-------------------------------------------+
-- | virt_disk_format            | (slot: c_int) -> u8 (DiskFormat tag)      |
-- |                             | Returns disk format for VM.               |
-- +-----------------------------+-------------------------------------------+
-- | virt_session_count          | () -> u32                                 |
-- |                             | Returns number of active VM sessions.     |
-- +-----------------------------+-------------------------------------------+
