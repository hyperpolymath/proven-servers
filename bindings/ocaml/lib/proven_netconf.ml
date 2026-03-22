(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** NETCONF (RFC 6241) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-netconf/ffi/zig/src/netconf.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for operations, datastores, edit
    operations, error types, error severities, and session states. *)

(** NETCONF operations matching [NetconfOperation] in netconf.zig. *)
type netconf_operation =
  | Get | GetConfig | EditConfig | CopyConfig | DeleteConfig | Lock
  | Unlock | CloseSession | KillSession | Commit | Validate | DiscardChanges

(** Datastores matching [Datastore] in netconf.zig. *)
type datastore =
  | Running | Startup | Candidate

(** Edit operations matching [EditOperation] in netconf.zig. *)
type edit_operation =
  | Merge | Replace | Create | Delete | Remove

(** NETCONF error types matching [NetconfErrorType] in netconf.zig. *)
type netconf_error_type =
  | Transport | Rpc | Protocol | Application

(** Error severities matching [ErrorSeverity] in netconf.zig. *)
type error_severity =
  | Error | Warning

(** Session states matching [NetconfState] in netconf.zig. *)
type netconf_state =
  | Idle | Connected | Locked | Editing | Closing | Terminated

(** Convert a NETCONF operation to its ABI tag value. *)
let netconf_operation_to_tag = function
  | Get -> 0 | GetConfig -> 1 | EditConfig -> 2 | CopyConfig -> 3
  | DeleteConfig -> 4 | Lock -> 5 | Unlock -> 6 | CloseSession -> 7
  | KillSession -> 8 | Commit -> 9 | Validate -> 10 | DiscardChanges -> 11

(** Decode a NETCONF operation from its ABI tag value. *)
let netconf_operation_of_tag = function
  | 0 -> Some Get | 1 -> Some GetConfig | 2 -> Some EditConfig
  | 3 -> Some CopyConfig | 4 -> Some DeleteConfig | 5 -> Some Lock
  | 6 -> Some Unlock | 7 -> Some CloseSession | 8 -> Some KillSession
  | 9 -> Some Commit | 10 -> Some Validate | 11 -> Some DiscardChanges
  | _ -> None

(** Convert a datastore to its ABI tag value. *)
let datastore_to_tag = function
  | Running -> 0 | Startup -> 1 | Candidate -> 2

(** Decode a datastore from its ABI tag value. *)
let datastore_of_tag = function
  | 0 -> Some Running | 1 -> Some Startup | 2 -> Some Candidate | _ -> None

(** Convert an edit operation to its ABI tag value. *)
let edit_operation_to_tag = function
  | Merge -> 0 | Replace -> 1 | Create -> 2 | Delete -> 3 | Remove -> 4

(** Decode an edit operation from its ABI tag value. *)
let edit_operation_of_tag = function
  | 0 -> Some Merge | 1 -> Some Replace | 2 -> Some Create
  | 3 -> Some Delete | 4 -> Some Remove | _ -> None

(** Convert a NETCONF error type to its ABI tag value. *)
let netconf_error_type_to_tag = function
  | Transport -> 0 | Rpc -> 1 | Protocol -> 2 | Application -> 3

(** Decode a NETCONF error type from its ABI tag value. *)
let netconf_error_type_of_tag = function
  | 0 -> Some Transport | 1 -> Some Rpc | 2 -> Some Protocol
  | 3 -> Some Application | _ -> None

(** Convert an error severity to its ABI tag value. *)
let error_severity_to_tag = function
  | Error -> 0 | Warning -> 1

(** Decode an error severity from its ABI tag value. *)
let error_severity_of_tag = function
  | 0 -> Some Error | 1 -> Some Warning | _ -> None

(** Convert a NETCONF state to its ABI tag value. *)
let netconf_state_to_tag = function
  | Idle -> 0 | Connected -> 1 | Locked -> 2 | Editing -> 3
  | Closing -> 4 | Terminated -> 5

(** Decode a NETCONF state from its ABI tag value. *)
let netconf_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Connected | 2 -> Some Locked
  | 3 -> Some Editing | 4 -> Some Closing | 5 -> Some Terminated
  | _ -> None

(* --- C FFI declarations --- *)

external c_netconf_abi_version : unit -> int = "netconf_abi_version"
external c_netconf_create_context : unit -> int = "netconf_create_context"
external c_netconf_destroy_context : int -> unit = "netconf_destroy_context"
external c_netconf_can_transition : int -> int -> int = "netconf_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_netconf]. *)
let abi_version () = c_netconf_abi_version ()

(** Create a new NETCONF context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_netconf_create_context ())

(** Destroy a NETCONF context, releasing its slot. *)
let destroy_context slot = c_netconf_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_netconf_can_transition (netconf_state_to_tag from) (netconf_state_to_tag to_) = 1
