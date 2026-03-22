(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** File Servertypes for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-fileserver/ffi/zig/src/fileserver.zig]. *)

(** FileOperation matching [FileOperation] in fileserver.zig. *)
type file_operation =
  | Read  (** Read (tag 0). *)
  | Write  (** Write (tag 1). *)
  | Create  (** Create (tag 2). *)
  | Delete  (** Delete (tag 3). *)
  | Rename  (** Rename (tag 4). *)
  | List  (** List (tag 5). *)
  | Stat  (** Stat (tag 6). *)
  | Lock  (** Lock (tag 7). *)
  | Unlock  (** Unlock (tag 8). *)
  | Watch  (** Watch (tag 9). *)

let file_operation_to_tag = function
  | Read -> 0
  | Write -> 1
  | Create -> 2
  | Delete -> 3
  | Rename -> 4
  | List -> 5
  | Stat -> 6
  | Lock -> 7
  | Unlock -> 8
  | Watch -> 9

let file_operation_of_tag = function
  | 0 -> Some Read
  | 1 -> Some Write
  | 2 -> Some Create
  | 3 -> Some Delete
  | 4 -> Some Rename
  | 5 -> Some List
  | 6 -> Some Stat
  | 7 -> Some Lock
  | 8 -> Some Unlock
  | 9 -> Some Watch
  | _ -> None

(** FileType matching [FileType] in fileserver.zig. *)
type file_type =
  | Regular  (** Regular (tag 0). *)
  | Directory  (** Directory (tag 1). *)
  | Symlink  (** Symlink (tag 2). *)
  | BlockDevice  (** BlockDevice (tag 3). *)
  | CharDevice  (** CharDevice (tag 4). *)
  | Fifo  (** FIFO (tag 5). *)
  | Socket  (** Socket (tag 6). *)

let file_type_to_tag = function
  | Regular -> 0
  | Directory -> 1
  | Symlink -> 2
  | BlockDevice -> 3
  | CharDevice -> 4
  | Fifo -> 5
  | Socket -> 6

let file_type_of_tag = function
  | 0 -> Some Regular
  | 1 -> Some Directory
  | 2 -> Some Symlink
  | 3 -> Some BlockDevice
  | 4 -> Some CharDevice
  | 5 -> Some Fifo
  | 6 -> Some Socket
  | _ -> None

(** FilePermission matching [FilePermission] in fileserver.zig. *)
type file_permission =
  | OwnerRead  (** OwnerRead (tag 0). *)
  | OwnerWrite  (** OwnerWrite (tag 1). *)
  | OwnerExecute  (** OwnerExecute (tag 2). *)
  | GroupRead  (** GroupRead (tag 3). *)
  | GroupWrite  (** GroupWrite (tag 4). *)
  | GroupExecute  (** GroupExecute (tag 5). *)
  | OtherRead  (** OtherRead (tag 6). *)
  | OtherWrite  (** OtherWrite (tag 7). *)
  | OtherExecute  (** OtherExecute (tag 8). *)

let file_permission_to_tag = function
  | OwnerRead -> 0
  | OwnerWrite -> 1
  | OwnerExecute -> 2
  | GroupRead -> 3
  | GroupWrite -> 4
  | GroupExecute -> 5
  | OtherRead -> 6
  | OtherWrite -> 7
  | OtherExecute -> 8

let file_permission_of_tag = function
  | 0 -> Some OwnerRead
  | 1 -> Some OwnerWrite
  | 2 -> Some OwnerExecute
  | 3 -> Some GroupRead
  | 4 -> Some GroupWrite
  | 5 -> Some GroupExecute
  | 6 -> Some OtherRead
  | 7 -> Some OtherWrite
  | 8 -> Some OtherExecute
  | _ -> None

(** LockType matching [LockType] in fileserver.zig. *)
type lock_type =
  | Shared  (** Shared (tag 0). *)
  | Exclusive  (** Exclusive (tag 1). *)
  | Advisory  (** Advisory (tag 2). *)
  | Mandatory  (** Mandatory (tag 3). *)

let lock_type_to_tag = function
  | Shared -> 0 | Exclusive -> 1 | Advisory -> 2 | Mandatory -> 3

let lock_type_of_tag = function
  | 0 -> Some Shared
  | 1 -> Some Exclusive
  | 2 -> Some Advisory
  | 3 -> Some Mandatory
  | _ -> None

(** FileErrorCode matching [FileErrorCode] in fileserver.zig. *)
type file_error_code =
  | NotFound  (** NotFound (tag 0). *)
  | PermissionDenied  (** PermissionDenied (tag 1). *)
  | AlreadyExists  (** AlreadyExists (tag 2). *)
  | NotEmpty  (** NotEmpty (tag 3). *)
  | IsDirectory  (** IsDirectory (tag 4). *)
  | NotDirectory  (** NotDirectory (tag 5). *)
  | NoSpace  (** NoSpace (tag 6). *)
  | ReadOnly  (** ReadOnly (tag 7). *)
  | Locked  (** Locked (tag 8). *)
  | IoError  (** I/O error (tag 9). *)

let file_error_code_to_tag = function
  | NotFound -> 0
  | PermissionDenied -> 1
  | AlreadyExists -> 2
  | NotEmpty -> 3
  | IsDirectory -> 4
  | NotDirectory -> 5
  | NoSpace -> 6
  | ReadOnly -> 7
  | Locked -> 8
  | IoError -> 9

let file_error_code_of_tag = function
  | 0 -> Some NotFound
  | 1 -> Some PermissionDenied
  | 2 -> Some AlreadyExists
  | 3 -> Some NotEmpty
  | 4 -> Some IsDirectory
  | 5 -> Some NotDirectory
  | 6 -> Some NoSpace
  | 7 -> Some ReadOnly
  | 8 -> Some Locked
  | 9 -> Some IoError
  | _ -> None

(** SessionState matching [SessionState] in fileserver.zig. *)
type session_state =
  | Idle  (** Idle (tag 0). *)
  | Connected  (** Connected (tag 1). *)
  | Operating  (** Operating (tag 2). *)
  | FsLocked  (** Locked (tag 3). *)
  | Disconnecting  (** Disconnecting (tag 4). *)

let session_state_to_tag = function
  | Idle -> 0
  | Connected -> 1
  | Operating -> 2
  | FsLocked -> 3
  | Disconnecting -> 4

let session_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Connected
  | 2 -> Some Operating
  | 3 -> Some FsLocked
  | 4 -> Some Disconnecting
  | _ -> None

(* --- C FFI declarations --- *)

external c_fileserver_abi_version : unit -> int = "fileserver_abi_version"
external c_fileserver_create_context : unit -> int = "fileserver_create_context"
external c_fileserver_destroy_context : int -> unit = "fileserver_destroy_context"
external c_fileserver_state : int -> int = "fileserver_state"
external c_fileserver_can_transition : int -> int -> int = "fileserver_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_fileserver_abi_version ()

let create_context () = Proven_error.from_slot (c_fileserver_create_context ())

let destroy_context slot = c_fileserver_destroy_context slot

let get_state slot = session_state_of_tag (c_fileserver_state slot)

let can_transition ~from ~to_ =
  c_fileserver_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
