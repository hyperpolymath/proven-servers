(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Monitoring/uptime protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-monitor/ffi/zig/src/monitor.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for check types, statuses, alert
    channels, severities, check states, and monitor states. *)

(** Check types matching [CheckType] in monitor.zig. *)
type check_type =
  | Http | Tcp | Udp | Icmp | Dns | Certificate | Disk | Cpu
  | Memory | Process | Custom

(** Monitor statuses matching [Status] in monitor.zig. *)
type status =
  | Up | Down | Degraded | Unknown | Maintenance

(** Alert channels matching [AlertChannel] in monitor.zig. *)
type alert_channel =
  | Email | Sms | Webhook | Slack | PagerDuty

(** Severity levels matching [Severity] in monitor.zig. *)
type severity =
  | Info | Warning | Error | Critical

(** Check states matching [CheckState] in monitor.zig. *)
type check_state =
  | Pending | CheckState_Running | Passed | Failed | Timeout | CsError

(** Monitor states matching [MonitorState] in monitor.zig. *)
type monitor_state =
  | Idle | Configured | MonitorState_Running | MonPaused
  | Alerting | Shutdown

(** Convert a check type to its ABI tag value. *)
let check_type_to_tag = function
  | Http -> 0 | Tcp -> 1 | Udp -> 2 | Icmp -> 3 | Dns -> 4
  | Certificate -> 5 | Disk -> 6 | Cpu -> 7 | Memory -> 8
  | Process -> 9 | Custom -> 10

(** Decode a check type from its ABI tag value. *)
let check_type_of_tag = function
  | 0 -> Some Http | 1 -> Some Tcp | 2 -> Some Udp | 3 -> Some Icmp
  | 4 -> Some Dns | 5 -> Some Certificate | 6 -> Some Disk | 7 -> Some Cpu
  | 8 -> Some Memory | 9 -> Some Process | 10 -> Some Custom | _ -> None

(** Convert a status to its ABI tag value. *)
let status_to_tag = function
  | Up -> 0 | Down -> 1 | Degraded -> 2 | Unknown -> 3 | Maintenance -> 4

(** Decode a status from its ABI tag value. *)
let status_of_tag = function
  | 0 -> Some Up | 1 -> Some Down | 2 -> Some Degraded
  | 3 -> Some Unknown | 4 -> Some Maintenance | _ -> None

(** Convert an alert channel to its ABI tag value. *)
let alert_channel_to_tag = function
  | Email -> 0 | Sms -> 1 | Webhook -> 2 | Slack -> 3 | PagerDuty -> 4

(** Decode an alert channel from its ABI tag value. *)
let alert_channel_of_tag = function
  | 0 -> Some Email | 1 -> Some Sms | 2 -> Some Webhook
  | 3 -> Some Slack | 4 -> Some PagerDuty | _ -> None

(** Convert a severity to its ABI tag value. *)
let severity_to_tag = function
  | Info -> 0 | Warning -> 1 | Error -> 2 | Critical -> 3

(** Decode a severity from its ABI tag value. *)
let severity_of_tag = function
  | 0 -> Some Info | 1 -> Some Warning | 2 -> Some Error
  | 3 -> Some Critical | _ -> None

(** Convert a check state to its ABI tag value. *)
let check_state_to_tag = function
  | Pending -> 0 | CheckState_Running -> 1 | Passed -> 2 | Failed -> 3
  | Timeout -> 4 | CsError -> 5

(** Decode a check state from its ABI tag value. *)
let check_state_of_tag = function
  | 0 -> Some Pending | 1 -> Some CheckState_Running | 2 -> Some Passed
  | 3 -> Some Failed | 4 -> Some Timeout | 5 -> Some CsError | _ -> None

(** Convert a monitor state to its ABI tag value. *)
let monitor_state_to_tag = function
  | Idle -> 0 | Configured -> 1 | MonitorState_Running -> 2
  | MonPaused -> 3 | Alerting -> 4 | Shutdown -> 5

(** Decode a monitor state from its ABI tag value. *)
let monitor_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Configured | 2 -> Some MonitorState_Running
  | 3 -> Some MonPaused | 4 -> Some Alerting | 5 -> Some Shutdown
  | _ -> None

(* --- C FFI declarations --- *)

external c_monitor_abi_version : unit -> int = "monitor_abi_version"
external c_monitor_create_context : unit -> int = "monitor_create_context"
external c_monitor_destroy_context : int -> unit = "monitor_destroy_context"
external c_monitor_can_transition : int -> int -> int = "monitor_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_monitor]. *)
let abi_version () = c_monitor_abi_version ()

(** Create a new monitor context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_monitor_create_context ())

(** Destroy a monitor context, releasing its slot. *)
let destroy_context slot = c_monitor_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_monitor_can_transition (monitor_state_to_tag from) (monitor_state_to_tag to_) = 1
