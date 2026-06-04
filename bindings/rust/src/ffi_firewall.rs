// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! Safe Rust wrappers around the `proven-firewall` Zig FFI exports.
//!
//! Wraps the C-ABI functions from `protocols/proven-firewall/ffi/zig/src/firewall.zig`.
//! All functions are gated behind the `ffi` feature flag.

#[cfg(feature = "ffi")]
use crate::error::{ProvenError, ProvenResult};
#[cfg(feature = "ffi")]
use std::os::raw::c_int;

// ---------------------------------------------------------------------------
// Firewall enums (ABI tags from firewall.zig)
// ---------------------------------------------------------------------------

/// Firewall rule actions matching `Action` in firewall.zig.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum FirewallAction {
    /// Accept the packet.
    Accept = 0,
    /// Silently drop the packet.
    Drop = 1,
    /// Reject with ICMP error.
    Reject = 2,
    /// Log and continue processing.
    Log = 3,
    /// Redirect to a different destination.
    Redirect = 4,
    /// Destination NAT.
    Dnat = 5,
    /// Source NAT.
    Snat = 6,
    /// IP masquerading.
    Masquerade = 7,
}

#[cfg(feature = "ffi")]
impl FirewallAction {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Accept),
            1 => Some(Self::Drop),
            2 => Some(Self::Reject),
            3 => Some(Self::Log),
            4 => Some(Self::Redirect),
            5 => Some(Self::Dnat),
            6 => Some(Self::Snat),
            7 => Some(Self::Masquerade),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

/// Firewall packet lifecycle states.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PacketState {
    /// No packet classified yet.
    Idle = 0,
    /// Packet classified (protocol, IPs, ports set).
    Classified = 1,
    /// Chain evaluation in progress.
    Evaluating = 2,
    /// Decision made.
    Decided = 3,
    /// Committed (final).
    Committed = 4,
}

#[cfg(feature = "ffi")]
impl PacketState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Classified),
            2 => Some(Self::Evaluating),
            3 => Some(Self::Decided),
            4 => Some(Self::Committed),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }
}

/// Connection tracking states.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ConntrackState {
    /// No connection tracking.
    None = 0,
    /// Tracking in progress.
    Tracking = 1,
    /// Connection established.
    Established = 2,
    /// Related connection.
    Related = 3,
    /// Connection expired.
    Expired = 4,
}

#[cfg(feature = "ffi")]
impl ConntrackState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::None),
            1 => Some(Self::Tracking),
            2 => Some(Self::Established),
            3 => Some(Self::Related),
            4 => Some(Self::Expired),
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
    fn fw_abi_version() -> u32;
    fn fw_create_context() -> c_int;
    fn fw_destroy_context(slot: c_int);
    fn fw_packet_state(slot: c_int) -> u8;
    fn fw_conntrack_state(slot: c_int) -> u8;
    fn fw_get_decision(slot: c_int) -> u8;
    fn fw_rule_count(slot: c_int) -> u16;
    fn fw_packet_proto(slot: c_int) -> u8;
    fn fw_packet_chain(slot: c_int) -> u8;
    fn fw_packet_src_ip(slot: c_int) -> u32;
    fn fw_packet_dst_ip(slot: c_int) -> u32;
    fn fw_packet_src_port(slot: c_int) -> u16;
    fn fw_packet_dst_port(slot: c_int) -> u16;
    fn fw_conn_state(slot: c_int) -> u8;
    fn fw_classify_packet(
        slot: c_int, proto: u8, chain: u8,
        src_ip: u32, dst_ip: u32,
        src_port: u16, dst_port: u16,
    ) -> u8;
    fn fw_begin_chain(slot: c_int) -> u8;
    fn fw_add_rule(slot: c_int, match_type: u8, match_value: u32, action: u8, priority: u16) -> u8;
    fn fw_set_default_action(slot: c_int, action: u8) -> u8;
    fn fw_evaluate_rules(slot: c_int) -> u8;
    fn fw_commit(slot: c_int) -> u8;
    fn fw_begin_tracking(slot: c_int) -> u8;
    fn fw_complete_tracking(slot: c_int, conn_state_tag: u8) -> u8;
    fn fw_expire_conn(slot: c_int) -> u8;
    fn fw_can_transition(from: u8, to: u8) -> u8;
    fn fw_can_conntrack_transition(from: u8, to: u8) -> u8;
}

// ---------------------------------------------------------------------------
// Context handle
// ---------------------------------------------------------------------------

/// An opaque handle to a firewall context slot.
#[cfg(feature = "ffi")]
#[derive(Debug)]
pub struct FirewallContext {
    slot: c_int,
}

#[cfg(feature = "ffi")]
impl Drop for FirewallContext {
    fn drop(&mut self) {
        unsafe { fw_destroy_context(self.slot) }
    }
}

// ---------------------------------------------------------------------------
// Safe wrappers
// ---------------------------------------------------------------------------

/// Return the ABI version.
#[cfg(feature = "ffi")]
pub fn abi_version() -> u32 {
    unsafe { fw_abi_version() }
}

/// Create a new firewall context.
#[cfg(feature = "ffi")]
pub fn create_context() -> ProvenResult<FirewallContext> {
    let slot = unsafe { fw_create_context() };
    ProvenError::from_slot(slot).map(|s| FirewallContext { slot: s })
}

/// Get the current packet lifecycle state.
#[cfg(feature = "ffi")]
pub fn packet_state(ctx: &FirewallContext) -> Option<PacketState> {
    let tag = unsafe { fw_packet_state(ctx.slot) };
    PacketState::from_tag(tag)
}

/// Get the current connection tracking state.
#[cfg(feature = "ffi")]
pub fn conntrack_state(ctx: &FirewallContext) -> Option<ConntrackState> {
    let tag = unsafe { fw_conntrack_state(ctx.slot) };
    ConntrackState::from_tag(tag)
}

/// Get the decision action tag (only meaningful after evaluation).
#[cfg(feature = "ffi")]
pub fn get_decision(ctx: &FirewallContext) -> Option<FirewallAction> {
    let tag = unsafe { fw_get_decision(ctx.slot) };
    FirewallAction::from_tag(tag)
}

/// Get the number of rules in the chain.
#[cfg(feature = "ffi")]
pub fn rule_count(ctx: &FirewallContext) -> u16 {
    unsafe { fw_rule_count(ctx.slot) }
}

/// Get the classified packet protocol tag.
#[cfg(feature = "ffi")]
pub fn packet_proto(ctx: &FirewallContext) -> u8 {
    unsafe { fw_packet_proto(ctx.slot) }
}

/// Get the classified packet chain tag.
#[cfg(feature = "ffi")]
pub fn packet_chain(ctx: &FirewallContext) -> u8 {
    unsafe { fw_packet_chain(ctx.slot) }
}

/// Get the source IP (as a raw u32 in network order).
#[cfg(feature = "ffi")]
pub fn packet_src_ip(ctx: &FirewallContext) -> u32 {
    unsafe { fw_packet_src_ip(ctx.slot) }
}

/// Get the destination IP.
#[cfg(feature = "ffi")]
pub fn packet_dst_ip(ctx: &FirewallContext) -> u32 {
    unsafe { fw_packet_dst_ip(ctx.slot) }
}

/// Get the source port.
#[cfg(feature = "ffi")]
pub fn packet_src_port(ctx: &FirewallContext) -> u16 {
    unsafe { fw_packet_src_port(ctx.slot) }
}

/// Get the destination port.
#[cfg(feature = "ffi")]
pub fn packet_dst_port(ctx: &FirewallContext) -> u16 {
    unsafe { fw_packet_dst_port(ctx.slot) }
}

/// Classify a packet (set protocol, chain, IPs, ports). Transitions Idle -> Classified.
#[cfg(feature = "ffi")]
pub fn classify_packet(
    ctx: &FirewallContext,
    proto: u8,
    chain: u8,
    src_ip: u32,
    dst_ip: u32,
    src_port: u16,
    dst_port: u16,
) -> ProvenResult<()> {
    let result = unsafe {
        fw_classify_packet(ctx.slot, proto, chain, src_ip, dst_ip, src_port, dst_port)
    };
    ProvenError::from_status(result)
}

/// Begin chain evaluation. Transitions Classified -> Evaluating.
#[cfg(feature = "ffi")]
pub fn begin_chain(ctx: &FirewallContext) -> ProvenResult<()> {
    let result = unsafe { fw_begin_chain(ctx.slot) };
    ProvenError::from_status(result)
}

/// Add a rule to the evaluation chain.
#[cfg(feature = "ffi")]
pub fn add_rule(
    ctx: &FirewallContext,
    match_type: u8,
    match_value: u32,
    action: FirewallAction,
    priority: u16,
) -> ProvenResult<()> {
    let result = unsafe {
        fw_add_rule(ctx.slot, match_type, match_value, action.to_tag(), priority)
    };
    ProvenError::from_status(result)
}

/// Set the default action (applied when no rules match).
#[cfg(feature = "ffi")]
pub fn set_default_action(ctx: &FirewallContext, action: FirewallAction) -> ProvenResult<()> {
    let result = unsafe { fw_set_default_action(ctx.slot, action.to_tag()) };
    ProvenError::from_status(result)
}

/// Evaluate rules against the classified packet. Transitions Evaluating -> Decided.
#[cfg(feature = "ffi")]
pub fn evaluate_rules(ctx: &FirewallContext) -> ProvenResult<()> {
    let result = unsafe { fw_evaluate_rules(ctx.slot) };
    ProvenError::from_status(result)
}

/// Commit the decision. Transitions Decided -> Committed.
#[cfg(feature = "ffi")]
pub fn commit(ctx: &FirewallContext) -> ProvenResult<()> {
    let result = unsafe { fw_commit(ctx.slot) };
    ProvenError::from_status(result)
}

/// Begin connection tracking. Transitions None -> Tracking.
#[cfg(feature = "ffi")]
pub fn begin_tracking(ctx: &FirewallContext) -> ProvenResult<()> {
    let result = unsafe { fw_begin_tracking(ctx.slot) };
    ProvenError::from_status(result)
}

/// Complete connection tracking with a state. Transitions Tracking -> state.
#[cfg(feature = "ffi")]
pub fn complete_tracking(ctx: &FirewallContext, conn_state: ConntrackState) -> ProvenResult<()> {
    let result = unsafe { fw_complete_tracking(ctx.slot, conn_state.to_tag()) };
    ProvenError::from_status(result)
}

/// Expire a connection. Transitions Established/Related -> Expired.
#[cfg(feature = "ffi")]
pub fn expire_conn(ctx: &FirewallContext) -> ProvenResult<()> {
    let result = unsafe { fw_expire_conn(ctx.slot) };
    ProvenError::from_status(result)
}

/// Stateless query: check whether a packet state transition is valid.
#[cfg(feature = "ffi")]
pub fn can_transition(from: PacketState, to: PacketState) -> bool {
    unsafe { fw_can_transition(from.to_tag(), to.to_tag()) == 1 }
}

/// Stateless query: check whether a conntrack state transition is valid.
#[cfg(feature = "ffi")]
pub fn can_conntrack_transition(from: ConntrackState, to: ConntrackState) -> bool {
    unsafe { fw_can_conntrack_transition(from.to_tag(), to.to_tag()) == 1 }
}
