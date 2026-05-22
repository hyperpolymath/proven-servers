(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Kerberos authentication protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-kerberos/ffi/zig/src/kerberos.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for message types, encryption types,
    principal types, ticket flags, and authentication states. *)

(** Kerberos message types matching [MessageType] in kerberos.zig. *)
type message_type =
  | AsReq | AsRep | TgsReq | TgsRep | ApReq | ApRep
  | KrbError | KrbSafe | KrbPriv | KrbCred

(** Encryption types matching [EncryptionType] in kerberos.zig. *)
type encryption_type =
  | Aes256CtsHmacSha1 | Aes128CtsHmacSha1 | Aes256CtsHmacSha384
  | Rc4Hmac | Des3CbcSha1

(** Principal name types matching [PrincipalType] in kerberos.zig. *)
type principal_type =
  | NtUnknown | NtPrincipal | NtSrvInst | NtSrvHst
  | NtUid | NtX500 | NtEnterprise

(** Ticket flags matching [TicketFlag] in kerberos.zig. *)
type ticket_flag =
  | Forwardable | Forwarded | Proxiable | Proxy
  | Renewable | PreAuthent | HwAuthent

(** Error codes matching [ErrorCode] in kerberos.zig. *)
type error_code =
  | KdcErrNone | KdcErrNameExp | KdcErrServiceExp | KdcErrBadPvno
  | KdcErrCOldMastKvno | KdcErrSOldMastKvno | KdcErrCPrincipalUnknown
  | KdcErrSPrincipalUnknown | KdcErrPreauthFailed | KdcErrPreauthRequired

(** Authentication states matching [AuthState] in kerberos.zig. *)
type auth_state =
  | Initial | TgtObtained | ServiceTicketObtained | Authenticated | AuthFailed

(** Encryption strength levels matching [EncStrength] in kerberos.zig. *)
type enc_strength =
  | Strong | Medium | Weak

(** Pre-authentication types matching [PreAuthType] in kerberos.zig. *)
type pre_auth_type =
  | PaEncTimestamp | PaEtypeInfo2 | PaFxFast | PaFxCookie

(** Negotiation states matching [NegotiationState] in kerberos.zig. *)
type negotiation_state =
  | NegIdle | Proposed | Selected | NegFailed

(** Convert a message type to its ABI tag value. *)
let message_type_to_tag = function
  | AsReq -> 0 | AsRep -> 1 | TgsReq -> 2 | TgsRep -> 3 | ApReq -> 4
  | ApRep -> 5 | KrbError -> 6 | KrbSafe -> 7 | KrbPriv -> 8 | KrbCred -> 9

(** Decode a message type from its ABI tag value. *)
let message_type_of_tag = function
  | 0 -> Some AsReq | 1 -> Some AsRep | 2 -> Some TgsReq | 3 -> Some TgsRep
  | 4 -> Some ApReq | 5 -> Some ApRep | 6 -> Some KrbError
  | 7 -> Some KrbSafe | 8 -> Some KrbPriv | 9 -> Some KrbCred | _ -> None

(** Convert an encryption type to its ABI tag value. *)
let encryption_type_to_tag = function
  | Aes256CtsHmacSha1 -> 0 | Aes128CtsHmacSha1 -> 1
  | Aes256CtsHmacSha384 -> 2 | Rc4Hmac -> 3 | Des3CbcSha1 -> 4

(** Decode an encryption type from its ABI tag value. *)
let encryption_type_of_tag = function
  | 0 -> Some Aes256CtsHmacSha1 | 1 -> Some Aes128CtsHmacSha1
  | 2 -> Some Aes256CtsHmacSha384 | 3 -> Some Rc4Hmac
  | 4 -> Some Des3CbcSha1 | _ -> None

(** Convert a principal type to its ABI tag value. *)
let principal_type_to_tag = function
  | NtUnknown -> 0 | NtPrincipal -> 1 | NtSrvInst -> 2 | NtSrvHst -> 3
  | NtUid -> 4 | NtX500 -> 5 | NtEnterprise -> 6

(** Decode a principal type from its ABI tag value. *)
let principal_type_of_tag = function
  | 0 -> Some NtUnknown | 1 -> Some NtPrincipal | 2 -> Some NtSrvInst
  | 3 -> Some NtSrvHst | 4 -> Some NtUid | 5 -> Some NtX500
  | 6 -> Some NtEnterprise | _ -> None

(** Convert a ticket flag to its ABI tag value. *)
let ticket_flag_to_tag = function
  | Forwardable -> 0 | Forwarded -> 1 | Proxiable -> 2 | Proxy -> 3
  | Renewable -> 4 | PreAuthent -> 5 | HwAuthent -> 6

(** Decode a ticket flag from its ABI tag value. *)
let ticket_flag_of_tag = function
  | 0 -> Some Forwardable | 1 -> Some Forwarded | 2 -> Some Proxiable
  | 3 -> Some Proxy | 4 -> Some Renewable | 5 -> Some PreAuthent
  | 6 -> Some HwAuthent | _ -> None

(** Convert an error code to its ABI tag value. *)
let error_code_to_tag = function
  | KdcErrNone -> 0 | KdcErrNameExp -> 1 | KdcErrServiceExp -> 2
  | KdcErrBadPvno -> 3 | KdcErrCOldMastKvno -> 4 | KdcErrSOldMastKvno -> 5
  | KdcErrCPrincipalUnknown -> 6 | KdcErrSPrincipalUnknown -> 7
  | KdcErrPreauthFailed -> 8 | KdcErrPreauthRequired -> 9

(** Decode an error code from its ABI tag value. *)
let error_code_of_tag = function
  | 0 -> Some KdcErrNone | 1 -> Some KdcErrNameExp
  | 2 -> Some KdcErrServiceExp | 3 -> Some KdcErrBadPvno
  | 4 -> Some KdcErrCOldMastKvno | 5 -> Some KdcErrSOldMastKvno
  | 6 -> Some KdcErrCPrincipalUnknown | 7 -> Some KdcErrSPrincipalUnknown
  | 8 -> Some KdcErrPreauthFailed | 9 -> Some KdcErrPreauthRequired
  | _ -> None

(** Convert an auth state to its ABI tag value. *)
let auth_state_to_tag = function
  | Initial -> 0 | TgtObtained -> 1 | ServiceTicketObtained -> 2
  | Authenticated -> 3 | AuthFailed -> 4

(** Decode an auth state from its ABI tag value. *)
let auth_state_of_tag = function
  | 0 -> Some Initial | 1 -> Some TgtObtained
  | 2 -> Some ServiceTicketObtained | 3 -> Some Authenticated
  | 4 -> Some AuthFailed | _ -> None

(** Convert an encryption strength to its ABI tag value. *)
let enc_strength_to_tag = function
  | Strong -> 0 | Medium -> 1 | Weak -> 2

(** Decode an encryption strength from its ABI tag value. *)
let enc_strength_of_tag = function
  | 0 -> Some Strong | 1 -> Some Medium | 2 -> Some Weak | _ -> None

(** Convert a pre-auth type to its ABI tag value. *)
let pre_auth_type_to_tag = function
  | PaEncTimestamp -> 0 | PaEtypeInfo2 -> 1 | PaFxFast -> 2 | PaFxCookie -> 3

(** Decode a pre-auth type from its ABI tag value. *)
let pre_auth_type_of_tag = function
  | 0 -> Some PaEncTimestamp | 1 -> Some PaEtypeInfo2
  | 2 -> Some PaFxFast | 3 -> Some PaFxCookie | _ -> None

(** Convert a negotiation state to its ABI tag value. *)
let negotiation_state_to_tag = function
  | NegIdle -> 0 | Proposed -> 1 | Selected -> 2 | NegFailed -> 3

(** Decode a negotiation state from its ABI tag value. *)
let negotiation_state_of_tag = function
  | 0 -> Some NegIdle | 1 -> Some Proposed | 2 -> Some Selected
  | 3 -> Some NegFailed | _ -> None

(* --- C FFI declarations --- *)

external c_kerberos_abi_version : unit -> int = "kerberos_abi_version"
external c_kerberos_create_context : unit -> int = "kerberos_create_context"
external c_kerberos_destroy_context : int -> unit = "kerberos_destroy_context"
external c_kerberos_can_transition : int -> int -> int = "kerberos_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_kerberos]. *)
let abi_version () = c_kerberos_abi_version ()

(** Create a new Kerberos context in the Initial state. *)
let create_context () =
  Proven_error.from_slot (c_kerberos_create_context ())

(** Destroy a Kerberos context, releasing its slot. *)
let destroy_context slot = c_kerberos_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_kerberos_can_transition (auth_state_to_tag from) (auth_state_to_tag to_) = 1
