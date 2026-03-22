(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** DNS-over-TLStypes for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-dot/ffi/zig/src/dot.zig]. *)

(** SessionState matching [SessionState] in dot.zig. *)
type session_state =
  | Connecting  (** Connecting (tag 0). *)
  | Handshaking  (** Handshaking (tag 1). *)
  | Established  (** Established (tag 2). *)
  | Closing  (** Closing (tag 3). *)
  | Closed  (** Closed (tag 4). *)

let session_state_to_tag = function
  | Connecting -> 0
  | Handshaking -> 1
  | Established -> 2
  | Closing -> 3
  | Closed -> 4

let session_state_of_tag = function
  | 0 -> Some Connecting
  | 1 -> Some Handshaking
  | 2 -> Some Established
  | 3 -> Some Closing
  | 4 -> Some Closed
  | _ -> None

(** PaddingStrategy matching [PaddingStrategy] in dot.zig. *)
type padding_strategy =
  | NoPadding  (** NoPadding (tag 0). *)
  | BlockPadding  (** BlockPadding (tag 1). *)
  | RandomPadding  (** RandomPadding (tag 2). *)

let padding_strategy_to_tag = function
  | NoPadding -> 0 | BlockPadding -> 1 | RandomPadding -> 2

let padding_strategy_of_tag = function
  | 0 -> Some NoPadding
  | 1 -> Some BlockPadding
  | 2 -> Some RandomPadding
  | _ -> None

(** ErrorReason matching [ErrorReason] in dot.zig. *)
type error_reason =
  | HandshakeFailed  (** HandshakeFailed (tag 0). *)
  | CertificateInvalid  (** CertificateInvalid (tag 1). *)
  | Timeout  (** Timeout (tag 2). *)
  | UpstreamError  (** UpstreamError (tag 3). *)

let error_reason_to_tag = function
  | HandshakeFailed -> 0
  | CertificateInvalid -> 1
  | Timeout -> 2
  | UpstreamError -> 3

let error_reason_of_tag = function
  | 0 -> Some HandshakeFailed
  | 1 -> Some CertificateInvalid
  | 2 -> Some Timeout
  | 3 -> Some UpstreamError
  | _ -> None

(** ServerState matching [ServerState] in dot.zig. *)
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

external c_dot_abi_version : unit -> int = "dot_abi_version"
external c_dot_create_context : unit -> int = "dot_create_context"
external c_dot_destroy_context : int -> unit = "dot_destroy_context"
external c_dot_state : int -> int = "dot_state"
external c_dot_server_state : int -> int = "dot_server_state"
external c_dot_can_transition : int -> int -> int = "dot_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_dot_abi_version ()

let create_context () = Proven_error.from_slot (c_dot_create_context ())

let destroy_context slot = c_dot_destroy_context slot

let get_state slot = session_state_of_tag (c_dot_state slot)

let can_transition ~from ~to_ =
  c_dot_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
