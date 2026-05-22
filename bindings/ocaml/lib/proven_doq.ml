(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** DNS-over-QUICtypes for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-doq/ffi/zig/src/doq.zig]. *)

(** StreamType matching [StreamType] in doq.zig. *)
type stream_type =
  | Unidirectional  (** Unidirectional (tag 0). *)
  | Bidirectional  (** Bidirectional (tag 1). *)

let stream_type_to_tag = function
  | Unidirectional -> 0 | Bidirectional -> 1

let stream_type_of_tag = function
  | 0 -> Some Unidirectional
  | 1 -> Some Bidirectional
  | _ -> None

(** ErrorCode matching [ErrorCode] in doq.zig. *)
type error_code =
  | NoError  (** NoError (tag 0). *)
  | InternalError  (** InternalError (tag 1). *)
  | ExcessiveLoad  (** ExcessiveLoad (tag 2). *)
  | ProtocolError  (** ProtocolError (tag 3). *)

let error_code_to_tag = function
  | NoError -> 0
  | InternalError -> 1
  | ExcessiveLoad -> 2
  | ProtocolError -> 3

let error_code_of_tag = function
  | 0 -> Some NoError
  | 1 -> Some InternalError
  | 2 -> Some ExcessiveLoad
  | 3 -> Some ProtocolError
  | _ -> None

(** SessionState matching [SessionState] in doq.zig. *)
type session_state =
  | Initial  (** Initial (tag 0). *)
  | Handshaking  (** Handshaking (tag 1). *)
  | Ready  (** Ready (tag 2). *)
  | Draining  (** Draining (tag 3). *)
  | Closed  (** Closed (tag 4). *)

let session_state_to_tag = function
  | Initial -> 0
  | Handshaking -> 1
  | Ready -> 2
  | Draining -> 3
  | Closed -> 4

let session_state_of_tag = function
  | 0 -> Some Initial
  | 1 -> Some Handshaking
  | 2 -> Some Ready
  | 3 -> Some Draining
  | 4 -> Some Closed
  | _ -> None

(** ServerState matching [ServerState] in doq.zig. *)
type server_state =
  | Idle  (** Idle (tag 0). *)
  | Bound  (** Bound (tag 1). *)
  | Listening  (** Listening (tag 2). *)
  | Processing  (** Processing (tag 3). *)
  | Shutdown  (** Shutdown (tag 4). *)

let server_state_to_tag = function
  | Idle -> 0
  | Bound -> 1
  | Listening -> 2
  | Processing -> 3
  | Shutdown -> 4

let server_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Bound
  | 2 -> Some Listening
  | 3 -> Some Processing
  | 4 -> Some Shutdown
  | _ -> None

(* --- C FFI declarations --- *)

external c_doq_abi_version : unit -> int = "doq_abi_version"
external c_doq_create_context : unit -> int = "doq_create_context"
external c_doq_destroy_context : int -> unit = "doq_destroy_context"
external c_doq_state : int -> int = "doq_state"
external c_doq_server_state : int -> int = "doq_server_state"
external c_doq_can_transition : int -> int -> int = "doq_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_doq_abi_version ()

let create_context () = Proven_error.from_slot (c_doq_create_context ())

let destroy_context slot = c_doq_destroy_context slot

let get_state slot = session_state_of_tag (c_doq_state slot)

let can_transition ~from ~to_ =
  c_doq_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
