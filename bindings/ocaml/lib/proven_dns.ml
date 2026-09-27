(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Partial DNS lifecycle and ABI-tag declarations for the bounded
    root-question message-builder; this is not a general resolver and DNSSEC
    crypto fails closed.

    Native operations deliberately raise [Failure] until OCaml-compatible C
    stubs are implemented. The previous direct references to raw Zig C symbols
    had an incompatible calling convention and were removed. *)

(** DNS query lifecycle states matching [DnsState] in dns.zig. *)
type dns_state =
  | Idle             (** Waiting for a query. *)
  | Query_received   (** Query received and parsed. *)
  | Lookup           (** Performing DNS lookup. *)
  | Response_building (** Building response message. *)
  | Sent             (** Response sent (terminal). *)

(** DNSSEC lifecycle states matching [DnssecState] in dns.zig. *)
type dnssec_state =
  | Disabled   (** DNSSEC disabled. *)
  | Enabled    (** ABI mode bit; response construction then fails closed. *)
  | Key_loaded (** Abstract model state; the FFI cannot load a key. *)
  | Validated  (** Abstract model state; the FFI cannot validate DNSSEC. *)

(** DNSSEC signing algorithms matching [DnssecAlgorithm] in dns.zig. *)
type dnssec_algorithm =
  | Rsa_sha256        (** RSA/SHA-256. *)
  | Rsa_sha512        (** RSA/SHA-512. *)
  | Ecdsa_p256_sha256 (** ECDSA P-256/SHA-256. *)
  | Ecdsa_p384_sha384 (** ECDSA P-384/SHA-384. *)
  | Ed25519           (** Ed25519. *)

let dns_state_to_tag = function
  | Idle -> 0 | Query_received -> 1 | Lookup -> 2
  | Response_building -> 3 | Sent -> 4

let dns_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Query_received | 2 -> Some Lookup
  | 3 -> Some Response_building | 4 -> Some Sent | _ -> None

let dnssec_state_to_tag = function
  | Disabled -> 0 | Enabled -> 1 | Key_loaded -> 2 | Validated -> 3

let dnssec_state_of_tag = function
  | 0 -> Some Disabled | 1 -> Some Enabled | 2 -> Some Key_loaded
  | 3 -> Some Validated | _ -> None

let algorithm_to_tag = function
  | Rsa_sha256 -> 0 | Rsa_sha512 -> 1 | Ecdsa_p256_sha256 -> 2
  | Ecdsa_p384_sha384 -> 3 | Ed25519 -> 4

(* --- Disabled native FFI declarations --- *)
(* Raw Zig C symbols are not OCaml primitives. All operations
   raise a clear exception until OCaml-compatible stubs exist. *)

let c_dns_abi_version : unit -> int = fun () ->
  Proven_unavailable.raise_unavailable ()
let c_dns_create_context : unit -> int = fun () ->
  Proven_unavailable.raise_unavailable ()
let c_dns_destroy_context : int -> unit = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_state : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_dnssec_state : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_rcode : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_answer_count : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_authority_count : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_additional_count : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_begin_lookup : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_begin_response : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_set_rcode : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_enable_dnssec : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_load_dnssec_key : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_sign_response : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_validate_dnssec : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_can_transition : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_dns_can_dnssec_transition : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()

(* --- Safe wrappers --- *)

let abi_version () = c_dns_abi_version ()

let create_context () = Proven_error.from_slot (c_dns_create_context ())

let destroy_context slot = c_dns_destroy_context slot

let get_state slot = dns_state_of_tag (c_dns_state slot)

let get_dnssec_state slot = dnssec_state_of_tag (c_dns_dnssec_state slot)

let get_rcode slot = c_dns_rcode slot

let answer_count slot = c_dns_answer_count slot

let authority_count slot = c_dns_authority_count slot

let additional_count slot = c_dns_additional_count slot

let begin_lookup slot = Proven_error.from_status (c_dns_begin_lookup slot)

let begin_response slot = Proven_error.from_status (c_dns_begin_response slot)

let set_rcode slot rcode = Proven_error.from_status (c_dns_set_rcode slot rcode)

(* Enables the mode bit only; response construction rejects without a signer. *)
let enable_dnssec slot = Proven_error.from_status (c_dns_enable_dnssec slot)

(* Always fails closed; the ABI carries an algorithm tag but no key bytes. *)
let load_dnssec_key slot algo =
  Proven_error.from_status (c_dns_load_dnssec_key slot (algorithm_to_tag algo))

(* Always fails closed because no DNSSEC signing backend is present. *)
let sign_response slot = Proven_error.from_status (c_dns_sign_response slot)

(* The binding raises unavailable; no validation result is produced. *)
let validate_dnssec slot = c_dns_validate_dnssec slot = 0

let can_transition ~from ~to_ =
  c_dns_can_transition (dns_state_to_tag from) (dns_state_to_tag to_) = 1

let can_dnssec_transition ~from ~to_ =
  c_dns_can_dnssec_transition (dnssec_state_to_tag from) (dnssec_state_to_tag to_) = 1
