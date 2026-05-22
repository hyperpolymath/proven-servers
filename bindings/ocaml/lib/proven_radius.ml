(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** RADIUS authentication/accounting bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-radius/ffi/zig/src/radius.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for packet types, attribute types,
    service types, auth methods, session states, and result codes. *)

(** RADIUS packet types matching [PacketType] in radius.zig. *)
type packet_type =
  | Access_request | Access_accept | Access_reject
  | Accounting_request | Accounting_response | Access_challenge

(** RADIUS attribute types matching [AttributeType] in radius.zig. *)
type attribute_type =
  | User_name | User_password | Nas_ip_address | Nas_port
  | Service_type_attr | Framed_protocol | Framed_ip_address
  | Reply_message | Session_timeout

(** RADIUS service types matching [ServiceType] in radius.zig. *)
type service_type =
  | Login | Framed | Callback_login | Callback_framed
  | Outbound | Administrative

(** RADIUS authentication methods matching [AuthMethod] in radius.zig. *)
type auth_method = Pap | Chap | Mschap | Mschapv2 | Eap

(** RADIUS session states matching [SessionState] in radius.zig. *)
type session_state =
  | Idle | Authenticating | Authorized | Rejected
  | Challenged | Accounting | Complete

(** RADIUS result codes matching [RadiusResult] in radius.zig. *)
type radius_result = Ok | Err | Invalid_param | Pool_exhausted | Bad_secret

(** Convert a packet type to its ABI tag value. *)
let packet_type_to_tag = function
  | Access_request -> 0 | Access_accept -> 1 | Access_reject -> 2
  | Accounting_request -> 3 | Accounting_response -> 4 | Access_challenge -> 5

(** Decode a packet type from its ABI tag value. *)
let packet_type_of_tag = function
  | 0 -> Some Access_request | 1 -> Some Access_accept
  | 2 -> Some Access_reject | 3 -> Some Accounting_request
  | 4 -> Some Accounting_response | 5 -> Some Access_challenge | _ -> None

(** Convert an attribute type to its ABI tag value. *)
let attribute_type_to_tag = function
  | User_name -> 0 | User_password -> 1 | Nas_ip_address -> 2
  | Nas_port -> 3 | Service_type_attr -> 4 | Framed_protocol -> 5
  | Framed_ip_address -> 6 | Reply_message -> 7 | Session_timeout -> 8

(** Decode an attribute type from its ABI tag value. *)
let attribute_type_of_tag = function
  | 0 -> Some User_name | 1 -> Some User_password | 2 -> Some Nas_ip_address
  | 3 -> Some Nas_port | 4 -> Some Service_type_attr | 5 -> Some Framed_protocol
  | 6 -> Some Framed_ip_address | 7 -> Some Reply_message
  | 8 -> Some Session_timeout | _ -> None

(** Convert a service type to its ABI tag value. *)
let service_type_to_tag = function
  | Login -> 0 | Framed -> 1 | Callback_login -> 2
  | Callback_framed -> 3 | Outbound -> 4 | Administrative -> 5

(** Decode a service type from its ABI tag value. *)
let service_type_of_tag = function
  | 0 -> Some Login | 1 -> Some Framed | 2 -> Some Callback_login
  | 3 -> Some Callback_framed | 4 -> Some Outbound
  | 5 -> Some Administrative | _ -> None

(** Convert an auth method to its ABI tag value. *)
let auth_method_to_tag = function
  | Pap -> 0 | Chap -> 1 | Mschap -> 2 | Mschapv2 -> 3 | Eap -> 4

(** Decode an auth method from its ABI tag value. *)
let auth_method_of_tag = function
  | 0 -> Some Pap | 1 -> Some Chap | 2 -> Some Mschap
  | 3 -> Some Mschapv2 | 4 -> Some Eap | _ -> None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | Authenticating -> 1 | Authorized -> 2 | Rejected -> 3
  | Challenged -> 4 | Accounting -> 5 | Complete -> 6

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Authenticating | 2 -> Some Authorized
  | 3 -> Some Rejected | 4 -> Some Challenged | 5 -> Some Accounting
  | 6 -> Some Complete | _ -> None

(** Convert a result to its ABI tag value. *)
let radius_result_to_tag = function
  | Ok -> 0 | Err -> 1 | Invalid_param -> 2
  | Pool_exhausted -> 3 | Bad_secret -> 4

(** Decode a result from its ABI tag value. *)
let radius_result_of_tag = function
  | 0 -> Some Ok | 1 -> Some Err | 2 -> Some Invalid_param
  | 3 -> Some Pool_exhausted | 4 -> Some Bad_secret | _ -> None

(* --- C FFI declarations --- *)

external c_radius_abi_version : unit -> int = "radius_abi_version"
external c_radius_create_context : unit -> int = "radius_create_context"
external c_radius_destroy_context : int -> unit = "radius_destroy_context"
external c_radius_can_transition : int -> int -> int = "radius_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_radius]. *)
let abi_version () = c_radius_abi_version ()

(** Create a new RADIUS context. *)
let create_context () =
  Proven_error.from_slot (c_radius_create_context ())

(** Destroy a RADIUS context, releasing its slot. *)
let destroy_context slot = c_radius_destroy_context slot

(** Stateless query: check whether a session state transition is valid. *)
let can_transition ~from ~to_ =
  c_radius_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
