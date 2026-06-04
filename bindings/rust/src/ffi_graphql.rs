// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! Safe Rust wrappers around the `proven-graphql` Zig FFI exports.
//!
//! Wraps the C-ABI functions from `protocols/proven-graphql/ffi/zig/src/graphql.zig`.
//! All functions are gated behind the `ffi` feature flag.

#[cfg(feature = "ffi")]
use crate::error::{ProvenError, ProvenResult};
#[cfg(feature = "ffi")]
use std::os::raw::c_int;

// ---------------------------------------------------------------------------
// GraphQL request phases (ABI tags from graphql.zig)
// ---------------------------------------------------------------------------

/// GraphQL request lifecycle phases matching the Zig FFI.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum GraphqlPhase {
    /// Request received, not yet parsed.
    Received = 0,
    /// Query parsed and validated.
    Parsed = 1,
    /// Execution in progress.
    Executing = 2,
    /// Execution complete, response ready.
    Complete = 3,
    /// Error occurred.
    Error = 4,
}

#[cfg(feature = "ffi")]
impl GraphqlPhase {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Received),
            1 => Some(Self::Parsed),
            2 => Some(Self::Executing),
            3 => Some(Self::Complete),
            4 => Some(Self::Error),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

// ---------------------------------------------------------------------------
// Raw FFI declarations
// ---------------------------------------------------------------------------

#[cfg(feature = "ffi")]
extern "C" {
    fn graphql_abi_version() -> u32;
    fn graphql_create(op_type: u8) -> c_int;
    fn graphql_destroy(slot: c_int);
    fn graphql_phase(slot: c_int) -> u8;
    fn graphql_operation_type(slot: c_int) -> u8;
    fn graphql_error_category(slot: c_int) -> u8;
    fn graphql_advance(slot: c_int) -> u8;
    fn graphql_abort(slot: c_int, err_cat: u8) -> u8;
    fn graphql_set_query_depth(slot: c_int, depth: u16) -> u8;
    fn graphql_query_depth(slot: c_int) -> u16;
    fn graphql_set_complexity(slot: c_int, score: u16) -> u8;
    fn graphql_complexity(slot: c_int) -> u16;
    fn graphql_resolve_field(slot: c_int, type_kind: u8, scalar_kind: u8) -> u8;
    fn graphql_fields_resolved(slot: c_int) -> u16;
    fn graphql_can_transition(from: u8, to: u8) -> u8;
    fn graphql_sub_create(slot: c_int) -> c_int;
    fn graphql_sub_phase(slot: c_int) -> u8;
    fn graphql_sub_advance(slot: c_int) -> u8;
    fn graphql_sub_emit_event(slot: c_int) -> u8;
    fn graphql_sub_abort(slot: c_int) -> u8;
    fn graphql_sub_event_count(slot: c_int) -> u32;
    fn graphql_sub_can_transition(from: u8, to: u8) -> u8;
    fn graphql_introspection_query(slot: c_int, intro_field: u8) -> u8;
    fn graphql_check_depth(depth: u16, max_depth: u16) -> u8;
    fn graphql_check_complexity(score: u16, max_complexity: u16) -> u8;
}

// ---------------------------------------------------------------------------
// Context handle
// ---------------------------------------------------------------------------

/// An opaque handle to a GraphQL request context slot.
#[cfg(feature = "ffi")]
#[derive(Debug)]
pub struct GraphqlContext {
    slot: c_int,
}

#[cfg(feature = "ffi")]
impl Drop for GraphqlContext {
    fn drop(&mut self) {
        unsafe { graphql_destroy(self.slot) }
    }
}

// ---------------------------------------------------------------------------
// Safe wrappers
// ---------------------------------------------------------------------------

/// Return the ABI version.
#[cfg(feature = "ffi")]
pub fn abi_version() -> u32 {
    unsafe { graphql_abi_version() }
}

/// Create a new GraphQL request context.
///
/// `op_type`: 0 = Query, 1 = Mutation, 2 = Subscription.
#[cfg(feature = "ffi")]
pub fn create(op_type: u8) -> ProvenResult<GraphqlContext> {
    let slot = unsafe { graphql_create(op_type) };
    ProvenError::from_slot(slot).map(|s| GraphqlContext { slot: s })
}

/// Get the current request phase.
#[cfg(feature = "ffi")]
pub fn phase(ctx: &GraphqlContext) -> Option<GraphqlPhase> {
    let tag = unsafe { graphql_phase(ctx.slot) };
    GraphqlPhase::from_tag(tag)
}

/// Get the operation type tag (0=query, 1=mutation, 2=subscription).
#[cfg(feature = "ffi")]
pub fn operation_type(ctx: &GraphqlContext) -> u8 {
    unsafe { graphql_operation_type(ctx.slot) }
}

/// Get the error category tag (255 = no error).
#[cfg(feature = "ffi")]
pub fn error_category(ctx: &GraphqlContext) -> u8 {
    unsafe { graphql_error_category(ctx.slot) }
}

/// Advance to the next lifecycle phase.
#[cfg(feature = "ffi")]
pub fn advance(ctx: &GraphqlContext) -> ProvenResult<()> {
    let result = unsafe { graphql_advance(ctx.slot) };
    ProvenError::from_status(result)
}

/// Abort the request with an error category.
#[cfg(feature = "ffi")]
pub fn abort(ctx: &GraphqlContext, err_category: u8) -> ProvenResult<()> {
    let result = unsafe { graphql_abort(ctx.slot, err_category) };
    ProvenError::from_status(result)
}

/// Set the query nesting depth (for depth limiting).
#[cfg(feature = "ffi")]
pub fn set_query_depth(ctx: &GraphqlContext, depth: u16) -> ProvenResult<()> {
    let result = unsafe { graphql_set_query_depth(ctx.slot, depth) };
    ProvenError::from_status(result)
}

/// Get the current query depth.
#[cfg(feature = "ffi")]
pub fn query_depth(ctx: &GraphqlContext) -> u16 {
    unsafe { graphql_query_depth(ctx.slot) }
}

/// Set the query complexity score.
#[cfg(feature = "ffi")]
pub fn set_complexity(ctx: &GraphqlContext, score: u16) -> ProvenResult<()> {
    let result = unsafe { graphql_set_complexity(ctx.slot, score) };
    ProvenError::from_status(result)
}

/// Get the current complexity score.
#[cfg(feature = "ffi")]
pub fn complexity(ctx: &GraphqlContext) -> u16 {
    unsafe { graphql_complexity(ctx.slot) }
}

/// Record a field resolution with type and scalar kind.
#[cfg(feature = "ffi")]
pub fn resolve_field(ctx: &GraphqlContext, type_kind: u8, scalar_kind: u8) -> ProvenResult<()> {
    let result = unsafe { graphql_resolve_field(ctx.slot, type_kind, scalar_kind) };
    ProvenError::from_status(result)
}

/// Get the number of fields resolved so far.
#[cfg(feature = "ffi")]
pub fn fields_resolved(ctx: &GraphqlContext) -> u16 {
    unsafe { graphql_fields_resolved(ctx.slot) }
}

/// Stateless query: check whether a request phase transition is valid.
#[cfg(feature = "ffi")]
pub fn can_transition(from: GraphqlPhase, to: GraphqlPhase) -> bool {
    unsafe { graphql_can_transition(from.to_tag(), to.to_tag()) == 1 }
}

/// Create a subscription from a context in subscription operation type.
/// Returns the subscription slot ID.
#[cfg(feature = "ffi")]
pub fn sub_create(ctx: &GraphqlContext) -> ProvenResult<i32> {
    let slot = unsafe { graphql_sub_create(ctx.slot) };
    ProvenError::from_slot(slot)
}

/// Get the subscription phase tag.
#[cfg(feature = "ffi")]
pub fn sub_phase(ctx: &GraphqlContext) -> u8 {
    unsafe { graphql_sub_phase(ctx.slot) }
}

/// Advance the subscription lifecycle.
#[cfg(feature = "ffi")]
pub fn sub_advance(ctx: &GraphqlContext) -> ProvenResult<()> {
    let result = unsafe { graphql_sub_advance(ctx.slot) };
    ProvenError::from_status(result)
}

/// Emit a subscription event.
#[cfg(feature = "ffi")]
pub fn sub_emit_event(ctx: &GraphqlContext) -> ProvenResult<()> {
    let result = unsafe { graphql_sub_emit_event(ctx.slot) };
    ProvenError::from_status(result)
}

/// Abort a subscription.
#[cfg(feature = "ffi")]
pub fn sub_abort(ctx: &GraphqlContext) -> ProvenResult<()> {
    let result = unsafe { graphql_sub_abort(ctx.slot) };
    ProvenError::from_status(result)
}

/// Get the subscription event count.
#[cfg(feature = "ffi")]
pub fn sub_event_count(ctx: &GraphqlContext) -> u32 {
    unsafe { graphql_sub_event_count(ctx.slot) }
}

/// Run an introspection query on a specific field.
#[cfg(feature = "ffi")]
pub fn introspection_query(ctx: &GraphqlContext, intro_field: u8) -> ProvenResult<()> {
    let result = unsafe { graphql_introspection_query(ctx.slot, intro_field) };
    ProvenError::from_status(result)
}

/// Stateless: check if a query depth is within limits.
#[cfg(feature = "ffi")]
pub fn check_depth(depth: u16, max_depth: u16) -> bool {
    unsafe { graphql_check_depth(depth, max_depth) == 1 }
}

/// Stateless: check if a complexity score is within limits.
#[cfg(feature = "ffi")]
pub fn check_complexity(score: u16, max_complexity: u16) -> bool {
    unsafe { graphql_check_complexity(score, max_complexity) == 1 }
}
