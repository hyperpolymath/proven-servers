(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** SNMP (Simple Network Management Protocol) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-snmp/ffi/zig/src/snmp.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for SNMP versions, PDU types,
    and error statuses. *)

(** SNMP protocol versions matching [Version] in snmp.zig. *)
type version = V1 | V2c | V3

(** SNMP PDU types matching [PduType] in snmp.zig. *)
type pdu_type =
  | Get_request | Get_next_request | Get_response | Set_request
  | Get_bulk_request | Inform_request | Snmp_v2_trap

(** SNMP error statuses matching [ErrorStatus] in snmp.zig. *)
type error_status =
  | No_error | Too_big | No_such_name | Bad_value | Read_only | Gen_err
  | No_access | Wrong_type | Wrong_length | Wrong_value | No_creation
  | Inconsistent_value | Resource_unavailable | Commit_failed
  | Undo_failed | Authorization_error

(** Convert a version to its ABI tag value. *)
let version_to_tag = function
  | V1 -> 0 | V2c -> 1 | V3 -> 2

(** Decode a version from its ABI tag value. *)
let version_of_tag = function
  | 0 -> Some V1 | 1 -> Some V2c | 2 -> Some V3 | _ -> None

(** Convert a PDU type to its ABI tag value. *)
let pdu_type_to_tag = function
  | Get_request -> 0 | Get_next_request -> 1 | Get_response -> 2
  | Set_request -> 3 | Get_bulk_request -> 4 | Inform_request -> 5
  | Snmp_v2_trap -> 6

(** Decode a PDU type from its ABI tag value. *)
let pdu_type_of_tag = function
  | 0 -> Some Get_request | 1 -> Some Get_next_request
  | 2 -> Some Get_response | 3 -> Some Set_request
  | 4 -> Some Get_bulk_request | 5 -> Some Inform_request
  | 6 -> Some Snmp_v2_trap | _ -> None

(** Convert an error status to its ABI tag value. *)
let error_status_to_tag = function
  | No_error -> 0 | Too_big -> 1 | No_such_name -> 2 | Bad_value -> 3
  | Read_only -> 4 | Gen_err -> 5 | No_access -> 6 | Wrong_type -> 7
  | Wrong_length -> 8 | Wrong_value -> 9 | No_creation -> 10
  | Inconsistent_value -> 11 | Resource_unavailable -> 12
  | Commit_failed -> 13 | Undo_failed -> 14 | Authorization_error -> 15

(** Decode an error status from its ABI tag value. *)
let error_status_of_tag = function
  | 0 -> Some No_error | 1 -> Some Too_big | 2 -> Some No_such_name
  | 3 -> Some Bad_value | 4 -> Some Read_only | 5 -> Some Gen_err
  | 6 -> Some No_access | 7 -> Some Wrong_type | 8 -> Some Wrong_length
  | 9 -> Some Wrong_value | 10 -> Some No_creation
  | 11 -> Some Inconsistent_value | 12 -> Some Resource_unavailable
  | 13 -> Some Commit_failed | 14 -> Some Undo_failed
  | 15 -> Some Authorization_error | _ -> None

(* --- C FFI declarations --- *)

external c_snmp_abi_version : unit -> int = "snmp_abi_version"
external c_snmp_create_context : unit -> int = "snmp_create_context"
external c_snmp_destroy_context : int -> unit = "snmp_destroy_context"
external c_snmp_can_transition : int -> int -> int = "snmp_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_snmp]. *)
let abi_version () = c_snmp_abi_version ()

(** Create a new SNMP context. *)
let create_context () =
  Proven_error.from_slot (c_snmp_create_context ())

(** Destroy an SNMP context, releasing its slot. *)
let destroy_context slot = c_snmp_destroy_context slot

(** Stateless query: check whether a version transition is valid. *)
let can_transition ~from ~to_ =
  c_snmp_can_transition (version_to_tag from) (version_to_tag to_) = 1
