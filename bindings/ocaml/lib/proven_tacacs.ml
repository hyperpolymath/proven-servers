(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** TACACS+ authentication bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-tacacs/ffi/zig/src/tacacs.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for packet types, authentication types,
    actions, statuses, authorization, accounting, and session states. *)

(** TACACS+ packet types matching [PacketType] in tacacs.zig. *)
type packet_type = Authentication | Authorization | Accounting

(** Authentication method types matching [AuthenType] in tacacs.zig. *)
type authen_type = Ascii | Pap | Chap | Ms_chap_v1 | Ms_chap_v2

(** Authentication actions matching [AuthenAction] in tacacs.zig. *)
type authen_action = Login | Change_pass | Send_auth

(** Authentication result statuses matching [AuthenStatus] in tacacs.zig. *)
type authen_status =
  | Pass | Authen_fail | Get_data | Get_user | Get_pass
  | Restart | Authen_error | Authen_follow

(** Authorization result statuses matching [AuthorStatus] in tacacs.zig. *)
type author_status =
  | Pass_add | Pass_repl | Author_fail | Author_error | Author_follow

(** Accounting result statuses matching [AcctStatus] in tacacs.zig. *)
type acct_status = Success | Acct_error | Acct_follow

(** Accounting flags matching [AcctFlag] in tacacs.zig. *)
type acct_flag = Start | Stop | Watchdog

(** TACACS+ session states matching [SessionState] in tacacs.zig. *)
type session_state = Idle | Authenticating | Authorizing | Active | Closing

(** Convert a packet type to its ABI tag value. *)
let packet_type_to_tag = function
  | Authentication -> 0 | Authorization -> 1 | Accounting -> 2

(** Decode a packet type from its ABI tag value. *)
let packet_type_of_tag = function
  | 0 -> Some Authentication | 1 -> Some Authorization
  | 2 -> Some Accounting | _ -> None

(** Convert an authen type to its ABI tag value. *)
let authen_type_to_tag = function
  | Ascii -> 0 | Pap -> 1 | Chap -> 2 | Ms_chap_v1 -> 3 | Ms_chap_v2 -> 4

(** Decode an authen type from its ABI tag value. *)
let authen_type_of_tag = function
  | 0 -> Some Ascii | 1 -> Some Pap | 2 -> Some Chap
  | 3 -> Some Ms_chap_v1 | 4 -> Some Ms_chap_v2 | _ -> None

(** Convert an authen action to its ABI tag value. *)
let authen_action_to_tag = function
  | Login -> 0 | Change_pass -> 1 | Send_auth -> 2

(** Decode an authen action from its ABI tag value. *)
let authen_action_of_tag = function
  | 0 -> Some Login | 1 -> Some Change_pass | 2 -> Some Send_auth | _ -> None

(** Convert an authen status to its ABI tag value. *)
let authen_status_to_tag = function
  | Pass -> 0 | Authen_fail -> 1 | Get_data -> 2 | Get_user -> 3
  | Get_pass -> 4 | Restart -> 5 | Authen_error -> 6 | Authen_follow -> 7

(** Decode an authen status from its ABI tag value. *)
let authen_status_of_tag = function
  | 0 -> Some Pass | 1 -> Some Authen_fail | 2 -> Some Get_data
  | 3 -> Some Get_user | 4 -> Some Get_pass | 5 -> Some Restart
  | 6 -> Some Authen_error | 7 -> Some Authen_follow | _ -> None

(** Convert an author status to its ABI tag value. *)
let author_status_to_tag = function
  | Pass_add -> 0 | Pass_repl -> 1 | Author_fail -> 2
  | Author_error -> 3 | Author_follow -> 4

(** Decode an author status from its ABI tag value. *)
let author_status_of_tag = function
  | 0 -> Some Pass_add | 1 -> Some Pass_repl | 2 -> Some Author_fail
  | 3 -> Some Author_error | 4 -> Some Author_follow | _ -> None

(** Convert an acct status to its ABI tag value. *)
let acct_status_to_tag = function
  | Success -> 0 | Acct_error -> 1 | Acct_follow -> 2

(** Decode an acct status from its ABI tag value. *)
let acct_status_of_tag = function
  | 0 -> Some Success | 1 -> Some Acct_error | 2 -> Some Acct_follow | _ -> None

(** Convert an acct flag to its ABI tag value. *)
let acct_flag_to_tag = function
  | Start -> 0 | Stop -> 1 | Watchdog -> 2

(** Decode an acct flag from its ABI tag value. *)
let acct_flag_of_tag = function
  | 0 -> Some Start | 1 -> Some Stop | 2 -> Some Watchdog | _ -> None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | Authenticating -> 1 | Authorizing -> 2
  | Active -> 3 | Closing -> 4

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Authenticating | 2 -> Some Authorizing
  | 3 -> Some Active | 4 -> Some Closing | _ -> None

(* --- C FFI declarations --- *)

external c_tacacs_abi_version : unit -> int = "tacacs_abi_version"
external c_tacacs_create_context : unit -> int = "tacacs_create_context"
external c_tacacs_destroy_context : int -> unit = "tacacs_destroy_context"
external c_tacacs_can_transition : int -> int -> int = "tacacs_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_tacacs]. *)
let abi_version () = c_tacacs_abi_version ()

(** Create a new TACACS+ context. *)
let create_context () =
  Proven_error.from_slot (c_tacacs_create_context ())

(** Destroy a TACACS+ context, releasing its slot. *)
let destroy_context slot = c_tacacs_destroy_context slot

(** Stateless query: check whether a session state transition is valid. *)
let can_transition ~from ~to_ =
  c_tacacs_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
