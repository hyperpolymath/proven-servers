(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** CalDAV (RFC 4791) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-caldav/ffi/zig/src/caldav.zig]. *)

(** ComponentType matching [ComponentType] in caldav.zig. *)
type component_type =
  | Vevent  (** VEVENT (tag 0). *)
  | Vtodo  (** VTODO (tag 1). *)
  | Vjournal  (** VJOURNAL (tag 2). *)
  | Vfreebusy  (** VFREEBUSY (tag 3). *)

let component_type_to_tag = function
  | Vevent -> 0 | Vtodo -> 1 | Vjournal -> 2 | Vfreebusy -> 3

let component_type_of_tag = function
  | 0 -> Some Vevent | 1 -> Some Vtodo | 2 -> Some Vjournal
  | 3 -> Some Vfreebusy | _ -> None

(** CalMethod matching [CalMethod] in caldav.zig. *)
type cal_method =
  | Get  (** GET (tag 0). *)
  | Put  (** PUT (tag 1). *)
  | Delete  (** DELETE (tag 2). *)
  | Propfind  (** PROPFIND (tag 3). *)
  | Proppatch  (** PROPPATCH (tag 4). *)
  | Report  (** REPORT (tag 5). *)
  | Mkcalendar  (** MKCALENDAR (tag 6). *)

let cal_method_to_tag = function
  | Get -> 0 | Put -> 1 | Delete -> 2 | Propfind -> 3 | Proppatch -> 4
  | Report -> 5 | Mkcalendar -> 6

let cal_method_of_tag = function
  | 0 -> Some Get | 1 -> Some Put | 2 -> Some Delete | 3 -> Some Propfind
  | 4 -> Some Proppatch | 5 -> Some Report | 6 -> Some Mkcalendar
  | _ -> None

(** ScheduleStatus matching [ScheduleStatus] in caldav.zig. *)
type schedule_status =
  | NeedsAction  (** NeedsAction (tag 0). *)
  | Accepted  (** Accepted (tag 1). *)
  | Declined  (** Declined (tag 2). *)
  | Tentative  (** Tentative (tag 3). *)
  | Delegated  (** Delegated (tag 4). *)

let schedule_status_to_tag = function
  | NeedsAction -> 0 | Accepted -> 1 | Declined -> 2 | Tentative -> 3
  | Delegated -> 4

let schedule_status_of_tag = function
  | 0 -> Some NeedsAction | 1 -> Some Accepted | 2 -> Some Declined
  | 3 -> Some Tentative | 4 -> Some Delegated | _ -> None

(** CalError matching [CalError] in caldav.zig. *)
type cal_error =
  | ValidCalendarData  (** ValidCalendarData (tag 0). *)
  | NoResourceTypeChange  (** NoResourceTypeChange (tag 1). *)
  | SupportedComponentMismatch  (** SupportedComponentMismatch (tag 2). *)
  | MaxResourceSize  (** MaxResourceSize (tag 3). *)
  | UidConflict  (** UidConflict (tag 4). *)
  | PreconditionFailed  (** PreconditionFailed (tag 5). *)

let cal_error_to_tag = function
  | ValidCalendarData -> 0 | NoResourceTypeChange -> 1
  | SupportedComponentMismatch -> 2 | MaxResourceSize -> 3
  | UidConflict -> 4 | PreconditionFailed -> 5

let cal_error_of_tag = function
  | 0 -> Some ValidCalendarData | 1 -> Some NoResourceTypeChange
  | 2 -> Some SupportedComponentMismatch | 3 -> Some MaxResourceSize
  | 4 -> Some UidConflict | 5 -> Some PreconditionFailed | _ -> None

(** ServerState matching [ServerState] in caldav.zig. *)
type server_state =
  | Idle  (** Idle (tag 0). *)
  | Bound  (** Bound (tag 1). *)
  | Serving  (** Serving (tag 2). *)
  | Scheduling  (** Scheduling (tag 3). *)
  | Shutdown  (** Shutdown (tag 4). *)

let server_state_to_tag = function
  | Idle -> 0 | Bound -> 1 | Serving -> 2 | Scheduling -> 3 | Shutdown -> 4

let server_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Bound | 2 -> Some Serving
  | 3 -> Some Scheduling | 4 -> Some Shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_caldav_abi_version : unit -> int = "caldav_abi_version"
external c_caldav_create_context : unit -> int = "caldav_create_context"
external c_caldav_destroy_context : int -> unit = "caldav_destroy_context"
external c_caldav_state : int -> int = "caldav_state"
external c_caldav_can_transition : int -> int -> int = "caldav_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_caldav_abi_version ()

let create_context () = Proven_error.from_slot (c_caldav_create_context ())

let destroy_context slot = c_caldav_destroy_context slot

let get_state slot = server_state_of_tag (c_caldav_state slot)

let can_transition ~from ~to_ =
  c_caldav_can_transition (server_state_to_tag from) (server_state_to_tag to_) = 1
