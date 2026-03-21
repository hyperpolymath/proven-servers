-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SshBastionABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ssh_bastion.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching SshBastionABI.Types exactly.

module SshBastionABI.Foreign

import SshBastionABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a SshBastion context.
||| Created by ssh_bastion_create*(), destroyed by ssh_bastion_destroy*().
export
data SshBastionContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ssh_bastion_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (26 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | ssh_bastion_abi_version           | () -> u32                                   |
-- | ssh_bastion_create                | (kex_method: u8, auth_method: u8) -> c_int  |
-- | ssh_bastion_destroy               | (slot: c_int) -> void                       |
-- | ssh_bastion_state                 | (slot: c_int) -> u8                         |
-- | ssh_bastion_kex_method            | (slot: c_int) -> u8                         |
-- | ssh_bastion_auth_method           | (slot: c_int) -> u8                         |
-- | ssh_bastion_can_transfer          | (slot: c_int) -> u8                         |
-- | ssh_bastion_disconnect_reason     | (slot: c_int) -> u8                         |
-- | ssh_bastion_auth_failures         | (slot: c_int) -> u8                         |
-- | ssh_bastion_complete_kex          | (slot: c_int) -> u8                         |
-- | ssh_bastion_authenticate          | (slot: c_int, user_len: u16) -> u8          |
-- | ssh_bastion_record_auth_failure   | (slot: c_int) -> u8                         |
-- | ssh_bastion_open_channel          | (slot: c_int, ch_type: u8) -> c_int         |
-- | ssh_bastion_confirm_channel       | (slot: c_int, ch_id: u8) -> u8              |
-- | ssh_bastion_close_channel         | (slot: c_int, ch_id: u8) -> u8              |
-- | ssh_bastion_channel_state         | (slot: c_int, ch_id: u8) -> u8              |
-- | ssh_bastion_channel_type          | (slot: c_int, ch_id: u8) -> u8              |
-- | ssh_bastion_channel_count         | (slot: c_int) -> u8                         |
-- | ssh_bastion_rekey                 | (slot: c_int) -> u8                         |
-- | ssh_bastion_disconnect            | (slot: c_int, reason: u8) -> u8             |
-- | ssh_bastion_can_transition        | (from: u8, to: u8) -> u8                    |
-- | ssh_bastion_audit_count           | (slot: c_int) -> u32                        |
-- | ssh_bastion_audit_entry           | (slot: c_int, entry_idx: u32) -> u8         |
-- | ssh_bastion_audit_entry_to        | (slot: c_int, entry_idx: u32) -> u8         |
-- | ssh_bastion_set_recording         | (slot: c_int, enabled: u8) -> u8            |
-- | ssh_bastion_is_recording          | (slot: c_int) -> u8                         |
-- +───────────────────────────────────+─────────────────────────────────────────────+
