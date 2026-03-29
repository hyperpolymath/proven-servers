-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DnsABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/dns.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching DnsABI.Types exactly.

module DnsABI.Foreign

import DnsABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Dns context.
||| Created by dns_create*(), destroyed by dns_destroy*().
export
data DnsContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match dns_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (25 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | dns_abi_version                   | () -> u32                                   |
-- | dns_create_context                | () -> c_int                                 |
-- | dns_destroy_context               | (slot: c_int) -> void                       |
-- | dns_state                         | (slot: c_int) -> u8                         |
-- | dns_dnssec_state                  | (slot: c_int) -> u8                         |
-- | dns_rcode                         | (slot: c_int) -> u8                         |
-- | dns_answer_count                  | (slot: c_int) -> u16                        |
-- | dns_authority_count               | (slot: c_int) -> u16                        |
-- | dns_additional_count              | (slot: c_int) -> u16                        |
-- | dns_query_rtype                   | (slot: c_int) -> u8                         |
-- | dns_query_class                   | (slot: c_int) -> u8                         |
-- | dns_parse_query                   | (slot: c_int, buf: ptr, len: u16) -> u8     |
-- | dns_begin_lookup                  | (slot: c_int) -> u8                         |
-- | dns_begin_response                | (slot: c_int) -> u8                         |
-- | dns_add_answer                    | (slot: c_int, rtype: u8, rclass: u8, ttl... |
-- | dns_add_authority                 | (slot: c_int, rtype: u8, rclass: u8, ttl... |
-- | dns_add_additional                | (slot: c_int, rtype: u8, rclass: u8, ttl... |
-- | dns_set_rcode                     | (slot: c_int, rcode_tag: u8) -> u8          |
-- | dns_build_response                | (slot: c_int, out: ptr, out_len: ptr) -> u8 |
-- | dns_enable_dnssec                 | (slot: c_int) -> u8                         |
-- | dns_load_dnssec_key               | (slot: c_int, algo: u8) -> u8               |
-- | dns_sign_response                 | (slot: c_int) -> u8                         |
-- | dns_validate_dnssec               | (slot: c_int) -> u8                         |
-- | dns_can_transition                | (from: u8, to: u8) -> u8                    |
-- | dns_can_dnssec_transition         | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
