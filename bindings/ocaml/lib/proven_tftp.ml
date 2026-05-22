(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** TFTP (Trivial File Transfer Protocol) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-tftp/ffi/zig/src/tftp.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for opcodes, transfer modes,
    error codes, and transfer states. *)

(** TFTP opcodes matching [Opcode] in tftp.zig. *)
type opcode = Rrq | Wrq | Data | Ack | Error

(** TFTP transfer modes matching [TransferMode] in tftp.zig. *)
type transfer_mode = Net_ascii | Octet | Mail

(** TFTP error codes matching [TftpError] in tftp.zig. *)
type tftp_error =
  | Not_defined | File_not_found | Access_violation | Disk_full
  | Illegal_operation | Unknown_tid | File_exists | No_such_user

(** TFTP transfer states matching [TransferState] in tftp.zig. *)
type transfer_state = Idle | Reading | Writing | In_error | Complete

(** Convert an opcode to its ABI tag value. *)
let opcode_to_tag = function
  | Rrq -> 0 | Wrq -> 1 | Data -> 2 | Ack -> 3 | Error -> 4

(** Decode an opcode from its ABI tag value. *)
let opcode_of_tag = function
  | 0 -> Some Rrq | 1 -> Some Wrq | 2 -> Some Data
  | 3 -> Some Ack | 4 -> Some Error | _ -> None

(** Convert a transfer mode to its ABI tag value. *)
let transfer_mode_to_tag = function
  | Net_ascii -> 0 | Octet -> 1 | Mail -> 2

(** Decode a transfer mode from its ABI tag value. *)
let transfer_mode_of_tag = function
  | 0 -> Some Net_ascii | 1 -> Some Octet | 2 -> Some Mail | _ -> None

(** Convert a TFTP error to its ABI tag value. *)
let tftp_error_to_tag = function
  | Not_defined -> 0 | File_not_found -> 1 | Access_violation -> 2
  | Disk_full -> 3 | Illegal_operation -> 4 | Unknown_tid -> 5
  | File_exists -> 6 | No_such_user -> 7

(** Decode a TFTP error from its ABI tag value. *)
let tftp_error_of_tag = function
  | 0 -> Some Not_defined | 1 -> Some File_not_found
  | 2 -> Some Access_violation | 3 -> Some Disk_full
  | 4 -> Some Illegal_operation | 5 -> Some Unknown_tid
  | 6 -> Some File_exists | 7 -> Some No_such_user | _ -> None

(** Convert a transfer state to its ABI tag value. *)
let transfer_state_to_tag = function
  | Idle -> 0 | Reading -> 1 | Writing -> 2 | In_error -> 3 | Complete -> 4

(** Decode a transfer state from its ABI tag value. *)
let transfer_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Reading | 2 -> Some Writing
  | 3 -> Some In_error | 4 -> Some Complete | _ -> None

(* --- C FFI declarations --- *)

external c_tftp_abi_version : unit -> int = "tftp_abi_version"
external c_tftp_create_context : unit -> int = "tftp_create_context"
external c_tftp_destroy_context : int -> unit = "tftp_destroy_context"
external c_tftp_can_transition : int -> int -> int = "tftp_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_tftp]. *)
let abi_version () = c_tftp_abi_version ()

(** Create a new TFTP context. *)
let create_context () =
  Proven_error.from_slot (c_tftp_create_context ())

(** Destroy a TFTP context, releasing its slot. *)
let destroy_context slot = c_tftp_destroy_context slot

(** Stateless query: check whether a transfer state transition is valid. *)
let can_transition ~from ~to_ =
  c_tftp_can_transition (transfer_state_to_tag from) (transfer_state_to_tag to_) = 1
