(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** OCSP (RFC 6960) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ocsp/ffi/zig/src/ocsp.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for certificate statuses, response statuses,
    hash algorithms, and responder states. *)

(** Certificate statuses matching [CertStatus] in ocsp.zig. *)
type cert_status =
  | Good | Revoked | Unknown

(** Response statuses matching [ResponseStatus] in ocsp.zig. *)
type response_status =
  | Successful | MalformedRequest | InternalError | TryLater
  | SigRequired | Unauthorized

(** Hash algorithms matching [HashAlgorithm] in ocsp.zig. *)
type hash_algorithm =
  | Sha1 | Sha256 | Sha384 | Sha512

(** Responder states matching [ResponderState] in ocsp.zig. *)
type responder_state =
  | Idle | Ready | Processing | Signing | Closing

(** Convert a certificate status to its ABI tag value. *)
let cert_status_to_tag = function
  | Good -> 0 | Revoked -> 1 | Unknown -> 2

(** Decode a certificate status from its ABI tag value. *)
let cert_status_of_tag = function
  | 0 -> Some Good | 1 -> Some Revoked | 2 -> Some Unknown | _ -> None

(** Convert a response status to its ABI tag value. *)
let response_status_to_tag = function
  | Successful -> 0 | MalformedRequest -> 1 | InternalError -> 2
  | TryLater -> 3 | SigRequired -> 4 | Unauthorized -> 5

(** Decode a response status from its ABI tag value. *)
let response_status_of_tag = function
  | 0 -> Some Successful | 1 -> Some MalformedRequest
  | 2 -> Some InternalError | 3 -> Some TryLater | 4 -> Some SigRequired
  | 5 -> Some Unauthorized | _ -> None

(** Convert a hash algorithm to its ABI tag value. *)
let hash_algorithm_to_tag = function
  | Sha1 -> 0 | Sha256 -> 1 | Sha384 -> 2 | Sha512 -> 3

(** Decode a hash algorithm from its ABI tag value. *)
let hash_algorithm_of_tag = function
  | 0 -> Some Sha1 | 1 -> Some Sha256 | 2 -> Some Sha384
  | 3 -> Some Sha512 | _ -> None

(** Convert a responder state to its ABI tag value. *)
let responder_state_to_tag = function
  | Idle -> 0 | Ready -> 1 | Processing -> 2 | Signing -> 3 | Closing -> 4

(** Decode a responder state from its ABI tag value. *)
let responder_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Ready | 2 -> Some Processing
  | 3 -> Some Signing | 4 -> Some Closing | _ -> None

(* --- C FFI declarations --- *)

external c_ocsp_abi_version : unit -> int = "ocsp_abi_version"
external c_ocsp_create_context : unit -> int = "ocsp_create_context"
external c_ocsp_destroy_context : int -> unit = "ocsp_destroy_context"
external c_ocsp_can_transition : int -> int -> int = "ocsp_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_ocsp]. *)
let abi_version () = c_ocsp_abi_version ()

(** Create a new OCSP context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_ocsp_create_context ())

(** Destroy an OCSP context, releasing its slot. *)
let destroy_context slot = c_ocsp_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_ocsp_can_transition (responder_state_to_tag from) (responder_state_to_tag to_) = 1
