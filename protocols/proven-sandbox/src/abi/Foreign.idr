-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SandboxABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/sandbox.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected sandbox pool
--   - Execution policy enforcement per sandbox
--   - Resource limit tracking (CPU, memory, disk, network, fds, processes)
--   - Syscall policy per sandbox
--   - Sandbox lifecycle state transitions
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SandboxABI.Types exactly.

module SandboxABI.Foreign

import SandboxABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a sandbox session.
||| Created by sandbox_create(), destroyed by sandbox_destroy().
export
data SandboxContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match sandbox_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16 functions)
---------------------------------------------------------------------------

-- +-------------------------------+-------------------------------------------+
-- | Function                      | Signature                                 |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_abi_version           | () -> u32                                 |
-- |                               | Returns ABI version (must equal           |
-- |                               | abiVersion).                              |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_create                | (policy: u8, syscall_policy: u8)          |
-- |                               |  -> c_int (slot)                          |
-- |                               | Creates sandbox with given policies.      |
-- |                               | Returns -1 on failure.                    |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_destroy               | (slot: c_int) -> void                     |
-- |                               | Releases a sandbox slot.                  |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_state                 | (slot: c_int) -> u8 (SandboxState tag)    |
-- |                               | Returns current sandbox state.            |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_start                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions Ready -> Running.             |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_suspend               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions Running -> Suspended.         |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_resume                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions Suspended -> Running.         |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_terminate             | (slot: c_int, reason: u8)                 |
-- |                               |  -> u8 (0=ok, 1=rejected)                 |
-- |                               | Transitions Running/Suspended ->          |
-- |                               | Terminated.                               |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_cleanup               | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Transitions Terminated -> Destroyed.      |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_set_limit             | (slot: c_int, limit_type: u8,             |
-- |                               |  value: u64) -> u8 (0=ok, 1=rejected)    |
-- |                               | Sets a resource limit on the sandbox.     |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_get_limit             | (slot: c_int, limit_type: u8) -> u64      |
-- |                               | Returns the current limit value (0 if     |
-- |                               | unset or invalid).                        |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_policy                | (slot: c_int) -> u8                       |
-- |                               | Returns the ExecutionPolicy tag.          |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_syscall_policy        | (slot: c_int) -> u8                       |
-- |                               | Returns the SyscallPolicy tag.            |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_exit_reason           | (slot: c_int) -> u8                       |
-- |                               | Returns the ExitReason tag (valid only    |
-- |                               | in Terminated state).                     |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_can_transition        | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                               | Stateless: checks sandbox state           |
-- |                               | transition validity.                      |
-- +-------------------------------+-------------------------------------------+
-- | sandbox_active_count          | () -> u32                                 |
-- |                               | Returns number of active sandbox slots.   |
-- +-------------------------------+-------------------------------------------+
