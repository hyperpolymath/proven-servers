(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** CoAP (Constrained Application Protocol) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-coap/ffi/zig/src/coap.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for CoAP methods, message types,
    content formats, response classes, and session states. *)

(** CoAP methods matching [Method] in coap.zig. *)
type method_ = Get | Post | Put | Delete

(** CoAP message types matching [MessageType] in coap.zig. *)
type message_type = Confirmable | Non_confirmable | Acknowledgement | Reset

(** Content formats matching [ContentFormat] in coap.zig. *)
type content_format =
  | Text_plain | Link_format | Xml | Octet_stream | Exi | Json | Cbor

(** Response classes matching [ResponseClass] in coap.zig. *)
type response_class = Success | Client_error | Server_error | Signaling | Empty

(** Session lifecycle states matching [SessionState] in coap.zig. *)
type session_state = Idle | Bound | Serving | Observing | Shutdown

(** Convert a [method_] to its ABI tag value. *)
let method_to_tag = function
  | Get -> 0 | Post -> 1 | Put -> 2 | Delete -> 3

(** Decode a [method_] from its ABI tag value. *)
let method_of_tag = function
  | 0 -> Some Get | 1 -> Some Post | 2 -> Some Put | 3 -> Some Delete
  | _ -> None

(** Convert a [message_type] to its ABI tag value. *)
let message_type_to_tag = function
  | Confirmable -> 0 | Non_confirmable -> 1 | Acknowledgement -> 2
  | Reset -> 3

(** Decode a [message_type] from its ABI tag value. *)
let message_type_of_tag = function
  | 0 -> Some Confirmable | 1 -> Some Non_confirmable
  | 2 -> Some Acknowledgement | 3 -> Some Reset | _ -> None

(** Convert a [content_format] to its ABI tag value. *)
let content_format_to_tag = function
  | Text_plain -> 0 | Link_format -> 1 | Xml -> 2 | Octet_stream -> 3
  | Exi -> 4 | Json -> 5 | Cbor -> 6

(** Decode a [content_format] from its ABI tag value. *)
let content_format_of_tag = function
  | 0 -> Some Text_plain | 1 -> Some Link_format | 2 -> Some Xml
  | 3 -> Some Octet_stream | 4 -> Some Exi | 5 -> Some Json
  | 6 -> Some Cbor | _ -> None

(** Convert a [response_class] to its ABI tag value. *)
let response_class_to_tag = function
  | Success -> 0 | Client_error -> 1 | Server_error -> 2 | Signaling -> 3
  | Empty -> 4

(** Decode a [response_class] from its ABI tag value. *)
let response_class_of_tag = function
  | 0 -> Some Success | 1 -> Some Client_error | 2 -> Some Server_error
  | 3 -> Some Signaling | 4 -> Some Empty | _ -> None

(** Convert a [session_state] to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | Bound -> 1 | Serving -> 2 | Observing -> 3 | Shutdown -> 4

(** Decode a [session_state] from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Bound | 2 -> Some Serving
  | 3 -> Some Observing | 4 -> Some Shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_coap_abi_version : unit -> int = "coap_abi_version"
external c_coap_create_context : unit -> int = "coap_create_context"
external c_coap_destroy_context : int -> unit = "coap_destroy_context"
external c_coap_can_transition : int -> int -> int = "coap_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_coap]. *)
let abi_version () = c_coap_abi_version ()

(** Create a new CoAP context. *)
let create_context () =
  Proven_error.from_slot (c_coap_create_context ())

(** Destroy a CoAP context, releasing its slot. *)
let destroy_context slot = c_coap_destroy_context slot

(** Stateless query: check whether a session state transition is valid. *)
let can_transition ~from ~to_ =
  c_coap_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
