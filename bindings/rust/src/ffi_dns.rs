// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! Safe Rust wrappers around the `proven-dns` Zig FFI exports.
//!
//! Wraps the C-ABI functions from `protocols/proven-dns/ffi/zig/src/dns.zig`:
//! - Context lifecycle: `dns_create_context`, `dns_destroy_context`
//! - Query parsing: `dns_parse_query`
//! - Lifecycle transitions: `dns_begin_lookup`, `dns_begin_response`
//! - Record management: `dns_add_answer`, `dns_add_authority`, `dns_add_additional`
//! - Response building: `dns_set_rcode`, `dns_build_response`
//! - DNSSEC: `dns_enable_dnssec`, `dns_load_dnssec_key`, `dns_sign_response`,
//!   `dns_validate_dnssec`
//! - State queries: `dns_state`, `dns_dnssec_state`, `dns_rcode`,
//!   `dns_answer_count`, `dns_authority_count`, `dns_additional_count`,
//!   `dns_query_rtype`, `dns_query_class`
//! - Transition checks: `dns_can_transition`, `dns_can_dnssec_transition`
//!
//! All functions are gated behind the `ffi` feature flag.

#[cfg(feature = "ffi")]
use crate::error::{ProvenError, ProvenResult};
#[cfg(feature = "ffi")]
use std::os::raw::c_int;

// ---------------------------------------------------------------------------
// DNS lifecycle states (ABI tags from dns.zig)
// ---------------------------------------------------------------------------

/// DNS query lifecycle states matching `DnsState` in dns.zig.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DnsState {
    /// Waiting for a query.
    Idle = 0,
    /// Query received and parsed.
    QueryReceived = 1,
    /// Performing DNS lookup.
    Lookup = 2,
    /// Building response message.
    ResponseBuilding = 3,
    /// Response sent (terminal).
    Sent = 4,
}

#[cfg(feature = "ffi")]
impl DnsState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::QueryReceived),
            2 => Some(Self::Lookup),
            3 => Some(Self::ResponseBuilding),
            4 => Some(Self::Sent),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

/// DNSSEC states matching `DnssecState` in dns.zig.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DnssecState {
    /// DNSSEC disabled.
    Disabled = 0,
    /// DNSSEC enabled, no key loaded.
    Enabled = 1,
    /// DNSSEC key loaded.
    KeyLoaded = 2,
    /// Response validated / signed.
    Validated = 3,
}

#[cfg(feature = "ffi")]
impl DnssecState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Disabled),
            1 => Some(Self::Enabled),
            2 => Some(Self::KeyLoaded),
            3 => Some(Self::Validated),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

/// DNSSEC signing algorithms matching `DnssecAlgorithm` in dns.zig.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DnssecAlgorithm {
    /// RSA/SHA-256.
    RsaSha256 = 0,
    /// RSA/SHA-512.
    RsaSha512 = 1,
    /// ECDSA P-256/SHA-256.
    EcdsaP256Sha256 = 2,
    /// ECDSA P-384/SHA-384.
    EcdsaP384Sha384 = 3,
    /// Ed25519.
    Ed25519 = 4,
}

#[cfg(feature = "ffi")]
impl DnssecAlgorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::RsaSha256),
            1 => Some(Self::RsaSha512),
            2 => Some(Self::EcdsaP256Sha256),
            3 => Some(Self::EcdsaP384Sha384),
            4 => Some(Self::Ed25519),
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
    fn dns_abi_version() -> u32;
    fn dns_create_context() -> c_int;
    fn dns_destroy_context(slot: c_int);
    fn dns_state(slot: c_int) -> u8;
    fn dns_dnssec_state(slot: c_int) -> u8;
    fn dns_rcode(slot: c_int) -> u8;
    fn dns_answer_count(slot: c_int) -> u16;
    fn dns_authority_count(slot: c_int) -> u16;
    fn dns_additional_count(slot: c_int) -> u16;
    fn dns_query_rtype(slot: c_int) -> u8;
    fn dns_query_class(slot: c_int) -> u8;
    fn dns_parse_query(slot: c_int, buf: *const u8, len: u16) -> u8;
    fn dns_begin_lookup(slot: c_int) -> u8;
    fn dns_begin_response(slot: c_int) -> u8;
    fn dns_add_answer(slot: c_int, rtype: u8, rclass: u8, ttl: u32, rdata: *const u8, rdlen: u16) -> u8;
    fn dns_add_authority(slot: c_int, rtype: u8, rclass: u8, ttl: u32, rdata: *const u8, rdlen: u16) -> u8;
    fn dns_add_additional(slot: c_int, rtype: u8, rclass: u8, ttl: u32, rdata: *const u8, rdlen: u16) -> u8;
    fn dns_set_rcode(slot: c_int, rcode_tag: u8) -> u8;
    fn dns_build_response(slot: c_int, out: *mut u8, out_len: *mut u16) -> u8;
    fn dns_enable_dnssec(slot: c_int) -> u8;
    fn dns_load_dnssec_key(slot: c_int, algo: u8) -> u8;
    fn dns_sign_response(slot: c_int) -> u8;
    fn dns_validate_dnssec(slot: c_int) -> u8;
    fn dns_can_transition(from: u8, to: u8) -> u8;
    fn dns_can_dnssec_transition(from: u8, to: u8) -> u8;
}

// ---------------------------------------------------------------------------
// Context handle
// ---------------------------------------------------------------------------

/// An opaque handle to a DNS context slot in the Zig FFI pool.
///
/// Created via [`create_context`] and automatically destroyed on drop.
#[cfg(feature = "ffi")]
#[derive(Debug)]
pub struct DnsContext {
    slot: c_int,
}

#[cfg(feature = "ffi")]
impl Drop for DnsContext {
    fn drop(&mut self) {
        unsafe { dns_destroy_context(self.slot) }
    }
}

// ---------------------------------------------------------------------------
// Safe wrappers
// ---------------------------------------------------------------------------

/// Return the ABI version of the linked DNS library.
#[cfg(feature = "ffi")]
pub fn abi_version() -> u32 {
    unsafe { dns_abi_version() }
}

/// Create a new DNS context in the Idle state.
#[cfg(feature = "ffi")]
pub fn create_context() -> ProvenResult<DnsContext> {
    let slot = unsafe { dns_create_context() };
    ProvenError::from_slot(slot).map(|s| DnsContext { slot: s })
}

/// Get the current lifecycle state.
#[cfg(feature = "ffi")]
pub fn state(ctx: &DnsContext) -> Option<DnsState> {
    let tag = unsafe { dns_state(ctx.slot) };
    DnsState::from_tag(tag)
}

/// Get the current DNSSEC state.
#[cfg(feature = "ffi")]
pub fn dnssec_state(ctx: &DnsContext) -> Option<DnssecState> {
    let tag = unsafe { dns_dnssec_state(ctx.slot) };
    DnssecState::from_tag(tag)
}

/// Get the response code tag.
#[cfg(feature = "ffi")]
pub fn rcode(ctx: &DnsContext) -> u8 {
    unsafe { dns_rcode(ctx.slot) }
}

/// Get the number of answer records.
#[cfg(feature = "ffi")]
pub fn answer_count(ctx: &DnsContext) -> u16 {
    unsafe { dns_answer_count(ctx.slot) }
}

/// Get the number of authority records.
#[cfg(feature = "ffi")]
pub fn authority_count(ctx: &DnsContext) -> u16 {
    unsafe { dns_authority_count(ctx.slot) }
}

/// Get the number of additional records.
#[cfg(feature = "ffi")]
pub fn additional_count(ctx: &DnsContext) -> u16 {
    unsafe { dns_additional_count(ctx.slot) }
}

/// Get the query record type (ABI tag, 255 = unset).
#[cfg(feature = "ffi")]
pub fn query_rtype(ctx: &DnsContext) -> u8 {
    unsafe { dns_query_rtype(ctx.slot) }
}

/// Get the query class (ABI tag, 255 = unset).
#[cfg(feature = "ffi")]
pub fn query_class(ctx: &DnsContext) -> u8 {
    unsafe { dns_query_class(ctx.slot) }
}

/// Parse a DNS query from raw bytes. Transitions Idle -> QueryReceived.
#[cfg(feature = "ffi")]
pub fn parse_query(ctx: &DnsContext, data: &[u8]) -> ProvenResult<()> {
    let result = unsafe {
        dns_parse_query(ctx.slot, data.as_ptr(), data.len() as u16)
    };
    ProvenError::from_status(result)
}

/// Begin DNS lookup. Transitions QueryReceived -> Lookup.
#[cfg(feature = "ffi")]
pub fn begin_lookup(ctx: &DnsContext) -> ProvenResult<()> {
    let result = unsafe { dns_begin_lookup(ctx.slot) };
    ProvenError::from_status(result)
}

/// Begin building the response. Transitions Lookup -> ResponseBuilding.
#[cfg(feature = "ffi")]
pub fn begin_response(ctx: &DnsContext) -> ProvenResult<()> {
    let result = unsafe { dns_begin_response(ctx.slot) };
    ProvenError::from_status(result)
}

/// Add a resource record to the answer section.
///
/// Only valid in ResponseBuilding state. Record type and class are ABI tags.
#[cfg(feature = "ffi")]
pub fn add_answer(ctx: &DnsContext, rtype: u8, rclass: u8, ttl: u32, rdata: &[u8]) -> ProvenResult<()> {
    let result = unsafe {
        dns_add_answer(ctx.slot, rtype, rclass, ttl, rdata.as_ptr(), rdata.len() as u16)
    };
    ProvenError::from_status(result)
}

/// Add a resource record to the authority section.
#[cfg(feature = "ffi")]
pub fn add_authority(ctx: &DnsContext, rtype: u8, rclass: u8, ttl: u32, rdata: &[u8]) -> ProvenResult<()> {
    let result = unsafe {
        dns_add_authority(ctx.slot, rtype, rclass, ttl, rdata.as_ptr(), rdata.len() as u16)
    };
    ProvenError::from_status(result)
}

/// Add a resource record to the additional section.
#[cfg(feature = "ffi")]
pub fn add_additional(ctx: &DnsContext, rtype: u8, rclass: u8, ttl: u32, rdata: &[u8]) -> ProvenResult<()> {
    let result = unsafe {
        dns_add_additional(ctx.slot, rtype, rclass, ttl, rdata.as_ptr(), rdata.len() as u16)
    };
    ProvenError::from_status(result)
}

/// Set the response code (RCODE). Only valid in ResponseBuilding state.
#[cfg(feature = "ffi")]
pub fn set_rcode(ctx: &DnsContext, rcode_tag: u8) -> ProvenResult<()> {
    let result = unsafe { dns_set_rcode(ctx.slot, rcode_tag) };
    ProvenError::from_status(result)
}

/// Build the DNS response message. Transitions ResponseBuilding -> Sent.
///
/// The output buffer must be at least 512 bytes. On success, returns the
/// number of bytes written to `out`.
#[cfg(feature = "ffi")]
pub fn build_response(ctx: &DnsContext, out: &mut [u8]) -> ProvenResult<u16> {
    let mut out_len: u16 = 0;
    let result = unsafe {
        dns_build_response(ctx.slot, out.as_mut_ptr(), &mut out_len)
    };
    ProvenError::from_status(result).map(|()| out_len)
}

/// Enable DNSSEC. Transitions Disabled -> Enabled.
#[cfg(feature = "ffi")]
pub fn enable_dnssec(ctx: &DnsContext) -> ProvenResult<()> {
    let result = unsafe { dns_enable_dnssec(ctx.slot) };
    ProvenError::from_status(result)
}

/// Load a DNSSEC signing key. Transitions Enabled -> KeyLoaded.
#[cfg(feature = "ffi")]
pub fn load_dnssec_key(ctx: &DnsContext, algo: DnssecAlgorithm) -> ProvenResult<()> {
    let result = unsafe { dns_load_dnssec_key(ctx.slot, algo.to_tag()) };
    ProvenError::from_status(result)
}

/// Sign the response (DNSSEC). Transitions KeyLoaded -> Validated.
#[cfg(feature = "ffi")]
pub fn sign_response(ctx: &DnsContext) -> ProvenResult<()> {
    let result = unsafe { dns_sign_response(ctx.slot) };
    ProvenError::from_status(result)
}

/// Check DNSSEC validation result. Returns `true` if validated.
#[cfg(feature = "ffi")]
pub fn validate_dnssec(ctx: &DnsContext) -> bool {
    unsafe { dns_validate_dnssec(ctx.slot) == 0 }
}

/// Stateless query: check whether a DNS lifecycle transition is valid.
#[cfg(feature = "ffi")]
pub fn can_transition(from: DnsState, to: DnsState) -> bool {
    unsafe { dns_can_transition(from.to_tag(), to.to_tag()) == 1 }
}

/// Stateless query: check whether a DNSSEC state transition is valid.
#[cfg(feature = "ffi")]
pub fn can_dnssec_transition(from: DnssecState, to: DnssecState) -> bool {
    unsafe { dns_can_dnssec_transition(from.to_tag(), to.to_tag()) == 1 }
}
