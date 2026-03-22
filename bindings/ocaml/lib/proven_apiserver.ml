(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** API Server protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-apiserver/ffi/zig/src/apiserver.zig]. *)

(** AuthScheme matching [AuthScheme] in apiserver.zig. *)
type auth_scheme =
  | ApiKey  (** ApiKey (tag 0). *)
  | Bearer  (** Bearer (tag 1). *)
  | Basic  (** Basic (tag 2). *)
  | OAuth2  (** OAuth2 (tag 3). *)
  | Hmac  (** HMAC (tag 4). *)
  | Mtls  (** mTLS (tag 5). *)

let auth_scheme_to_tag = function
  | ApiKey -> 0 | Bearer -> 1 | Basic -> 2 | OAuth2 -> 3
  | Hmac -> 4 | Mtls -> 5

let auth_scheme_of_tag = function
  | 0 -> Some ApiKey | 1 -> Some Bearer | 2 -> Some Basic
  | 3 -> Some OAuth2 | 4 -> Some Hmac | 5 -> Some Mtls | _ -> None

(** RateLimitStrategy matching [RateLimitStrategy] in apiserver.zig. *)
type rate_limit_strategy =
  | FixedWindow  (** FixedWindow (tag 0). *)
  | SlidingWindow  (** SlidingWindow (tag 1). *)
  | TokenBucket  (** TokenBucket (tag 2). *)
  | LeakyBucket  (** LeakyBucket (tag 3). *)

let rate_limit_strategy_to_tag = function
  | FixedWindow -> 0 | SlidingWindow -> 1 | TokenBucket -> 2
  | LeakyBucket -> 3

let rate_limit_strategy_of_tag = function
  | 0 -> Some FixedWindow | 1 -> Some SlidingWindow
  | 2 -> Some TokenBucket | 3 -> Some LeakyBucket | _ -> None

(** ApiVersion matching [ApiVersion] in apiserver.zig. *)
type api_version =
  | V1  (** V1 (tag 0). *)
  | V2  (** V2 (tag 1). *)
  | V3  (** V3 (tag 2). *)
  | Latest  (** Latest (tag 3). *)
  | Deprecated  (** Deprecated (tag 4). *)

let api_version_to_tag = function
  | V1 -> 0 | V2 -> 1 | V3 -> 2 | Latest -> 3 | Deprecated -> 4

let api_version_of_tag = function
  | 0 -> Some V1 | 1 -> Some V2 | 2 -> Some V3 | 3 -> Some Latest
  | 4 -> Some Deprecated | _ -> None

(** ResponseFormat matching [ResponseFormat] in apiserver.zig. *)
type response_format =
  | Json  (** JSON (tag 0). *)
  | Xml  (** XML (tag 1). *)
  | Protobuf  (** Protobuf (tag 2). *)
  | MessagePack  (** MessagePack (tag 3). *)

let response_format_to_tag = function
  | Json -> 0 | Xml -> 1 | Protobuf -> 2 | MessagePack -> 3

let response_format_of_tag = function
  | 0 -> Some Json | 1 -> Some Xml | 2 -> Some Protobuf
  | 3 -> Some MessagePack | _ -> None

(** GatewayError matching [GatewayError] in apiserver.zig. *)
type gateway_error =
  | Unauthorized  (** Unauthorized (tag 0). *)
  | RateLimited  (** RateLimited (tag 1). *)
  | NotFound  (** NotFound (tag 2). *)
  | BadRequest  (** BadRequest (tag 3). *)
  | ServiceUnavailable  (** ServiceUnavailable (tag 4). *)
  | CircuitOpen  (** CircuitOpen (tag 5). *)

let gateway_error_to_tag = function
  | Unauthorized -> 0 | RateLimited -> 1 | NotFound -> 2
  | BadRequest -> 3 | ServiceUnavailable -> 4 | CircuitOpen -> 5

let gateway_error_of_tag = function
  | 0 -> Some Unauthorized | 1 -> Some RateLimited | 2 -> Some NotFound
  | 3 -> Some BadRequest | 4 -> Some ServiceUnavailable
  | 5 -> Some CircuitOpen | _ -> None

(* --- C FFI declarations --- *)

external c_apiserver_abi_version : unit -> int = "apiserver_abi_version"
external c_apiserver_create_context : unit -> int = "apiserver_create_context"
external c_apiserver_destroy_context : int -> unit = "apiserver_destroy_context"
external c_apiserver_state : int -> int = "apiserver_state"
external c_apiserver_can_transition : int -> int -> int = "apiserver_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_apiserver_abi_version ()

let create_context () = Proven_error.from_slot (c_apiserver_create_context ())

let destroy_context slot = c_apiserver_destroy_context slot

let get_state slot = api_version_of_tag (c_apiserver_state slot)

let can_transition ~from ~to_ =
  c_apiserver_can_transition (api_version_to_tag from) (api_version_to_tag to_) = 1
