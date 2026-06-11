// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! Safe Rust wrappers around the `proven-ssh-bastion` Zig FFI exports.
//!
//! Wraps the C-ABI functions from `protocols/proven-ssh-bastion/ffi/zig/src/ssh_bastion.zig`.
//! All functions are gated behind the `ffi` feature flag.

#[cfg(feature = "ffi")]
use crate::error::{ProvenError, ProvenResult};
#[cfg(feature = "ffi")]
use crate::ssh::{AuthMethod, BastionState, ChannelState, ChannelType, DisconnectReason, KexMethod};
#[cfg(feature = "ffi")]
use std::os::raw::c_int;

// ---------------------------------------------------------------------------
// Raw FFI declarations
// ---------------------------------------------------------------------------

#[cfg(feature = "ffi")]
extern "C" {
    fn ssh_bastion_abi_version() -> u32;
    fn ssh_bastion_create(kex_method: u8, auth_method: u8) -> c_int;
    fn ssh_bastion_destroy(slot: c_int);
    fn ssh_bastion_state(slot: c_int) -> u8;
    fn ssh_bastion_kex_method(slot: c_int) -> u8;
    fn ssh_bastion_auth_method(slot: c_int) -> u8;
    fn ssh_bastion_can_transfer(slot: c_int) -> u8;
    fn ssh_bastion_disconnect_reason(slot: c_int) -> u8;
    fn ssh_bastion_auth_failures(slot: c_int) -> u8;
    fn ssh_bastion_complete_kex(slot: c_int) -> u8;
    fn ssh_bastion_authenticate(slot: c_int, user_len: u16) -> u8;
    fn ssh_bastion_record_auth_failure(slot: c_int) -> u8;
    fn ssh_bastion_open_channel(slot: c_int, ch_type: u8) -> c_int;
    fn ssh_bastion_confirm_channel(slot: c_int, ch_id: u8) -> u8;
    fn ssh_bastion_close_channel(slot: c_int, ch_id: u8) -> u8;
    fn ssh_bastion_channel_state(slot: c_int, ch_id: u8) -> u8;
    fn ssh_bastion_channel_type(slot: c_int, ch_id: u8) -> u8;
    fn ssh_bastion_channel_count(slot: c_int) -> u8;
    fn ssh_bastion_rekey(slot: c_int) -> u8;
    fn ssh_bastion_disconnect(slot: c_int, reason: u8) -> u8;
    fn ssh_bastion_can_transition(from: u8, to: u8) -> u8;
    fn ssh_bastion_audit_count(slot: c_int) -> u32;
    fn ssh_bastion_audit_entry(slot: c_int, entry_idx: u32) -> u8;
    fn ssh_bastion_audit_entry_to(slot: c_int, entry_idx: u32) -> u8;
    fn ssh_bastion_set_recording(slot: c_int, enabled: u8) -> u8;
    fn ssh_bastion_is_recording(slot: c_int) -> u8;
}

// ---------------------------------------------------------------------------
// Context handle
// ---------------------------------------------------------------------------

/// An opaque handle to an SSH bastion session context slot.
#[cfg(feature = "ffi")]
#[derive(Debug)]
pub struct SshBastionContext {
    slot: c_int,
}

#[cfg(feature = "ffi")]
impl Drop for SshBastionContext {
    fn drop(&mut self) {
        unsafe { ssh_bastion_destroy(self.slot) }
    }
}

// ---------------------------------------------------------------------------
// Safe wrappers
// ---------------------------------------------------------------------------

/// Return the ABI version.
#[cfg(feature = "ffi")]
pub fn abi_version() -> u32 {
    unsafe { ssh_bastion_abi_version() }
}

/// Create a new SSH bastion session with the given key exchange and auth methods.
#[cfg(feature = "ffi")]
pub fn create(kex: KexMethod, auth: AuthMethod) -> ProvenResult<SshBastionContext> {
    let slot = unsafe { ssh_bastion_create(kex.to_tag(), auth.to_tag()) };
    ProvenError::from_slot(slot).map(|s| SshBastionContext { slot: s })
}

/// Get the current bastion state.
#[cfg(feature = "ffi")]
pub fn state(ctx: &SshBastionContext) -> Option<BastionState> {
    let tag = unsafe { ssh_bastion_state(ctx.slot) };
    BastionState::from_tag(tag)
}

/// Get the configured key exchange method.
#[cfg(feature = "ffi")]
pub fn kex_method(ctx: &SshBastionContext) -> Option<KexMethod> {
    let tag = unsafe { ssh_bastion_kex_method(ctx.slot) };
    KexMethod::from_tag(tag)
}

/// Get the configured authentication method.
#[cfg(feature = "ffi")]
pub fn auth_method(ctx: &SshBastionContext) -> Option<AuthMethod> {
    let tag = unsafe { ssh_bastion_auth_method(ctx.slot) };
    AuthMethod::from_tag(tag)
}

/// Check if data transfer is allowed (session must be Active).
#[cfg(feature = "ffi")]
pub fn can_transfer_data(ctx: &SshBastionContext) -> bool {
    unsafe { ssh_bastion_can_transfer(ctx.slot) == 1 }
}

/// Get the disconnect reason (None if not disconnected).
#[cfg(feature = "ffi")]
pub fn disconnect_reason(ctx: &SshBastionContext) -> Option<DisconnectReason> {
    let tag = unsafe { ssh_bastion_disconnect_reason(ctx.slot) };
    DisconnectReason::from_tag(tag)
}

/// Get the number of failed auth attempts.
#[cfg(feature = "ffi")]
pub fn auth_failures(ctx: &SshBastionContext) -> u8 {
    unsafe { ssh_bastion_auth_failures(ctx.slot) }
}

/// Complete key exchange. Transitions Connected -> KeyExchanged.
#[cfg(feature = "ffi")]
pub fn complete_kex(ctx: &SshBastionContext) -> ProvenResult<()> {
    let result = unsafe { ssh_bastion_complete_kex(ctx.slot) };
    ProvenError::from_status(result)
}

/// Authenticate the user. Transitions KeyExchanged -> Authenticated.
#[cfg(feature = "ffi")]
pub fn authenticate(ctx: &SshBastionContext) -> ProvenResult<()> {
    let result = unsafe { ssh_bastion_authenticate(ctx.slot, 0) };
    ProvenError::from_status(result)
}

/// Record a failed auth attempt. Returns `true` if locked out (3+ failures).
#[cfg(feature = "ffi")]
pub fn record_auth_failure(ctx: &SshBastionContext) -> bool {
    unsafe { ssh_bastion_record_auth_failure(ctx.slot) == 1 }
}

/// Open a channel. Returns the channel ID (0-9).
///
/// Transitions Authenticated -> ChannelOpen (first channel) or stays Active.
#[cfg(feature = "ffi")]
pub fn open_channel(ctx: &SshBastionContext, ch_type: ChannelType) -> ProvenResult<u8> {
    let ch_id = unsafe { ssh_bastion_open_channel(ctx.slot, ch_type.to_tag()) };
    ProvenError::from_slot(ch_id).map(|id| id as u8)
}

/// Confirm a channel (Opening -> Open). Transitions ChannelOpen -> Active.
#[cfg(feature = "ffi")]
pub fn confirm_channel(ctx: &SshBastionContext, ch_id: u8) -> ProvenResult<()> {
    let result = unsafe { ssh_bastion_confirm_channel(ctx.slot, ch_id) };
    ProvenError::from_status(result)
}

/// Close a specific channel.
#[cfg(feature = "ffi")]
pub fn close_channel(ctx: &SshBastionContext, ch_id: u8) -> ProvenResult<()> {
    let result = unsafe { ssh_bastion_close_channel(ctx.slot, ch_id) };
    ProvenError::from_status(result)
}

/// Get the state of a specific channel.
#[cfg(feature = "ffi")]
pub fn channel_state(ctx: &SshBastionContext, ch_id: u8) -> Option<ChannelState> {
    let tag = unsafe { ssh_bastion_channel_state(ctx.slot, ch_id) };
    ChannelState::from_tag(tag)
}

/// Get the type of a specific channel.
#[cfg(feature = "ffi")]
pub fn channel_type(ctx: &SshBastionContext, ch_id: u8) -> Option<ChannelType> {
    let tag = unsafe { ssh_bastion_channel_type(ctx.slot, ch_id) };
    ChannelType::from_tag(tag)
}

/// Get the count of active (non-closed) channels.
#[cfg(feature = "ffi")]
pub fn channel_count(ctx: &SshBastionContext) -> u8 {
    unsafe { ssh_bastion_channel_count(ctx.slot) }
}

/// Re-key the session. Only valid in Active state.
#[cfg(feature = "ffi")]
pub fn rekey(ctx: &SshBastionContext) -> ProvenResult<()> {
    let result = unsafe { ssh_bastion_rekey(ctx.slot) };
    ProvenError::from_status(result)
}

/// Disconnect with a reason. Transitions any non-Closed -> Closed.
#[cfg(feature = "ffi")]
pub fn disconnect(ctx: &SshBastionContext, reason: DisconnectReason) -> ProvenResult<()> {
    let result = unsafe { ssh_bastion_disconnect(ctx.slot, reason.to_tag()) };
    ProvenError::from_status(result)
}

/// Stateless query: check whether a bastion state transition is valid.
#[cfg(feature = "ffi")]
pub fn can_transition(from: BastionState, to: BastionState) -> bool {
    unsafe { ssh_bastion_can_transition(from.to_tag(), to.to_tag()) == 1 }
}

/// Get the number of audit log entries.
#[cfg(feature = "ffi")]
pub fn audit_count(ctx: &SshBastionContext) -> u32 {
    unsafe { ssh_bastion_audit_count(ctx.slot) }
}

/// Read the from_state of an audit log entry.
#[cfg(feature = "ffi")]
pub fn audit_entry_from(ctx: &SshBastionContext, index: u32) -> Option<BastionState> {
    let tag = unsafe { ssh_bastion_audit_entry(ctx.slot, index) };
    BastionState::from_tag(tag)
}

/// Read the to_state of an audit log entry.
#[cfg(feature = "ffi")]
pub fn audit_entry_to(ctx: &SshBastionContext, index: u32) -> Option<BastionState> {
    let tag = unsafe { ssh_bastion_audit_entry_to(ctx.slot, index) };
    BastionState::from_tag(tag)
}

/// Enable or disable session recording.
#[cfg(feature = "ffi")]
pub fn set_recording(ctx: &SshBastionContext, enabled: bool) -> ProvenResult<()> {
    let result = unsafe { ssh_bastion_set_recording(ctx.slot, enabled as u8) };
    ProvenError::from_status(result)
}

/// Check whether session recording is active.
#[cfg(feature = "ffi")]
pub fn is_recording(ctx: &SshBastionContext) -> bool {
    unsafe { ssh_bastion_is_recording(ctx.slot) == 1 }
}
