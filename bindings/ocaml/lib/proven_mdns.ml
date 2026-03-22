(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** mDNS (RFC 6762) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-mdns/ffi/zig/src/mdns.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for record types, query types, conflict
    actions, service flags, and responder states. *)

(** mDNS record types matching [MdnsRecordType] in mdns.zig. *)
type mdns_record_type =
  | A | Aaaa | Ptr | Srv | Txt

(** Query types matching [QueryType] in mdns.zig. *)
type query_type =
  | Standard | OneShot | Continuous

(** Conflict resolution actions matching [ConflictAction] in mdns.zig. *)
type conflict_action =
  | Probe | Defend | Withdraw

(** Service flags matching [ServiceFlag] in mdns.zig. *)
type service_flag =
  | Unique | Shared

(** Responder states matching [ResponderState] in mdns.zig. *)
type responder_state =
  | Idle | Probing | Announcing | Running | ShuttingDown

(** Convert a record type to its ABI tag value. *)
let mdns_record_type_to_tag = function
  | A -> 0 | Aaaa -> 1 | Ptr -> 2 | Srv -> 3 | Txt -> 4

(** Decode a record type from its ABI tag value. *)
let mdns_record_type_of_tag = function
  | 0 -> Some A | 1 -> Some Aaaa | 2 -> Some Ptr | 3 -> Some Srv
  | 4 -> Some Txt | _ -> None

(** Convert a query type to its ABI tag value. *)
let query_type_to_tag = function
  | Standard -> 0 | OneShot -> 1 | Continuous -> 2

(** Decode a query type from its ABI tag value. *)
let query_type_of_tag = function
  | 0 -> Some Standard | 1 -> Some OneShot | 2 -> Some Continuous
  | _ -> None

(** Convert a conflict action to its ABI tag value. *)
let conflict_action_to_tag = function
  | Probe -> 0 | Defend -> 1 | Withdraw -> 2

(** Decode a conflict action from its ABI tag value. *)
let conflict_action_of_tag = function
  | 0 -> Some Probe | 1 -> Some Defend | 2 -> Some Withdraw | _ -> None

(** Convert a service flag to its ABI tag value. *)
let service_flag_to_tag = function
  | Unique -> 0 | Shared -> 1

(** Decode a service flag from its ABI tag value. *)
let service_flag_of_tag = function
  | 0 -> Some Unique | 1 -> Some Shared | _ -> None

(** Convert a responder state to its ABI tag value. *)
let responder_state_to_tag = function
  | Idle -> 0 | Probing -> 1 | Announcing -> 2 | Running -> 3
  | ShuttingDown -> 4

(** Decode a responder state from its ABI tag value. *)
let responder_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Probing | 2 -> Some Announcing
  | 3 -> Some Running | 4 -> Some ShuttingDown | _ -> None

(* --- C FFI declarations --- *)

external c_mdns_abi_version : unit -> int = "mdns_abi_version"
external c_mdns_create_context : unit -> int = "mdns_create_context"
external c_mdns_destroy_context : int -> unit = "mdns_destroy_context"
external c_mdns_can_transition : int -> int -> int = "mdns_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_mdns]. *)
let abi_version () = c_mdns_abi_version ()

(** Create a new mDNS context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_mdns_create_context ())

(** Destroy an mDNS context, releasing its slot. *)
let destroy_context slot = c_mdns_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_mdns_can_transition (responder_state_to_tag from) (responder_state_to_tag to_) = 1
