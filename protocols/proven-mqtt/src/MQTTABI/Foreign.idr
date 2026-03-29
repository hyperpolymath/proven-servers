-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- MQTTABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/mqtt.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Topic subscription tree (fixed array)
--   - QoS delivery tracking per session
--   - Retained message store
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching MQTTABI.Layout exactly.

module MQTTABI.Foreign

import MQTTABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an MQTT broker session.
||| Created by mqtt_create(), destroyed by mqtt_destroy().
export
data MqttContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match mqtt_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (16+ functions)
---------------------------------------------------------------------------

-- +-------------------------+-----------------------------------------------+
-- | Function                | Signature                                     |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_abi_version        | () -> u32                                     |
-- |                         | Returns ABI version (must equal abiVersion).  |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_create             | (version: u8, clean_session: u8,              |
-- |                         |  keep_alive: u16) -> c_int (slot)             |
-- |                         | Creates session in Idle state, then           |
-- |                         | transitions to Connected. Returns -1 on       |
-- |                         | failure (no free slots or invalid version).   |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_destroy            | (slot: c_int) -> void                         |
-- |                         | Releases a session slot.                      |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_state              | (slot: c_int) -> u8 (BrokerState tag)         |
-- |                         | Returns current broker state for the session. |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_version            | (slot: c_int) -> u8 (MQTTVersion tag)         |
-- |                         | Returns the MQTT protocol version.            |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_subscribe          | (slot: c_int, topic_ptr: ptr, topic_len: u32, |
-- |                         |  qos: u8) -> u8 (0=ok, 1=rejected)           |
-- |                         | Subscribes to a topic filter. Transitions     |
-- |                         | Connected -> Subscribed or stays Subscribed.  |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_unsubscribe        | (slot: c_int, topic_ptr: ptr, topic_len: u32) |
-- |                         |  -> u8 (0=ok, 1=rejected)                     |
-- |                         | Unsubscribes from a topic. May transition     |
-- |                         | Subscribed -> Connected if last subscription. |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_subscription_count | (slot: c_int) -> u32                          |
-- |                         | Returns number of active subscriptions.       |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_publish            | (slot: c_int, topic_ptr: ptr, topic_len: u32, |
-- |                         |  payload_ptr: ptr, payload_len: u32,          |
-- |                         |  qos: u8, retain: u8,                         |
-- |                         |  packet_id: u16) -> u8 (0=ok, 1=rejected)    |
-- |                         | Publishes a message. For QoS > 0, begins     |
-- |                         | the delivery state machine.                   |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_puback             | (slot: c_int, packet_id: u16) -> u8           |
-- |                         | Acknowledges QoS 1 delivery (PUBACK).        |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_pubrec             | (slot: c_int, packet_id: u16) -> u8           |
-- |                         | QoS 2 step 1 acknowledgement (PUBREC).       |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_pubrel             | (slot: c_int, packet_id: u16) -> u8           |
-- |                         | QoS 2 step 2 release (PUBREL).               |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_pubcomp            | (slot: c_int, packet_id: u16) -> u8           |
-- |                         | QoS 2 step 3 complete (PUBCOMP).             |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_qos_state          | (slot: c_int, packet_id: u16) -> u8           |
-- |                         | Returns QoSDeliveryState tag for a packet ID.|
-- +-------------------------+-----------------------------------------------+
-- | mqtt_disconnect         | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                         | Client disconnect. Transitions to             |
-- |                         | Disconnecting from Connected/Subscribed/      |
-- |                         | Publishing.                                   |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_cleanup            | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                         | Complete cleanup. Transitions Disconnecting   |
-- |                         | -> Idle. Clears subscriptions and pending     |
-- |                         | messages if clean session.                    |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_can_publish        | (slot: c_int) -> u8 (1=yes, 0=no)            |
-- |                         | Whether the session can publish (Connected    |
-- |                         | or Subscribed).                               |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_can_subscribe      | (slot: c_int) -> u8 (1=yes, 0=no)            |
-- |                         | Whether the session can subscribe (Connected  |
-- |                         | or Subscribed).                               |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_retained_count     | () -> u32                                     |
-- |                         | Returns number of retained messages.          |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_can_transition     | (from: u8, to: u8) -> u8 (1=yes, 0=no)       |
-- |                         | Stateless: checks if a broker state           |
-- |                         | transition is valid per Transitions.idr.      |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_qos_can_transition | (qos_level: u8, from: u8, to: u8)            |
-- |                         |  -> u8 (1=yes, 0=no)                          |
-- |                         | Stateless: checks if a QoS delivery state    |
-- |                         | transition is valid for the given QoS level.  |
-- +-------------------------+-----------------------------------------------+
-- | mqtt_topic_matches      | (topic_ptr: ptr, topic_len: u32,              |
-- |                         |  filter_ptr: ptr, filter_len: u32)            |
-- |                         |  -> u8 (1=match, 0=no match)                  |
-- |                         | Stateless: topic name vs filter matching.     |
-- +-------------------------+-----------------------------------------------+
