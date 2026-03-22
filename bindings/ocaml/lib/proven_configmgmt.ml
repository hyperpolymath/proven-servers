(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Configuration management protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-configmgmt/ffi/zig/src/configmgmt.zig]. Provides OCaml
    variant types matching the Idris2 ABI enums for resource types, resource
    states, change actions, drift statuses, and apply modes. *)

(** Managed resource types matching [ResourceType] in configmgmt.zig. *)
type resource_type =
  | File | Package | Service | User | Group | Cron | Mount | Firewall
  | Registry

(** Resource states matching [ResourceState] in configmgmt.zig. *)
type resource_state = Present | Absent | Running | Stopped | Enabled | Disabled

(** Change actions matching [ChangeAction] in configmgmt.zig. *)
type change_action = Create | Modify | Delete | Restart | Reload | Skip

(** Drift statuses matching [DriftStatus] in configmgmt.zig. *)
type drift_status = In_sync | Drifted | D_unknown | Unmanaged

(** Apply modes matching [ApplyMode] in configmgmt.zig. *)
type apply_mode = Enforce | Dry_run | Audit

(** Convert a [resource_type] to its ABI tag value. *)
let resource_type_to_tag = function
  | File -> 0 | Package -> 1 | Service -> 2 | User -> 3 | Group -> 4
  | Cron -> 5 | Mount -> 6 | Firewall -> 7 | Registry -> 8

(** Decode a [resource_type] from its ABI tag value. *)
let resource_type_of_tag = function
  | 0 -> Some File | 1 -> Some Package | 2 -> Some Service | 3 -> Some User
  | 4 -> Some Group | 5 -> Some Cron | 6 -> Some Mount
  | 7 -> Some Firewall | 8 -> Some Registry | _ -> None

(** Convert a [resource_state] to its ABI tag value. *)
let resource_state_to_tag = function
  | Present -> 0 | Absent -> 1 | Running -> 2 | Stopped -> 3
  | Enabled -> 4 | Disabled -> 5

(** Decode a [resource_state] from its ABI tag value. *)
let resource_state_of_tag = function
  | 0 -> Some Present | 1 -> Some Absent | 2 -> Some Running
  | 3 -> Some Stopped | 4 -> Some Enabled | 5 -> Some Disabled | _ -> None

(** Convert a [change_action] to its ABI tag value. *)
let change_action_to_tag = function
  | Create -> 0 | Modify -> 1 | Delete -> 2 | Restart -> 3 | Reload -> 4
  | Skip -> 5

(** Decode a [change_action] from its ABI tag value. *)
let change_action_of_tag = function
  | 0 -> Some Create | 1 -> Some Modify | 2 -> Some Delete
  | 3 -> Some Restart | 4 -> Some Reload | 5 -> Some Skip | _ -> None

(** Convert a [drift_status] to its ABI tag value. *)
let drift_status_to_tag = function
  | In_sync -> 0 | Drifted -> 1 | D_unknown -> 2 | Unmanaged -> 3

(** Decode a [drift_status] from its ABI tag value. *)
let drift_status_of_tag = function
  | 0 -> Some In_sync | 1 -> Some Drifted | 2 -> Some D_unknown
  | 3 -> Some Unmanaged | _ -> None

(** Convert an [apply_mode] to its ABI tag value. *)
let apply_mode_to_tag = function
  | Enforce -> 0 | Dry_run -> 1 | Audit -> 2

(** Decode an [apply_mode] from its ABI tag value. *)
let apply_mode_of_tag = function
  | 0 -> Some Enforce | 1 -> Some Dry_run | 2 -> Some Audit | _ -> None

(* --- C FFI declarations --- *)

external c_configmgmt_abi_version : unit -> int = "configmgmt_abi_version"
external c_configmgmt_create_context : unit -> int = "configmgmt_create_context"
external c_configmgmt_destroy_context : int -> unit = "configmgmt_destroy_context"
external c_configmgmt_can_transition : int -> int -> int = "configmgmt_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_configmgmt]. *)
let abi_version () = c_configmgmt_abi_version ()

(** Create a new config management context. *)
let create_context () =
  Proven_error.from_slot (c_configmgmt_create_context ())

(** Destroy a config management context, releasing its slot. *)
let destroy_context slot = c_configmgmt_destroy_context slot

(** Stateless query: check whether a resource state transition is valid. *)
let can_transition ~from ~to_ =
  c_configmgmt_can_transition (resource_state_to_tag from) (resource_state_to_tag to_) = 1
