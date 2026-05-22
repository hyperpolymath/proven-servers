(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** RTSP (Real Time Streaming Protocol) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-rtsp/ffi/zig/src/rtsp.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for methods, transport protocols,
    session states, status codes, and error codes. *)

(** RTSP methods matching [Method] in rtsp.zig. *)
type method_ =
  | Describe | Setup | Play | Pause | Teardown
  | Get_parameter | Set_parameter | Options | Announce | Record | Redirect

(** RTSP transport protocols matching [TransportProtocol] in rtsp.zig. *)
type transport_protocol = Rtp_avp_udp | Rtp_avp_tcp | Rtp_avp_udp_multicast

(** RTSP session states matching [SessionState] in rtsp.zig. *)
type session_state = Init | Ready | Playing | Recording

(** RTSP status codes matching [StatusCode] in rtsp.zig. *)
type status_code =
  | Status_ok | Moved_permanently | Moved_temporarily | Bad_request
  | Unauthorized | Not_found | Method_not_allowed | Not_acceptable
  | Session_not_found | Internal_server_error | Not_implemented
  | Service_unavailable

(** RTSP error codes matching [RtspError] in rtsp.zig. *)
type rtsp_error =
  | Rtsp_ok | Invalid_slot | Not_active | Invalid_transition
  | Rtsp_method_not_allowed | Transport_error | Session_expired

(** Convert a method to its ABI tag value. *)
let method_to_tag = function
  | Describe -> 0 | Setup -> 1 | Play -> 2 | Pause -> 3 | Teardown -> 4
  | Get_parameter -> 5 | Set_parameter -> 6 | Options -> 7
  | Announce -> 8 | Record -> 9 | Redirect -> 10

(** Decode a method from its ABI tag value. *)
let method_of_tag = function
  | 0 -> Some Describe | 1 -> Some Setup | 2 -> Some Play
  | 3 -> Some Pause | 4 -> Some Teardown | 5 -> Some Get_parameter
  | 6 -> Some Set_parameter | 7 -> Some Options | 8 -> Some Announce
  | 9 -> Some Record | 10 -> Some Redirect | _ -> None

(** Convert a transport protocol to its ABI tag value. *)
let transport_protocol_to_tag = function
  | Rtp_avp_udp -> 0 | Rtp_avp_tcp -> 1 | Rtp_avp_udp_multicast -> 2

(** Decode a transport protocol from its ABI tag value. *)
let transport_protocol_of_tag = function
  | 0 -> Some Rtp_avp_udp | 1 -> Some Rtp_avp_tcp
  | 2 -> Some Rtp_avp_udp_multicast | _ -> None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Init -> 0 | Ready -> 1 | Playing -> 2 | Recording -> 3

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Init | 1 -> Some Ready | 2 -> Some Playing
  | 3 -> Some Recording | _ -> None

(** Convert a status code to its ABI tag value. *)
let status_code_to_tag = function
  | Status_ok -> 0 | Moved_permanently -> 1 | Moved_temporarily -> 2
  | Bad_request -> 3 | Unauthorized -> 4 | Not_found -> 5
  | Method_not_allowed -> 6 | Not_acceptable -> 7 | Session_not_found -> 8
  | Internal_server_error -> 9 | Not_implemented -> 10
  | Service_unavailable -> 11

(** Decode a status code from its ABI tag value. *)
let status_code_of_tag = function
  | 0 -> Some Status_ok | 1 -> Some Moved_permanently
  | 2 -> Some Moved_temporarily | 3 -> Some Bad_request
  | 4 -> Some Unauthorized | 5 -> Some Not_found
  | 6 -> Some Method_not_allowed | 7 -> Some Not_acceptable
  | 8 -> Some Session_not_found | 9 -> Some Internal_server_error
  | 10 -> Some Not_implemented | 11 -> Some Service_unavailable | _ -> None

(** Convert an error to its ABI tag value. *)
let rtsp_error_to_tag = function
  | Rtsp_ok -> 0 | Invalid_slot -> 1 | Not_active -> 2
  | Invalid_transition -> 3 | Rtsp_method_not_allowed -> 4
  | Transport_error -> 5 | Session_expired -> 6

(** Decode an error from its ABI tag value. *)
let rtsp_error_of_tag = function
  | 0 -> Some Rtsp_ok | 1 -> Some Invalid_slot | 2 -> Some Not_active
  | 3 -> Some Invalid_transition | 4 -> Some Rtsp_method_not_allowed
  | 5 -> Some Transport_error | 6 -> Some Session_expired | _ -> None

(* --- C FFI declarations --- *)

external c_rtsp_abi_version : unit -> int = "rtsp_abi_version"
external c_rtsp_create_context : unit -> int = "rtsp_create_context"
external c_rtsp_destroy_context : int -> unit = "rtsp_destroy_context"
external c_rtsp_can_transition : int -> int -> int = "rtsp_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_rtsp]. *)
let abi_version () = c_rtsp_abi_version ()

(** Create a new RTSP context. *)
let create_context () =
  Proven_error.from_slot (c_rtsp_create_context ())

(** Destroy an RTSP context, releasing its slot. *)
let destroy_context slot = c_rtsp_destroy_context slot

(** Stateless query: check whether a session state transition is valid. *)
let can_transition ~from ~to_ =
  c_rtsp_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
