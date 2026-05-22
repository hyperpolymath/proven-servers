(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Authentication server protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-authserver/ffi/zig/src/authserver.zig]. *)

(** AuthMethod matching [AuthMethod] in authserver.zig. *)
type auth_method =
  | Password  (** Password (tag 0). *)
  | Certificate  (** Certificate (tag 1). *)
  | OAuth2  (** OAuth2 (tag 2). *)
  | Saml  (** SAML (tag 3). *)
  | Fido2  (** FIDO2 (tag 4). *)
  | Kerberos  (** Kerberos (tag 5). *)
  | Ldap  (** LDAP (tag 6). *)
  | Radius  (** RADIUS (tag 7). *)

let auth_method_to_tag = function
  | Password -> 0 | Certificate -> 1 | OAuth2 -> 2 | Saml -> 3
  | Fido2 -> 4 | Kerberos -> 5 | Ldap -> 6 | Radius -> 7

let auth_method_of_tag = function
  | 0 -> Some Password | 1 -> Some Certificate | 2 -> Some OAuth2
  | 3 -> Some Saml | 4 -> Some Fido2 | 5 -> Some Kerberos
  | 6 -> Some Ldap | 7 -> Some Radius | _ -> None

(** TokenType matching [TokenType] in authserver.zig. *)
type token_type =
  | Access  (** Access (tag 0). *)
  | Refresh  (** Refresh (tag 1). *)
  | Id  (** Id (tag 2). *)
  | Api  (** Api (tag 3). *)

let token_type_to_tag = function
  | Access -> 0 | Refresh -> 1 | Id -> 2 | Api -> 3

let token_type_of_tag = function
  | 0 -> Some Access | 1 -> Some Refresh | 2 -> Some Id | 3 -> Some Api
  | _ -> None

(** AuthResult matching [AuthResult] in authserver.zig. *)
type auth_result =
  | Success  (** Success (tag 0). *)
  | InvalidCredentials  (** InvalidCredentials (tag 1). *)
  | AccountLocked  (** AccountLocked (tag 2). *)
  | AccountExpired  (** AccountExpired (tag 3). *)
  | MfaRequired  (** MfaRequired (tag 4). *)
  | IpBlocked  (** IpBlocked (tag 5). *)

let auth_result_to_tag = function
  | Success -> 0 | InvalidCredentials -> 1 | AccountLocked -> 2
  | AccountExpired -> 3 | MfaRequired -> 4 | IpBlocked -> 5

let auth_result_of_tag = function
  | 0 -> Some Success | 1 -> Some InvalidCredentials
  | 2 -> Some AccountLocked | 3 -> Some AccountExpired
  | 4 -> Some MfaRequired | 5 -> Some IpBlocked | _ -> None

(** MfaMethod matching [MfaMethod] in authserver.zig. *)
type mfa_method =
  | Totp  (** TOTP (tag 0). *)
  | Sms  (** SMS (tag 1). *)
  | Push  (** Push (tag 2). *)
  | Fido2Mfa  (** FIDO2 MFA (tag 3). *)
  | Email  (** Email (tag 4). *)

let mfa_method_to_tag = function
  | Totp -> 0 | Sms -> 1 | Push -> 2 | Fido2Mfa -> 3 | Email -> 4

let mfa_method_of_tag = function
  | 0 -> Some Totp | 1 -> Some Sms | 2 -> Some Push | 3 -> Some Fido2Mfa
  | 4 -> Some Email | _ -> None

(** SessionState matching [SessionState] in authserver.zig. *)
type session_state =
  | Active  (** Active (tag 0). *)
  | Expired  (** Expired (tag 1). *)
  | Revoked  (** Revoked (tag 2). *)
  | Locked  (** Locked (tag 3). *)

let session_state_to_tag = function
  | Active -> 0 | Expired -> 1 | Revoked -> 2 | Locked -> 3

let session_state_of_tag = function
  | 0 -> Some Active | 1 -> Some Expired | 2 -> Some Revoked
  | 3 -> Some Locked | _ -> None

(* --- C FFI declarations --- *)

external c_authserver_abi_version : unit -> int = "authserver_abi_version"
external c_authserver_create_context : unit -> int = "authserver_create_context"
external c_authserver_destroy_context : int -> unit = "authserver_destroy_context"
external c_authserver_state : int -> int = "authserver_state"
external c_authserver_can_transition : int -> int -> int = "authserver_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_authserver_abi_version ()

let create_context () = Proven_error.from_slot (c_authserver_create_context ())

let destroy_context slot = c_authserver_destroy_context slot

let get_state slot = session_state_of_tag (c_authserver_state slot)

let can_transition ~from ~to_ =
  c_authserver_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
