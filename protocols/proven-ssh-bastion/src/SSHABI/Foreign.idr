-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- SSHABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ssh_bastion.zig) must provide.
-- This includes 18+ functions covering session lifecycle, state queries,
-- channel management, authentication, audit logging, and session recording.

module SSHABI.Foreign

import SSH.Session
import SSH.Auth
import SSH.Channel
import SSH.Transport
import SSHABI.Layout
import SSHABI.Transitions

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an SSH bastion session.
||| Created by ssh_bastion_create(), destroyed by ssh_bastion_destroy().
export
data SshContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match ssh_bastion_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-------------------------------------------------------------------------+
-- | Function                     | Signature                                |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_abi_version      | () -> u32                                |
-- |                              | Returns ABI version (currently 1).       |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_create           | (kex_method: u8, auth_method: u8)        |
-- |                              | -> c_int (slot index, or -1 on failure)  |
-- |                              | Creates session in Connected state.      |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_destroy          | (slot: c_int) -> void                    |
-- |                              | Releases a session slot.                 |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_state            | (slot: c_int) -> u8 (BastionState tag)   |
-- |                              | Returns current session state.           |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_kex_method       | (slot: c_int) -> u8 (KexMethod tag)      |
-- |                              | Returns configured kex method.           |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_auth_method      | (slot: c_int) -> u8 (AuthMethod tag)     |
-- |                              | Returns configured auth method.          |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_complete_kex     | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                              | Connected -> KeyExchanged.               |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_authenticate     | (slot: c_int, user_len: u16)             |
-- |                              | -> u8 (0=ok, 1=rejected)                 |
-- |                              | KeyExchanged -> Authenticated.           |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_open_channel     | (slot: c_int, ch_type: u8)               |
-- |                              | -> c_int (channel id, or -1)             |
-- |                              | Authenticated/Active -> ChannelOpen.     |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_confirm_channel  | (slot: c_int, ch_id: u8)                 |
-- |                              | -> u8 (0=ok, 1=rejected)                 |
-- |                              | ChannelOpen -> Active.                   |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_close_channel    | (slot: c_int, ch_id: u8)                 |
-- |                              | -> u8 (0=ok, 1=rejected)                 |
-- |                              | Closes a specific channel.               |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_channel_state    | (slot: c_int, ch_id: u8)                 |
-- |                              | -> u8 (ChannelState tag)                 |
-- |                              | Returns state of a specific channel.     |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_channel_type     | (slot: c_int, ch_id: u8)                 |
-- |                              | -> u8 (ChannelType tag)                  |
-- |                              | Returns type of a specific channel.      |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_channel_count    | (slot: c_int) -> u8                      |
-- |                              | Returns number of active channels.       |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_rekey            | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                              | Active -> Active (rekey).                |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_disconnect       | (slot: c_int, reason: u8)                |
-- |                              | -> u8 (0=ok, 1=rejected)                 |
-- |                              | Any non-Closed -> Closed.                |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_disconnect_reason| (slot: c_int) -> u8                      |
-- |                              | Returns the disconnect reason tag.       |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_can_transfer     | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                              | Whether data transfer is allowed.        |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_can_transition   | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                              | Stateless transition table query.        |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_audit_count      | (slot: c_int) -> u32                     |
-- |                              | Returns number of audit log entries.     |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_audit_entry      | (slot: c_int, idx: u32)                  |
-- |                              | -> u8 (from_state tag of the entry)      |
-- |                              | Read a specific audit log entry.         |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_set_recording    | (slot: c_int, enabled: u8)               |
-- |                              | -> u8 (0=ok, 1=rejected)                 |
-- |                              | Enable/disable session recording.        |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_is_recording     | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                              | Whether session recording is active.     |
-- +------------------------------+------------------------------------------+
-- | ssh_bastion_auth_failures    | (slot: c_int) -> u8                      |
-- |                              | Returns number of failed auth attempts.  |
-- +------------------------------+------------------------------------------+
