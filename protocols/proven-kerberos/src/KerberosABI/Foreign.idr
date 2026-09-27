-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- KerberosABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the Kerberos model.
-- The Zig FFI stores principal/enctype metadata only. It has no KDC, ticket
-- issuance or validation, encryption, or authenticator backend; AS, TGS, and
-- AP exchange operations fail closed.
--
-- All functions use C calling convention and communicate state via
-- Bits8 tags matching KerberosABI.Layout exactly.

module KerberosABI.Foreign

import KerberosABI.Layout

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a Kerberos authentication session.
||| Created by krb_create(), destroyed by krb_destroy().
export
data KrbContext : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version -- must match krb_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract (20+ functions)
---------------------------------------------------------------------------

-- +-------------------------------+-------------------------------------------+
-- | Function                      | Signature                                 |
-- +-------------------------------+-------------------------------------------+
-- | krb_abi_version               | () -> u32                                 |
-- |                               | Returns ABI version (must equal           |
-- |                               | abiVersion).                              |
-- +-------------------------------+-------------------------------------------+
-- | krb_create                    | (realm_ptr: ptr, realm_len: u32)          |
-- |                               |  -> c_int (slot)                          |
-- |                               | Creates session in Initial state.         |
-- |                               | Returns -1 on failure (no free slots or   |
-- |                               | invalid realm).                           |
-- +-------------------------------+-------------------------------------------+
-- | krb_destroy                   | (slot: c_int) -> void                     |
-- |                               | Releases a session slot.                  |
-- +-------------------------------+-------------------------------------------+
-- | krb_auth_state                | (slot: c_int) -> u8 (AuthState tag)       |
-- |                               | Returns current auth lifecycle state.     |
-- +-------------------------------+-------------------------------------------+
-- | krb_set_client_principal      | (slot: c_int, name_ptr: ptr,              |
-- |                               |  name_len: u32, ptype: u8)               |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- |                               | Sets client principal name and type.      |
-- +-------------------------------+-------------------------------------------+
-- | krb_set_service_principal     | (slot: c_int, name_ptr: ptr,              |
-- |                               |  name_len: u32, ptype: u8)               |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- |                               | Sets service principal name and type.     |
-- +-------------------------------+-------------------------------------------+
-- | krb_propose_enctypes          | (slot: c_int, types_ptr: ptr,             |
-- |                               |  count: u32) -> u8 (0=ok, 1=rejected)    |
-- |                               | Client proposes supported encryption      |
-- |                               | types (array of u8 tags).                 |
-- +-------------------------------+-------------------------------------------+
-- | krb_negotiate_enctype         | (slot: c_int, server_types_ptr: ptr,      |
-- |                               |  count: u32)                              |
-- |                               |  -> u8 (selected enc tag, 255=failure)    |
-- |                               | Selects an enctype metadata tag only;      |
-- |                               | no encryption or KDC exchange occurs.     |
-- +-------------------------------+-------------------------------------------+
-- | krb_negotiation_state         | (slot: c_int) -> u8 (NegotiationState)    |
-- |                               | Returns current negotiation state.        |
-- +-------------------------------+-------------------------------------------+
-- | krb_selected_enctype          | (slot: c_int)                             |
-- |                               |  -> u8 (EncryptionType tag, 255=none)     |
-- |                               | Returns the negotiated encryption type    |
-- |                               | or 255 if not yet selected.               |
-- +-------------------------------+-------------------------------------------+
-- | krb_obtain_tgt                | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Always rejects: no KDC, credentials,      |
-- |                               | pre-authentication, or ticket backend.    |
-- +-------------------------------+-------------------------------------------+
-- | krb_obtain_service_ticket     | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Always rejects: no validated TGT or KDC. |
-- +-------------------------------+-------------------------------------------+
-- | krb_authenticate              | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Always rejects: no service ticket or      |
-- |                               | authenticator is verified.                |
-- +-------------------------------+-------------------------------------------+
-- | krb_fail                      | (slot: c_int, error_code: u8)             |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- |                               | Forces transition to AuthFailed with the  |
-- |                               | given error code. Valid from any           |
-- |                               | non-terminal state.                       |
-- +-------------------------------+-------------------------------------------+
-- | krb_retry                     | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Resets from AuthFailed -> Initial.        |
-- |                               | Clears tickets and negotiation state.     |
-- +-------------------------------+-------------------------------------------+
-- | krb_renew_tgt                 | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Always rejects: no real TGT is issued.    |
-- +-------------------------------+-------------------------------------------+
-- | krb_reauth                    | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Requires modeled Authenticated state,     |
-- |                               | unreachable without a KDC backend.        |
-- +-------------------------------+-------------------------------------------+
-- | krb_has_tgt                   | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                               | Model flag only; always false without a KDC. |
-- +-------------------------------+-------------------------------------------+
-- | krb_has_service_ticket        | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                               | Model flag only; always false without TGS. |
-- +-------------------------------+-------------------------------------------+
-- | krb_has_access                | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                               | Model flag only; always false without AP verification. |
-- +-------------------------------+-------------------------------------------+
-- | krb_last_error                | (slot: c_int) -> u8 (ErrorCode tag)       |
-- |                               | Returns the last error code set by        |
-- |                               | krb_fail(), or 0 (KDC_ERR_NONE).         |
-- +-------------------------------+-------------------------------------------+
-- | krb_ticket_flags_count        | (slot: c_int) -> u32                      |
-- |                               | Returns the number of flags set on the    |
-- |                               | TGT.                                      |
-- +-------------------------------+-------------------------------------------+
-- | krb_add_ticket_flag           | (slot: c_int, flag: u8)                   |
-- |                               |  -> u8 (0=ok, 1=rejected)                |
-- |                               | Adds modeled flag metadata only;          |
-- |                               | TGTObtained is unreachable in this FFI.   |
-- +-------------------------------+-------------------------------------------+
-- | krb_has_ticket_flag           | (slot: c_int, flag: u8) -> u8 (1/0)      |
-- |                               | Whether the model contains this flag.     |
-- +-------------------------------+-------------------------------------------+
-- | krb_can_transition            | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                               | Stateless: checks if an auth state        |
-- |                               | transition is valid per Transitions.idr.  |
-- +-------------------------------+-------------------------------------------+
-- | krb_neg_can_transition        | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                               | Stateless: checks if a negotiation state  |
-- |                               | transition is valid.                      |
-- +-------------------------------+-------------------------------------------+
-- | krb_enc_strength              | (enc_type: u8)                            |
-- |                               |  -> u8 (EncStrength tag, 255=invalid)     |
-- |                               | Stateless: returns the strength           |
-- |                               | classification of an encryption type.     |
-- +-------------------------------+-------------------------------------------+
