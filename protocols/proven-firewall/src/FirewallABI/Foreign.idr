-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FirewallABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module FirewallABI.Foreign

import FirewallABI.Layout
import FirewallABI.Transitions

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a firewall context.
||| Created by fw_create_context(), destroyed by fw_destroy_context().
export
data FirewallHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match fw_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function                   | Signature                                |
-- +----------------------------+------------------------------------------+
-- | fw_abi_version             | () -> Bits32                             |
-- +----------------------------+------------------------------------------+
-- | fw_create_context          | () -> c_int (slot)                       |
-- |                            | Creates context in Arrived state with    |
-- |                            | Untracked connection tracking.           |
-- +----------------------------+------------------------------------------+
-- | fw_destroy_context         | (slot: c_int) -> ()                      |
-- +----------------------------+------------------------------------------+
-- | fw_packet_state            | (slot: c_int) -> u8 (PacketState tag)    |
-- |                            | 0=Arrived, 1=Classified, 2=ChainTraversal|
-- |                            | 3=Decided, 4=Committed                   |
-- +----------------------------+------------------------------------------+
-- | fw_conntrack_state         | (slot: c_int) -> u8 (ConnTrackState tag) |
-- |                            | 0=Untracked, 1=Tracking, 2=Tracked,     |
-- |                            | 3=Expired                                |
-- +----------------------------+------------------------------------------+
-- | fw_classify_packet         | (slot: c_int, proto: u8, chain: u8,     |
-- |                            |  src_ip: u32, dst_ip: u32,               |
-- |                            |  src_port: u16, dst_port: u16) -> u8     |
-- |                            | Arrived -> Classified.                   |
-- +----------------------------+------------------------------------------+
-- | fw_begin_chain             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                            | Classified -> ChainTraversal.            |
-- +----------------------------+------------------------------------------+
-- | fw_add_rule                | (slot: c_int, match_type: u8,            |
-- |                            |  match_value: u32, action: u8,           |
-- |                            |  priority: u16) -> u8                    |
-- |                            | Add rule to the chain (max 64 rules).    |
-- +----------------------------+------------------------------------------+
-- | fw_evaluate_rules          | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                            | ChainTraversal -> Decided.               |
-- |                            | Evaluates rules in priority order.       |
-- +----------------------------+------------------------------------------+
-- | fw_get_decision            | (slot: c_int) -> u8 (Action tag)         |
-- |                            | Returns the action decided for packet.   |
-- +----------------------------+------------------------------------------+
-- | fw_set_default_action      | (slot: c_int, action: u8) -> u8          |
-- |                            | Set default action when no rule matches. |
-- +----------------------------+------------------------------------------+
-- | fw_commit                  | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                            | Decided -> Committed.                    |
-- +----------------------------+------------------------------------------+
-- | fw_begin_tracking          | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                            | Untracked -> Tracking.                   |
-- +----------------------------+------------------------------------------+
-- | fw_complete_tracking       | (slot: c_int, conn_state: u8) -> u8      |
-- |                            | Tracking -> Tracked.                     |
-- |                            | conn_state: 0=New, 1=Established,        |
-- |                            | 2=Related, 3=Invalid.                    |
-- +----------------------------+------------------------------------------+
-- | fw_expire_conn             | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                            | Tracked -> Expired.                      |
-- +----------------------------+------------------------------------------+
-- | fw_conn_state              | (slot: c_int) -> u8 (ConnState tag)      |
-- |                            | Returns tracked connection state.        |
-- +----------------------------+------------------------------------------+
-- | fw_rule_count              | (slot: c_int) -> u16                      |
-- +----------------------------+------------------------------------------+
-- | fw_packet_proto            | (slot: c_int) -> u8 (Protocol tag)        |
-- +----------------------------+------------------------------------------+
-- | fw_packet_chain            | (slot: c_int) -> u8 (ChainType tag)       |
-- +----------------------------+------------------------------------------+
-- | fw_packet_src_ip           | (slot: c_int) -> u32                      |
-- +----------------------------+------------------------------------------+
-- | fw_packet_dst_ip           | (slot: c_int) -> u32                      |
-- +----------------------------+------------------------------------------+
-- | fw_packet_src_port         | (slot: c_int) -> u16                      |
-- +----------------------------+------------------------------------------+
-- | fw_packet_dst_port         | (slot: c_int) -> u16                      |
-- +----------------------------+------------------------------------------+
-- | fw_can_transition          | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                            | Stateless packet lifecycle check.        |
-- +----------------------------+------------------------------------------+
-- | fw_can_conntrack_transition| (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                            | Stateless connection tracking check.     |
-- +----------------------------+------------------------------------------+
