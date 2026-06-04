-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- FirewallABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/firewall.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching FirewallABI.Types exactly.

module FirewallABI.Foreign

import FirewallABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Firewall context.
||| Created by firewall_create*(), destroyed by firewall_destroy*().
export
data FirewallContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match firewall_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (25 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | fw_abi_version                    | () -> u32                                   |
-- | fw_create_context                 | () -> c_int                                 |
-- | fw_destroy_context                | (slot: c_int) -> void                       |
-- | fw_packet_state                   | (slot: c_int) -> u8                         |
-- | fw_conntrack_state                | (slot: c_int) -> u8                         |
-- | fw_get_decision                   | (slot: c_int) -> u8                         |
-- | fw_rule_count                     | (slot: c_int) -> u16                        |
-- | fw_packet_proto                   | (slot: c_int) -> u8                         |
-- | fw_packet_chain                   | (slot: c_int) -> u8                         |
-- | fw_packet_src_ip                  | (slot: c_int) -> u32                        |
-- | fw_packet_dst_ip                  | (slot: c_int) -> u32                        |
-- | fw_packet_src_port                | (slot: c_int) -> u16                        |
-- | fw_packet_dst_port                | (slot: c_int) -> u16                        |
-- | fw_conn_state                     | (slot: c_int) -> u8                         |
-- | fw_classify_packet                | (slot: c_int, proto: u8, chain: u8, src_... |
-- | fw_begin_chain                    | (slot: c_int) -> u8                         |
-- | fw_add_rule                       | (slot: c_int, match_type: u8, match_valu... |
-- | fw_set_default_action             | (slot: c_int, action: u8) -> u8             |
-- | fw_evaluate_rules                 | (slot: c_int) -> u8                         |
-- | fw_commit                         | (slot: c_int) -> u8                         |
-- | fw_begin_tracking                 | (slot: c_int) -> u8                         |
-- | fw_complete_tracking              | (slot: c_int, conn_state_tag: u8) -> u8     |
-- | fw_expire_conn                    | (slot: c_int) -> u8                         |
-- | fw_can_transition                 | (from: u8, to: u8) -> u8                    |
-- | fw_can_conntrack_transition       | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
