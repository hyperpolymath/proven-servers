// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! Safe Rust wrappers around the `proven-httpd` Zig FFI exports.
//!
//! Wraps the C-ABI functions from `protocols/proven-httpd/ffi/zig/src/httpd.zig`:
//! - Context lifecycle: `http_create_context`, `http_destroy_context`
//! - Request parsing: `http_parse_request`
//! - Request queries: `http_get_method`, `http_get_path`, `http_get_header`, `http_get_body`
//! - Response construction: `http_set_status`, `http_set_header`, `http_set_body`, `http_send_response`
//! - Phase & transition: `http_get_phase`, `http_get_version`, `http_keep_alive_check`,
//!   `http_reset_context`, `http_can_transition`
//!
//! All functions are gated behind the `ffi` feature flag.

#[cfg(feature = "ffi")]
use crate::error::{ProvenError, ProvenResult};
#[cfg(feature = "ffi")]
use crate::http::{Method, RequestPhase, StatusCode, Version};
#[cfg(feature = "ffi")]
use std::os::raw::c_int;

// ---------------------------------------------------------------------------
// Raw FFI declarations
// ---------------------------------------------------------------------------

#[cfg(feature = "ffi")]
extern "C" {
    fn http_abi_version() -> u32;
    fn http_create_context() -> c_int;
    fn http_destroy_context(slot: c_int);
    fn http_parse_request(slot: c_int, data: *const u8, len: u32) -> u8;
    fn http_get_method(slot: c_int) -> u8;
    fn http_get_path(slot: c_int, buf: *mut u8, len: u32) -> u32;
    fn http_get_header(slot: c_int, key: *const u8, klen: u32, buf: *mut u8, blen: u32) -> u32;
    fn http_get_body(slot: c_int, buf: *mut u8, len: u32) -> u32;
    fn http_set_status(slot: c_int, status_tag: u8) -> u8;
    fn http_set_header(slot: c_int, key: *const u8, klen: u32, val: *const u8, vlen: u32) -> u8;
    fn http_set_body(slot: c_int, data: *const u8, len: u32) -> u8;
    fn http_send_response(slot: c_int) -> u8;
    fn http_keep_alive_check(slot: c_int) -> u8;
    fn http_get_phase(slot: c_int) -> u8;
    fn http_get_version(slot: c_int) -> u8;
    fn http_reset_context(slot: c_int) -> u8;
    fn http_can_transition(from: u8, to: u8) -> u8;
}

// ---------------------------------------------------------------------------
// Opaque context handle
// ---------------------------------------------------------------------------

/// An opaque handle to an HTTP context slot in the Zig FFI pool.
///
/// Created via [`create_context`] and automatically destroyed on drop.
/// The slot index is guaranteed to be in range [0, 63].
#[cfg(feature = "ffi")]
#[derive(Debug)]
pub struct HttpContext {
    slot: c_int,
}

#[cfg(feature = "ffi")]
impl Drop for HttpContext {
    fn drop(&mut self) {
        // SAFETY: slot was validated on creation; destroy is idempotent.
        unsafe { http_destroy_context(self.slot) }
    }
}

// ---------------------------------------------------------------------------
// Parse result
// ---------------------------------------------------------------------------

/// Result of feeding raw HTTP data into a context.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ParseResult {
    /// Parsing complete, request is ready for processing.
    Complete,
    /// Request was malformed and rejected.
    Rejected,
    /// Need more data (headers or body incomplete).
    NeedMore,
}

// ---------------------------------------------------------------------------
// Safe wrappers
// ---------------------------------------------------------------------------

/// Return the ABI version of the linked `libproven_httpd`.
#[cfg(feature = "ffi")]
pub fn abi_version() -> u32 {
    // SAFETY: No preconditions, pure query function.
    unsafe { http_abi_version() }
}

/// Create a new HTTP context in the Idle phase.
///
/// Returns an owned [`HttpContext`] handle that will release its slot on drop.
///
/// # Errors
///
/// Returns [`ProvenError::PoolExhausted`] if all 64 slots are in use.
#[cfg(feature = "ffi")]
pub fn create_context() -> ProvenResult<HttpContext> {
    // SAFETY: No preconditions; returns -1 on failure.
    let slot = unsafe { http_create_context() };
    ProvenError::from_slot(slot).map(|s| HttpContext { slot: s })
}

/// Feed raw HTTP data into a context for parsing.
///
/// Handles the full Idle -> Receiving -> HeadersParsed -> Complete
/// (or BodyReceiving -> Complete) transition chain.
///
/// # Errors
///
/// Returns [`ProvenError::InvalidSlot`] if the slot is invalid.
#[cfg(feature = "ffi")]
pub fn parse_request(ctx: &HttpContext, data: &[u8]) -> ProvenResult<ParseResult> {
    // SAFETY: data pointer and length are valid; slot was validated on creation.
    let result = unsafe {
        http_parse_request(ctx.slot, data.as_ptr(), data.len() as u32)
    };
    match result {
        0 => Ok(ParseResult::Complete),
        1 => Ok(ParseResult::Rejected),
        2 => Ok(ParseResult::NeedMore),
        _ => Err(ProvenError::Unknown { code: result as i32 }),
    }
}

/// Get the HTTP method of the parsed request.
///
/// Returns `None` if the method has not been parsed yet (tag 255).
#[cfg(feature = "ffi")]
pub fn get_method(ctx: &HttpContext) -> Option<Method> {
    // SAFETY: slot was validated on creation.
    let tag = unsafe { http_get_method(ctx.slot) };
    Method::from_tag(tag)
}

/// Copy the request path into the provided buffer.
///
/// Returns the number of bytes written, or 0 if no path is set.
#[cfg(feature = "ffi")]
pub fn get_path(ctx: &HttpContext, buf: &mut [u8]) -> usize {
    // SAFETY: buf pointer and length are valid; slot was validated on creation.
    let written = unsafe {
        http_get_path(ctx.slot, buf.as_mut_ptr(), buf.len() as u32)
    };
    written as usize
}

/// Look up a request header by key (case-insensitive).
///
/// Copies the header value into `buf`. Returns the number of bytes
/// written, or 0 if the header was not found.
#[cfg(feature = "ffi")]
pub fn get_header(ctx: &HttpContext, key: &str, buf: &mut [u8]) -> usize {
    // SAFETY: key and buf pointers are valid; slot was validated on creation.
    let written = unsafe {
        http_get_header(
            ctx.slot,
            key.as_ptr(),
            key.len() as u32,
            buf.as_mut_ptr(),
            buf.len() as u32,
        )
    };
    written as usize
}

/// Copy the request body into the provided buffer.
///
/// Returns the number of bytes written, or 0 if no body is present.
#[cfg(feature = "ffi")]
pub fn get_body(ctx: &HttpContext, buf: &mut [u8]) -> usize {
    // SAFETY: buf pointer and length are valid; slot was validated on creation.
    let written = unsafe {
        http_get_body(ctx.slot, buf.as_mut_ptr(), buf.len() as u32)
    };
    written as usize
}

/// Set the response status code.
///
/// Requires the context to be in Complete or Responding phase.
/// Transitions Complete -> Responding if needed.
///
/// # Errors
///
/// Returns [`ProvenError::InvalidState`] if in the wrong phase.
#[cfg(feature = "ffi")]
pub fn set_status(ctx: &HttpContext, status: StatusCode) -> ProvenResult<()> {
    // SAFETY: slot was validated on creation; status tag is in range.
    let result = unsafe { http_set_status(ctx.slot, status.to_tag()) };
    ProvenError::from_status(result)
}

/// Set a response header.
///
/// Requires the context to be in Complete or Responding phase.
///
/// # Errors
///
/// Returns [`ProvenError::InvalidState`] if in the wrong phase, or
/// [`ProvenError::CapacityExceeded`] if the header array is full.
#[cfg(feature = "ffi")]
pub fn set_header(ctx: &HttpContext, key: &str, value: &str) -> ProvenResult<()> {
    // SAFETY: key and value pointers are valid; slot was validated on creation.
    let result = unsafe {
        http_set_header(
            ctx.slot,
            key.as_ptr(),
            key.len() as u32,
            value.as_ptr(),
            value.len() as u32,
        )
    };
    ProvenError::from_status(result)
}

/// Set the response body.
///
/// Requires the context to be in Complete or Responding phase.
///
/// # Errors
///
/// Returns [`ProvenError::InvalidState`] if in the wrong phase, or
/// [`ProvenError::CapacityExceeded`] if the body exceeds the buffer limit.
#[cfg(feature = "ffi")]
pub fn set_body(ctx: &HttpContext, data: &[u8]) -> ProvenResult<()> {
    // SAFETY: data pointer and length are valid; slot was validated on creation.
    let result = unsafe {
        http_set_body(ctx.slot, data.as_ptr(), data.len() as u32)
    };
    ProvenError::from_status(result)
}

/// Send the response, transitioning Responding -> Sent.
///
/// # Errors
///
/// Returns [`ProvenError::InvalidState`] if not in Responding phase.
#[cfg(feature = "ffi")]
pub fn send_response(ctx: &HttpContext) -> ProvenResult<()> {
    // SAFETY: slot was validated on creation.
    let result = unsafe { http_send_response(ctx.slot) };
    ProvenError::from_status(result)
}

/// Check if the connection uses keep-alive.
#[cfg(feature = "ffi")]
pub fn keep_alive_check(ctx: &HttpContext) -> bool {
    // SAFETY: slot was validated on creation.
    unsafe { http_keep_alive_check(ctx.slot) == 1 }
}

/// Get the current request processing phase.
#[cfg(feature = "ffi")]
pub fn get_phase(ctx: &HttpContext) -> Option<RequestPhase> {
    // SAFETY: slot was validated on creation.
    let tag = unsafe { http_get_phase(ctx.slot) };
    RequestPhase::from_tag(tag)
}

/// Get the HTTP version of the parsed request.
#[cfg(feature = "ffi")]
pub fn get_version(ctx: &HttpContext) -> Option<Version> {
    // SAFETY: slot was validated on creation.
    let tag = unsafe { http_get_version(ctx.slot) };
    Version::from_tag(tag)
}

/// Reset the context for keep-alive reuse (Sent -> Idle).
///
/// # Errors
///
/// Returns [`ProvenError::InvalidState`] if not in Sent phase.
#[cfg(feature = "ffi")]
pub fn reset_context(ctx: &HttpContext) -> ProvenResult<()> {
    // SAFETY: slot was validated on creation.
    let result = unsafe { http_reset_context(ctx.slot) };
    ProvenError::from_status(result)
}

/// Stateless query: check whether a lifecycle transition is valid.
///
/// Returns `true` if the transition from `from` to `to` is allowed
/// by the HTTP request lifecycle state machine.
#[cfg(feature = "ffi")]
pub fn can_transition(from: RequestPhase, to: RequestPhase) -> bool {
    // SAFETY: Pure function with no side effects.
    unsafe { http_can_transition(from.to_tag(), to.to_tag()) == 1 }
}
