(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** NFS (Network File System) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-nfs/ffi/zig/src/nfs.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for operations, file types, statuses,
    and NFS states. *)

(** NFS operations matching [Operation] in nfs.zig. *)
type operation =
  | Access | Close | Commit | Create | GetAttr | Link | Lock | Lookup
  | Open | Read | ReadDir | Remove | Rename | SetAttr | Write

(** File types matching [FileType] in nfs.zig. *)
type file_type =
  | Regular | Directory | BlockDevice | CharDevice | FileType_Link
  | Socket | Fifo

(** NFS status codes matching [Status] in nfs.zig. *)
type status =
  | Ok | Perm | NoEnt | Io | NxIo | Status_Access | Exist | NotDir
  | IsDir | FBig | NoSpc | ROfs | NotEmpty | Stale

(** NFS states matching [NfsState] in nfs.zig. *)
type nfs_state =
  | Idle | Mounted | FileOpen | Locked | Busy | Unmounting

(** Convert an operation to its ABI tag value. *)
let operation_to_tag = function
  | Access -> 0 | Close -> 1 | Commit -> 2 | Create -> 3 | GetAttr -> 4
  | Link -> 5 | Lock -> 6 | Lookup -> 7 | Open -> 8 | Read -> 9
  | ReadDir -> 10 | Remove -> 11 | Rename -> 12 | SetAttr -> 13
  | Write -> 14

(** Decode an operation from its ABI tag value. *)
let operation_of_tag = function
  | 0 -> Some Access | 1 -> Some Close | 2 -> Some Commit
  | 3 -> Some Create | 4 -> Some GetAttr | 5 -> Some Link | 6 -> Some Lock
  | 7 -> Some Lookup | 8 -> Some Open | 9 -> Some Read
  | 10 -> Some ReadDir | 11 -> Some Remove | 12 -> Some Rename
  | 13 -> Some SetAttr | 14 -> Some Write | _ -> None

(** Convert a file type to its ABI tag value. *)
let file_type_to_tag = function
  | Regular -> 0 | Directory -> 1 | BlockDevice -> 2 | CharDevice -> 3
  | FileType_Link -> 4 | Socket -> 5 | Fifo -> 6

(** Decode a file type from its ABI tag value. *)
let file_type_of_tag = function
  | 0 -> Some Regular | 1 -> Some Directory | 2 -> Some BlockDevice
  | 3 -> Some CharDevice | 4 -> Some FileType_Link | 5 -> Some Socket
  | 6 -> Some Fifo | _ -> None

(** Convert a status to its ABI tag value. *)
let status_to_tag = function
  | Ok -> 0 | Perm -> 1 | NoEnt -> 2 | Io -> 3 | NxIo -> 4
  | Status_Access -> 5 | Exist -> 6 | NotDir -> 7 | IsDir -> 8
  | FBig -> 9 | NoSpc -> 10 | ROfs -> 11 | NotEmpty -> 12 | Stale -> 13

(** Decode a status from its ABI tag value. *)
let status_of_tag = function
  | 0 -> Some Ok | 1 -> Some Perm | 2 -> Some NoEnt | 3 -> Some Io
  | 4 -> Some NxIo | 5 -> Some Status_Access | 6 -> Some Exist
  | 7 -> Some NotDir | 8 -> Some IsDir | 9 -> Some FBig | 10 -> Some NoSpc
  | 11 -> Some ROfs | 12 -> Some NotEmpty | 13 -> Some Stale | _ -> None

(** Convert an NFS state to its ABI tag value. *)
let nfs_state_to_tag = function
  | Idle -> 0 | Mounted -> 1 | FileOpen -> 2 | Locked -> 3
  | Busy -> 4 | Unmounting -> 5

(** Decode an NFS state from its ABI tag value. *)
let nfs_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Mounted | 2 -> Some FileOpen
  | 3 -> Some Locked | 4 -> Some Busy | 5 -> Some Unmounting | _ -> None

(* --- C FFI declarations --- *)

external c_nfs_abi_version : unit -> int = "nfs_abi_version"
external c_nfs_create_context : unit -> int = "nfs_create_context"
external c_nfs_destroy_context : int -> unit = "nfs_destroy_context"
external c_nfs_can_transition : int -> int -> int = "nfs_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_nfs]. *)
let abi_version () = c_nfs_abi_version ()

(** Create a new NFS context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_nfs_create_context ())

(** Destroy an NFS context, releasing its slot. *)
let destroy_context slot = c_nfs_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_nfs_can_transition (nfs_state_to_tag from) (nfs_state_to_tag to_) = 1
