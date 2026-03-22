(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** VoIP/SIP protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-voip/ffi/zig/src/voip.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for SIP methods, response codes,
    and dialog states. *)

(** SIP methods matching [Method] in voip.zig. *)
type method_ =
  | Invite | Ack | Bye | Cancel | Register | Options | Info
  | Update | Subscribe | Notify | Refer | Message | Prack

(** SIP response codes matching [ResponseCode] in voip.zig. *)
type response_code =
  | Trying | Ringing | Session_progress | Ok | Multiple_choices
  | Moved_permanently | Moved_temporarily | Bad_request | Unauthorized
  | Forbidden | Not_found | Method_not_allowed | Request_timeout
  | Busy_here | Decline | Server_internal_error | Service_unavailable

(** SIP dialog states matching [DialogState] in voip.zig. *)
type dialog_state = Early | Confirmed | Terminated

(** Convert a method to its ABI tag value. *)
let method_to_tag = function
  | Invite -> 0 | Ack -> 1 | Bye -> 2 | Cancel -> 3 | Register -> 4
  | Options -> 5 | Info -> 6 | Update -> 7 | Subscribe -> 8
  | Notify -> 9 | Refer -> 10 | Message -> 11 | Prack -> 12

(** Decode a method from its ABI tag value. *)
let method_of_tag = function
  | 0 -> Some Invite | 1 -> Some Ack | 2 -> Some Bye | 3 -> Some Cancel
  | 4 -> Some Register | 5 -> Some Options | 6 -> Some Info
  | 7 -> Some Update | 8 -> Some Subscribe | 9 -> Some Notify
  | 10 -> Some Refer | 11 -> Some Message | 12 -> Some Prack | _ -> None

(** Convert a response code to its ABI tag value. *)
let response_code_to_tag = function
  | Trying -> 0 | Ringing -> 1 | Session_progress -> 2 | Ok -> 3
  | Multiple_choices -> 4 | Moved_permanently -> 5 | Moved_temporarily -> 6
  | Bad_request -> 7 | Unauthorized -> 8 | Forbidden -> 9
  | Not_found -> 10 | Method_not_allowed -> 11 | Request_timeout -> 12
  | Busy_here -> 13 | Decline -> 14 | Server_internal_error -> 15
  | Service_unavailable -> 16

(** Decode a response code from its ABI tag value. *)
let response_code_of_tag = function
  | 0 -> Some Trying | 1 -> Some Ringing | 2 -> Some Session_progress
  | 3 -> Some Ok | 4 -> Some Multiple_choices | 5 -> Some Moved_permanently
  | 6 -> Some Moved_temporarily | 7 -> Some Bad_request
  | 8 -> Some Unauthorized | 9 -> Some Forbidden | 10 -> Some Not_found
  | 11 -> Some Method_not_allowed | 12 -> Some Request_timeout
  | 13 -> Some Busy_here | 14 -> Some Decline
  | 15 -> Some Server_internal_error | 16 -> Some Service_unavailable
  | _ -> None

(** Convert a dialog state to its ABI tag value. *)
let dialog_state_to_tag = function
  | Early -> 0 | Confirmed -> 1 | Terminated -> 2

(** Decode a dialog state from its ABI tag value. *)
let dialog_state_of_tag = function
  | 0 -> Some Early | 1 -> Some Confirmed | 2 -> Some Terminated | _ -> None

(* --- C FFI declarations --- *)

external c_voip_abi_version : unit -> int = "voip_abi_version"
external c_voip_create_context : unit -> int = "voip_create_context"
external c_voip_destroy_context : int -> unit = "voip_destroy_context"
external c_voip_can_transition : int -> int -> int = "voip_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_voip]. *)
let abi_version () = c_voip_abi_version ()

(** Create a new VoIP/SIP context. *)
let create_context () =
  Proven_error.from_slot (c_voip_create_context ())

(** Destroy a VoIP/SIP context, releasing its slot. *)
let destroy_context slot = c_voip_destroy_context slot

(** Stateless query: check whether a dialog state transition is valid. *)
let can_transition ~from ~to_ =
  c_voip_can_transition (dialog_state_to_tag from) (dialog_state_to_tag to_) = 1
