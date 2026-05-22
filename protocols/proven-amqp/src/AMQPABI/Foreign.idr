-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- AMQPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/amqp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected session pool
--   - Channel tracking per session (max 16 channels per session)
--   - Exchange/queue/binding declarations per session
--   - Consumer tracking per channel
--   - Delivery tag monotonic counters per channel
--   - Publisher confirm tracking
--   - Topic exchange routing key matching
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching AMQPABI.Layout exactly.

module AMQPABI.Foreign

import AMQPABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an AMQP broker session.
||| Created by amqp_create(), destroyed by amqp_destroy().
export
data AmqpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match amqp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (22+ functions)
---------------------------------------------------------------------------

-- +-----------------------------+-------------------------------------------+
-- | Function                    | Signature                                 |
-- +-----------------------------+-------------------------------------------+
-- | amqp_abi_version            | () -> u32                                 |
-- |                             | Returns ABI version (must equal           |
-- |                             | abiVersion).                              |
-- +-----------------------------+-------------------------------------------+
-- | amqp_create                 | (vhost_ptr: ptr, vhost_len: u32,          |
-- |                             |  frame_max: u32, channel_max: u16,        |
-- |                             |  heartbeat: u16) -> c_int (slot)          |
-- |                             | Creates session, transitions Idle ->      |
-- |                             | Connected. Returns -1 on failure.         |
-- +-----------------------------+-------------------------------------------+
-- | amqp_destroy                | (slot: c_int) -> void                     |
-- |                             | Releases a session slot.                  |
-- +-----------------------------+-------------------------------------------+
-- | amqp_state                  | (slot: c_int) -> u8 (BrokerState tag)     |
-- |                             | Returns current broker state.             |
-- +-----------------------------+-------------------------------------------+
-- | amqp_channel_open           | (slot: c_int, channel: u16) -> u8         |
-- |                             | (0=ok, 1=rejected)                        |
-- |                             | Opens a channel. Transitions Connected    |
-- |                             | -> ChannelOpen or stays ChannelOpen.      |
-- +-----------------------------+-------------------------------------------+
-- | amqp_channel_close          | (slot: c_int, channel: u16) -> u8         |
-- |                             | (0=ok, 1=rejected)                        |
-- |                             | Closes a channel. May transition          |
-- |                             | ChannelOpen -> Connected if last.         |
-- +-----------------------------+-------------------------------------------+
-- | amqp_channel_count          | (slot: c_int) -> u16                      |
-- |                             | Returns number of open channels.          |
-- +-----------------------------+-------------------------------------------+
-- | amqp_exchange_declare       | (slot: c_int, channel: u16,               |
-- |                             |  name_ptr: ptr, name_len: u32,            |
-- |                             |  exch_type: u8, durable: u8,              |
-- |                             |  auto_delete: u8, internal: u8)           |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | amqp_queue_declare          | (slot: c_int, channel: u16,               |
-- |                             |  name_ptr: ptr, name_len: u32,            |
-- |                             |  durable: u8, exclusive: u8,              |
-- |                             |  auto_delete: u8) -> u8                   |
-- +-----------------------------+-------------------------------------------+
-- | amqp_queue_bind             | (slot: c_int, channel: u16,               |
-- |                             |  queue_ptr: ptr, queue_len: u32,          |
-- |                             |  exchange_ptr: ptr, exchange_len: u32,    |
-- |                             |  routing_key_ptr: ptr, rk_len: u32)      |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | amqp_basic_publish          | (slot: c_int, channel: u16,               |
-- |                             |  exchange_ptr: ptr, exchange_len: u32,    |
-- |                             |  routing_key_ptr: ptr, rk_len: u32,      |
-- |                             |  body_ptr: ptr, body_len: u32,           |
-- |                             |  delivery_mode: u8, priority: u8,        |
-- |                             |  mandatory: u8) -> u8                    |
-- +-----------------------------+-------------------------------------------+
-- | amqp_basic_consume          | (slot: c_int, channel: u16,               |
-- |                             |  queue_ptr: ptr, queue_len: u32,          |
-- |                             |  consumer_tag_ptr: ptr, ct_len: u32,     |
-- |                             |  no_ack: u8, exclusive: u8)              |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | Transitions ChannelOpen -> Consuming.     |
-- +-----------------------------+-------------------------------------------+
-- | amqp_basic_cancel           | (slot: c_int, channel: u16,               |
-- |                             |  consumer_tag_ptr: ptr, ct_len: u32)     |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- |                             | May transition Consuming -> ChannelOpen.  |
-- +-----------------------------+-------------------------------------------+
-- | amqp_basic_ack              | (slot: c_int, channel: u16,               |
-- |                             |  delivery_tag: u64, multiple: u8)        |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | amqp_basic_nack             | (slot: c_int, channel: u16,               |
-- |                             |  delivery_tag: u64, multiple: u8,        |
-- |                             |  requeue: u8) -> u8                      |
-- +-----------------------------+-------------------------------------------+
-- | amqp_basic_reject           | (slot: c_int, channel: u16,               |
-- |                             |  delivery_tag: u64, requeue: u8)         |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | amqp_basic_qos              | (slot: c_int, channel: u16,               |
-- |                             |  prefetch_count: u16,                     |
-- |                             |  prefetch_size: u32, global: u8)         |
-- |                             |  -> u8 (0=ok, 1=rejected)                 |
-- +-----------------------------+-------------------------------------------+
-- | amqp_consumer_count         | (slot: c_int) -> u32                      |
-- |                             | Returns total active consumers.           |
-- +-----------------------------+-------------------------------------------+
-- | amqp_disconnect             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions to Disconnecting.             |
-- +-----------------------------+-------------------------------------------+
-- | amqp_cleanup                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Transitions Disconnecting -> Idle.        |
-- +-----------------------------+-------------------------------------------+
-- | amqp_can_publish            | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- +-----------------------------+-------------------------------------------+
-- | amqp_can_consume            | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- +-----------------------------+-------------------------------------------+
-- | amqp_can_transition         | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless: checks broker state            |
-- |                             | transition validity.                      |
-- +-----------------------------+-------------------------------------------+
-- | amqp_routing_match          | (routing_key_ptr: ptr, rk_len: u32,       |
-- |                             |  pattern_ptr: ptr, pat_len: u32,         |
-- |                             |  exch_type: u8) -> u8 (1=match, 0=no)    |
-- |                             | Stateless: routing key matching per       |
-- |                             | exchange type (direct/fanout/topic).      |
-- +-----------------------------+-------------------------------------------+
