(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Load balancer protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-loadbalancer/ffi/zig/src/loadbalancer.zig]. Provides
    OCaml variant types matching the Idris2 ABI enums for algorithms, health
    check types, backend states, session persistence, and protocols. *)

(** Load balancing algorithms matching [Algorithm] in loadbalancer.zig. *)
type algorithm =
  | RoundRobin | LeastConnections | IpHash | Random
  | WeightedRoundRobin | LeastResponseTime

(** Health check types matching [HealthCheckType] in loadbalancer.zig. *)
type health_check_type =
  | HealthCheckType_Http | HealthCheckType_Tcp | HealthCheckType_Grpc
  | Script

(** Backend states matching [BackendState] in loadbalancer.zig. *)
type backend_state =
  | Healthy | Unhealthy | Draining | Disabled

(** Session persistence modes matching [SessionPersistence] in loadbalancer.zig. *)
type session_persistence =
  | None | Cookie | SourceIp | Header

(** Load balancer protocols matching [LbProtocol] in loadbalancer.zig. *)
type lb_protocol =
  | LbProtocol_Http | Https | LbProtocol_Tcp | Udp | LbProtocol_Grpc

(** Convert an algorithm to its ABI tag value. *)
let algorithm_to_tag = function
  | RoundRobin -> 0 | LeastConnections -> 1 | IpHash -> 2 | Random -> 3
  | WeightedRoundRobin -> 4 | LeastResponseTime -> 5

(** Decode an algorithm from its ABI tag value. *)
let algorithm_of_tag = function
  | 0 -> Some RoundRobin | 1 -> Some LeastConnections | 2 -> Some IpHash
  | 3 -> Some Random | 4 -> Some WeightedRoundRobin
  | 5 -> Some LeastResponseTime | _ -> None

(** Convert a health check type to its ABI tag value. *)
let health_check_type_to_tag = function
  | HealthCheckType_Http -> 0 | HealthCheckType_Tcp -> 1
  | HealthCheckType_Grpc -> 2 | Script -> 3

(** Decode a health check type from its ABI tag value. *)
let health_check_type_of_tag = function
  | 0 -> Some HealthCheckType_Http | 1 -> Some HealthCheckType_Tcp
  | 2 -> Some HealthCheckType_Grpc | 3 -> Some Script | _ -> None

(** Convert a backend state to its ABI tag value. *)
let backend_state_to_tag = function
  | Healthy -> 0 | Unhealthy -> 1 | Draining -> 2 | Disabled -> 3

(** Decode a backend state from its ABI tag value. *)
let backend_state_of_tag = function
  | 0 -> Some Healthy | 1 -> Some Unhealthy | 2 -> Some Draining
  | 3 -> Some Disabled | _ -> None

(** Convert a session persistence to its ABI tag value. *)
let session_persistence_to_tag = function
  | None -> 0 | Cookie -> 1 | SourceIp -> 2 | Header -> 3

(** Decode a session persistence from its ABI tag value. *)
let session_persistence_of_tag = function
  | 0 -> Some None | 1 -> Some Cookie | 2 -> Some SourceIp
  | 3 -> Some Header | _ -> Option.None

(** Convert a LB protocol to its ABI tag value. *)
let lb_protocol_to_tag = function
  | LbProtocol_Http -> 0 | Https -> 1 | LbProtocol_Tcp -> 2
  | Udp -> 3 | LbProtocol_Grpc -> 4

(** Decode a LB protocol from its ABI tag value. *)
let lb_protocol_of_tag = function
  | 0 -> Some LbProtocol_Http | 1 -> Some Https | 2 -> Some LbProtocol_Tcp
  | 3 -> Some Udp | 4 -> Some LbProtocol_Grpc | _ -> None

(* --- C FFI declarations --- *)

external c_loadbalancer_abi_version : unit -> int = "loadbalancer_abi_version"
external c_loadbalancer_create_context : unit -> int = "loadbalancer_create_context"
external c_loadbalancer_destroy_context : int -> unit = "loadbalancer_destroy_context"
external c_loadbalancer_can_transition : int -> int -> int = "loadbalancer_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_loadbalancer]. *)
let abi_version () = c_loadbalancer_abi_version ()

(** Create a new load balancer context. *)
let create_context () =
  Proven_error.from_slot (c_loadbalancer_create_context ())

(** Destroy a load balancer context, releasing its slot. *)
let destroy_context slot = c_loadbalancer_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_loadbalancer_can_transition (backend_state_to_tag from) (backend_state_to_tag to_) = 1
