// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! Safe Rust wrappers around the `proven-smtp` Zig FFI exports.
//!
//! Wraps the C-ABI functions from `protocols/proven-smtp/ffi/zig/src/smtp.zig`.
//! All functions are gated behind the `ffi` feature flag.

#[cfg(feature = "ffi")]
use crate::error::{ProvenError, ProvenResult};
#[cfg(feature = "ffi")]
use crate::smtp::{AuthMechanism, SmtpSessionState};
#[cfg(feature = "ffi")]
use std::os::raw::c_int;

// ---------------------------------------------------------------------------
// Raw FFI declarations
// ---------------------------------------------------------------------------

#[cfg(feature = "ffi")]
extern "C" {
    fn smtp_abi_version() -> u32;
    fn smtp_create_context() -> c_int;
    fn smtp_destroy_context(slot: c_int);
    fn smtp_get_state(slot: c_int) -> u8;
    fn smtp_get_reply_code(slot: c_int) -> u8;
    fn smtp_get_recipient_count(slot: c_int) -> u8;
    fn smtp_get_data_size(slot: c_int) -> u32;
    fn smtp_get_auth_mechanism(slot: c_int) -> u8;
    fn smtp_is_authenticated(slot: c_int) -> u8;
    fn smtp_is_tls_active(slot: c_int) -> u8;
    fn smtp_greet(slot: c_int, is_ehlo: u8) -> u8;
    fn smtp_authenticate(slot: c_int, mech: u8) -> u8;
    fn smtp_auth_complete(slot: c_int, success: u8) -> u8;
    fn smtp_set_sender(slot: c_int) -> u8;
    fn smtp_add_recipient(slot: c_int) -> u8;
    fn smtp_start_data(slot: c_int) -> u8;
    fn smtp_append_data(slot: c_int, len: u32) -> u8;
    fn smtp_finish_data(slot: c_int) -> u8;
    fn smtp_reset(slot: c_int) -> u8;
    fn smtp_quit(slot: c_int) -> u8;
    fn smtp_enable_tls(slot: c_int) -> u8;
    fn smtp_can_transition(from: u8, to: u8) -> u8;
}

// ---------------------------------------------------------------------------
// Context handle
// ---------------------------------------------------------------------------

/// An opaque handle to an SMTP session context slot.
#[cfg(feature = "ffi")]
#[derive(Debug)]
pub struct SmtpContext {
    slot: c_int,
}

#[cfg(feature = "ffi")]
impl Drop for SmtpContext {
    fn drop(&mut self) {
        unsafe { smtp_destroy_context(self.slot) }
    }
}

// ---------------------------------------------------------------------------
// Safe wrappers
// ---------------------------------------------------------------------------

/// Return the ABI version of the linked SMTP library.
#[cfg(feature = "ffi")]
pub fn abi_version() -> u32 {
    unsafe { smtp_abi_version() }
}

/// Create a new SMTP session in the Connected state.
#[cfg(feature = "ffi")]
pub fn create_context() -> ProvenResult<SmtpContext> {
    let slot = unsafe { smtp_create_context() };
    ProvenError::from_slot(slot).map(|s| SmtpContext { slot: s })
}

/// Get the current session state.
#[cfg(feature = "ffi")]
pub fn get_state(ctx: &SmtpContext) -> Option<SmtpSessionState> {
    let tag = unsafe { smtp_get_state(ctx.slot) };
    SmtpSessionState::from_tag(tag)
}

/// Get the last reply code tag (0-16, maps to `ReplyCode`).
#[cfg(feature = "ffi")]
pub fn get_reply_code(ctx: &SmtpContext) -> u8 {
    unsafe { smtp_get_reply_code(ctx.slot) }
}

/// Get the number of recipients in the current transaction.
#[cfg(feature = "ffi")]
pub fn get_recipient_count(ctx: &SmtpContext) -> u8 {
    unsafe { smtp_get_recipient_count(ctx.slot) }
}

/// Get the accumulated message data size in bytes.
#[cfg(feature = "ffi")]
pub fn get_data_size(ctx: &SmtpContext) -> u32 {
    unsafe { smtp_get_data_size(ctx.slot) }
}

/// Get the current AUTH mechanism (None if unset).
#[cfg(feature = "ffi")]
pub fn get_auth_mechanism(ctx: &SmtpContext) -> Option<AuthMechanism> {
    let tag = unsafe { smtp_get_auth_mechanism(ctx.slot) };
    AuthMechanism::from_tag(tag)
}

/// Check if the session is authenticated.
#[cfg(feature = "ffi")]
pub fn is_authenticated(ctx: &SmtpContext) -> bool {
    unsafe { smtp_is_authenticated(ctx.slot) == 1 }
}

/// Check if TLS is active.
#[cfg(feature = "ffi")]
pub fn is_tls_active(ctx: &SmtpContext) -> bool {
    unsafe { smtp_is_tls_active(ctx.slot) == 1 }
}

/// HELO/EHLO: greet the server. Transitions Connected -> Greeted.
///
/// `ehlo` selects EHLO (true) vs HELO (false).
#[cfg(feature = "ffi")]
pub fn greet(ctx: &SmtpContext, ehlo: bool) -> ProvenResult<()> {
    let result = unsafe { smtp_greet(ctx.slot, ehlo as u8) };
    ProvenError::from_status(result)
}

/// Begin AUTH exchange. Transitions Greeted -> AuthStarted.
#[cfg(feature = "ffi")]
pub fn authenticate(ctx: &SmtpContext, mechanism: AuthMechanism) -> ProvenResult<()> {
    let result = unsafe { smtp_authenticate(ctx.slot, mechanism.to_tag()) };
    ProvenError::from_status(result)
}

/// Complete AUTH exchange.
///
/// `success = true` transitions AuthStarted -> Authenticated.
/// `success = false` transitions AuthStarted -> Greeted.
#[cfg(feature = "ffi")]
pub fn auth_complete(ctx: &SmtpContext, success: bool) -> ProvenResult<()> {
    let result = unsafe { smtp_auth_complete(ctx.slot, success as u8) };
    ProvenError::from_status(result)
}

/// MAIL FROM: set the sender. Transitions Greeted/Authenticated -> MailFrom.
#[cfg(feature = "ffi")]
pub fn set_sender(ctx: &SmtpContext) -> ProvenResult<()> {
    let result = unsafe { smtp_set_sender(ctx.slot) };
    ProvenError::from_status(result)
}

/// RCPT TO: add a recipient. Transitions MailFrom/RcptTo -> RcptTo.
#[cfg(feature = "ffi")]
pub fn add_recipient(ctx: &SmtpContext) -> ProvenResult<()> {
    let result = unsafe { smtp_add_recipient(ctx.slot) };
    ProvenError::from_status(result)
}

/// DATA: begin message body transfer. Transitions RcptTo -> Data.
#[cfg(feature = "ffi")]
pub fn start_data(ctx: &SmtpContext) -> ProvenResult<()> {
    let result = unsafe { smtp_start_data(ctx.slot) };
    ProvenError::from_status(result)
}

/// Append data bytes to the message.
#[cfg(feature = "ffi")]
pub fn append_data(ctx: &SmtpContext, len: u32) -> ProvenResult<()> {
    let result = unsafe { smtp_append_data(ctx.slot, len) };
    ProvenError::from_status(result)
}

/// Finish data transfer (end-of-data marker). Transitions Data -> MessageReceived.
#[cfg(feature = "ffi")]
pub fn finish_data(ctx: &SmtpContext) -> ProvenResult<()> {
    let result = unsafe { smtp_finish_data(ctx.slot) };
    ProvenError::from_status(result)
}

/// RSET: reset the mail transaction. Returns to Greeted or Authenticated.
#[cfg(feature = "ffi")]
pub fn reset(ctx: &SmtpContext) -> ProvenResult<()> {
    let result = unsafe { smtp_reset(ctx.slot) };
    ProvenError::from_status(result)
}

/// QUIT: end the session. Transitions to Quit.
#[cfg(feature = "ffi")]
pub fn quit(ctx: &SmtpContext) -> ProvenResult<()> {
    let result = unsafe { smtp_quit(ctx.slot) };
    ProvenError::from_status(result)
}

/// STARTTLS: enable TLS on the connection.
#[cfg(feature = "ffi")]
pub fn enable_tls(ctx: &SmtpContext) -> ProvenResult<()> {
    let result = unsafe { smtp_enable_tls(ctx.slot) };
    ProvenError::from_status(result)
}

/// Stateless query: check whether a session state transition is valid.
#[cfg(feature = "ffi")]
pub fn can_transition(from: SmtpSessionState, to: SmtpSessionState) -> bool {
    unsafe { smtp_can_transition(from.to_tag(), to.to_tag()) == 1 }
}
