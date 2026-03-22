(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** CT Logtypes for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ctlog/ffi/zig/src/ctlog.zig]. *)

(** LogEntryType matching [LogEntryType] in ctlog.zig. *)
type log_entry_type =
  | X509Entry  (** X509Entry (tag 0). *)
  | PrecertEntry  (** PrecertEntry (tag 1). *)

let log_entry_type_to_tag = function
  | X509Entry -> 0 | PrecertEntry -> 1

let log_entry_type_of_tag = function
  | 0 -> Some X509Entry
  | 1 -> Some PrecertEntry
  | _ -> None

(** SignatureType matching [SignatureType] in ctlog.zig. *)
type signature_type =
  | CertificateTimestamp  (** CertificateTimestamp (tag 0). *)
  | TreeHash  (** TreeHash (tag 1). *)

let signature_type_to_tag = function
  | CertificateTimestamp -> 0 | TreeHash -> 1

let signature_type_of_tag = function
  | 0 -> Some CertificateTimestamp
  | 1 -> Some TreeHash
  | _ -> None

(** MerkleLeafType matching [MerkleLeafType] in ctlog.zig. *)
type merkle_leaf_type =
  | TimestampedEntry  (** TimestampedEntry (tag 0). *)

let merkle_leaf_type_to_tag = function
  | TimestampedEntry -> 0

let merkle_leaf_type_of_tag = function
  | 0 -> Some TimestampedEntry
  | _ -> None

(** SubmissionStatus matching [SubmissionStatus] in ctlog.zig. *)
type submission_status =
  | Accepted  (** Accepted (tag 0). *)
  | Duplicate  (** Duplicate (tag 1). *)
  | RateLimited  (** RateLimited (tag 2). *)
  | Rejected  (** Rejected (tag 3). *)
  | InvalidChain  (** InvalidChain (tag 4). *)
  | UnknownAnchor  (** UnknownAnchor (tag 5). *)

let submission_status_to_tag = function
  | Accepted -> 0
  | Duplicate -> 1
  | RateLimited -> 2
  | Rejected -> 3
  | InvalidChain -> 4
  | UnknownAnchor -> 5

let submission_status_of_tag = function
  | 0 -> Some Accepted
  | 1 -> Some Duplicate
  | 2 -> Some RateLimited
  | 3 -> Some Rejected
  | 4 -> Some InvalidChain
  | 5 -> Some UnknownAnchor
  | _ -> None

(** VerificationResult matching [VerificationResult] in ctlog.zig. *)
type verification_result =
  | ValidProof  (** ValidProof (tag 0). *)
  | InvalidProof  (** InvalidProof (tag 1). *)
  | InconsistentTree  (** InconsistentTree (tag 2). *)
  | StaleSth  (** Stale STH (tag 3). *)

let verification_result_to_tag = function
  | ValidProof -> 0
  | InvalidProof -> 1
  | InconsistentTree -> 2
  | StaleSth -> 3

let verification_result_of_tag = function
  | 0 -> Some ValidProof
  | 1 -> Some InvalidProof
  | 2 -> Some InconsistentTree
  | 3 -> Some StaleSth
  | _ -> None

(** ServerState matching [ServerState] in ctlog.zig. *)
type server_state =
  | Idle  (** Idle (tag 0). *)
  | Active  (** Active (tag 1). *)
  | Merging  (** Merging (tag 2). *)
  | Signing  (** Signing (tag 3). *)
  | Shutdown  (** Shutdown (tag 4). *)

let server_state_to_tag = function
  | Idle -> 0
  | Active -> 1
  | Merging -> 2
  | Signing -> 3
  | Shutdown -> 4

let server_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Active
  | 2 -> Some Merging
  | 3 -> Some Signing
  | 4 -> Some Shutdown
  | _ -> None

(* --- C FFI declarations --- *)

external c_ctlog_abi_version : unit -> int = "ctlog_abi_version"
external c_ctlog_create_context : unit -> int = "ctlog_create_context"
external c_ctlog_destroy_context : int -> unit = "ctlog_destroy_context"
external c_ctlog_state : int -> int = "ctlog_state"
external c_ctlog_can_transition : int -> int -> int = "ctlog_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_ctlog_abi_version ()

let create_context () = Proven_error.from_slot (c_ctlog_create_context ())

let destroy_context slot = c_ctlog_destroy_context slot

let get_state slot = server_state_of_tag (c_ctlog_state slot)

let can_transition ~from ~to_ =
  c_ctlog_can_transition (server_state_to_tag from) (server_state_to_tag to_) = 1
