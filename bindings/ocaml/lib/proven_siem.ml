(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** SIEM (Security Information and Event Management) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-siem/ffi/zig/src/siem.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for event severity, event categories,
    correlation rules, and alert states. *)

(** Event severity levels matching [EventSeverity] in siem.zig. *)
type event_severity = Info | Low | Medium | High | Critical

(** Event categories matching [EventCategory] in siem.zig. *)
type event_category =
  | Authentication | Network_traffic | File_activity | Process_execution
  | Policy_violation | Malware | Data_exfiltration

(** Correlation rule types matching [CorrelationRule] in siem.zig. *)
type correlation_rule = Threshold | Sequence | Aggregation | Absence | Statistical

(** Alert lifecycle states matching [AlertState] in siem.zig. *)
type alert_state = New | Acknowledged | In_progress | Resolved | False_positive

(** Convert an event severity to its ABI tag value. *)
let event_severity_to_tag = function
  | Info -> 0 | Low -> 1 | Medium -> 2 | High -> 3 | Critical -> 4

(** Decode an event severity from its ABI tag value. *)
let event_severity_of_tag = function
  | 0 -> Some Info | 1 -> Some Low | 2 -> Some Medium
  | 3 -> Some High | 4 -> Some Critical | _ -> None

(** Convert an event category to its ABI tag value. *)
let event_category_to_tag = function
  | Authentication -> 0 | Network_traffic -> 1 | File_activity -> 2
  | Process_execution -> 3 | Policy_violation -> 4 | Malware -> 5
  | Data_exfiltration -> 6

(** Decode an event category from its ABI tag value. *)
let event_category_of_tag = function
  | 0 -> Some Authentication | 1 -> Some Network_traffic
  | 2 -> Some File_activity | 3 -> Some Process_execution
  | 4 -> Some Policy_violation | 5 -> Some Malware
  | 6 -> Some Data_exfiltration | _ -> None

(** Convert a correlation rule to its ABI tag value. *)
let correlation_rule_to_tag = function
  | Threshold -> 0 | Sequence -> 1 | Aggregation -> 2
  | Absence -> 3 | Statistical -> 4

(** Decode a correlation rule from its ABI tag value. *)
let correlation_rule_of_tag = function
  | 0 -> Some Threshold | 1 -> Some Sequence | 2 -> Some Aggregation
  | 3 -> Some Absence | 4 -> Some Statistical | _ -> None

(** Convert an alert state to its ABI tag value. *)
let alert_state_to_tag = function
  | New -> 0 | Acknowledged -> 1 | In_progress -> 2
  | Resolved -> 3 | False_positive -> 4

(** Decode an alert state from its ABI tag value. *)
let alert_state_of_tag = function
  | 0 -> Some New | 1 -> Some Acknowledged | 2 -> Some In_progress
  | 3 -> Some Resolved | 4 -> Some False_positive | _ -> None

(* --- C FFI declarations --- *)

external c_siem_abi_version : unit -> int = "siem_abi_version"
external c_siem_create_context : unit -> int = "siem_create_context"
external c_siem_destroy_context : int -> unit = "siem_destroy_context"
external c_siem_can_transition : int -> int -> int = "siem_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_siem]. *)
let abi_version () = c_siem_abi_version ()

(** Create a new SIEM context. *)
let create_context () =
  Proven_error.from_slot (c_siem_create_context ())

(** Destroy a SIEM context, releasing its slot. *)
let destroy_context slot = c_siem_destroy_context slot

(** Stateless query: check whether an alert state transition is valid. *)
let can_transition ~from ~to_ =
  c_siem_can_transition (alert_state_to_tag from) (alert_state_to_tag to_) = 1
