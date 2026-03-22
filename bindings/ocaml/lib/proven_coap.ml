(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** CoAP (Constrained Application Protocol) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-coap/ffi/zig/src/coap.zig]. *)

(** Method matching [Method] in coap.zig. *)
type method_ =
  | Get  (** GET (tag 0). *)
  | Post  (** POST (tag 1). *)
  | Put  (** PUT (tag 2). *)
  | Delete  (** DELETE (tag 3). *)

let method_to_tag = function
  | Get -> 0 | Post -> 1 | Put -> 2 | Delete -> 3

let method_of_tag = function
  | 0 -> Some Get | 1 -> Some Post | 2 -> Some Put | 3 -> Some Delete
  | _ -> None

(** MessageType matching [MessageType] in coap.zig. *)
type message_type =
  | Confirmable  (** CON (tag 0). *)
  | NonConfirmable  (** NON (tag 1). *)
  | Acknowledgement  (** ACK (tag 2). *)
  | Reset  (** RST (tag 3). *)

let message_type_to_tag = function
  | Confirmable -> 0 | NonConfirmable -> 1 | Acknowledgement -> 2
  | Reset -> 3

let message_type_of_tag = function
  | 0 -> Some Confirmable | 1 -> Some NonConfirmable
  | 2 -> Some Acknowledgement | 3 -> Some Reset | _ -> None

(** ContentFormat matching [ContentFormat] in coap.zig. *)
type content_format =
  | TextPlain  (** text/plain (tag 0). *)
  | LinkFormat  (** application/link-format (tag 1). *)
  | Xml  (** application/xml (tag 2). *)
  | OctetStream  (** application/octet-stream (tag 3). *)
  | Exi  (** application/exi (tag 4). *)
  | Json  (** application/json (tag 5). *)
  | Cbor  (** application/cbor (tag 6). *)

let content_format_to_tag = function
  | TextPlain -> 0 | LinkFormat -> 1 | Xml -> 2 | OctetStream -> 3
  | Exi -> 4 | Json -> 5 | Cbor -> 6

let content_format_of_tag = function
  | 0 -> Some TextPlain | 1 -> Some LinkFormat | 2 -> Some Xml
  | 3 -> Some OctetStream | 4 -> Some Exi | 5 -> Some Json
  | 6 -> Some Cbor | _ -> None

(** ResponseClass matching [ResponseClass] in coap.zig. *)
type response_class =
  | Success  (** 2.xx Success (tag 0). *)
  | ClientError  (** 4.xx Client Error (tag 1). *)
  | ServerError  (** 5.xx Server Error (tag 2). *)
  | Signaling  (** 7.xx Signaling (tag 3). *)
  | Empty  (** Empty (tag 4). *)

let response_class_to_tag = function
  | Success -> 0 | ClientError -> 1 | ServerError -> 2 | Signaling -> 3
  | Empty -> 4

let response_class_of_tag = function
  | 0 -> Some Success | 1 -> Some ClientError | 2 -> Some ServerError
  | 3 -> Some Signaling | 4 -> Some Empty | _ -> None

(** SessionState matching [SessionState] in coap.zig. *)
type session_state =
  | Idle  (** Idle (tag 0). *)
  | Bound  (** Bound (tag 1). *)
  | Serving  (** Serving (tag 2). *)
  | Observing  (** Observing (tag 3). *)
  | Shutdown  (** Shutdown (tag 4). *)

let session_state_to_tag = function
  | Idle -> 0 | Bound -> 1 | Serving -> 2 | Observing -> 3 | Shutdown -> 4

let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Bound | 2 -> Some Serving
  | 3 -> Some Observing | 4 -> Some Shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_coap_abi_version : unit -> int = "coap_abi_version"
external c_coap_create_context : unit -> int = "coap_create_context"
external c_coap_destroy_context : int -> unit = "coap_destroy_context"
external c_coap_state : int -> int = "coap_state"
external c_coap_can_transition : int -> int -> int = "coap_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_coap_abi_version ()

let create_context () = Proven_error.from_slot (c_coap_create_context ())

let destroy_context slot = c_coap_destroy_context slot

let get_state slot = session_state_of_tag (c_coap_state slot)

let can_transition ~from ~to_ =
  c_coap_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
