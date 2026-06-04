-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- KerberosABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/kerberos.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected context pool
--   - State machine transitions
--   - Thread-safe via per-pool mutex
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching KerberosABI.Types exactly.

module KerberosABI.Foreign

import KerberosABI.Types

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Kerberos context.
||| Created by kerberos_create*(), destroyed by kerberos_destroy*().
export
data KerberosContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match kerberos_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (27 functions)
---------------------------------------------------------------------------

-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | Function                          | Signature                                   |
-- +───────────────────────────────────+─────────────────────────────────────────────+
-- | krb_abi_version                   | () -> u32                                   |
-- | krb_create                        | (realm_ptr: ptr, realm_len: u32) -> c_int   |
-- | krb_destroy                       | (slot: c_int) -> void                       |
-- | krb_auth_state                    | (slot: c_int) -> u8                         |
-- | krb_set_client_principal          | (slot: c_int, name_ptr: ptr, name_len: u... |
-- | krb_set_service_principal         | (slot: c_int, name_ptr: ptr, name_len: u... |
-- | krb_propose_enctypes              | (slot: c_int, types_ptr: ptr, count: u32... |
-- | krb_negotiate_enctype             | (slot: c_int, server_types_ptr: ptr, cou... |
-- | krb_negotiation_state             | (slot: c_int) -> u8                         |
-- | krb_selected_enctype              | (slot: c_int) -> u8                         |
-- | krb_obtain_tgt                    | (slot: c_int) -> u8                         |
-- | krb_obtain_service_ticket         | (slot: c_int) -> u8                         |
-- | krb_authenticate                  | (slot: c_int) -> u8                         |
-- | krb_fail                          | (slot: c_int, error_code: u8) -> u8         |
-- | krb_retry                         | (slot: c_int) -> u8                         |
-- | krb_renew_tgt                     | (slot: c_int) -> u8                         |
-- | krb_reauth                        | (slot: c_int) -> u8                         |
-- | krb_has_tgt                       | (slot: c_int) -> u8                         |
-- | krb_has_service_ticket            | (slot: c_int) -> u8                         |
-- | krb_has_access                    | (slot: c_int) -> u8                         |
-- | krb_last_error                    | (slot: c_int) -> u8                         |
-- | krb_ticket_flags_count            | (slot: c_int) -> u32                        |
-- | krb_add_ticket_flag               | (slot: c_int, flag: u8) -> u8               |
-- | krb_has_ticket_flag               | (slot: c_int, flag: u8) -> u8               |
-- | krb_can_transition                | (from: u8, to: u8) -> u8                    |
-- | krb_neg_can_transition            | (from: u8, to: u8) -> u8                    |
-- | krb_enc_strength                  | (enc_type: u8) -> u8                        |
-- +───────────────────────────────────+─────────────────────────────────────────────+
