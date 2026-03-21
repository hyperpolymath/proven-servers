// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! Safe Rust wrappers around the `proven-grpc` Zig FFI exports.
//!
//! Wraps the C-ABI functions from `protocols/proven-grpc/ffi/zig/src/grpc.zig`.
//! All functions are gated behind the `ffi` feature flag.

#[cfg(feature = "ffi")]
use crate::error::{ProvenError, ProvenResult};
#[cfg(feature = "ffi")]
use crate::grpc::{Compression, StatusCode, StreamState};
#[cfg(feature = "ffi")]
use std::os::raw::c_int;

// ---------------------------------------------------------------------------
// Raw FFI declarations
// ---------------------------------------------------------------------------

#[cfg(feature = "ffi")]
extern "C" {
    fn grpc_abi_version() -> u32;
    fn grpc_create(compression: u8) -> c_int;
    fn grpc_destroy(slot: c_int);
    fn grpc_stream_state(slot: c_int) -> u8;
    fn grpc_compression(slot: c_int) -> u8;
    fn grpc_status_code(slot: c_int) -> u8;
    fn grpc_set_status(slot: c_int, status: u8) -> u8;
    fn grpc_stream_id(slot: c_int) -> u32;
    fn grpc_send_headers(slot: c_int) -> u8;
    fn grpc_local_end_stream(slot: c_int) -> u8;
    fn grpc_remote_end_stream(slot: c_int) -> u8;
    fn grpc_reset_stream(slot: c_int, status: u8) -> u8;
    fn grpc_close_half_local(slot: c_int) -> u8;
    fn grpc_close_half_remote(slot: c_int) -> u8;
    fn grpc_push_promise(slot: c_int) -> u8;
    fn grpc_reserved_to_half(slot: c_int) -> u8;
    fn grpc_can_send(slot: c_int) -> u8;
    fn grpc_can_receive(slot: c_int) -> u8;
    fn grpc_send_window(slot: c_int) -> i32;
    fn grpc_recv_window(slot: c_int) -> i32;
    fn grpc_update_send_window(slot: c_int, delta: i32) -> u8;
    fn grpc_update_recv_window(slot: c_int, delta: i32) -> u8;
    fn grpc_can_transition(from: u8, to: u8) -> u8;
}

// ---------------------------------------------------------------------------
// Context handle
// ---------------------------------------------------------------------------

/// An opaque handle to a gRPC stream context slot.
#[cfg(feature = "ffi")]
#[derive(Debug)]
pub struct GrpcContext {
    slot: c_int,
}

#[cfg(feature = "ffi")]
impl Drop for GrpcContext {
    fn drop(&mut self) {
        unsafe { grpc_destroy(self.slot) }
    }
}

// ---------------------------------------------------------------------------
// Safe wrappers
// ---------------------------------------------------------------------------

/// Return the ABI version.
#[cfg(feature = "ffi")]
pub fn abi_version() -> u32 {
    unsafe { grpc_abi_version() }
}

/// Create a new gRPC stream context with the given compression algorithm.
#[cfg(feature = "ffi")]
pub fn create(compression: Compression) -> ProvenResult<GrpcContext> {
    let slot = unsafe { grpc_create(compression as u8) };
    ProvenError::from_slot(slot).map(|s| GrpcContext { slot: s })
}

/// Get the current HTTP/2 stream state.
#[cfg(feature = "ffi")]
pub fn stream_state(ctx: &GrpcContext) -> Option<StreamState> {
    let tag = unsafe { grpc_stream_state(ctx.slot) };
    StreamState::from_tag(tag)
}

/// Get the compression algorithm.
#[cfg(feature = "ffi")]
pub fn compression(ctx: &GrpcContext) -> u8 {
    unsafe { grpc_compression(ctx.slot) }
}

/// Get the gRPC status code.
#[cfg(feature = "ffi")]
pub fn status_code(ctx: &GrpcContext) -> Option<StatusCode> {
    let tag = unsafe { grpc_status_code(ctx.slot) };
    StatusCode::from_code(tag)
}

/// Set the gRPC status code.
#[cfg(feature = "ffi")]
pub fn set_status(ctx: &GrpcContext, status: StatusCode) -> ProvenResult<()> {
    let result = unsafe { grpc_set_status(ctx.slot, status.to_code()) };
    ProvenError::from_status(result)
}

/// Get the HTTP/2 stream ID.
#[cfg(feature = "ffi")]
pub fn stream_id(ctx: &GrpcContext) -> u32 {
    unsafe { grpc_stream_id(ctx.slot) }
}

/// Send HEADERS frame. Transitions Idle -> Open.
#[cfg(feature = "ffi")]
pub fn send_headers(ctx: &GrpcContext) -> ProvenResult<()> {
    let result = unsafe { grpc_send_headers(ctx.slot) };
    ProvenError::from_status(result)
}

/// Local END_STREAM. Transitions Open -> HalfClosedLocal.
#[cfg(feature = "ffi")]
pub fn local_end_stream(ctx: &GrpcContext) -> ProvenResult<()> {
    let result = unsafe { grpc_local_end_stream(ctx.slot) };
    ProvenError::from_status(result)
}

/// Remote END_STREAM. Transitions Open -> HalfClosedRemote.
#[cfg(feature = "ffi")]
pub fn remote_end_stream(ctx: &GrpcContext) -> ProvenResult<()> {
    let result = unsafe { grpc_remote_end_stream(ctx.slot) };
    ProvenError::from_status(result)
}

/// RST_STREAM. Transitions Open -> Closed with the given status code.
#[cfg(feature = "ffi")]
pub fn reset_stream(ctx: &GrpcContext, status: StatusCode) -> ProvenResult<()> {
    let result = unsafe { grpc_reset_stream(ctx.slot, status.to_code()) };
    ProvenError::from_status(result)
}

/// Close from HalfClosedLocal -> Closed.
#[cfg(feature = "ffi")]
pub fn close_half_local(ctx: &GrpcContext) -> ProvenResult<()> {
    let result = unsafe { grpc_close_half_local(ctx.slot) };
    ProvenError::from_status(result)
}

/// Close from HalfClosedRemote -> Closed.
#[cfg(feature = "ffi")]
pub fn close_half_remote(ctx: &GrpcContext) -> ProvenResult<()> {
    let result = unsafe { grpc_close_half_remote(ctx.slot) };
    ProvenError::from_status(result)
}

/// PUSH_PROMISE. Transitions Idle -> Reserved.
#[cfg(feature = "ffi")]
pub fn push_promise(ctx: &GrpcContext) -> ProvenResult<()> {
    let result = unsafe { grpc_push_promise(ctx.slot) };
    ProvenError::from_status(result)
}

/// Reserved -> HalfClosedRemote (server sends HEADERS on push).
#[cfg(feature = "ffi")]
pub fn reserved_to_half(ctx: &GrpcContext) -> ProvenResult<()> {
    let result = unsafe { grpc_reserved_to_half(ctx.slot) };
    ProvenError::from_status(result)
}

/// Check if DATA frames can be sent from this state.
#[cfg(feature = "ffi")]
pub fn can_send(ctx: &GrpcContext) -> bool {
    unsafe { grpc_can_send(ctx.slot) == 1 }
}

/// Check if DATA frames can be received in this state.
#[cfg(feature = "ffi")]
pub fn can_receive(ctx: &GrpcContext) -> bool {
    unsafe { grpc_can_receive(ctx.slot) == 1 }
}

/// Get the send-side flow control window.
#[cfg(feature = "ffi")]
pub fn send_window(ctx: &GrpcContext) -> i32 {
    unsafe { grpc_send_window(ctx.slot) }
}

/// Get the receive-side flow control window.
#[cfg(feature = "ffi")]
pub fn recv_window(ctx: &GrpcContext) -> i32 {
    unsafe { grpc_recv_window(ctx.slot) }
}

/// Update the send-side flow control window by `delta`.
#[cfg(feature = "ffi")]
pub fn update_send_window(ctx: &GrpcContext, delta: i32) -> ProvenResult<()> {
    let result = unsafe { grpc_update_send_window(ctx.slot, delta) };
    ProvenError::from_status(result)
}

/// Update the receive-side flow control window by `delta`.
#[cfg(feature = "ffi")]
pub fn update_recv_window(ctx: &GrpcContext, delta: i32) -> ProvenResult<()> {
    let result = unsafe { grpc_update_recv_window(ctx.slot, delta) };
    ProvenError::from_status(result)
}

/// Stateless query: check whether a stream state transition is valid.
#[cfg(feature = "ffi")]
pub fn can_transition(from: StreamState, to: StreamState) -> bool {
    unsafe { grpc_can_transition(from.to_tag(), to.to_tag()) == 1 }
}
