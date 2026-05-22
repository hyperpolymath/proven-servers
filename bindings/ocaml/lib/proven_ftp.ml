(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** FTP protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ftp/ffi/zig/src/ftp.zig]. *)

(** FTP session states matching [SessionState] in ftp.zig. *)
type session_state =
  | Connected     (** TCP connection established. *)
  | User_ok       (** USER accepted, password required. *)
  | Authenticated (** Fully authenticated. *)
  | Renaming      (** Rename in progress (RNFR sent). *)
  | Quit          (** Session ended. *)

(** FTP transfer states matching [TransferStateTag] in ftp.zig. *)
type transfer_state =
  | Transfer_idle        (** No transfer in progress. *)
  | Transfer_in_progress (** Transfer active. *)
  | Transfer_completed   (** Transfer completed successfully. *)
  | Transfer_aborted     (** Transfer was aborted. *)

let state_to_tag = function
  | Connected -> 0 | User_ok -> 1 | Authenticated -> 2
  | Renaming -> 3 | Quit -> 4

let state_of_tag = function
  | 0 -> Some Connected | 1 -> Some User_ok | 2 -> Some Authenticated
  | 3 -> Some Renaming | 4 -> Some Quit | _ -> None

let transfer_state_of_tag = function
  | 0 -> Some Transfer_idle | 1 -> Some Transfer_in_progress
  | 2 -> Some Transfer_completed | 3 -> Some Transfer_aborted | _ -> None

(* --- C FFI declarations --- *)

external c_ftp_abi_version : unit -> int = "ftp_abi_version"
external c_ftp_create : unit -> int = "ftp_create"
external c_ftp_destroy : int -> unit = "ftp_destroy"
external c_ftp_state : int -> int = "ftp_state"
external c_ftp_transfer_type : int -> int = "ftp_transfer_type"
external c_ftp_data_mode : int -> int = "ftp_data_mode"
external c_ftp_transfer_state : int -> int = "ftp_transfer_state"
external c_ftp_file_count : int -> int = "ftp_file_count"
external c_ftp_last_reply_code : int -> int = "ftp_last_reply_code"
external c_ftp_quit : int -> int = "ftp_quit"
external c_ftp_cdup : int -> int = "ftp_cdup"
external c_ftp_set_type : int -> int -> int = "ftp_set_type"
external c_ftp_set_passive : int -> int = "ftp_set_passive"
external c_ftp_set_active : int -> int -> int = "ftp_set_active"
external c_ftp_begin_transfer : int -> int = "ftp_begin_transfer"
external c_ftp_complete_transfer : int -> int = "ftp_complete_transfer"
external c_ftp_abort_transfer : int -> int = "ftp_abort_transfer"
external c_ftp_begin_rename : int -> int = "ftp_begin_rename"
external c_ftp_complete_rename : int -> int = "ftp_complete_rename"
external c_ftp_can_transfer : int -> int = "ftp_can_transfer"
external c_ftp_can_transition : int -> int -> int = "ftp_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_ftp_abi_version ()
let create () = Proven_error.from_slot (c_ftp_create ())
let destroy slot = c_ftp_destroy slot
let get_state slot = state_of_tag (c_ftp_state slot)
let transfer_type slot = c_ftp_transfer_type slot
let data_mode slot = c_ftp_data_mode slot
let get_transfer_state slot = transfer_state_of_tag (c_ftp_transfer_state slot)
let file_count slot = c_ftp_file_count slot
let last_reply_code slot = c_ftp_last_reply_code slot
let quit_session slot = Proven_error.from_status (c_ftp_quit slot)
let change_dir_up slot = Proven_error.from_status (c_ftp_cdup slot)
let set_type slot type_tag = Proven_error.from_status (c_ftp_set_type slot type_tag)
let set_passive slot = Proven_error.from_status (c_ftp_set_passive slot)
let set_active slot ~port = Proven_error.from_status (c_ftp_set_active slot port)
let begin_transfer slot = Proven_error.from_status (c_ftp_begin_transfer slot)
let complete_transfer slot = Proven_error.from_status (c_ftp_complete_transfer slot)
let abort_transfer slot = Proven_error.from_status (c_ftp_abort_transfer slot)
let begin_rename slot = Proven_error.from_status (c_ftp_begin_rename slot)
let complete_rename slot = Proven_error.from_status (c_ftp_complete_rename slot)
let can_transfer st = c_ftp_can_transfer (state_to_tag st) = 1

let can_transition ~from ~to_ =
  c_ftp_can_transition (state_to_tag from) (state_to_tag to_) = 1
