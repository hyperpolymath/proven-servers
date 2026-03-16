-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- IDSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module IDSABI.Foreign

import IDSABI.Layout
import IDSABI.Transitions

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an IDS inspection context.
||| Created by ids_create_context(), destroyed by ids_destroy_context().
export
data IDSHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ids_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +------------------------------------------------------------------------+
-- | Function                    | Signature                                |
-- +-----------------------------+------------------------------------------+
-- | ids_abi_version             | () -> Bits32                             |
-- +-----------------------------+------------------------------------------+
-- | ids_create_context          | () -> c_int (slot)                       |
-- |                             | Creates context in Captured/Idle state.  |
-- +-----------------------------+------------------------------------------+
-- | ids_destroy_context         | (slot: c_int) -> ()                      |
-- +-----------------------------+------------------------------------------+
-- | ids_inspection_state        | (slot: c_int) -> u8 (InspectionState)    |
-- |                             | 0=Captured, 1=Decoded, 2=Inspecting,     |
-- |                             | 3=Evaluated, 4=Disposed                  |
-- +-----------------------------+------------------------------------------+
-- | ids_alert_state             | (slot: c_int) -> u8 (AlertState tag)     |
-- |                             | 0=Idle, 1=Triggered, 2=Escalated,        |
-- |                             | 3=Acknowledged, 4=Closed                 |
-- +-----------------------------+------------------------------------------+
-- | ids_decode_packet           | (slot: c_int, proto: u8, dir: u8,       |
-- |                             |  src_ip: u32, dst_ip: u32,               |
-- |                             |  src_port: u16, dst_port: u16) -> u8     |
-- |                             | Captured -> Decoded.                     |
-- +-----------------------------+------------------------------------------+
-- | ids_begin_inspection        | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Decoded -> Inspecting.                   |
-- +-----------------------------+------------------------------------------+
-- | ids_add_rule                | (slot: c_int, match_type: u8,            |
-- |                             |  match_value: u32, action: u8,           |
-- |                             |  severity: u8, detection: u8,            |
-- |                             |  priority: u16) -> u8                    |
-- |                             | Add a detection rule (max 64 rules).     |
-- +-----------------------------+------------------------------------------+
-- | ids_evaluate_rules          | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Inspecting -> Evaluated.                 |
-- |                             | Evaluates rules in priority order.       |
-- +-----------------------------+------------------------------------------+
-- | ids_dispose                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                             | Evaluated -> Disposed.                   |
-- +-----------------------------+------------------------------------------+
-- | ids_get_action              | (slot: c_int) -> u8 (Action tag)         |
-- |                             | Returns the decided action for packet.   |
-- +-----------------------------+------------------------------------------+
-- | ids_get_match_status        | (slot: c_int) -> u8 (MatchStatus tag)    |
-- |                             | 0=NoMatch, 1=Matched, 2=Suppressed.     |
-- +-----------------------------+------------------------------------------+
-- | ids_get_match_severity      | (slot: c_int) -> u8 (AlertSeverity tag)  |
-- |                             | Severity of highest-priority match.      |
-- +-----------------------------+------------------------------------------+
-- | ids_get_match_detection     | (slot: c_int) -> u8 (DetectionMethod)    |
-- |                             | Detection method of the matching rule.   |
-- +-----------------------------+------------------------------------------+
-- | ids_get_threat_level        | (slot: c_int) -> u8 (ThreatLevel tag)    |
-- |                             | Assessed threat level of the packet.     |
-- +-----------------------------+------------------------------------------+
-- | ids_rule_count              | (slot: c_int) -> u16                      |
-- +-----------------------------+------------------------------------------+
-- | ids_alert_count             | (slot: c_int) -> u16                      |
-- +-----------------------------+------------------------------------------+
-- | ids_packet_proto            | (slot: c_int) -> u8 (Protocol tag)        |
-- +-----------------------------+------------------------------------------+
-- | ids_packet_direction        | (slot: c_int) -> u8 (Direction tag)       |
-- +-----------------------------+------------------------------------------+
-- | ids_packet_src_ip           | (slot: c_int) -> u32                      |
-- +-----------------------------+------------------------------------------+
-- | ids_packet_dst_ip           | (slot: c_int) -> u32                      |
-- +-----------------------------+------------------------------------------+
-- | ids_packet_src_port         | (slot: c_int) -> u16                      |
-- +-----------------------------+------------------------------------------+
-- | ids_packet_dst_port         | (slot: c_int) -> u16                      |
-- +-----------------------------+------------------------------------------+
-- | ids_trigger_alert           | (slot: c_int, severity: u8) -> u8         |
-- |                             | Idle -> Triggered.                        |
-- +-----------------------------+------------------------------------------+
-- | ids_escalate_alert          | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                             | Triggered -> Escalated.                   |
-- +-----------------------------+------------------------------------------+
-- | ids_acknowledge_alert       | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                             | Triggered/Escalated -> Acknowledged.      |
-- +-----------------------------+------------------------------------------+
-- | ids_close_alert             | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                             | Acknowledged -> Closed.                   |
-- +-----------------------------+------------------------------------------+
-- | ids_auto_close_alert        | (slot: c_int) -> u8 (0=ok, 1=rejected)    |
-- |                             | Triggered -> Closed (suppression).        |
-- +-----------------------------+------------------------------------------+
-- | ids_can_inspection_transition | (from: u8, to: u8) -> u8 (1=yes, 0=no) |
-- |                             | Stateless inspection lifecycle check.     |
-- +-----------------------------+------------------------------------------+
-- | ids_can_alert_transition    | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                             | Stateless alert lifecycle check.          |
-- +-----------------------------+------------------------------------------+
-- | ids_set_default_action      | (slot: c_int, action: u8) -> u8           |
-- |                             | Set default action when no rule matches.  |
-- +-----------------------------+------------------------------------------+
-- | ids_get_alert_severity      | (slot: c_int) -> u8 (AlertSeverity tag)   |
-- |                             | Current alert severity.                   |
-- +-----------------------------+------------------------------------------+
