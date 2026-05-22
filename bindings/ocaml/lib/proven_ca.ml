(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Certificate Authority / PKI protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ca/ffi/zig/src/ca.zig]. *)

(** CertType matching [CertType] in ca.zig. *)
type cert_type =
  | Root  (** Root (tag 0). *)
  | Intermediate  (** Intermediate (tag 1). *)
  | EndEntity  (** EndEntity (tag 2). *)
  | CrossSigned  (** CrossSigned (tag 3). *)
  | CodeSigning  (** CodeSigning (tag 4). *)
  | EmailProtection  (** EmailProtection (tag 5). *)
  | OcspSigning  (** OcspSigning (tag 6). *)

let cert_type_to_tag = function
  | Root -> 0 | Intermediate -> 1 | EndEntity -> 2 | CrossSigned -> 3
  | CodeSigning -> 4 | EmailProtection -> 5 | OcspSigning -> 6

let cert_type_of_tag = function
  | 0 -> Some Root | 1 -> Some Intermediate | 2 -> Some EndEntity
  | 3 -> Some CrossSigned | 4 -> Some CodeSigning
  | 5 -> Some EmailProtection | 6 -> Some OcspSigning | _ -> None

(** KeyAlgorithm matching [KeyAlgorithm] in ca.zig. *)
type key_algorithm =
  | Rsa2048  (** RSA 2048-bit (tag 0). *)
  | Rsa4096  (** RSA 4096-bit (tag 1). *)
  | EcdsaP256  (** ECDSA P-256 (tag 2). *)
  | EcdsaP384  (** ECDSA P-384 (tag 3). *)
  | Ed25519  (** Ed25519 (tag 4). *)
  | Ed448  (** Ed448 (tag 5). *)

let key_algorithm_to_tag = function
  | Rsa2048 -> 0 | Rsa4096 -> 1 | EcdsaP256 -> 2 | EcdsaP384 -> 3
  | Ed25519 -> 4 | Ed448 -> 5

let key_algorithm_of_tag = function
  | 0 -> Some Rsa2048 | 1 -> Some Rsa4096 | 2 -> Some EcdsaP256
  | 3 -> Some EcdsaP384 | 4 -> Some Ed25519 | 5 -> Some Ed448 | _ -> None

(** SignatureAlgorithm matching [SignatureAlgorithm] in ca.zig. *)
type signature_algorithm =
  | Sha256WithRsa  (** SHA-256 with RSA (tag 0). *)
  | Sha384WithRsa  (** SHA-384 with RSA (tag 1). *)
  | Sha512WithRsa  (** SHA-512 with RSA (tag 2). *)
  | Sha256WithEcdsa  (** SHA-256 with ECDSA (tag 3). *)
  | Sha384WithEcdsa  (** SHA-384 with ECDSA (tag 4). *)
  | PureEd25519  (** Pure Ed25519 (tag 5). *)
  | PureEd448  (** Pure Ed448 (tag 6). *)

let signature_algorithm_to_tag = function
  | Sha256WithRsa -> 0 | Sha384WithRsa -> 1 | Sha512WithRsa -> 2
  | Sha256WithEcdsa -> 3 | Sha384WithEcdsa -> 4 | PureEd25519 -> 5
  | PureEd448 -> 6

let signature_algorithm_of_tag = function
  | 0 -> Some Sha256WithRsa | 1 -> Some Sha384WithRsa
  | 2 -> Some Sha512WithRsa | 3 -> Some Sha256WithEcdsa
  | 4 -> Some Sha384WithEcdsa | 5 -> Some PureEd25519
  | 6 -> Some PureEd448 | _ -> None

(** CertState matching [CertState] in ca.zig. *)
type cert_state =
  | Pending  (** Pending (tag 0). *)
  | Active  (** Active (tag 1). *)
  | Revoked  (** Revoked (tag 2). *)
  | Expired  (** Expired (tag 3). *)
  | Suspended  (** Suspended (tag 4). *)

let cert_state_to_tag = function
  | Pending -> 0 | Active -> 1 | Revoked -> 2 | Expired -> 3
  | Suspended -> 4

let cert_state_of_tag = function
  | 0 -> Some Pending | 1 -> Some Active | 2 -> Some Revoked
  | 3 -> Some Expired | 4 -> Some Suspended | _ -> None

(** RevocationReason matching [RevocationReason] in ca.zig. *)
type revocation_reason =
  | Unspecified  (** Unspecified (tag 0). *)
  | KeyCompromise  (** KeyCompromise (tag 1). *)
  | CaCompromise  (** CaCompromise (tag 2). *)
  | AffiliationChanged  (** AffiliationChanged (tag 3). *)
  | Superseded  (** Superseded (tag 4). *)
  | CessationOfOperation  (** CessationOfOperation (tag 5). *)
  | CertificateHold  (** CertificateHold (tag 6). *)

let revocation_reason_to_tag = function
  | Unspecified -> 0 | KeyCompromise -> 1 | CaCompromise -> 2
  | AffiliationChanged -> 3 | Superseded -> 4
  | CessationOfOperation -> 5 | CertificateHold -> 6

let revocation_reason_of_tag = function
  | 0 -> Some Unspecified | 1 -> Some KeyCompromise
  | 2 -> Some CaCompromise | 3 -> Some AffiliationChanged
  | 4 -> Some Superseded | 5 -> Some CessationOfOperation
  | 6 -> Some CertificateHold | _ -> None

(** CrlStatus matching [CrlStatus] in ca.zig. *)
type crl_status =
  | Current  (** Current (tag 0). *)
  | CrlExpired  (** CrlExpired (tag 1). *)
  | CrlPending  (** CrlPending (tag 2). *)
  | CrlError  (** CrlError (tag 3). *)

let crl_status_to_tag = function
  | Current -> 0 | CrlExpired -> 1 | CrlPending -> 2 | CrlError -> 3

let crl_status_of_tag = function
  | 0 -> Some Current | 1 -> Some CrlExpired | 2 -> Some CrlPending
  | 3 -> Some CrlError | _ -> None

(** OcspStatus matching [OcspStatus] in ca.zig. *)
type ocsp_status =
  | Good  (** Good (tag 0). *)
  | OcspRevoked  (** OcspRevoked (tag 1). *)
  | OcspUnknown  (** Unknown (tag 2). *)
  | Unavailable  (** Unavailable (tag 3). *)

let ocsp_status_to_tag = function
  | Good -> 0 | OcspRevoked -> 1 | OcspUnknown -> 2 | Unavailable -> 3

let ocsp_status_of_tag = function
  | 0 -> Some Good | 1 -> Some OcspRevoked | 2 -> Some OcspUnknown
  | 3 -> Some Unavailable | _ -> None

(** Extension matching [Extension] in ca.zig. *)
type extension =
  | BasicConstraints  (** BasicConstraints (tag 0). *)
  | KeyUsage  (** KeyUsage (tag 1). *)
  | ExtKeyUsage  (** ExtKeyUsage (tag 2). *)
  | SubjectAltName  (** SubjectAltName (tag 3). *)
  | AuthorityInfoAccess  (** AuthorityInfoAccess (tag 4). *)
  | CrlDistributionPoints  (** CrlDistributionPoints (tag 5). *)

let extension_to_tag = function
  | BasicConstraints -> 0 | KeyUsage -> 1 | ExtKeyUsage -> 2
  | SubjectAltName -> 3 | AuthorityInfoAccess -> 4
  | CrlDistributionPoints -> 5

let extension_of_tag = function
  | 0 -> Some BasicConstraints | 1 -> Some KeyUsage
  | 2 -> Some ExtKeyUsage | 3 -> Some SubjectAltName
  | 4 -> Some AuthorityInfoAccess | 5 -> Some CrlDistributionPoints
  | _ -> None

(** KeyUsageBit matching [KeyUsageBit] in ca.zig. *)
type key_usage_bit =
  | DigitalSignature  (** DigitalSignature (tag 0). *)
  | NonRepudiation  (** NonRepudiation (tag 1). *)
  | KeyEncipherment  (** KeyEncipherment (tag 2). *)
  | DataEncipherment  (** DataEncipherment (tag 3). *)
  | KeyAgreement  (** KeyAgreement (tag 4). *)
  | KeyCertSign  (** KeyCertSign (tag 5). *)
  | CrlSign  (** CrlSign (tag 6). *)
  | EncipherOnly  (** EncipherOnly (tag 7). *)
  | DecipherOnly  (** DecipherOnly (tag 8). *)

let key_usage_bit_to_tag = function
  | DigitalSignature -> 0 | NonRepudiation -> 1 | KeyEncipherment -> 2
  | DataEncipherment -> 3 | KeyAgreement -> 4 | KeyCertSign -> 5
  | CrlSign -> 6 | EncipherOnly -> 7 | DecipherOnly -> 8

let key_usage_bit_of_tag = function
  | 0 -> Some DigitalSignature | 1 -> Some NonRepudiation
  | 2 -> Some KeyEncipherment | 3 -> Some DataEncipherment
  | 4 -> Some KeyAgreement | 5 -> Some KeyCertSign | 6 -> Some CrlSign
  | 7 -> Some EncipherOnly | 8 -> Some DecipherOnly | _ -> None

(* --- C FFI declarations --- *)

external c_ca_abi_version : unit -> int = "ca_abi_version"
external c_ca_create_context : unit -> int = "ca_create_context"
external c_ca_destroy_context : int -> unit = "ca_destroy_context"
external c_ca_state : int -> int = "ca_state"
external c_ca_can_transition : int -> int -> int = "ca_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_ca_abi_version ()

let create_context () = Proven_error.from_slot (c_ca_create_context ())

let destroy_context slot = c_ca_destroy_context slot

let get_state slot = cert_state_of_tag (c_ca_state slot)

let can_transition ~from ~to_ =
  c_ca_can_transition (cert_state_to_tag from) (cert_state_to_tag to_) = 1
