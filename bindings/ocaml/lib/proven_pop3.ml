(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** POP3 protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-pop3/ffi/zig/src/pop3.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for POP3 commands, states,
    responses, and error codes. *)

(** POP3 commands matching [Command] in pop3.zig. *)
type command =
  | User | Pass | Stat | List | Retr | Dele
  | Noop | Rset | Quit | Top | Uidl

(** POP3 session states matching [State] in pop3.zig. *)
type state = Authorization | Transaction | Update

(** POP3 response types matching [Response] in pop3.zig. *)
type response = Response_ok | Err

(** POP3 error codes matching [Pop3Error] in pop3.zig. *)
type pop3_error =
  | Pop3_ok | Invalid_slot | Not_active | Invalid_transition
  | Invalid_command | Auth_failed

(** Convert a command to its ABI tag value. *)
let command_to_tag = function
  | User -> 0 | Pass -> 1 | Stat -> 2 | List -> 3 | Retr -> 4
  | Dele -> 5 | Noop -> 6 | Rset -> 7 | Quit -> 8 | Top -> 9 | Uidl -> 10

(** Decode a command from its ABI tag value. *)
let command_of_tag = function
  | 0 -> Some User | 1 -> Some Pass | 2 -> Some Stat | 3 -> Some List
  | 4 -> Some Retr | 5 -> Some Dele | 6 -> Some Noop | 7 -> Some Rset
  | 8 -> Some Quit | 9 -> Some Top | 10 -> Some Uidl | _ -> None

(** Convert a state to its ABI tag value. *)
let state_to_tag = function
  | Authorization -> 0 | Transaction -> 1 | Update -> 2

(** Decode a state from its ABI tag value. *)
let state_of_tag = function
  | 0 -> Some Authorization | 1 -> Some Transaction
  | 2 -> Some Update | _ -> None

(** Convert a response to its ABI tag value. *)
let response_to_tag = function
  | Response_ok -> 0 | Err -> 1

(** Decode a response from its ABI tag value. *)
let response_of_tag = function
  | 0 -> Some Response_ok | 1 -> Some Err | _ -> None

(** Convert an error to its ABI tag value. *)
let pop3_error_to_tag = function
  | Pop3_ok -> 0 | Invalid_slot -> 1 | Not_active -> 2
  | Invalid_transition -> 3 | Invalid_command -> 4 | Auth_failed -> 5

(** Decode an error from its ABI tag value. *)
let pop3_error_of_tag = function
  | 0 -> Some Pop3_ok | 1 -> Some Invalid_slot | 2 -> Some Not_active
  | 3 -> Some Invalid_transition | 4 -> Some Invalid_command
  | 5 -> Some Auth_failed | _ -> None

(* --- C FFI declarations --- *)

external c_pop3_abi_version : unit -> int = "pop3_abi_version"
external c_pop3_create_context : unit -> int = "pop3_create_context"
external c_pop3_destroy_context : int -> unit = "pop3_destroy_context"
external c_pop3_can_transition : int -> int -> int = "pop3_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_pop3]. *)
let abi_version () = c_pop3_abi_version ()

(** Create a new POP3 context in the Authorization state. *)
let create_context () =
  Proven_error.from_slot (c_pop3_create_context ())

(** Destroy a POP3 context, releasing its slot. *)
let destroy_context slot = c_pop3_destroy_context slot

(** Stateless query: check whether a state transition is valid. *)
let can_transition ~from ~to_ =
  c_pop3_can_transition (state_to_tag from) (state_to_tag to_) = 1
