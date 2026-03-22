(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** S3-compatible object store protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-objectstore/ffi/zig/src/objectstore.zig]. Provides OCaml
    variant types matching the Idris2 ABI enums for operations, storage
    classes, ACLs, error codes, and session states. *)

(** Object store operations matching [Operation] in objectstore.zig. *)
type operation =
  | PutObject | GetObject | DeleteObject | ListObjects | HeadObject
  | CopyObject | CreateBucket | DeleteBucket | ListBuckets
  | InitMultipartUpload | UploadPart | CompleteMultipartUpload

(** Storage classes matching [StorageClass] in objectstore.zig. *)
type storage_class =
  | Standard | InfrequentAccess | Glacier | DeepArchive | OneZone

(** ACL types matching [Acl] in objectstore.zig. *)
type acl =
  | Private | PublicRead | PublicReadWrite | AuthenticatedRead

(** Error codes matching [ErrorCode] in objectstore.zig. *)
type error_code =
  | NoSuchBucket | NoSuchKey | BucketAlreadyExists | BucketNotEmpty
  | AccessDenied | EntityTooLarge | InvalidPart | IncompleteBody

(** Session states matching [SessionState] in objectstore.zig. *)
type session_state =
  | Idle | Ready | BucketActive | Uploading | Closing

(** Convert an operation to its ABI tag value. *)
let operation_to_tag = function
  | PutObject -> 0 | GetObject -> 1 | DeleteObject -> 2 | ListObjects -> 3
  | HeadObject -> 4 | CopyObject -> 5 | CreateBucket -> 6
  | DeleteBucket -> 7 | ListBuckets -> 8 | InitMultipartUpload -> 9
  | UploadPart -> 10 | CompleteMultipartUpload -> 11

(** Decode an operation from its ABI tag value. *)
let operation_of_tag = function
  | 0 -> Some PutObject | 1 -> Some GetObject | 2 -> Some DeleteObject
  | 3 -> Some ListObjects | 4 -> Some HeadObject | 5 -> Some CopyObject
  | 6 -> Some CreateBucket | 7 -> Some DeleteBucket | 8 -> Some ListBuckets
  | 9 -> Some InitMultipartUpload | 10 -> Some UploadPart
  | 11 -> Some CompleteMultipartUpload | _ -> None

(** Convert a storage class to its ABI tag value. *)
let storage_class_to_tag = function
  | Standard -> 0 | InfrequentAccess -> 1 | Glacier -> 2
  | DeepArchive -> 3 | OneZone -> 4

(** Decode a storage class from its ABI tag value. *)
let storage_class_of_tag = function
  | 0 -> Some Standard | 1 -> Some InfrequentAccess | 2 -> Some Glacier
  | 3 -> Some DeepArchive | 4 -> Some OneZone | _ -> None

(** Convert an ACL to its ABI tag value. *)
let acl_to_tag = function
  | Private -> 0 | PublicRead -> 1 | PublicReadWrite -> 2
  | AuthenticatedRead -> 3

(** Decode an ACL from its ABI tag value. *)
let acl_of_tag = function
  | 0 -> Some Private | 1 -> Some PublicRead | 2 -> Some PublicReadWrite
  | 3 -> Some AuthenticatedRead | _ -> None

(** Convert an error code to its ABI tag value. *)
let error_code_to_tag = function
  | NoSuchBucket -> 0 | NoSuchKey -> 1 | BucketAlreadyExists -> 2
  | BucketNotEmpty -> 3 | AccessDenied -> 4 | EntityTooLarge -> 5
  | InvalidPart -> 6 | IncompleteBody -> 7

(** Decode an error code from its ABI tag value. *)
let error_code_of_tag = function
  | 0 -> Some NoSuchBucket | 1 -> Some NoSuchKey
  | 2 -> Some BucketAlreadyExists | 3 -> Some BucketNotEmpty
  | 4 -> Some AccessDenied | 5 -> Some EntityTooLarge
  | 6 -> Some InvalidPart | 7 -> Some IncompleteBody | _ -> None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | Ready -> 1 | BucketActive -> 2 | Uploading -> 3
  | Closing -> 4

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Ready | 2 -> Some BucketActive
  | 3 -> Some Uploading | 4 -> Some Closing | _ -> None

(* --- C FFI declarations --- *)

external c_objectstore_abi_version : unit -> int = "objectstore_abi_version"
external c_objectstore_create_context : unit -> int = "objectstore_create_context"
external c_objectstore_destroy_context : int -> unit = "objectstore_destroy_context"
external c_objectstore_can_transition : int -> int -> int = "objectstore_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_objectstore]. *)
let abi_version () = c_objectstore_abi_version ()

(** Create a new object store context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_objectstore_create_context ())

(** Destroy an object store context, releasing its slot. *)
let destroy_context slot = c_objectstore_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_objectstore_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
