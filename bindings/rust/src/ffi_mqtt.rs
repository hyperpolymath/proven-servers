// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! Safe Rust wrappers around the `proven-mqtt` Zig FFI exports.
//!
//! Wraps the C-ABI functions from `protocols/proven-mqtt/ffi/zig/src/mqtt.zig`.
//! All functions are gated behind the `ffi` feature flag.

#[cfg(feature = "ffi")]
use crate::error::{ProvenError, ProvenResult};
#[cfg(feature = "ffi")]
use crate::mqtt::QoS;
#[cfg(feature = "ffi")]
use std::os::raw::c_int;

// ---------------------------------------------------------------------------
// MQTT session states (ABI tags from mqtt.zig)
// ---------------------------------------------------------------------------

/// MQTT broker session states matching the Zig FFI.
#[cfg(feature = "ffi")]
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum MqttSessionState {
    /// Client connected, CONNECT not yet received.
    Idle = 0,
    /// CONNECT received, session active.
    Connected = 1,
    /// Client disconnected cleanly.
    Disconnected = 2,
}

#[cfg(feature = "ffi")]
impl MqttSessionState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Connected),
            2 => Some(Self::Disconnected),
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
    fn mqtt_abi_version() -> u32;
    fn mqtt_create(version: u8, clean_session: u8, keep_alive: u16) -> c_int;
    fn mqtt_destroy(slot: c_int);
    fn mqtt_state(slot: c_int) -> u8;
    fn mqtt_version(slot: c_int) -> u8;
    fn mqtt_can_publish(slot: c_int) -> u8;
    fn mqtt_can_subscribe(slot: c_int) -> u8;
    fn mqtt_subscription_count(slot: c_int) -> u32;
    fn mqtt_subscribe(slot: c_int, topic_ptr: *const u8, topic_len: u32, qos: u8) -> u8;
    fn mqtt_unsubscribe(slot: c_int, topic_ptr: *const u8, topic_len: u32) -> u8;
    fn mqtt_publish(
        slot: c_int, topic_ptr: *const u8, topic_len: u32,
        payload_ptr: *const u8, payload_len: u32,
        qos: u8, retain: u8, packet_id: u16,
    ) -> u8;
    fn mqtt_puback(slot: c_int, packet_id: u16) -> u8;
    fn mqtt_pubrec(slot: c_int, packet_id: u16) -> u8;
    fn mqtt_pubrel(slot: c_int, packet_id: u16) -> u8;
    fn mqtt_pubcomp(slot: c_int, packet_id: u16) -> u8;
    fn mqtt_qos_state(slot: c_int, packet_id: u16) -> u8;
    fn mqtt_disconnect(slot: c_int) -> u8;
    fn mqtt_cleanup(slot: c_int) -> u8;
    fn mqtt_retained_count() -> u32;
    fn mqtt_can_transition(from: u8, to: u8) -> u8;
    fn mqtt_qos_can_transition(qos_level: u8, from: u8, to: u8) -> u8;
    fn mqtt_topic_matches(
        filter_ptr: *const u8, filter_len: u32,
        topic_ptr: *const u8, topic_len: u32,
    ) -> u8;
}

// ---------------------------------------------------------------------------
// Context handle
// ---------------------------------------------------------------------------

/// An opaque handle to an MQTT session context slot.
#[cfg(feature = "ffi")]
#[derive(Debug)]
pub struct MqttContext {
    slot: c_int,
}

#[cfg(feature = "ffi")]
impl Drop for MqttContext {
    fn drop(&mut self) {
        unsafe { mqtt_destroy(self.slot) }
    }
}

// ---------------------------------------------------------------------------
// Safe wrappers
// ---------------------------------------------------------------------------

/// Return the ABI version.
#[cfg(feature = "ffi")]
pub fn abi_version() -> u32 {
    unsafe { mqtt_abi_version() }
}

/// Create a new MQTT session.
///
/// `version`: 0 = MQTT 3.1.1, 1 = MQTT 5.0.
/// `clean_session`: whether to start a clean session.
/// `keep_alive`: keep-alive interval in seconds.
#[cfg(feature = "ffi")]
pub fn create(version: u8, clean_session: bool, keep_alive: u16) -> ProvenResult<MqttContext> {
    let slot = unsafe { mqtt_create(version, clean_session as u8, keep_alive) };
    ProvenError::from_slot(slot).map(|s| MqttContext { slot: s })
}

/// Get the current session state.
#[cfg(feature = "ffi")]
pub fn state(ctx: &MqttContext) -> Option<MqttSessionState> {
    let tag = unsafe { mqtt_state(ctx.slot) };
    MqttSessionState::from_tag(tag)
}

/// Get the MQTT protocol version tag.
#[cfg(feature = "ffi")]
pub fn version(ctx: &MqttContext) -> u8 {
    unsafe { mqtt_version(ctx.slot) }
}

/// Check if the session can publish messages.
#[cfg(feature = "ffi")]
pub fn can_publish(ctx: &MqttContext) -> bool {
    unsafe { mqtt_can_publish(ctx.slot) == 1 }
}

/// Check if the session can subscribe to topics.
#[cfg(feature = "ffi")]
pub fn can_subscribe(ctx: &MqttContext) -> bool {
    unsafe { mqtt_can_subscribe(ctx.slot) == 1 }
}

/// Get the number of active subscriptions.
#[cfg(feature = "ffi")]
pub fn subscription_count(ctx: &MqttContext) -> u32 {
    unsafe { mqtt_subscription_count(ctx.slot) }
}

/// Subscribe to a topic with the given QoS level.
#[cfg(feature = "ffi")]
pub fn subscribe(ctx: &MqttContext, topic: &str, qos: QoS) -> ProvenResult<()> {
    let result = unsafe {
        mqtt_subscribe(ctx.slot, topic.as_ptr(), topic.len() as u32, qos.to_code())
    };
    ProvenError::from_status(result)
}

/// Unsubscribe from a topic.
#[cfg(feature = "ffi")]
pub fn unsubscribe(ctx: &MqttContext, topic: &str) -> ProvenResult<()> {
    let result = unsafe {
        mqtt_unsubscribe(ctx.slot, topic.as_ptr(), topic.len() as u32)
    };
    ProvenError::from_status(result)
}

/// Publish a message to a topic.
#[cfg(feature = "ffi")]
pub fn publish(
    ctx: &MqttContext,
    topic: &str,
    payload: &[u8],
    qos: QoS,
    retain: bool,
    packet_id: u16,
) -> ProvenResult<()> {
    let result = unsafe {
        mqtt_publish(
            ctx.slot,
            topic.as_ptr(), topic.len() as u32,
            payload.as_ptr(), payload.len() as u32,
            qos.to_code(), retain as u8, packet_id,
        )
    };
    ProvenError::from_status(result)
}

/// Acknowledge a QoS 1 publish (PUBACK).
#[cfg(feature = "ffi")]
pub fn puback(ctx: &MqttContext, packet_id: u16) -> ProvenResult<()> {
    let result = unsafe { mqtt_puback(ctx.slot, packet_id) };
    ProvenError::from_status(result)
}

/// QoS 2 step 1: publish received (PUBREC).
#[cfg(feature = "ffi")]
pub fn pubrec(ctx: &MqttContext, packet_id: u16) -> ProvenResult<()> {
    let result = unsafe { mqtt_pubrec(ctx.slot, packet_id) };
    ProvenError::from_status(result)
}

/// QoS 2 step 2: publish release (PUBREL).
#[cfg(feature = "ffi")]
pub fn pubrel(ctx: &MqttContext, packet_id: u16) -> ProvenResult<()> {
    let result = unsafe { mqtt_pubrel(ctx.slot, packet_id) };
    ProvenError::from_status(result)
}

/// QoS 2 step 3: publish complete (PUBCOMP).
#[cfg(feature = "ffi")]
pub fn pubcomp(ctx: &MqttContext, packet_id: u16) -> ProvenResult<()> {
    let result = unsafe { mqtt_pubcomp(ctx.slot, packet_id) };
    ProvenError::from_status(result)
}

/// Get the QoS delivery state for a packet ID (ABI tag).
#[cfg(feature = "ffi")]
pub fn qos_state(ctx: &MqttContext, packet_id: u16) -> u8 {
    unsafe { mqtt_qos_state(ctx.slot, packet_id) }
}

/// Disconnect the session cleanly.
#[cfg(feature = "ffi")]
pub fn disconnect(ctx: &MqttContext) -> ProvenResult<()> {
    let result = unsafe { mqtt_disconnect(ctx.slot) };
    ProvenError::from_status(result)
}

/// Clean up session resources (subscriptions, QoS state).
#[cfg(feature = "ffi")]
pub fn cleanup(ctx: &MqttContext) -> ProvenResult<()> {
    let result = unsafe { mqtt_cleanup(ctx.slot) };
    ProvenError::from_status(result)
}

/// Get the global retained message count.
#[cfg(feature = "ffi")]
pub fn retained_count() -> u32 {
    unsafe { mqtt_retained_count() }
}

/// Stateless query: check whether a session state transition is valid.
#[cfg(feature = "ffi")]
pub fn can_transition(from: MqttSessionState, to: MqttSessionState) -> bool {
    unsafe { mqtt_can_transition(from.to_tag(), to.to_tag()) == 1 }
}

/// Stateless query: check whether a QoS delivery state transition is valid.
#[cfg(feature = "ffi")]
pub fn qos_can_transition(qos_level: QoS, from: u8, to: u8) -> bool {
    unsafe { mqtt_qos_can_transition(qos_level.to_code(), from, to) == 1 }
}

/// Stateless query: check if a topic matches a subscription filter.
///
/// Supports MQTT wildcards: `+` (single level), `#` (multi level).
#[cfg(feature = "ffi")]
pub fn topic_matches(filter: &str, topic: &str) -> bool {
    unsafe {
        mqtt_topic_matches(
            filter.as_ptr(), filter.len() as u32,
            topic.as_ptr(), topic.len() as u32,
        ) == 1
    }
}
