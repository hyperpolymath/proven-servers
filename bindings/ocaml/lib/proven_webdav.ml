(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** WebDAV protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-webdav/ffi/zig/src/webdav.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for WebDAV methods, status codes,
    lock scopes, lock types, depths, and property operations. *)

(** WebDAV methods matching [Method] in webdav.zig. *)
type method_ = Propfind | Proppatch | Mkcol | Copy | Move | Lock | Unlock

(** WebDAV-specific status codes matching [StatusCode] in webdav.zig. *)
type status_code =
  | Multi_status | Unprocessable_entity | Locked
  | Failed_dependency | Insufficient_storage

(** WebDAV lock scopes matching [LockScope] in webdav.zig. *)
type lock_scope = Exclusive | Shared

(** WebDAV lock types matching [LockType] in webdav.zig. *)
type lock_type = Write

(** WebDAV depth values matching [Depth] in webdav.zig. *)
type depth = Zero | One | Infinity

(** WebDAV property operations matching [PropertyOp] in webdav.zig. *)
type property_op = Set | Remove

(** Convert a method to its ABI tag value. *)
let method_to_tag = function
  | Propfind -> 0 | Proppatch -> 1 | Mkcol -> 2 | Copy -> 3
  | Move -> 4 | Lock -> 5 | Unlock -> 6

(** Decode a method from its ABI tag value. *)
let method_of_tag = function
  | 0 -> Some Propfind | 1 -> Some Proppatch | 2 -> Some Mkcol
  | 3 -> Some Copy | 4 -> Some Move | 5 -> Some Lock
  | 6 -> Some Unlock | _ -> None

(** Convert a status code to its ABI tag value. *)
let status_code_to_tag = function
  | Multi_status -> 0 | Unprocessable_entity -> 1 | Locked -> 2
  | Failed_dependency -> 3 | Insufficient_storage -> 4

(** Decode a status code from its ABI tag value. *)
let status_code_of_tag = function
  | 0 -> Some Multi_status | 1 -> Some Unprocessable_entity
  | 2 -> Some Locked | 3 -> Some Failed_dependency
  | 4 -> Some Insufficient_storage | _ -> None

(** Convert a lock scope to its ABI tag value. *)
let lock_scope_to_tag = function
  | Exclusive -> 0 | Shared -> 1

(** Decode a lock scope from its ABI tag value. *)
let lock_scope_of_tag = function
  | 0 -> Some Exclusive | 1 -> Some Shared | _ -> None

(** Convert a lock type to its ABI tag value. *)
let lock_type_to_tag = function
  | Write -> 0

(** Decode a lock type from its ABI tag value. *)
let lock_type_of_tag = function
  | 0 -> Some Write | _ -> None

(** Convert a depth to its ABI tag value. *)
let depth_to_tag = function
  | Zero -> 0 | One -> 1 | Infinity -> 2

(** Decode a depth from its ABI tag value. *)
let depth_of_tag = function
  | 0 -> Some Zero | 1 -> Some One | 2 -> Some Infinity | _ -> None

(** Convert a property operation to its ABI tag value. *)
let property_op_to_tag = function
  | Set -> 0 | Remove -> 1

(** Decode a property operation from its ABI tag value. *)
let property_op_of_tag = function
  | 0 -> Some Set | 1 -> Some Remove | _ -> None

(* --- C FFI declarations --- *)

external c_webdav_abi_version : unit -> int = "webdav_abi_version"
external c_webdav_create_context : unit -> int = "webdav_create_context"
external c_webdav_destroy_context : int -> unit = "webdav_destroy_context"
external c_webdav_can_transition : int -> int -> int = "webdav_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_webdav]. *)
let abi_version () = c_webdav_abi_version ()

(** Create a new WebDAV context. *)
let create_context () =
  Proven_error.from_slot (c_webdav_create_context ())

(** Destroy a WebDAV context, releasing its slot. *)
let destroy_context slot = c_webdav_destroy_context slot

(** Stateless query: check whether a depth transition is valid. *)
let can_transition ~from ~to_ =
  c_webdav_can_transition (depth_to_tag from) (depth_to_tag to_) = 1
