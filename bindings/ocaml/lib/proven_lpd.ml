(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Line Printer Daemon (RFC 1179) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-lpd/ffi/zig/src/lpd.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for command codes, sub-command codes,
    and job statuses. *)

(** Command codes matching [CommandCode] in lpd.zig. Tags start at 1. *)
type command_code =
  | PrintJob | ReceiveJob | ShortQueue | LongQueue | RemoveJobs

(** Sub-command codes matching [SubCommandCode] in lpd.zig. Tags start at 1. *)
type sub_command_code =
  | AbortJob | ControlFile | DataFile

(** Job statuses matching [JobStatus] in lpd.zig. *)
type job_status =
  | Pending | Printing | Complete | Failed

(** Convert a command code to its ABI tag value. *)
let command_code_to_tag = function
  | PrintJob -> 0 | ReceiveJob -> 1 | ShortQueue -> 2
  | LongQueue -> 3 | RemoveJobs -> 4

(** Decode a command code from its ABI tag value. *)
let command_code_of_tag = function
  | 0 -> Some PrintJob | 1 -> Some ReceiveJob | 2 -> Some ShortQueue
  | 3 -> Some LongQueue | 4 -> Some RemoveJobs | _ -> None

(** Convert a sub-command code to its ABI tag value. *)
let sub_command_code_to_tag = function
  | AbortJob -> 0 | ControlFile -> 1 | DataFile -> 2

(** Decode a sub-command code from its ABI tag value. *)
let sub_command_code_of_tag = function
  | 0 -> Some AbortJob | 1 -> Some ControlFile | 2 -> Some DataFile
  | _ -> None

(** Convert a job status to its ABI tag value. *)
let job_status_to_tag = function
  | Pending -> 0 | Printing -> 1 | Complete -> 2 | Failed -> 3

(** Decode a job status from its ABI tag value. *)
let job_status_of_tag = function
  | 0 -> Some Pending | 1 -> Some Printing | 2 -> Some Complete
  | 3 -> Some Failed | _ -> None

(* --- C FFI declarations --- *)

external c_lpd_abi_version : unit -> int = "lpd_abi_version"
external c_lpd_create_context : unit -> int = "lpd_create_context"
external c_lpd_destroy_context : int -> unit = "lpd_destroy_context"
external c_lpd_can_transition : int -> int -> int = "lpd_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_lpd]. *)
let abi_version () = c_lpd_abi_version ()

(** Create a new LPD context. *)
let create_context () =
  Proven_error.from_slot (c_lpd_create_context ())

(** Destroy an LPD context, releasing its slot. *)
let destroy_context slot = c_lpd_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_lpd_can_transition (job_status_to_tag from) (job_status_to_tag to_) = 1
