-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DNSABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module DNSABI.Foreign

import DNSABI.Layout
import DNSABI.Transitions

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a DNS context.
||| Created by dns_create_context(), destroyed by dns_destroy_context().
export
data DnsHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match dns_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function                | Signature                                   |
-- +-------------------------+---------------------------------------------+
-- | dns_abi_version         | () -> Bits32                                |
-- +-------------------------+---------------------------------------------+
-- | dns_create_context      | () -> c_int (slot)                          |
-- |                         | Creates context in Idle state with DNSSEC   |
-- |                         | disabled.                                   |
-- +-------------------------+---------------------------------------------+
-- | dns_destroy_context     | (slot: c_int) -> ()                         |
-- +-------------------------+---------------------------------------------+
-- | dns_state               | (slot: c_int) -> u8 (DnsState tag)          |
-- |                         | 0=Idle, 1=QueryReceived, 2=Lookup,          |
-- |                         | 3=ResponseBuilding, 4=Sent                  |
-- +-------------------------+---------------------------------------------+
-- | dns_dnssec_state        | (slot: c_int) -> u8 (DnssecState tag)       |
-- |                         | 0=Disabled, 1=Enabled, 2=KeyLoaded,         |
-- |                         | 3=Validated                                 |
-- +-------------------------+---------------------------------------------+
-- | dns_parse_query         | (slot: c_int, buf: *const u8,               |
-- |                         |  len: u16) -> u8 (0=ok, 1=error)            |
-- |                         | Idle -> QueryReceived.                      |
-- +-------------------------+---------------------------------------------+
-- | dns_begin_lookup        | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- |                         | QueryReceived -> Lookup.                    |
-- +-------------------------+---------------------------------------------+
-- | dns_begin_response      | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- |                         | Lookup -> ResponseBuilding.                 |
-- +-------------------------+---------------------------------------------+
-- | dns_add_answer          | (slot: c_int, rtype: u8, rclass: u8,        |
-- |                         |  ttl: u32, rdata: *const u8,                |
-- |                         |  rdlen: u16) -> u8 (0=ok, 1=rejected)       |
-- |                         | Only valid in ResponseBuilding state.       |
-- +-------------------------+---------------------------------------------+
-- | dns_add_authority       | (slot: c_int, rtype: u8, rclass: u8,        |
-- |                         |  ttl: u32, rdata: *const u8,                |
-- |                         |  rdlen: u16) -> u8 (0=ok, 1=rejected)       |
-- +-------------------------+---------------------------------------------+
-- | dns_add_additional      | (slot: c_int, rtype: u8, rclass: u8,        |
-- |                         |  ttl: u32, rdata: *const u8,                |
-- |                         |  rdlen: u16) -> u8 (0=ok, 1=rejected)       |
-- +-------------------------+---------------------------------------------+
-- | dns_set_rcode           | (slot: c_int, rcode: u8) -> u8              |
-- |                         | Set response code (only in building state). |
-- +-------------------------+---------------------------------------------+
-- | dns_build_response      | (slot: c_int, out: *u8, out_len: *u16)      |
-- |                         | -> u8 (0=ok, 1=error)                       |
-- |                         | ResponseBuilding -> Sent.                   |
-- +-------------------------+---------------------------------------------+
-- | dns_enable_dnssec       | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- |                         | Disabled -> Enabled.                        |
-- +-------------------------+---------------------------------------------+
-- | dns_load_dnssec_key     | (slot: c_int, algo: u8) -> u8               |
-- |                         | Enabled -> KeyLoaded.                       |
-- +-------------------------+---------------------------------------------+
-- | dns_sign_response       | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- |                         | KeyLoaded -> Validated.  Only valid during  |
-- |                         | ResponseBuilding lifecycle state.           |
-- +-------------------------+---------------------------------------------+
-- | dns_validate_dnssec     | (slot: c_int) -> u8 (0=ok, 1=rejected)      |
-- |                         | Check DNSSEC validation result.             |
-- +-------------------------+---------------------------------------------+
-- | dns_answer_count        | (slot: c_int) -> u16                         |
-- +-------------------------+---------------------------------------------+
-- | dns_authority_count     | (slot: c_int) -> u16                         |
-- +-------------------------+---------------------------------------------+
-- | dns_additional_count    | (slot: c_int) -> u16                         |
-- +-------------------------+---------------------------------------------+
-- | dns_rcode               | (slot: c_int) -> u8 (ResponseCode tag)      |
-- +-------------------------+---------------------------------------------+
-- | dns_query_rtype         | (slot: c_int) -> u8 (RecordType tag)         |
-- |                         | Returns the record type from the parsed     |
-- |                         | query question section.                     |
-- +-------------------------+---------------------------------------------+
-- | dns_query_class         | (slot: c_int) -> u8 (QueryClass tag)         |
-- +-------------------------+---------------------------------------------+
-- | dns_can_transition      | (from: u8, to: u8) -> u8 (1=yes, 0=no)      |
-- |                         | Stateless lifecycle transition check.       |
-- +-------------------------+---------------------------------------------+
-- | dns_can_dnssec_transition | (from: u8, to: u8) -> u8 (1=yes, 0=no)    |
-- |                         | Stateless DNSSEC transition check.          |
-- +-------------------------+---------------------------------------------+
