// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! Safe Rust wrappers around the `proven-ftp` Zig FFI exports.
//!
//! Wraps the C-ABI functions from `protocols/proven-ftp/ffi/zig/src/ftp.zig`.
//! All functions are gated behind the `ffi` feature flag.

#[cfg(feature = "ffi")]
use crate::error::{ProvenError, ProvenResult};
#[cfg(feature = "ffi")]
use std::os::raw::c_int;

// ---------------------------------------------------------------------------
// FTP session states (ABI tags from ftp.zig)
// ---------------------------------------------------------------------------

/// FTP session states matching `SessionState` in ftp.zig.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FtpSessionState {
    /// TCP connection established.
    Connected = 0,
    /// USER accepted, password required.
    UserOk = 1,
    /// Fully authenticated.
    Authenticated = 2,
    /// Rename in progress (RNFR sent).
    Renaming = 3,
    /// Session ended.
    Quit = 4,
}

#[cfg(feature = "ffi")]
impl FtpSessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Connected),
            1 => Some(Self::UserOk),
            2 => Some(Self::Authenticated),
            3 => Some(Self::Renaming),
            4 => Some(Self::Quit),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

/// FTP transfer states matching `TransferStateTag` in ftp.zig.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum TransferState {
    /// No transfer in progress.
    Idle = 0,
    /// Transfer active.
    InProgress = 1,
    /// Transfer completed successfully.
    Completed = 2,
    /// Transfer was aborted.
    Aborted = 3,
}

#[cfg(feature = "ffi")]
impl TransferState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::InProgress),
            2 => Some(Self::Completed),
            3 => Some(Self::Aborted),
            _ => None,
        }
    }
}

// ---------------------------------------------------------------------------
// Raw FFI declarations
// ---------------------------------------------------------------------------

#[cfg(feature = "ffi")]
extern "C" {
    fn ftp_abi_version() -> u32;
    fn ftp_create() -> c_int;
    fn ftp_destroy(slot: c_int);
    fn ftp_state(slot: c_int) -> u8;
    fn ftp_transfer_type(slot: c_int) -> u8;
    fn ftp_data_mode(slot: c_int) -> u8;
    fn ftp_transfer_state(slot: c_int) -> u8;
    fn ftp_bytes_transferred(slot: c_int) -> u64;
    fn ftp_file_count(slot: c_int) -> u32;
    fn ftp_last_reply_code(slot: c_int) -> u16;
    fn ftp_cwd(slot: c_int, buf: *mut u8, buf_len: u32) -> u32;
    fn ftp_user(slot: c_int, name: *const u8, len: u32) -> u8;
    fn ftp_pass(slot: c_int, pass: *const u8, len: u32) -> u8;
    fn ftp_quit(slot: c_int) -> u8;
    fn ftp_cwd_cmd(slot: c_int, path: *const u8, path_len: u32) -> u8;
    fn ftp_cdup(slot: c_int) -> u8;
    fn ftp_set_type(slot: c_int, type_tag: u8) -> u8;
    fn ftp_set_passive(slot: c_int) -> u8;
    fn ftp_set_active(slot: c_int, port: u16) -> u8;
    fn ftp_begin_transfer(slot: c_int) -> u8;
    fn ftp_add_bytes(slot: c_int, count: u64) -> u8;
    fn ftp_complete_transfer(slot: c_int) -> u8;
    fn ftp_abort_transfer(slot: c_int) -> u8;
    fn ftp_begin_rename(slot: c_int) -> u8;
    fn ftp_complete_rename(slot: c_int) -> u8;
    fn ftp_can_transfer(state_tag: u8) -> u8;
    fn ftp_can_transition(from: u8, to: u8) -> u8;
}

// ---------------------------------------------------------------------------
// Context handle
// ---------------------------------------------------------------------------

/// An opaque handle to an FTP session context slot.
#[cfg(feature = "ffi")]
#[derive(Debug)]
pub struct FtpContext {
    slot: c_int,
}

#[cfg(feature = "ffi")]
impl Drop for FtpContext {
    fn drop(&mut self) {
        unsafe { ftp_destroy(self.slot) }
    }
}

// ---------------------------------------------------------------------------
// Safe wrappers
// ---------------------------------------------------------------------------

/// Return the ABI version.
#[cfg(feature = "ffi")]
pub fn abi_version() -> u32 {
    unsafe { ftp_abi_version() }
}

/// Create a new FTP session in the Connected state.
#[cfg(feature = "ffi")]
pub fn create() -> ProvenResult<FtpContext> {
    let slot = unsafe { ftp_create() };
    ProvenError::from_slot(slot).map(|s| FtpContext { slot: s })
}

/// Get the current session state.
#[cfg(feature = "ffi")]
pub fn state(ctx: &FtpContext) -> Option<FtpSessionState> {
    let tag = unsafe { ftp_state(ctx.slot) };
    FtpSessionState::from_tag(tag)
}

/// Get the transfer type tag (0=ASCII, 1=binary).
#[cfg(feature = "ffi")]
pub fn transfer_type(ctx: &FtpContext) -> u8 {
    unsafe { ftp_transfer_type(ctx.slot) }
}

/// Get the data mode tag (0=active, 1=passive, 255=unset).
#[cfg(feature = "ffi")]
pub fn data_mode(ctx: &FtpContext) -> u8 {
    unsafe { ftp_data_mode(ctx.slot) }
}

/// Get the transfer state.
#[cfg(feature = "ffi")]
pub fn transfer_state(ctx: &FtpContext) -> Option<TransferState> {
    let tag = unsafe { ftp_transfer_state(ctx.slot) };
    TransferState::from_tag(tag)
}

/// Get bytes transferred in the current/last transfer.
#[cfg(feature = "ffi")]
pub fn bytes_transferred(ctx: &FtpContext) -> u64 {
    unsafe { ftp_bytes_transferred(ctx.slot) }
}

/// Get total file count.
#[cfg(feature = "ffi")]
pub fn file_count(ctx: &FtpContext) -> u32 {
    unsafe { ftp_file_count(ctx.slot) }
}

/// Get the last FTP numeric reply code (e.g. 220, 331, 230).
#[cfg(feature = "ffi")]
pub fn last_reply_code(ctx: &FtpContext) -> u16 {
    unsafe { ftp_last_reply_code(ctx.slot) }
}

/// Copy the current working directory into `buf`. Returns bytes written.
#[cfg(feature = "ffi")]
pub fn cwd(ctx: &FtpContext, buf: &mut [u8]) -> usize {
    let written = unsafe { ftp_cwd(ctx.slot, buf.as_mut_ptr(), buf.len() as u32) };
    written as usize
}

/// USER command. Transitions Connected -> UserOk.
#[cfg(feature = "ffi")]
pub fn user(ctx: &FtpContext, name: &str) -> ProvenResult<()> {
    let result = unsafe { ftp_user(ctx.slot, name.as_ptr(), name.len() as u32) };
    ProvenError::from_status(result)
}

/// PASS command. Transitions UserOk -> Authenticated.
#[cfg(feature = "ffi")]
pub fn pass(ctx: &FtpContext, password: &str) -> ProvenResult<()> {
    let result = unsafe { ftp_pass(ctx.slot, password.as_ptr(), password.len() as u32) };
    ProvenError::from_status(result)
}

/// QUIT command. Transitions to Quit from most states.
#[cfg(feature = "ffi")]
pub fn quit_session(ctx: &FtpContext) -> ProvenResult<()> {
    let result = unsafe { ftp_quit(ctx.slot) };
    ProvenError::from_status(result)
}

/// CWD command. Changes directory (path validated against traversal).
#[cfg(feature = "ffi")]
pub fn change_dir(ctx: &FtpContext, path: &str) -> ProvenResult<()> {
    let result = unsafe { ftp_cwd_cmd(ctx.slot, path.as_ptr(), path.len() as u32) };
    ProvenError::from_status(result)
}

/// CDUP command. Changes to parent directory.
#[cfg(feature = "ffi")]
pub fn change_dir_up(ctx: &FtpContext) -> ProvenResult<()> {
    let result = unsafe { ftp_cdup(ctx.slot) };
    ProvenError::from_status(result)
}

/// TYPE command. Sets transfer type (0=ASCII, 1=binary).
#[cfg(feature = "ffi")]
pub fn set_type(ctx: &FtpContext, type_tag: u8) -> ProvenResult<()> {
    let result = unsafe { ftp_set_type(ctx.slot, type_tag) };
    ProvenError::from_status(result)
}

/// PASV command. Sets passive data mode.
#[cfg(feature = "ffi")]
pub fn set_passive(ctx: &FtpContext) -> ProvenResult<()> {
    let result = unsafe { ftp_set_passive(ctx.slot) };
    ProvenError::from_status(result)
}

/// PORT command. Sets active data mode with the given port.
#[cfg(feature = "ffi")]
pub fn set_active(ctx: &FtpContext, port: u16) -> ProvenResult<()> {
    let result = unsafe { ftp_set_active(ctx.slot, port) };
    ProvenError::from_status(result)
}

/// Begin a data transfer. Requires Authenticated + data mode set.
#[cfg(feature = "ffi")]
pub fn begin_transfer(ctx: &FtpContext) -> ProvenResult<()> {
    let result = unsafe { ftp_begin_transfer(ctx.slot) };
    ProvenError::from_status(result)
}

/// Add bytes to the transfer counter.
#[cfg(feature = "ffi")]
pub fn add_bytes(ctx: &FtpContext, count: u64) -> ProvenResult<()> {
    let result = unsafe { ftp_add_bytes(ctx.slot, count) };
    ProvenError::from_status(result)
}

/// Complete a data transfer.
#[cfg(feature = "ffi")]
pub fn complete_transfer(ctx: &FtpContext) -> ProvenResult<()> {
    let result = unsafe { ftp_complete_transfer(ctx.slot) };
    ProvenError::from_status(result)
}

/// Abort a data transfer.
#[cfg(feature = "ffi")]
pub fn abort_transfer(ctx: &FtpContext) -> ProvenResult<()> {
    let result = unsafe { ftp_abort_transfer(ctx.slot) };
    ProvenError::from_status(result)
}

/// RNFR: begin rename operation. Transitions Authenticated -> Renaming.
#[cfg(feature = "ffi")]
pub fn begin_rename(ctx: &FtpContext) -> ProvenResult<()> {
    let result = unsafe { ftp_begin_rename(ctx.slot) };
    ProvenError::from_status(result)
}

/// RNTO: complete rename operation. Transitions Renaming -> Authenticated.
#[cfg(feature = "ffi")]
pub fn complete_rename(ctx: &FtpContext) -> ProvenResult<()> {
    let result = unsafe { ftp_complete_rename(ctx.slot) };
    ProvenError::from_status(result)
}

/// Stateless query: check if transfers are allowed from the given state.
#[cfg(feature = "ffi")]
pub fn can_transfer(state: FtpSessionState) -> bool {
    unsafe { ftp_can_transfer(state.to_tag()) == 1 }
}

/// Stateless query: check whether a session state transition is valid.
#[cfg(feature = "ffi")]
pub fn can_transition(from: FtpSessionState, to: FtpSessionState) -> bool {
    unsafe { ftp_can_transition(from.to_tag(), to.to_tag()) == 1 }
}
