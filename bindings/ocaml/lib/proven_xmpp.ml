(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** XMPP (Extensible Messaging and Presence Protocol) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-xmpp/ffi/zig/src/xmpp.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for stanza types, message types,
    presence types, IQ types, and stream errors. *)

(** XMPP stanza types matching [StanzaType] in xmpp.zig. *)
type stanza_type = Message | Presence | Iq

(** XMPP message types matching [MessageType] in xmpp.zig. *)
type message_type = Chat | Msg_error | Groupchat | Headline | Normal

(** XMPP presence types matching [PresenceType] in xmpp.zig. *)
type presence_type = Available | Away | Dnd | Xa | Unavailable

(** XMPP IQ types matching [IqType] in xmpp.zig. *)
type iq_type = Get | Set | Result | Iq_error

(** XMPP stream errors matching [StreamError] in xmpp.zig. *)
type stream_error =
  | Bad_format | Conflict | Connection_timeout | Host_gone
  | Host_unknown | Not_authorized | Policy_violation
  | Resource_constraint | System_shutdown

(** Convert a stanza type to its ABI tag value. *)
let stanza_type_to_tag = function
  | Message -> 0 | Presence -> 1 | Iq -> 2

(** Decode a stanza type from its ABI tag value. *)
let stanza_type_of_tag = function
  | 0 -> Some Message | 1 -> Some Presence | 2 -> Some Iq | _ -> None

(** Convert a message type to its ABI tag value. *)
let message_type_to_tag = function
  | Chat -> 0 | Msg_error -> 1 | Groupchat -> 2 | Headline -> 3 | Normal -> 4

(** Decode a message type from its ABI tag value. *)
let message_type_of_tag = function
  | 0 -> Some Chat | 1 -> Some Msg_error | 2 -> Some Groupchat
  | 3 -> Some Headline | 4 -> Some Normal | _ -> None

(** Convert a presence type to its ABI tag value. *)
let presence_type_to_tag = function
  | Available -> 0 | Away -> 1 | Dnd -> 2 | Xa -> 3 | Unavailable -> 4

(** Decode a presence type from its ABI tag value. *)
let presence_type_of_tag = function
  | 0 -> Some Available | 1 -> Some Away | 2 -> Some Dnd
  | 3 -> Some Xa | 4 -> Some Unavailable | _ -> None

(** Convert an IQ type to its ABI tag value. *)
let iq_type_to_tag = function
  | Get -> 0 | Set -> 1 | Result -> 2 | Iq_error -> 3

(** Decode an IQ type from its ABI tag value. *)
let iq_type_of_tag = function
  | 0 -> Some Get | 1 -> Some Set | 2 -> Some Result
  | 3 -> Some Iq_error | _ -> None

(** Convert a stream error to its ABI tag value. *)
let stream_error_to_tag = function
  | Bad_format -> 0 | Conflict -> 1 | Connection_timeout -> 2
  | Host_gone -> 3 | Host_unknown -> 4 | Not_authorized -> 5
  | Policy_violation -> 6 | Resource_constraint -> 7 | System_shutdown -> 8

(** Decode a stream error from its ABI tag value. *)
let stream_error_of_tag = function
  | 0 -> Some Bad_format | 1 -> Some Conflict | 2 -> Some Connection_timeout
  | 3 -> Some Host_gone | 4 -> Some Host_unknown | 5 -> Some Not_authorized
  | 6 -> Some Policy_violation | 7 -> Some Resource_constraint
  | 8 -> Some System_shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_xmpp_abi_version : unit -> int = "xmpp_abi_version"
external c_xmpp_create_context : unit -> int = "xmpp_create_context"
external c_xmpp_destroy_context : int -> unit = "xmpp_destroy_context"
external c_xmpp_can_transition : int -> int -> int = "xmpp_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_xmpp]. *)
let abi_version () = c_xmpp_abi_version ()

(** Create a new XMPP context. *)
let create_context () =
  Proven_error.from_slot (c_xmpp_create_context ())

(** Destroy an XMPP context, releasing its slot. *)
let destroy_context slot = c_xmpp_destroy_context slot

(** Stateless query: check whether a stanza type transition is valid. *)
let can_transition ~from ~to_ =
  c_xmpp_can_transition (stanza_type_to_tag from) (stanza_type_to_tag to_) = 1
