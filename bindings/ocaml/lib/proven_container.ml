(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Container runtime protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-container/ffi/zig/src/container.zig]. *)

(** ContainerState matching [ContainerState] in container.zig. *)
type container_state =
  | Creating  (** Creating (tag 0). *)
  | Running  (** Running (tag 1). *)
  | Paused  (** Paused (tag 2). *)
  | Restarting  (** Restarting (tag 3). *)
  | Stopped  (** Stopped (tag 4). *)
  | Removing  (** Removing (tag 5). *)
  | Dead  (** Dead (tag 6). *)

let container_state_to_tag = function
  | Creating -> 0 | Running -> 1 | Paused -> 2 | Restarting -> 3
  | Stopped -> 4 | Removing -> 5 | Dead -> 6

let container_state_of_tag = function
  | 0 -> Some Creating | 1 -> Some Running | 2 -> Some Paused
  | 3 -> Some Restarting | 4 -> Some Stopped | 5 -> Some Removing
  | 6 -> Some Dead | _ -> None

(** ContainerOperation matching [ContainerOperation] in container.zig. *)
type container_operation =
  | Create  (** Create (tag 0). *)
  | Start  (** Start (tag 1). *)
  | Stop  (** Stop (tag 2). *)
  | Restart  (** Restart (tag 3). *)
  | Pause  (** Pause (tag 4). *)
  | Unpause  (** Unpause (tag 5). *)
  | Kill  (** Kill (tag 6). *)
  | Remove  (** Remove (tag 7). *)
  | Exec  (** Exec (tag 8). *)
  | Logs  (** Logs (tag 9). *)
  | Inspect  (** Inspect (tag 10). *)

let container_operation_to_tag = function
  | Create -> 0 | Start -> 1 | Stop -> 2 | Restart -> 3 | Pause -> 4
  | Unpause -> 5 | Kill -> 6 | Remove -> 7 | Exec -> 8 | Logs -> 9
  | Inspect -> 10

let container_operation_of_tag = function
  | 0 -> Some Create | 1 -> Some Start | 2 -> Some Stop | 3 -> Some Restart
  | 4 -> Some Pause | 5 -> Some Unpause | 6 -> Some Kill | 7 -> Some Remove
  | 8 -> Some Exec | 9 -> Some Logs | 10 -> Some Inspect | _ -> None

(** NetworkMode matching [NetworkMode] in container.zig. *)
type network_mode =
  | Bridge  (** Bridge (tag 0). *)
  | Host  (** Host (tag 1). *)
  | NetNone  (** None (tag 2). *)
  | Overlay  (** Overlay (tag 3). *)
  | Macvlan  (** Macvlan (tag 4). *)

let network_mode_to_tag = function
  | Bridge -> 0 | Host -> 1 | NetNone -> 2 | Overlay -> 3 | Macvlan -> 4

let network_mode_of_tag = function
  | 0 -> Some Bridge | 1 -> Some Host | 2 -> Some NetNone
  | 3 -> Some Overlay | 4 -> Some Macvlan | _ -> None

(** VolumeType matching [VolumeType] in container.zig. *)
type volume_type =
  | Bind  (** Bind mount (tag 0). *)
  | Named  (** Named volume (tag 1). *)
  | Tmpfs  (** tmpfs (tag 2). *)

let volume_type_to_tag = function Bind -> 0 | Named -> 1 | Tmpfs -> 2

let volume_type_of_tag = function
  | 0 -> Some Bind | 1 -> Some Named | 2 -> Some Tmpfs | _ -> None

(** RestartPolicy matching [RestartPolicy] in container.zig. *)
type restart_policy =
  | No  (** No (tag 0). *)
  | Always  (** Always (tag 1). *)
  | OnFailure  (** OnFailure (tag 2). *)
  | UnlessStopped  (** UnlessStopped (tag 3). *)

let restart_policy_to_tag = function
  | No -> 0 | Always -> 1 | OnFailure -> 2 | UnlessStopped -> 3

let restart_policy_of_tag = function
  | 0 -> Some No | 1 -> Some Always | 2 -> Some OnFailure
  | 3 -> Some UnlessStopped | _ -> None

(** HealthStatus matching [HealthStatus] in container.zig. *)
type health_status =
  | Starting  (** Starting (tag 0). *)
  | Healthy  (** Healthy (tag 1). *)
  | Unhealthy  (** Unhealthy (tag 2). *)
  | NoCheck  (** NoCheck (tag 3). *)

let health_status_to_tag = function
  | Starting -> 0 | Healthy -> 1 | Unhealthy -> 2 | NoCheck -> 3

let health_status_of_tag = function
  | 0 -> Some Starting | 1 -> Some Healthy | 2 -> Some Unhealthy
  | 3 -> Some NoCheck | _ -> None

(* --- C FFI declarations --- *)

external c_container_abi_version : unit -> int = "container_abi_version"
external c_container_create_context : unit -> int = "container_create_context"
external c_container_destroy_context : int -> unit = "container_destroy_context"
external c_container_state : int -> int = "container_state"
external c_container_can_transition : int -> int -> int = "container_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_container_abi_version ()

let create_context () = Proven_error.from_slot (c_container_create_context ())

let destroy_context slot = c_container_destroy_context slot

let get_state slot = container_state_of_tag (c_container_state slot)

let can_transition ~from ~to_ =
  c_container_can_transition (container_state_to_tag from) (container_state_to_tag to_) = 1
