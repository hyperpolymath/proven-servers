-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- IdsABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ids.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching IdsABI.Types exactly.

module IdsABI.Foreign

import IdsABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Ids context.
||| Created by ids_create*(), destroyed by ids_destroy*().
export
data IdsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ids_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (32 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | ids_abi_version                   | () -> u32                                   |
-- | ids_create_context                | () -> c_int                                 |
-- | ids_destroy_context               | (slot: c_int) -> void                       |
-- | ids_inspection_state              | (slot: c_int) -> u8                         |
-- | ids_alert_state                   | (slot: c_int) -> u8                         |
-- | ids_decode_packet                 | (slot: c_int, proto: u8, dir: u8, src_ip... |
-- | ids_begin_inspection              | (slot: c_int) -> u8                         |
-- | ids_add_rule                      | (slot: c_int, match_type: u8, match_valu... |
-- | ids_evaluate_rules                | (slot: c_int) -> u8                         |
-- | ids_dispose                       | (slot: c_int) -> u8                         |
-- | ids_get_action                    | (slot: c_int) -> u8                         |
-- | ids_get_match_status              | (slot: c_int) -> u8                         |
-- | ids_get_match_severity            | (slot: c_int) -> u8                         |
-- | ids_get_match_detection           | (slot: c_int) -> u8                         |
-- | ids_get_threat_level              | (slot: c_int) -> u8                         |
-- | ids_rule_count                    | (slot: c_int) -> u16                        |
-- | ids_alert_count                   | (slot: c_int) -> u16                        |
-- | ids_packet_proto                  | (slot: c_int) -> u8                         |
-- | ids_packet_direction              | (slot: c_int) -> u8                         |
-- | ids_packet_src_ip                 | (slot: c_int) -> u32                        |
-- | ids_packet_dst_ip                 | (slot: c_int) -> u32                        |
-- | ids_packet_src_port               | (slot: c_int) -> u16                        |
-- | ids_packet_dst_port               | (slot: c_int) -> u16                        |
-- | ids_trigger_alert                 | (slot: c_int, severity: u8) -> u8           |
-- | ids_escalate_alert                | (slot: c_int) -> u8                         |
-- | ids_acknowledge_alert             | (slot: c_int) -> u8                         |
-- | ids_close_alert                   | (slot: c_int) -> u8                         |
-- | ids_auto_close_alert              | (slot: c_int) -> u8                         |
-- | ids_set_default_action            | (slot: c_int, action: u8) -> u8             |
-- | ids_get_alert_severity            | (slot: c_int) -> u8                         |
-- | ids_can_inspection_transition     | (from: u8, to: u8) -> u8                    |
-- | ids_can_alert_transition          | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
