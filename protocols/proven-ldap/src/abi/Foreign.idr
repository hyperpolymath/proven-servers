-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- LdapABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/ldap.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching LdapABI.Types exactly.

module LdapABI.Foreign

import LdapABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Ldap context.
||| Created by ldap_create*(), destroyed by ldap_destroy*().
export
data LdapContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ldap_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (19 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | ldap_abi_version                  | () -> u32                                   |
-- | ldap_create                       | () -> c_int                                 |
-- | ldap_destroy                      | (slot: c_int) -> void                       |
-- | ldap_state                        | (slot: c_int) -> u8                         |
-- | ldap_last_result                  | (slot: c_int) -> u8                         |
-- | ldap_message_id                   | (slot: c_int) -> u32                        |
-- | ldap_bind_dn                      | (slot: c_int, buf: ptr, buf_len: u32) ->... |
-- | ldap_bind                         | (slot: c_int, dn: ptr, dn_len: u32, _: p... |
-- | ldap_bind_complete                | (slot: c_int, result_tag: u8) -> u8         |
-- | ldap_unbind                       | (slot: c_int) -> u8                         |
-- | ldap_search                       | (slot: c_int, _: ptr, _: u32, scope: u8)... |
-- | ldap_modify                       | (slot: c_int) -> u8                         |
-- | ldap_add                          | (slot: c_int) -> u8                         |
-- | ldap_delete                       | (slot: c_int) -> u8                         |
-- | ldap_compare                      | (slot: c_int) -> u8                         |
-- | ldap_abandon                      | (slot: c_int, _: u32) -> u8                 |
-- | ldap_can_modify                   | (state_tag: u8) -> u8                       |
-- | ldap_can_search                   | (state_tag: u8) -> u8                       |
-- | ldap_can_transition               | (from: u8, to: u8) -> u8                    |
-- +───────────────────────────────────+─────────────────────────────────────────────+
