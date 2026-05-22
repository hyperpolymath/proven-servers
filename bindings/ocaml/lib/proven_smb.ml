(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** SMB (Server Message Block) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-smb/ffi/zig/src/smb.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for SMB commands, dialects,
    share types, and session states. *)

(** SMB commands matching [Command] in smb.zig. *)
type command =
  | Negotiate | Session_setup | Logoff | Tree_connect | Tree_disconnect
  | Create | Close | Read | Write | Lock | Ioctl | Cancel
  | Query_directory | Change_notify | Query_info | Set_info

(** SMB dialect versions matching [Dialect] in smb.zig. *)
type dialect = Smb2_0_2 | Smb2_1 | Smb3_0 | Smb3_0_2 | Smb3_1_1

(** SMB share types matching [ShareType] in smb.zig. *)
type share_type = Disk | Pipe | Print

(** SMB session states matching [SessionState] in smb.zig. *)
type session_state =
  | Idle | Negotiated | Authenticated | Tree_connected
  | File_open | Disconnecting

(** Convert a command to its ABI tag value. *)
let command_to_tag = function
  | Negotiate -> 0 | Session_setup -> 1 | Logoff -> 2
  | Tree_connect -> 3 | Tree_disconnect -> 4 | Create -> 5
  | Close -> 6 | Read -> 7 | Write -> 8 | Lock -> 9
  | Ioctl -> 10 | Cancel -> 11 | Query_directory -> 12
  | Change_notify -> 13 | Query_info -> 14 | Set_info -> 15

(** Decode a command from its ABI tag value. *)
let command_of_tag = function
  | 0 -> Some Negotiate | 1 -> Some Session_setup | 2 -> Some Logoff
  | 3 -> Some Tree_connect | 4 -> Some Tree_disconnect | 5 -> Some Create
  | 6 -> Some Close | 7 -> Some Read | 8 -> Some Write | 9 -> Some Lock
  | 10 -> Some Ioctl | 11 -> Some Cancel | 12 -> Some Query_directory
  | 13 -> Some Change_notify | 14 -> Some Query_info
  | 15 -> Some Set_info | _ -> None

(** Convert a dialect to its ABI tag value. *)
let dialect_to_tag = function
  | Smb2_0_2 -> 0 | Smb2_1 -> 1 | Smb3_0 -> 2
  | Smb3_0_2 -> 3 | Smb3_1_1 -> 4

(** Decode a dialect from its ABI tag value. *)
let dialect_of_tag = function
  | 0 -> Some Smb2_0_2 | 1 -> Some Smb2_1 | 2 -> Some Smb3_0
  | 3 -> Some Smb3_0_2 | 4 -> Some Smb3_1_1 | _ -> None

(** Convert a share type to its ABI tag value. *)
let share_type_to_tag = function
  | Disk -> 0 | Pipe -> 1 | Print -> 2

(** Decode a share type from its ABI tag value. *)
let share_type_of_tag = function
  | 0 -> Some Disk | 1 -> Some Pipe | 2 -> Some Print | _ -> None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | Negotiated -> 1 | Authenticated -> 2
  | Tree_connected -> 3 | File_open -> 4 | Disconnecting -> 5

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Negotiated | 2 -> Some Authenticated
  | 3 -> Some Tree_connected | 4 -> Some File_open
  | 5 -> Some Disconnecting | _ -> None

(* --- C FFI declarations --- *)

external c_smb_abi_version : unit -> int = "smb_abi_version"
external c_smb_create_context : unit -> int = "smb_create_context"
external c_smb_destroy_context : int -> unit = "smb_destroy_context"
external c_smb_can_transition : int -> int -> int = "smb_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_smb]. *)
let abi_version () = c_smb_abi_version ()

(** Create a new SMB context. *)
let create_context () =
  Proven_error.from_slot (c_smb_create_context ())

(** Destroy an SMB context, releasing its slot. *)
let destroy_context slot = c_smb_destroy_context slot

(** Stateless query: check whether a session state transition is valid. *)
let can_transition ~from ~to_ =
  c_smb_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
