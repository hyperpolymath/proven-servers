-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- KerberosABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation (ffi/zig/src/kerberos.zig) must provide.
--
-- The Zig FFI manages:
--   - 64-slot mutex-protected authentication session pool
--   - Ticket cache (TGTs and service tickets per session)
--   - Encryption type negotiation (strongest-common-cipher selection)
--   - Principal name storage and validation
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
-- |                               | Server selects strongest common cipher    |
-- |                               | from client proposal vs server list.      |
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
-- |                               | Simulates AS exchange: Initial ->         |
-- |                               | TGTObtained. Requires client principal    |
-- |                               | and realm to be set.                      |
-- +-------------------------------+-------------------------------------------+
-- | krb_obtain_service_ticket     | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Simulates TGS exchange: TGTObtained ->   |
-- |                               | ServiceTicketObtained. Requires service   |
-- |                               | principal to be set.                      |
-- +-------------------------------+-------------------------------------------+
-- | krb_authenticate              | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Simulates AP exchange:                    |
-- |                               | ServiceTicketObtained -> Authenticated.   |
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
-- |                               | Renews TGT: TGTObtained -> TGTObtained.  |
-- |                               | Resets ticket lifetime.                   |
-- +-------------------------------+-------------------------------------------+
-- | krb_reauth                    | (slot: c_int) -> u8 (0=ok, 1=rejected)   |
-- |                               | Re-authenticate: Authenticated ->         |
-- |                               | Initial. Clears all tickets.              |
-- +-------------------------------+-------------------------------------------+
-- | krb_has_tgt                   | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                               | Whether the session holds a valid TGT.    |
-- +-------------------------------+-------------------------------------------+
-- | krb_has_service_ticket        | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                               | Whether the session holds a service       |
-- |                               | ticket.                                   |
-- +-------------------------------+-------------------------------------------+
-- | krb_has_access                | (slot: c_int) -> u8 (1=yes, 0=no)        |
-- |                               | Whether the session is fully              |
-- |                               | authenticated.                            |
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
-- |                               | Adds a flag to the TGT. Requires          |
-- |                               | TGTObtained state.                        |
-- +-------------------------------+-------------------------------------------+
-- | krb_has_ticket_flag           | (slot: c_int, flag: u8) -> u8 (1/0)      |
-- |                               | Whether the TGT has a specific flag.      |
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
