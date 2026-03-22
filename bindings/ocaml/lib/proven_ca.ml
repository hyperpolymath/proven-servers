(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Certificate Authority / PKI protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ca/ffi/zig/src/ca.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for certificate types, key algorithms,
    signature algorithms, cert states, revocation reasons, CRL/OCSP status,
    extensions, and key usage bits. *)

(** Certificate types matching [CertType] in ca.zig. *)
type cert_type =
  | Root | Intermediate | End_entity | Cross_signed | Code_signing
  | Email_protection | Ocsp_signing

(** Key algorithms matching [KeyAlgorithm] in ca.zig. *)
type key_algorithm =
  | Rsa2048 | Rsa4096 | Ecdsa_p256 | Ecdsa_p384 | Ed25519 | Ed448

(** Signature algorithms matching [SignatureAlgorithm] in ca.zig. *)
type signature_algorithm =
  | Sha256_with_rsa | Sha384_with_rsa | Sha512_with_rsa
  | Sha256_with_ecdsa | Sha384_with_ecdsa | Pure_ed25519 | Pure_ed448

(** Certificate states matching [CertState] in ca.zig. *)
type cert_state = Pending | Active | Revoked | Expired | Suspended

(** Revocation reasons matching [RevocationReason] in ca.zig. *)
type revocation_reason =
  | Unspecified | Key_compromise | Ca_compromise | Affiliation_changed
  | Superseded | Cessation_of_operation | Certificate_hold

(** CRL status matching [CrlStatus] in ca.zig. *)
type crl_status = Current | Crl_expired | Crl_pending | Crl_error

(** OCSP status matching [OcspStatus] in ca.zig. *)
type ocsp_status = Good | Ocsp_revoked | Unknown | Unavailable

(** X.509 extensions matching [Extension] in ca.zig. *)
type extension =
  | Basic_constraints | Key_usage | Ext_key_usage | Subject_alt_name
  | Authority_info_access | Crl_distribution_points

(** Key usage bits matching [KeyUsageBit] in ca.zig. *)
type key_usage_bit =
  | Digital_signature | Non_repudiation | Key_encipherment
  | Data_encipherment | Key_agreement | Key_cert_sign | Crl_sign
  | Encipher_only | Decipher_only

(** Convert a [cert_type] to its ABI tag value. *)
let cert_type_to_tag = function
  | Root -> 0 | Intermediate -> 1 | End_entity -> 2 | Cross_signed -> 3
  | Code_signing -> 4 | Email_protection -> 5 | Ocsp_signing -> 6

(** Decode a [cert_type] from its ABI tag value. *)
let cert_type_of_tag = function
  | 0 -> Some Root | 1 -> Some Intermediate | 2 -> Some End_entity
  | 3 -> Some Cross_signed | 4 -> Some Code_signing
  | 5 -> Some Email_protection | 6 -> Some Ocsp_signing | _ -> None

(** Convert a [key_algorithm] to its ABI tag value. *)
let key_algorithm_to_tag = function
  | Rsa2048 -> 0 | Rsa4096 -> 1 | Ecdsa_p256 -> 2 | Ecdsa_p384 -> 3
  | Ed25519 -> 4 | Ed448 -> 5

(** Decode a [key_algorithm] from its ABI tag value. *)
let key_algorithm_of_tag = function
  | 0 -> Some Rsa2048 | 1 -> Some Rsa4096 | 2 -> Some Ecdsa_p256
  | 3 -> Some Ecdsa_p384 | 4 -> Some Ed25519 | 5 -> Some Ed448 | _ -> None

(** Convert a [signature_algorithm] to its ABI tag value. *)
let signature_algorithm_to_tag = function
  | Sha256_with_rsa -> 0 | Sha384_with_rsa -> 1 | Sha512_with_rsa -> 2
  | Sha256_with_ecdsa -> 3 | Sha384_with_ecdsa -> 4 | Pure_ed25519 -> 5
  | Pure_ed448 -> 6

(** Decode a [signature_algorithm] from its ABI tag value. *)
let signature_algorithm_of_tag = function
  | 0 -> Some Sha256_with_rsa | 1 -> Some Sha384_with_rsa
  | 2 -> Some Sha512_with_rsa | 3 -> Some Sha256_with_ecdsa
  | 4 -> Some Sha384_with_ecdsa | 5 -> Some Pure_ed25519
  | 6 -> Some Pure_ed448 | _ -> None

(** Convert a [cert_state] to its ABI tag value. *)
let cert_state_to_tag = function
  | Pending -> 0 | Active -> 1 | Revoked -> 2 | Expired -> 3
  | Suspended -> 4

(** Decode a [cert_state] from its ABI tag value. *)
let cert_state_of_tag = function
  | 0 -> Some Pending | 1 -> Some Active | 2 -> Some Revoked
  | 3 -> Some Expired | 4 -> Some Suspended | _ -> None

(** Convert a [revocation_reason] to its ABI tag value. *)
let revocation_reason_to_tag = function
  | Unspecified -> 0 | Key_compromise -> 1 | Ca_compromise -> 2
  | Affiliation_changed -> 3 | Superseded -> 4
  | Cessation_of_operation -> 5 | Certificate_hold -> 6

(** Decode a [revocation_reason] from its ABI tag value. *)
let revocation_reason_of_tag = function
  | 0 -> Some Unspecified | 1 -> Some Key_compromise
  | 2 -> Some Ca_compromise | 3 -> Some Affiliation_changed
  | 4 -> Some Superseded | 5 -> Some Cessation_of_operation
  | 6 -> Some Certificate_hold | _ -> None

(** Convert a [crl_status] to its ABI tag value. *)
let crl_status_to_tag = function
  | Current -> 0 | Crl_expired -> 1 | Crl_pending -> 2 | Crl_error -> 3

(** Decode a [crl_status] from its ABI tag value. *)
let crl_status_of_tag = function
  | 0 -> Some Current | 1 -> Some Crl_expired | 2 -> Some Crl_pending
  | 3 -> Some Crl_error | _ -> None

(** Convert an [ocsp_status] to its ABI tag value. *)
let ocsp_status_to_tag = function
  | Good -> 0 | Ocsp_revoked -> 1 | Unknown -> 2 | Unavailable -> 3

(** Decode an [ocsp_status] from its ABI tag value. *)
let ocsp_status_of_tag = function
  | 0 -> Some Good | 1 -> Some Ocsp_revoked | 2 -> Some Unknown
  | 3 -> Some Unavailable | _ -> None

(** Convert an [extension] to its ABI tag value. *)
let extension_to_tag = function
  | Basic_constraints -> 0 | Key_usage -> 1 | Ext_key_usage -> 2
  | Subject_alt_name -> 3 | Authority_info_access -> 4
  | Crl_distribution_points -> 5

(** Decode an [extension] from its ABI tag value. *)
let extension_of_tag = function
  | 0 -> Some Basic_constraints | 1 -> Some Key_usage
  | 2 -> Some Ext_key_usage | 3 -> Some Subject_alt_name
  | 4 -> Some Authority_info_access | 5 -> Some Crl_distribution_points
  | _ -> None

(** Convert a [key_usage_bit] to its ABI tag value. *)
let key_usage_bit_to_tag = function
  | Digital_signature -> 0 | Non_repudiation -> 1 | Key_encipherment -> 2
  | Data_encipherment -> 3 | Key_agreement -> 4 | Key_cert_sign -> 5
  | Crl_sign -> 6 | Encipher_only -> 7 | Decipher_only -> 8

(** Decode a [key_usage_bit] from its ABI tag value. *)
let key_usage_bit_of_tag = function
  | 0 -> Some Digital_signature | 1 -> Some Non_repudiation
  | 2 -> Some Key_encipherment | 3 -> Some Data_encipherment
  | 4 -> Some Key_agreement | 5 -> Some Key_cert_sign | 6 -> Some Crl_sign
  | 7 -> Some Encipher_only | 8 -> Some Decipher_only | _ -> None

(* --- C FFI declarations --- *)

external c_ca_abi_version : unit -> int = "ca_abi_version"
external c_ca_create_context : unit -> int = "ca_create_context"
external c_ca_destroy_context : int -> unit = "ca_destroy_context"
external c_ca_can_transition : int -> int -> int = "ca_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_ca]. *)
let abi_version () = c_ca_abi_version ()

(** Create a new CA context. *)
let create_context () =
  Proven_error.from_slot (c_ca_create_context ())

(** Destroy a CA context, releasing its slot. *)
let destroy_context slot = c_ca_destroy_context slot

(** Stateless query: check whether a cert state transition is valid. *)
let can_transition ~from ~to_ =
  c_ca_can_transition (cert_state_to_tag from) (cert_state_to_tag to_) = 1
