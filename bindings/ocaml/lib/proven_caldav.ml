(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** CalDAV (RFC 4791) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-caldav/ffi/zig/src/caldav.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for component types, calendar methods,
    schedule statuses, calendar errors, and server states. *)

(** iCalendar component types matching [ComponentType] in caldav.zig. *)
type component_type = Vevent | Vtodo | Vjournal | Vfreebusy

(** CalDAV methods matching [CalMethod] in caldav.zig. *)
type cal_method = Get | Put | Delete | Propfind | Proppatch | Report | Mkcalendar

(** Schedule participation statuses matching [ScheduleStatus] in caldav.zig. *)
type schedule_status = Needs_action | Accepted | Declined | Tentative | Delegated

(** CalDAV error conditions matching [CalError] in caldav.zig. *)
type cal_error =
  | Valid_calendar_data | No_resource_type_change
  | Supported_component_mismatch | Max_resource_size | Uid_conflict
  | Precondition_failed

(** Server lifecycle states matching [ServerState] in caldav.zig. *)
type server_state = Idle | Bound | Serving | Scheduling | Shutdown

(** Convert a [component_type] to its ABI tag value. *)
let component_type_to_tag = function
  | Vevent -> 0 | Vtodo -> 1 | Vjournal -> 2 | Vfreebusy -> 3

(** Decode a [component_type] from its ABI tag value. *)
let component_type_of_tag = function
  | 0 -> Some Vevent | 1 -> Some Vtodo | 2 -> Some Vjournal
  | 3 -> Some Vfreebusy | _ -> None

(** Convert a [cal_method] to its ABI tag value. *)
let cal_method_to_tag = function
  | Get -> 0 | Put -> 1 | Delete -> 2 | Propfind -> 3 | Proppatch -> 4
  | Report -> 5 | Mkcalendar -> 6

(** Decode a [cal_method] from its ABI tag value. *)
let cal_method_of_tag = function
  | 0 -> Some Get | 1 -> Some Put | 2 -> Some Delete | 3 -> Some Propfind
  | 4 -> Some Proppatch | 5 -> Some Report | 6 -> Some Mkcalendar
  | _ -> None

(** Convert a [schedule_status] to its ABI tag value. *)
let schedule_status_to_tag = function
  | Needs_action -> 0 | Accepted -> 1 | Declined -> 2 | Tentative -> 3
  | Delegated -> 4

(** Decode a [schedule_status] from its ABI tag value. *)
let schedule_status_of_tag = function
  | 0 -> Some Needs_action | 1 -> Some Accepted | 2 -> Some Declined
  | 3 -> Some Tentative | 4 -> Some Delegated | _ -> None

(** Convert a [cal_error] to its ABI tag value. *)
let cal_error_to_tag = function
  | Valid_calendar_data -> 0 | No_resource_type_change -> 1
  | Supported_component_mismatch -> 2 | Max_resource_size -> 3
  | Uid_conflict -> 4 | Precondition_failed -> 5

(** Decode a [cal_error] from its ABI tag value. *)
let cal_error_of_tag = function
  | 0 -> Some Valid_calendar_data | 1 -> Some No_resource_type_change
  | 2 -> Some Supported_component_mismatch | 3 -> Some Max_resource_size
  | 4 -> Some Uid_conflict | 5 -> Some Precondition_failed | _ -> None

(** Convert a [server_state] to its ABI tag value. *)
let server_state_to_tag = function
  | Idle -> 0 | Bound -> 1 | Serving -> 2 | Scheduling -> 3 | Shutdown -> 4

(** Decode a [server_state] from its ABI tag value. *)
let server_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Bound | 2 -> Some Serving
  | 3 -> Some Scheduling | 4 -> Some Shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_caldav_abi_version : unit -> int = "caldav_abi_version"
external c_caldav_create_context : unit -> int = "caldav_create_context"
external c_caldav_destroy_context : int -> unit = "caldav_destroy_context"
external c_caldav_can_transition : int -> int -> int = "caldav_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_caldav]. *)
let abi_version () = c_caldav_abi_version ()

(** Create a new CalDAV context. *)
let create_context () =
  Proven_error.from_slot (c_caldav_create_context ())

(** Destroy a CalDAV context, releasing its slot. *)
let destroy_context slot = c_caldav_destroy_context slot

(** Stateless query: check whether a server state transition is valid. *)
let can_transition ~from ~to_ =
  c_caldav_can_transition (server_state_to_tag from) (server_state_to_tag to_) = 1
