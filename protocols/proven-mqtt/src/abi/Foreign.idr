-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- MqttABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/mqtt.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching MqttABI.Types exactly.

module MqttABI.Foreign

import MqttABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Mqtt context.
||| Created by mqtt_create*(), destroyed by mqtt_destroy*().
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
-- FFI function contract (20 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | mqtt_abi_version                  | () -> u32                                   |
-- | mqtt_create                       | (version: u8, clean_session: u8, keep_al... |
-- | mqtt_destroy                      | (slot: c_int) -> void                       |
-- | mqtt_state                        | (slot: c_int) -> u8                         |
-- | mqtt_version                      | (slot: c_int) -> u8                         |
-- | mqtt_can_publish                  | (slot: c_int) -> u8                         |
-- | mqtt_can_subscribe                | (slot: c_int) -> u8                         |
-- | mqtt_subscription_count           | (slot: c_int) -> u32                        |
-- | mqtt_subscribe                    | (slot: c_int, topic_ptr: ptr, topic_len:... |
-- | mqtt_unsubscribe                  | (slot: c_int, topic_ptr: ptr, topic_len:... |
-- | mqtt_puback                       | (slot: c_int, packet_id: u16) -> u8         |
-- | mqtt_pubrec                       | (slot: c_int, packet_id: u16) -> u8         |
-- | mqtt_pubrel                       | (slot: c_int, packet_id: u16) -> u8         |
-- | mqtt_pubcomp                      | (slot: c_int, packet_id: u16) -> u8         |
-- | mqtt_qos_state                    | (slot: c_int, packet_id: u16) -> u8         |
-- | mqtt_disconnect                   | (slot: c_int) -> u8                         |
-- | mqtt_cleanup                      | (slot: c_int) -> u8                         |
-- | mqtt_retained_count               | () -> u32                                   |
-- | mqtt_can_transition               | (from: u8, to: u8) -> u8                    |
-- | mqtt_qos_can_transition           | (qos_level: u8, from: u8, to: u8) -> u8     |
-- +───────────────────────────────────+─────────────────────────────────────────────+
