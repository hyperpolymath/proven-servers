(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** DNS protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-dns/ffi/zig/src/dns.zig]. *)

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
  | Enabled    (** DNSSEC enabled, no key loaded. *)
  | Key_loaded (** DNSSEC key loaded. *)
  | Validated  (** Response validated / signed. *)

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

(* --- C FFI declarations --- *)

external c_dns_abi_version : unit -> int = "dns_abi_version"
external c_dns_create_context : unit -> int = "dns_create_context"
external c_dns_destroy_context : int -> unit = "dns_destroy_context"
external c_dns_state : int -> int = "dns_state"
external c_dns_dnssec_state : int -> int = "dns_dnssec_state"
external c_dns_rcode : int -> int = "dns_rcode"
external c_dns_answer_count : int -> int = "dns_answer_count"
external c_dns_authority_count : int -> int = "dns_authority_count"
external c_dns_additional_count : int -> int = "dns_additional_count"
external c_dns_begin_lookup : int -> int = "dns_begin_lookup"
external c_dns_begin_response : int -> int = "dns_begin_response"
external c_dns_set_rcode : int -> int -> int = "dns_set_rcode"
external c_dns_enable_dnssec : int -> int = "dns_enable_dnssec"
external c_dns_load_dnssec_key : int -> int -> int = "dns_load_dnssec_key"
external c_dns_sign_response : int -> int = "dns_sign_response"
external c_dns_validate_dnssec : int -> int = "dns_validate_dnssec"
external c_dns_can_transition : int -> int -> int = "dns_can_transition"
external c_dns_can_dnssec_transition : int -> int -> int = "dns_can_dnssec_transition"

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

let enable_dnssec slot = Proven_error.from_status (c_dns_enable_dnssec slot)

let load_dnssec_key slot algo =
  Proven_error.from_status (c_dns_load_dnssec_key slot (algorithm_to_tag algo))

let sign_response slot = Proven_error.from_status (c_dns_sign_response slot)

let validate_dnssec slot = c_dns_validate_dnssec slot = 0

let can_transition ~from ~to_ =
  c_dns_can_transition (dns_state_to_tag from) (dns_state_to_tag to_) = 1

let can_dnssec_transition ~from ~to_ =
  c_dns_can_dnssec_transition (dnssec_state_to_tag from) (dnssec_state_to_tag to_) = 1
