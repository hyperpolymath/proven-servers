(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** gRPC protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-grpc/ffi/zig/src/grpc.zig]. *)

(** HTTP/2 stream states (RFC 7540 Section 5.1). *)
type stream_state =
  | Idle               (** Stream not yet started. *)
  | Reserved           (** Reserved via PUSH_PROMISE. *)
  | Open               (** Stream open, data flowing. *)
  | Half_closed_local  (** Local side closed. *)
  | Half_closed_remote (** Remote side closed. *)
  | Closed             (** Stream fully closed. *)

(** gRPC status codes. *)
type status_code =
  | Ok | Cancelled | Unknown | Invalid_argument | Deadline_exceeded
  | Not_found | Already_exists | Permission_denied | Resource_exhausted
  | Failed_precondition | Aborted | Out_of_range | Unimplemented
  | Internal | Unavailable | Data_loss | Unauthenticated

(** Compression algorithms for gRPC. *)
type compression = Comp_none | Comp_gzip | Comp_deflate

let stream_state_to_tag = function
  | Idle -> 0 | Reserved -> 1 | Open -> 2 | Half_closed_local -> 3
  | Half_closed_remote -> 4 | Closed -> 5

let stream_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Reserved | 2 -> Some Open
  | 3 -> Some Half_closed_local | 4 -> Some Half_closed_remote
  | 5 -> Some Closed | _ -> None

let status_code_to_code = function
  | Ok -> 0 | Cancelled -> 1 | Unknown -> 2 | Invalid_argument -> 3
  | Deadline_exceeded -> 4 | Not_found -> 5 | Already_exists -> 6
  | Permission_denied -> 7 | Resource_exhausted -> 8
  | Failed_precondition -> 9 | Aborted -> 10 | Out_of_range -> 11
  | Unimplemented -> 12 | Internal -> 13 | Unavailable -> 14
  | Data_loss -> 15 | Unauthenticated -> 16

let status_code_of_code = function
  | 0 -> Some Ok | 1 -> Some Cancelled | 2 -> Some Unknown
  | 3 -> Some Invalid_argument | 4 -> Some Deadline_exceeded
  | 5 -> Some Not_found | 6 -> Some Already_exists
  | 7 -> Some Permission_denied | 8 -> Some Resource_exhausted
  | 9 -> Some Failed_precondition | 10 -> Some Aborted
  | 11 -> Some Out_of_range | 12 -> Some Unimplemented
  | 13 -> Some Internal | 14 -> Some Unavailable
  | 15 -> Some Data_loss | 16 -> Some Unauthenticated | _ -> None

let compression_to_tag = function
  | Comp_none -> 0 | Comp_gzip -> 1 | Comp_deflate -> 2

(* --- C FFI declarations --- *)

external c_grpc_abi_version : unit -> int = "grpc_abi_version"
external c_grpc_create : int -> int = "grpc_create"
external c_grpc_destroy : int -> unit = "grpc_destroy"
external c_grpc_stream_state : int -> int = "grpc_stream_state"
external c_grpc_compression : int -> int = "grpc_compression"
external c_grpc_status_code : int -> int = "grpc_status_code"
external c_grpc_set_status : int -> int -> int = "grpc_set_status"
external c_grpc_stream_id : int -> int = "grpc_stream_id"
external c_grpc_send_headers : int -> int = "grpc_send_headers"
external c_grpc_local_end_stream : int -> int = "grpc_local_end_stream"
external c_grpc_remote_end_stream : int -> int = "grpc_remote_end_stream"
external c_grpc_reset_stream : int -> int -> int = "grpc_reset_stream"
external c_grpc_close_half_local : int -> int = "grpc_close_half_local"
external c_grpc_close_half_remote : int -> int = "grpc_close_half_remote"
external c_grpc_push_promise : int -> int = "grpc_push_promise"
external c_grpc_reserved_to_half : int -> int = "grpc_reserved_to_half"
external c_grpc_can_send : int -> int = "grpc_can_send"
external c_grpc_can_receive : int -> int = "grpc_can_receive"
external c_grpc_send_window : int -> int = "grpc_send_window"
external c_grpc_recv_window : int -> int = "grpc_recv_window"
external c_grpc_update_send_window : int -> int -> int = "grpc_update_send_window"
external c_grpc_update_recv_window : int -> int -> int = "grpc_update_recv_window"
external c_grpc_can_transition : int -> int -> int = "grpc_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_grpc_abi_version ()

let create comp =
  Proven_error.from_slot (c_grpc_create (compression_to_tag comp))

let destroy slot = c_grpc_destroy slot
let get_stream_state slot = stream_state_of_tag (c_grpc_stream_state slot)
let get_compression slot = c_grpc_compression slot
let get_status_code slot = status_code_of_code (c_grpc_status_code slot)

let set_status slot status =
  Proven_error.from_status (c_grpc_set_status slot (status_code_to_code status))

let stream_id slot = c_grpc_stream_id slot
let send_headers slot = Proven_error.from_status (c_grpc_send_headers slot)
let local_end_stream slot = Proven_error.from_status (c_grpc_local_end_stream slot)
let remote_end_stream slot = Proven_error.from_status (c_grpc_remote_end_stream slot)

let reset_stream slot status =
  Proven_error.from_status (c_grpc_reset_stream slot (status_code_to_code status))

let close_half_local slot = Proven_error.from_status (c_grpc_close_half_local slot)
let close_half_remote slot = Proven_error.from_status (c_grpc_close_half_remote slot)
let push_promise slot = Proven_error.from_status (c_grpc_push_promise slot)
let reserved_to_half slot = Proven_error.from_status (c_grpc_reserved_to_half slot)
let can_send slot = c_grpc_can_send slot = 1
let can_receive slot = c_grpc_can_receive slot = 1
let send_window slot = c_grpc_send_window slot
let recv_window slot = c_grpc_recv_window slot

let update_send_window slot ~delta =
  Proven_error.from_status (c_grpc_update_send_window slot delta)

let update_recv_window slot ~delta =
  Proven_error.from_status (c_grpc_update_recv_window slot delta)

let can_transition ~from ~to_ =
  c_grpc_can_transition (stream_state_to_tag from) (stream_state_to_tag to_) = 1
