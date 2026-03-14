-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- LDAPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module LDAPABI.Foreign

import LDAP.Types
import LDAPABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to an LDAP session.
||| Created by ldap_create(), destroyed by ldap_destroy().
export
data LdapHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match ldap_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function               | Signature                                    |
-- +------------------------+----------------------------------------------+
-- | ldap_abi_version       | () -> Bits32                                 |
-- +------------------------+----------------------------------------------+
-- | ldap_create            | () -> c_int (slot, -1 on failure)            |
-- |                        | Creates session in Anonymous state.           |
-- +------------------------+----------------------------------------------+
-- | ldap_destroy           | (slot: c_int) -> ()                          |
-- +------------------------+----------------------------------------------+
-- | ldap_state             | (slot: c_int) -> u8 (SessionState tag)       |
-- +------------------------+----------------------------------------------+
-- | ldap_last_result       | (slot: c_int) -> u8 (ResultCode tag)         |
-- |                        | Last operation result (255 if none).         |
-- +------------------------+----------------------------------------------+
-- | ldap_message_id        | (slot: c_int) -> u32                         |
-- |                        | Current message ID counter.                  |
-- +------------------------+----------------------------------------------+
-- | ldap_bind_dn           | (slot: c_int, buf: *u8, len: u32) -> u32    |
-- |                        | Writes bind DN into buf, returns bytes.      |
-- +------------------------+----------------------------------------------+
-- | ldap_bind              | (slot: c_int, dn: *const u8, dn_len: u32,   |
-- |                        |  pw: *const u8, pw_len: u32) -> u8           |
-- |                        | (0=ok, 1=rejected)                           |
-- |                        | Simple bind: Anonymous/Bound -> Binding.     |
-- +------------------------+----------------------------------------------+
-- | ldap_bind_complete     | (slot: c_int, result_tag: u8) -> u8          |
-- |                        | (0=ok, 1=rejected)                           |
-- |                        | Complete bind: Binding -> Bound or Anonymous. |
-- +------------------------+----------------------------------------------+
-- | ldap_unbind            | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | Unbind: any non-Closed -> Closed.            |
-- +------------------------+----------------------------------------------+
-- | ldap_search            | (slot: c_int, base_dn: *const u8,            |
-- |                        |  base_len: u32, scope: u8) -> u8             |
-- |                        | (0=ok, 1=rejected, 2=bad scope)              |
-- |                        | Search: requires Anonymous or Bound.         |
-- +------------------------+----------------------------------------------+
-- | ldap_modify            | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | Modify: requires Bound.                      |
-- +------------------------+----------------------------------------------+
-- | ldap_add               | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | Add: requires Bound.                         |
-- +------------------------+----------------------------------------------+
-- | ldap_delete            | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | Delete: requires Bound.                      |
-- +------------------------+----------------------------------------------+
-- | ldap_compare           | (slot: c_int) -> u8 (0=ok, 1=rejected)       |
-- |                        | Compare: requires Bound.                     |
-- +------------------------+----------------------------------------------+
-- | ldap_abandon           | (slot: c_int, msg_id: u32) -> u8             |
-- |                        | (0=ok, 1=rejected)                           |
-- |                        | Abandon: requires Anonymous or Bound.        |
-- +------------------------+----------------------------------------------+
-- | ldap_can_modify        | (state: u8) -> u8 (1=yes, 0=no)              |
-- |                        | Stateless: whether state allows writes.      |
-- +------------------------+----------------------------------------------+
-- | ldap_can_search        | (state: u8) -> u8 (1=yes, 0=no)              |
-- |                        | Stateless: whether state allows search.      |
-- +------------------------+----------------------------------------------+
-- | ldap_can_transition    | (from: u8, to: u8) -> u8 (1=yes, 0=no)       |
-- |                        | Stateless: whether transition is valid.      |
-- +------------------------+----------------------------------------------+
