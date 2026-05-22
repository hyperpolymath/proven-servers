(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Application server protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-appserver/ffi/zig/src/appserver.zig]. *)

(** RequestType matching [RequestType] in appserver.zig. *)
type request_type =
  | Http  (** HTTP (tag 0). *)
  | WebSocket  (** WebSocket (tag 1). *)
  | Grpc  (** gRPC (tag 2). *)
  | GraphQl  (** GraphQL (tag 3). *)

let request_type_to_tag = function
  | Http -> 0 | WebSocket -> 1 | Grpc -> 2 | GraphQl -> 3

let request_type_of_tag = function
  | 0 -> Some Http | 1 -> Some WebSocket | 2 -> Some Grpc
  | 3 -> Some GraphQl | _ -> None

(** LifecycleState matching [LifecycleState] in appserver.zig. *)
type lifecycle_state =
  | Initializing  (** Initializing (tag 0). *)
  | Starting  (** Starting (tag 1). *)
  | Running  (** Running (tag 2). *)
  | Draining  (** Draining (tag 3). *)
  | Stopping  (** Stopping (tag 4). *)
  | Stopped  (** Stopped (tag 5). *)

let lifecycle_state_to_tag = function
  | Initializing -> 0 | Starting -> 1 | Running -> 2 | Draining -> 3
  | Stopping -> 4 | Stopped -> 5

let lifecycle_state_of_tag = function
  | 0 -> Some Initializing | 1 -> Some Starting | 2 -> Some Running
  | 3 -> Some Draining | 4 -> Some Stopping | 5 -> Some Stopped
  | _ -> None

(** HealthCheck matching [HealthCheck] in appserver.zig. *)
type health_check =
  | Liveness  (** Liveness (tag 0). *)
  | Readiness  (** Readiness (tag 1). *)
  | Startup  (** Startup (tag 2). *)

let health_check_to_tag = function
  | Liveness -> 0 | Readiness -> 1 | Startup -> 2

let health_check_of_tag = function
  | 0 -> Some Liveness | 1 -> Some Readiness | 2 -> Some Startup
  | _ -> None

(** DeployStrategy matching [DeployStrategy] in appserver.zig. *)
type deploy_strategy =
  | RollingUpdate  (** RollingUpdate (tag 0). *)
  | BlueGreen  (** BlueGreen (tag 1). *)
  | Canary  (** Canary (tag 2). *)
  | Recreate  (** Recreate (tag 3). *)

let deploy_strategy_to_tag = function
  | RollingUpdate -> 0 | BlueGreen -> 1 | Canary -> 2 | Recreate -> 3

let deploy_strategy_of_tag = function
  | 0 -> Some RollingUpdate | 1 -> Some BlueGreen | 2 -> Some Canary
  | 3 -> Some Recreate | _ -> None

(** ErrorCategory matching [ErrorCategory] in appserver.zig. *)
type error_category =
  | ClientError  (** ClientError (tag 0). *)
  | ServerError  (** ServerError (tag 1). *)
  | Timeout  (** Timeout (tag 2). *)
  | CircuitOpen  (** CircuitOpen (tag 3). *)
  | RateLimited  (** RateLimited (tag 4). *)

let error_category_to_tag = function
  | ClientError -> 0 | ServerError -> 1 | Timeout -> 2
  | CircuitOpen -> 3 | RateLimited -> 4

let error_category_of_tag = function
  | 0 -> Some ClientError | 1 -> Some ServerError | 2 -> Some Timeout
  | 3 -> Some CircuitOpen | 4 -> Some RateLimited | _ -> None

(* --- C FFI declarations --- *)

external c_appserver_abi_version : unit -> int = "appserver_abi_version"
external c_appserver_create_context : unit -> int = "appserver_create_context"
external c_appserver_destroy_context : int -> unit = "appserver_destroy_context"
external c_appserver_state : int -> int = "appserver_state"
external c_appserver_can_transition : int -> int -> int = "appserver_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_appserver_abi_version ()

let create_context () = Proven_error.from_slot (c_appserver_create_context ())

let destroy_context slot = c_appserver_destroy_context slot

let get_state slot = lifecycle_state_of_tag (c_appserver_state slot)

let can_transition ~from ~to_ =
  c_appserver_can_transition (lifecycle_state_to_tag from) (lifecycle_state_to_tag to_) = 1
