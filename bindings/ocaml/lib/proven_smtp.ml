(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** SMTP protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-smtp/ffi/zig/src/smtp.zig]. *)

(** SMTP session states. *)
type session_state =
  | Connected        (** TCP connection established. *)
  | Greeted          (** HELO/EHLO completed. *)
  | Auth_started     (** AUTH exchange in progress. *)
  | Authenticated    (** Successfully authenticated. *)
  | Mail_from        (** MAIL FROM accepted. *)
  | Rcpt_to          (** RCPT TO accepted. *)
  | Data             (** DATA transfer in progress. *)
  | Message_received (** End-of-data received. *)
  | Quit             (** Session ended. *)

(** SMTP AUTH mechanisms. *)
type auth_mechanism =
  | Plain      (** PLAIN mechanism. *)
  | Login      (** LOGIN mechanism. *)
  | Cram_md5   (** CRAM-MD5 mechanism. *)
  | Xoauth2    (** XOAUTH2 mechanism. *)

let state_to_tag = function
  | Connected -> 0 | Greeted -> 1 | Auth_started -> 2 | Authenticated -> 3
  | Mail_from -> 4 | Rcpt_to -> 5 | Data -> 6 | Message_received -> 7
  | Quit -> 8

let state_of_tag = function
  | 0 -> Some Connected | 1 -> Some Greeted | 2 -> Some Auth_started
  | 3 -> Some Authenticated | 4 -> Some Mail_from | 5 -> Some Rcpt_to
  | 6 -> Some Data | 7 -> Some Message_received | 8 -> Some Quit
  | _ -> None

let auth_mech_to_tag = function
  | Plain -> 0 | Login -> 1 | Cram_md5 -> 2 | Xoauth2 -> 3

let auth_mech_of_tag = function
  | 0 -> Some Plain | 1 -> Some Login | 2 -> Some Cram_md5
  | 3 -> Some Xoauth2 | _ -> None

(* --- C FFI declarations --- *)

external c_smtp_abi_version : unit -> int = "smtp_abi_version"
external c_smtp_create_context : unit -> int = "smtp_create_context"
external c_smtp_destroy_context : int -> unit = "smtp_destroy_context"
external c_smtp_get_state : int -> int = "smtp_get_state"
external c_smtp_get_reply_code : int -> int = "smtp_get_reply_code"
external c_smtp_get_recipient_count : int -> int = "smtp_get_recipient_count"
external c_smtp_get_data_size : int -> int = "smtp_get_data_size"
external c_smtp_get_auth_mechanism : int -> int = "smtp_get_auth_mechanism"
external c_smtp_is_authenticated : int -> int = "smtp_is_authenticated"
external c_smtp_is_tls_active : int -> int = "smtp_is_tls_active"
external c_smtp_greet : int -> int -> int = "smtp_greet"
external c_smtp_authenticate : int -> int -> int = "smtp_authenticate"
external c_smtp_auth_complete : int -> int -> int = "smtp_auth_complete"
external c_smtp_set_sender : int -> int = "smtp_set_sender"
external c_smtp_add_recipient : int -> int = "smtp_add_recipient"
external c_smtp_start_data : int -> int = "smtp_start_data"
external c_smtp_append_data : int -> int -> int = "smtp_append_data"
external c_smtp_finish_data : int -> int = "smtp_finish_data"
external c_smtp_reset : int -> int = "smtp_reset"
external c_smtp_quit : int -> int = "smtp_quit"
external c_smtp_enable_tls : int -> int = "smtp_enable_tls"
external c_smtp_can_transition : int -> int -> int = "smtp_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_smtp_abi_version ()
let create_context () = Proven_error.from_slot (c_smtp_create_context ())
let destroy_context slot = c_smtp_destroy_context slot
let get_state slot = state_of_tag (c_smtp_get_state slot)
let get_reply_code slot = c_smtp_get_reply_code slot
let get_recipient_count slot = c_smtp_get_recipient_count slot
let get_data_size slot = c_smtp_get_data_size slot
let get_auth_mechanism slot = auth_mech_of_tag (c_smtp_get_auth_mechanism slot)
let is_authenticated slot = c_smtp_is_authenticated slot = 1
let is_tls_active slot = c_smtp_is_tls_active slot = 1

let greet slot ~ehlo =
  Proven_error.from_status (c_smtp_greet slot (if ehlo then 1 else 0))

let authenticate slot mech =
  Proven_error.from_status (c_smtp_authenticate slot (auth_mech_to_tag mech))

let auth_complete slot ~success =
  Proven_error.from_status (c_smtp_auth_complete slot (if success then 1 else 0))

let set_sender slot = Proven_error.from_status (c_smtp_set_sender slot)
let add_recipient slot = Proven_error.from_status (c_smtp_add_recipient slot)
let start_data slot = Proven_error.from_status (c_smtp_start_data slot)
let append_data slot ~len = Proven_error.from_status (c_smtp_append_data slot len)
let finish_data slot = Proven_error.from_status (c_smtp_finish_data slot)
let reset slot = Proven_error.from_status (c_smtp_reset slot)
let quit slot = Proven_error.from_status (c_smtp_quit slot)
let enable_tls slot = Proven_error.from_status (c_smtp_enable_tls slot)

let can_transition ~from ~to_ =
  c_smtp_can_transition (state_to_tag from) (state_to_tag to_) = 1
