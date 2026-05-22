(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** DNS-over-HTTPStypes for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-doh/ffi/zig/src/doh.zig]. *)

(** ContentType matching [ContentType] in doh.zig. *)
type content_type =
  | DnsMessage  (** application/dns-message (tag 0). *)
  | DnsJson  (** application/dns-json (tag 1). *)

let content_type_to_tag = function
  | DnsMessage -> 0 | DnsJson -> 1

let content_type_of_tag = function
  | 0 -> Some DnsMessage
  | 1 -> Some DnsJson
  | _ -> None

(** RequestMethod matching [RequestMethod] in doh.zig. *)
type request_method =
  | Get  (** Get (tag 0). *)
  | Post  (** Post (tag 1). *)

let request_method_to_tag = function
  | Get -> 0 | Post -> 1

let request_method_of_tag = function
  | 0 -> Some Get
  | 1 -> Some Post
  | _ -> None

(** WireFormat matching [WireFormat] in doh.zig. *)
type wire_format =
  | Binary  (** Binary (tag 0). *)
  | Json  (** Json (tag 1). *)

let wire_format_to_tag = function
  | Binary -> 0 | Json -> 1

let wire_format_of_tag = function
  | 0 -> Some Binary
  | 1 -> Some Json
  | _ -> None

(** ErrorReason matching [ErrorReason] in doh.zig. *)
type error_reason =
  | BadContentType  (** BadContentType (tag 0). *)
  | BadMethod  (** BadMethod (tag 1). *)
  | PayloadTooLarge  (** PayloadTooLarge (tag 2). *)
  | UpstreamTimeout  (** UpstreamTimeout (tag 3). *)
  | UpstreamError  (** UpstreamError (tag 4). *)

let error_reason_to_tag = function
  | BadContentType -> 0
  | BadMethod -> 1
  | PayloadTooLarge -> 2
  | UpstreamTimeout -> 3
  | UpstreamError -> 4

let error_reason_of_tag = function
  | 0 -> Some BadContentType
  | 1 -> Some BadMethod
  | 2 -> Some PayloadTooLarge
  | 3 -> Some UpstreamTimeout
  | 4 -> Some UpstreamError
  | _ -> None

(** SessionState matching [SessionState] in doh.zig. *)
type session_state =
  | Idle  (** Idle (tag 0). *)
  | Bound  (** Bound (tag 1). *)
  | Serving  (** Serving (tag 2). *)
  | Resolving  (** Resolving (tag 3). *)
  | Shutdown  (** Shutdown (tag 4). *)

let session_state_to_tag = function
  | Idle -> 0
  | Bound -> 1
  | Serving -> 2
  | Resolving -> 3
  | Shutdown -> 4

let session_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Bound
  | 2 -> Some Serving
  | 3 -> Some Resolving
  | 4 -> Some Shutdown
  | _ -> None

(* --- C FFI declarations --- *)

external c_doh_abi_version : unit -> int = "doh_abi_version"
external c_doh_create_context : unit -> int = "doh_create_context"
external c_doh_destroy_context : int -> unit = "doh_destroy_context"
external c_doh_state : int -> int = "doh_state"
external c_doh_can_transition : int -> int -> int = "doh_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_doh_abi_version ()

let create_context () = Proven_error.from_slot (c_doh_create_context ())

let destroy_context slot = c_doh_destroy_context slot

let get_state slot = session_state_of_tag (c_doh_state slot)

let can_transition ~from ~to_ =
  c_doh_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
