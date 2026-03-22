(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Container runtime protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-container/ffi/zig/src/container.zig]. Provides OCaml
    variant types matching the Idris2 ABI enums for container states,
    operations, network modes, volume types, restart policies, and health
    statuses. *)

(** Container lifecycle states matching [ContainerState] in container.zig. *)
type container_state =
  | Creating | Running | Paused | Restarting | Stopped | Removing | Dead

(** Container operations matching [ContainerOperation] in container.zig. *)
type container_operation =
  | Create | Start | Stop | Restart | Pause | Unpause | Kill | Remove
  | Exec | Logs | Inspect

(** Network modes matching [NetworkMode] in container.zig. *)
type network_mode = Bridge | Host | None | Overlay | Macvlan

(** Volume types matching [VolumeType] in container.zig. *)
type volume_type = Bind | Named | Tmpfs

(** Restart policies matching [RestartPolicy] in container.zig. *)
type restart_policy = No | Always | On_failure | Unless_stopped

(** Health statuses matching [HealthStatus] in container.zig. *)
type health_status = Starting | Healthy | Unhealthy | No_check

(** Convert a [container_state] to its ABI tag value. *)
let container_state_to_tag = function
  | Creating -> 0 | Running -> 1 | Paused -> 2 | Restarting -> 3
  | Stopped -> 4 | Removing -> 5 | Dead -> 6

(** Decode a [container_state] from its ABI tag value. *)
let container_state_of_tag = function
  | 0 -> Some Creating | 1 -> Some Running | 2 -> Some Paused
  | 3 -> Some Restarting | 4 -> Some Stopped | 5 -> Some Removing
  | 6 -> Some Dead | _ -> None

(** Convert a [container_operation] to its ABI tag value. *)
let container_operation_to_tag = function
  | Create -> 0 | Start -> 1 | Stop -> 2 | Restart -> 3 | Pause -> 4
  | Unpause -> 5 | Kill -> 6 | Remove -> 7 | Exec -> 8 | Logs -> 9
  | Inspect -> 10

(** Decode a [container_operation] from its ABI tag value. *)
let container_operation_of_tag = function
  | 0 -> Some Create | 1 -> Some Start | 2 -> Some Stop | 3 -> Some Restart
  | 4 -> Some Pause | 5 -> Some Unpause | 6 -> Some Kill | 7 -> Some Remove
  | 8 -> Some Exec | 9 -> Some Logs | 10 -> Some Inspect | _ -> None

(** Convert a [network_mode] to its ABI tag value. *)
let network_mode_to_tag = function
  | Bridge -> 0 | Host -> 1 | None -> 2 | Overlay -> 3 | Macvlan -> 4

(** Decode a [network_mode] from its ABI tag value. *)
let network_mode_of_tag = function
  | 0 -> Some Bridge | 1 -> Some Host | 2 -> Some None | 3 -> Some Overlay
  | 4 -> Some Macvlan | _ -> Option.None

(** Convert a [volume_type] to its ABI tag value. *)
let volume_type_to_tag = function Bind -> 0 | Named -> 1 | Tmpfs -> 2

(** Decode a [volume_type] from its ABI tag value. *)
let volume_type_of_tag = function
  | 0 -> Some Bind | 1 -> Some Named | 2 -> Some Tmpfs | _ -> Option.None

(** Convert a [restart_policy] to its ABI tag value. *)
let restart_policy_to_tag = function
  | No -> 0 | Always -> 1 | On_failure -> 2 | Unless_stopped -> 3

(** Decode a [restart_policy] from its ABI tag value. *)
let restart_policy_of_tag = function
  | 0 -> Some No | 1 -> Some Always | 2 -> Some On_failure
  | 3 -> Some Unless_stopped | _ -> Option.None

(** Convert a [health_status] to its ABI tag value. *)
let health_status_to_tag = function
  | Starting -> 0 | Healthy -> 1 | Unhealthy -> 2 | No_check -> 3

(** Decode a [health_status] from its ABI tag value. *)
let health_status_of_tag = function
  | 0 -> Some Starting | 1 -> Some Healthy | 2 -> Some Unhealthy
  | 3 -> Some No_check | _ -> Option.None

(* --- C FFI declarations --- *)

external c_container_abi_version : unit -> int = "container_abi_version"
external c_container_create_context : unit -> int = "container_create_context"
external c_container_destroy_context : int -> unit = "container_destroy_context"
external c_container_can_transition : int -> int -> int = "container_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_container]. *)
let abi_version () = c_container_abi_version ()

(** Create a new container context. *)
let create_context () =
  Proven_error.from_slot (c_container_create_context ())

(** Destroy a container context, releasing its slot. *)
let destroy_context slot = c_container_destroy_context slot

(** Stateless query: check whether a container state transition is valid. *)
let can_transition ~from ~to_ =
  c_container_can_transition (container_state_to_tag from) (container_state_to_tag to_) = 1
