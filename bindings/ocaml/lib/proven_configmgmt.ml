(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Configuration management protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-configmgmt/ffi/zig/src/configmgmt.zig]. *)

(** ResourceType matching [ResourceType] in configmgmt.zig. *)
type resource_type =
  | File  (** File (tag 0). *)
  | Package  (** Package (tag 1). *)
  | Service  (** Service (tag 2). *)
  | User  (** User (tag 3). *)
  | Group  (** Group (tag 4). *)
  | Cron  (** Cron (tag 5). *)
  | Mount  (** Mount (tag 6). *)
  | Firewall  (** Firewall (tag 7). *)
  | Registry  (** Registry (tag 8). *)

let resource_type_to_tag = function
  | File -> 0 | Package -> 1 | Service -> 2 | User -> 3 | Group -> 4
  | Cron -> 5 | Mount -> 6 | Firewall -> 7 | Registry -> 8

let resource_type_of_tag = function
  | 0 -> Some File | 1 -> Some Package | 2 -> Some Service | 3 -> Some User
  | 4 -> Some Group | 5 -> Some Cron | 6 -> Some Mount
  | 7 -> Some Firewall | 8 -> Some Registry | _ -> None

(** ResourceState matching [ResourceState] in configmgmt.zig. *)
type resource_state =
  | Present  (** Present (tag 0). *)
  | Absent  (** Absent (tag 1). *)
  | Running  (** Running (tag 2). *)
  | Stopped  (** Stopped (tag 3). *)
  | Enabled  (** Enabled (tag 4). *)
  | Disabled  (** Disabled (tag 5). *)

let resource_state_to_tag = function
  | Present -> 0 | Absent -> 1 | Running -> 2 | Stopped -> 3
  | Enabled -> 4 | Disabled -> 5

let resource_state_of_tag = function
  | 0 -> Some Present | 1 -> Some Absent | 2 -> Some Running
  | 3 -> Some Stopped | 4 -> Some Enabled | 5 -> Some Disabled | _ -> None

(** ChangeAction matching [ChangeAction] in configmgmt.zig. *)
type change_action =
  | Create  (** Create (tag 0). *)
  | Modify  (** Modify (tag 1). *)
  | Delete  (** Delete (tag 2). *)
  | Restart  (** Restart (tag 3). *)
  | Reload  (** Reload (tag 4). *)
  | Skip  (** Skip (tag 5). *)

let change_action_to_tag = function
  | Create -> 0 | Modify -> 1 | Delete -> 2 | Restart -> 3 | Reload -> 4
  | Skip -> 5

let change_action_of_tag = function
  | 0 -> Some Create | 1 -> Some Modify | 2 -> Some Delete
  | 3 -> Some Restart | 4 -> Some Reload | 5 -> Some Skip | _ -> None

(** DriftStatus matching [DriftStatus] in configmgmt.zig. *)
type drift_status =
  | InSync  (** InSync (tag 0). *)
  | Drifted  (** Drifted (tag 1). *)
  | DUnknown  (** Unknown (tag 2). *)
  | Unmanaged  (** Unmanaged (tag 3). *)

let drift_status_to_tag = function
  | InSync -> 0 | Drifted -> 1 | DUnknown -> 2 | Unmanaged -> 3

let drift_status_of_tag = function
  | 0 -> Some InSync | 1 -> Some Drifted | 2 -> Some DUnknown
  | 3 -> Some Unmanaged | _ -> None

(** ApplyMode matching [ApplyMode] in configmgmt.zig. *)
type apply_mode =
  | Enforce  (** Enforce (tag 0). *)
  | DryRun  (** DryRun (tag 1). *)
  | Audit  (** Audit (tag 2). *)

let apply_mode_to_tag = function
  | Enforce -> 0 | DryRun -> 1 | Audit -> 2

let apply_mode_of_tag = function
  | 0 -> Some Enforce | 1 -> Some DryRun | 2 -> Some Audit | _ -> None

(* --- C FFI declarations --- *)

external c_configmgmt_abi_version : unit -> int = "configmgmt_abi_version"
external c_configmgmt_create_context : unit -> int = "configmgmt_create_context"
external c_configmgmt_destroy_context : int -> unit = "configmgmt_destroy_context"
external c_configmgmt_state : int -> int = "configmgmt_state"
external c_configmgmt_can_transition : int -> int -> int = "configmgmt_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_configmgmt_abi_version ()

let create_context () = Proven_error.from_slot (c_configmgmt_create_context ())

let destroy_context slot = c_configmgmt_destroy_context slot

let get_state slot = resource_state_of_tag (c_configmgmt_state slot)

let can_transition ~from ~to_ =
  c_configmgmt_can_transition (resource_state_to_tag from) (resource_state_to_tag to_) = 1
