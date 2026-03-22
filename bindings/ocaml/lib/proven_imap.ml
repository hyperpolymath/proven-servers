(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** IMAP protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-imap/ffi/zig/src/imap.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for IMAP commands, states, and flags. *)

(** IMAP commands matching [Command] in imap.zig. *)
type command =
  | Login | Logout | Select | Examine | Create | Delete | Rename
  | List | Fetch | Store | Search | Copy | Noop | Capability

(** IMAP session states matching [State] in imap.zig. *)
type state =
  | NotAuthenticated | Authenticated | Selected | State_Logout

(** Message flags matching [Flag] in imap.zig. *)
type flag =
  | Seen | Answered | Flagged | Deleted | Draft | Recent

(** Convert a command to its ABI tag value. *)
let command_to_tag = function
  | Login -> 0 | Logout -> 1 | Select -> 2 | Examine -> 3 | Create -> 4
  | Delete -> 5 | Rename -> 6 | List -> 7 | Fetch -> 8 | Store -> 9
  | Search -> 10 | Copy -> 11 | Noop -> 12 | Capability -> 13

(** Decode a command from its ABI tag value. *)
let command_of_tag = function
  | 0 -> Some Login | 1 -> Some Logout | 2 -> Some Select
  | 3 -> Some Examine | 4 -> Some Create | 5 -> Some Delete
  | 6 -> Some Rename | 7 -> Some List | 8 -> Some Fetch | 9 -> Some Store
  | 10 -> Some Search | 11 -> Some Copy | 12 -> Some Noop
  | 13 -> Some Capability | _ -> None

(** Convert a state to its ABI tag value. *)
let state_to_tag = function
  | NotAuthenticated -> 0 | Authenticated -> 1 | Selected -> 2
  | State_Logout -> 3

(** Decode a state from its ABI tag value. *)
let state_of_tag = function
  | 0 -> Some NotAuthenticated | 1 -> Some Authenticated
  | 2 -> Some Selected | 3 -> Some State_Logout | _ -> None

(** Convert a flag to its ABI tag value. *)
let flag_to_tag = function
  | Seen -> 0 | Answered -> 1 | Flagged -> 2 | Deleted -> 3
  | Draft -> 4 | Recent -> 5

(** Decode a flag from its ABI tag value. *)
let flag_of_tag = function
  | 0 -> Some Seen | 1 -> Some Answered | 2 -> Some Flagged
  | 3 -> Some Deleted | 4 -> Some Draft | 5 -> Some Recent | _ -> None

(* --- C FFI declarations --- *)

external c_imap_abi_version : unit -> int = "imap_abi_version"
external c_imap_create_context : unit -> int = "imap_create_context"
external c_imap_destroy_context : int -> unit = "imap_destroy_context"
external c_imap_can_transition : int -> int -> int = "imap_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_imap]. *)
let abi_version () = c_imap_abi_version ()

(** Create a new IMAP context in the NotAuthenticated state. *)
let create_context () =
  Proven_error.from_slot (c_imap_create_context ())

(** Destroy an IMAP context, releasing its slot. *)
let destroy_context slot = c_imap_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_imap_can_transition (state_to_tag from) (state_to_tag to_) = 1
