(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** STUN/TURN (RFC 8489/8656) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-stun/ffi/zig/src/stun.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for message types, transport
    protocols, and error codes. *)

(** STUN/TURN message types matching [MessageType] in stun.zig. *)
type message_type =
  | Binding_request | Binding_response | Binding_error
  | Allocate_request | Allocate_response | Allocate_error
  | Refresh_request | Refresh_response | Send_indication
  | Data_indication | Create_permission | Channel_bind

(** Transport protocols matching [TransportProtocol] in stun.zig. *)
type transport_protocol = Udp | Tcp | Tls | Dtls

(** STUN/TURN error codes matching [ErrorCode] in stun.zig. *)
type error_code =
  | Try_alternate | Bad_request | Unauthorized | Forbidden
  | Mobility_forbidden | Stale_nonce | Server_error | Insufficient_capacity

(** Convert a message type to its ABI tag value. *)
let message_type_to_tag = function
  | Binding_request -> 0 | Binding_response -> 1 | Binding_error -> 2
  | Allocate_request -> 3 | Allocate_response -> 4 | Allocate_error -> 5
  | Refresh_request -> 6 | Refresh_response -> 7 | Send_indication -> 8
  | Data_indication -> 9 | Create_permission -> 10 | Channel_bind -> 11

(** Decode a message type from its ABI tag value. *)
let message_type_of_tag = function
  | 0 -> Some Binding_request | 1 -> Some Binding_response
  | 2 -> Some Binding_error | 3 -> Some Allocate_request
  | 4 -> Some Allocate_response | 5 -> Some Allocate_error
  | 6 -> Some Refresh_request | 7 -> Some Refresh_response
  | 8 -> Some Send_indication | 9 -> Some Data_indication
  | 10 -> Some Create_permission | 11 -> Some Channel_bind | _ -> None

(** Convert a transport protocol to its ABI tag value. *)
let transport_protocol_to_tag = function
  | Udp -> 0 | Tcp -> 1 | Tls -> 2 | Dtls -> 3

(** Decode a transport protocol from its ABI tag value. *)
let transport_protocol_of_tag = function
  | 0 -> Some Udp | 1 -> Some Tcp | 2 -> Some Tls
  | 3 -> Some Dtls | _ -> None

(** Convert an error code to its ABI tag value. *)
let error_code_to_tag = function
  | Try_alternate -> 0 | Bad_request -> 1 | Unauthorized -> 2
  | Forbidden -> 3 | Mobility_forbidden -> 4 | Stale_nonce -> 5
  | Server_error -> 6 | Insufficient_capacity -> 7

(** Decode an error code from its ABI tag value. *)
let error_code_of_tag = function
  | 0 -> Some Try_alternate | 1 -> Some Bad_request | 2 -> Some Unauthorized
  | 3 -> Some Forbidden | 4 -> Some Mobility_forbidden | 5 -> Some Stale_nonce
  | 6 -> Some Server_error | 7 -> Some Insufficient_capacity | _ -> None

(* --- C FFI declarations --- *)

external c_stun_abi_version : unit -> int = "stun_abi_version"
external c_stun_create_context : unit -> int = "stun_create_context"
external c_stun_destroy_context : int -> unit = "stun_destroy_context"
external c_stun_can_transition : int -> int -> int = "stun_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_stun]. *)
let abi_version () = c_stun_abi_version ()

(** Create a new STUN/TURN context. *)
let create_context () =
  Proven_error.from_slot (c_stun_create_context ())

(** Destroy a STUN/TURN context, releasing its slot. *)
let destroy_context slot = c_stun_destroy_context slot

(** Stateless query: check whether a message type transition is valid. *)
let can_transition ~from ~to_ =
  c_stun_can_transition (message_type_to_tag from) (message_type_to_tag to_) = 1
