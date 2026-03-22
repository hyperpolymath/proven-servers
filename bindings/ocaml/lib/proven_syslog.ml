(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Syslog protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-syslog/ffi/zig/src/syslog.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for syslog severity levels,
    facilities, and transport modes. *)

(** Syslog severity levels matching [Severity] in syslog.zig. *)
type severity =
  | Emergency | Alert | Critical | Error | Warning
  | Notice | Informational | Debug

(** Syslog facilities matching [Facility] in syslog.zig. *)
type facility =
  | Kern | User | Mail | Daemon | Auth | Syslog | Lpr | News
  | Uucp | Cron | Auth_priv | Ftp | Ntp | Audit | Facility_alert | Clock
  | Local0 | Local1 | Local2 | Local3 | Local4 | Local5 | Local6 | Local7

(** Syslog transports matching [Transport] in syslog.zig. *)
type transport = Udp514 | Tcp514 | Tls6514

(** Convert a severity to its ABI tag value. *)
let severity_to_tag = function
  | Emergency -> 0 | Alert -> 1 | Critical -> 2 | Error -> 3
  | Warning -> 4 | Notice -> 5 | Informational -> 6 | Debug -> 7

(** Decode a severity from its ABI tag value. *)
let severity_of_tag = function
  | 0 -> Some Emergency | 1 -> Some Alert | 2 -> Some Critical
  | 3 -> Some Error | 4 -> Some Warning | 5 -> Some Notice
  | 6 -> Some Informational | 7 -> Some Debug | _ -> None

(** Convert a facility to its ABI tag value. *)
let facility_to_tag = function
  | Kern -> 0 | User -> 1 | Mail -> 2 | Daemon -> 3 | Auth -> 4
  | Syslog -> 5 | Lpr -> 6 | News -> 7 | Uucp -> 8 | Cron -> 9
  | Auth_priv -> 10 | Ftp -> 11 | Ntp -> 12 | Audit -> 13
  | Facility_alert -> 14 | Clock -> 15 | Local0 -> 16 | Local1 -> 17
  | Local2 -> 18 | Local3 -> 19 | Local4 -> 20 | Local5 -> 21
  | Local6 -> 22 | Local7 -> 23

(** Decode a facility from its ABI tag value. *)
let facility_of_tag = function
  | 0 -> Some Kern | 1 -> Some User | 2 -> Some Mail | 3 -> Some Daemon
  | 4 -> Some Auth | 5 -> Some Syslog | 6 -> Some Lpr | 7 -> Some News
  | 8 -> Some Uucp | 9 -> Some Cron | 10 -> Some Auth_priv | 11 -> Some Ftp
  | 12 -> Some Ntp | 13 -> Some Audit | 14 -> Some Facility_alert
  | 15 -> Some Clock | 16 -> Some Local0 | 17 -> Some Local1
  | 18 -> Some Local2 | 19 -> Some Local3 | 20 -> Some Local4
  | 21 -> Some Local5 | 22 -> Some Local6 | 23 -> Some Local7 | _ -> None

(** Convert a transport to its ABI tag value. *)
let transport_to_tag = function
  | Udp514 -> 0 | Tcp514 -> 1 | Tls6514 -> 2

(** Decode a transport from its ABI tag value. *)
let transport_of_tag = function
  | 0 -> Some Udp514 | 1 -> Some Tcp514 | 2 -> Some Tls6514 | _ -> None

(* --- C FFI declarations --- *)

external c_syslog_abi_version : unit -> int = "syslog_abi_version"
external c_syslog_create_context : unit -> int = "syslog_create_context"
external c_syslog_destroy_context : int -> unit = "syslog_destroy_context"
external c_syslog_can_transition : int -> int -> int = "syslog_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_syslog]. *)
let abi_version () = c_syslog_abi_version ()

(** Create a new syslog context. *)
let create_context () =
  Proven_error.from_slot (c_syslog_create_context ())

(** Destroy a syslog context, releasing its slot. *)
let destroy_context slot = c_syslog_destroy_context slot

(** Stateless query: check whether a severity transition is valid. *)
let can_transition ~from ~to_ =
  c_syslog_can_transition (severity_to_tag from) (severity_to_tag to_) = 1
