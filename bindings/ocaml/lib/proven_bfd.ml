(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** BFD (Bidirectional Forwarding Detection, RFC 5880) protocol bindings for
    proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-bfd/ffi/zig/src/bfd.zig]. *)

(** BfdState matching [BfdState] in bfd.zig. *)
type bfd_state =
  | AdminDown  (** AdminDown (tag 0). *)
  | Down  (** Down (tag 1). *)
  | Init  (** Init (tag 2). *)
  | Up  (** Up (tag 3). *)

let bfd_state_to_tag = function
  | AdminDown -> 0 | Down -> 1 | Init -> 2 | Up -> 3

let bfd_state_of_tag = function
  | 0 -> Some AdminDown | 1 -> Some Down | 2 -> Some Init | 3 -> Some Up
  | _ -> None

(** Diagnostic matching [Diagnostic] in bfd.zig. *)
type diagnostic =
  | NoDiagnostic  (** NoDiagnostic (tag 0). *)
  | ControlDetectionTimeExpired  (** ControlDetectionTimeExpired (tag 1). *)
  | EchoFunctionFailed  (** EchoFunctionFailed (tag 2). *)
  | NeighborSignaledSessionDown  (** NeighborSignaledSessionDown (tag 3). *)
  | ForwardingPlaneReset  (** ForwardingPlaneReset (tag 4). *)
  | PathDown  (** PathDown (tag 5). *)
  | ConcatenatedPathDown  (** ConcatenatedPathDown (tag 6). *)
  | AdministrativelyDown  (** AdministrativelyDown (tag 7). *)
  | ReverseConcatenatedPathDown  (** ReverseConcatenatedPathDown (tag 8). *)

let diagnostic_to_tag = function
  | NoDiagnostic -> 0 | ControlDetectionTimeExpired -> 1
  | EchoFunctionFailed -> 2 | NeighborSignaledSessionDown -> 3
  | ForwardingPlaneReset -> 4 | PathDown -> 5
  | ConcatenatedPathDown -> 6 | AdministrativelyDown -> 7
  | ReverseConcatenatedPathDown -> 8

let diagnostic_of_tag = function
  | 0 -> Some NoDiagnostic | 1 -> Some ControlDetectionTimeExpired
  | 2 -> Some EchoFunctionFailed
  | 3 -> Some NeighborSignaledSessionDown
  | 4 -> Some ForwardingPlaneReset | 5 -> Some PathDown
  | 6 -> Some ConcatenatedPathDown | 7 -> Some AdministrativelyDown
  | 8 -> Some ReverseConcatenatedPathDown | _ -> None

(** SessionMode matching [SessionMode] in bfd.zig. *)
type session_mode =
  | AsyncMode  (** AsyncMode (tag 0). *)
  | DemandMode  (** DemandMode (tag 1). *)

let session_mode_to_tag = function AsyncMode -> 0 | DemandMode -> 1

let session_mode_of_tag = function
  | 0 -> Some AsyncMode | 1 -> Some DemandMode | _ -> None

(** SessionState matching [SessionState] in bfd.zig. *)
type session_state =
  | Idle  (** Idle (tag 0). *)
  | SsDown  (** SsDown (tag 1). *)
  | Negotiating  (** Negotiating (tag 2). *)
  | Established  (** Established (tag 3). *)
  | Teardown  (** Teardown (tag 4). *)

let session_state_to_tag = function
  | Idle -> 0 | SsDown -> 1 | Negotiating -> 2 | Established -> 3
  | Teardown -> 4

let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some SsDown | 2 -> Some Negotiating
  | 3 -> Some Established | 4 -> Some Teardown | _ -> None

(* --- C FFI declarations --- *)

external c_bfd_abi_version : unit -> int = "bfd_abi_version"
external c_bfd_create_context : unit -> int = "bfd_create_context"
external c_bfd_destroy_context : int -> unit = "bfd_destroy_context"
external c_bfd_state : int -> int = "bfd_state"
external c_bfd_can_transition : int -> int -> int = "bfd_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_bfd_abi_version ()

let create_context () = Proven_error.from_slot (c_bfd_create_context ())

let destroy_context slot = c_bfd_destroy_context slot

let get_state slot = session_state_of_tag (c_bfd_state slot)

let can_transition ~from ~to_ =
  c_bfd_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
