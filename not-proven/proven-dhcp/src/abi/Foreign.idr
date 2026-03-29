-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DhcpABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/dhcp.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DhcpABI.Types exactly.

module DhcpABI.Foreign

import DhcpABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Dhcp context.
||| Created by dhcp_create*(), destroyed by dhcp_destroy*().
export
data DhcpContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match dhcp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (31 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | dhcp_abi_version                  | () -> u32                                   |
-- | dhcp_create_context               | () -> c_int                                 |
-- | dhcp_destroy_context              | (slot: c_int) -> void                       |
-- | dhcp_state                        | (slot: c_int) -> u8                         |
-- | dhcp_lease_state                  | (slot: c_int, lease_idx: u16) -> u8         |
-- | dhcp_client_xid                   | (slot: c_int) -> u32                        |
-- | dhcp_client_mac                   | (slot: c_int, out: ptr) -> u8               |
-- | dhcp_lease_ip                     | (slot: c_int, lease_idx: u16) -> u32        |
-- | dhcp_lease_expiry                 | (slot: c_int, lease_idx: u16) -> u32        |
-- | dhcp_pool_count                   | (slot: c_int) -> u16                        |
-- | dhcp_pool_available_count         | (slot: c_int) -> u16                        |
-- | dhcp_parse_discover               | (slot: c_int, buf: ptr, len: u16) -> u8     |
-- | dhcp_send_offer                   | (slot: c_int, offered_ip: u32, subnet: u... |
-- | dhcp_parse_request                | (slot: c_int, buf: ptr, len: u16) -> u8     |
-- | dhcp_send_ack                     | (slot: c_int) -> u8                         |
-- | dhcp_send_nak                     | (slot: c_int) -> u8                         |
-- | dhcp_reset                        | (slot: c_int) -> u8                         |
-- | dhcp_pool_allocate                | (slot: c_int) -> i32                        |
-- | dhcp_pool_bind                    | (slot: c_int, lease_idx: u16) -> u8         |
-- | dhcp_pool_release                 | (slot: c_int, lease_idx: u16) -> u8         |
-- | dhcp_pool_renew                   | (slot: c_int, lease_idx: u16) -> u8         |
-- | dhcp_pool_begin_rebind            | (slot: c_int, lease_idx: u16) -> u8         |
-- | dhcp_pool_begin_renew             | (slot: c_int, lease_idx: u16) -> u8         |
-- | dhcp_pool_expire                  | (slot: c_int, lease_idx: u16) -> u8         |
-- | dhcp_pool_reclaim                 | (slot: c_int, lease_idx: u16) -> u8         |
-- | dhcp_pool_decline                 | (slot: c_int, lease_idx: u16) -> u8         |
-- | dhcp_can_transition               | (from: u8, to: u8) -> u8                    |
-- | dhcp_can_lease_transition         | (from: u8, to: u8) -> u8                    |
-- | dhcp_has_relay_info               | (slot: c_int) -> u8                         |
-- | dhcp_relay_giaddr                 | (slot: c_int) -> u32                        |
-- | dhcp_relay_hops                   | (slot: c_int) -> u8                         |
-- +───────────────────────────────────+─────────────────────────────────────────────+
