(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Key Management Service protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-kms/ffi/zig/src/kms.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for object types, operations, key states,
    and algorithms. *)

(** Cryptographic object types matching [ObjectType] in kms.zig. *)
type object_type =
  | SymmetricKey | PublicKey | PrivateKey | SecretData
  | Certificate | OpaqueData

(** KMS operations matching [Operation] in kms.zig. *)
type operation =
  | Create | Get | Activate | Revoke | Destroy | Locate | Register
  | Rekey | Encrypt | Decrypt | Sign | Verify | Wrap | Unwrap | Mac

(** Key lifecycle states matching [KeyState] in kms.zig. *)
type key_state =
  | PreActive | Active | Deactivated | Compromised
  | Destroyed | DestroyedCompromised

(** Cryptographic algorithms matching [KmsAlgorithm] in kms.zig. *)
type kms_algorithm =
  | Aes128 | Aes256 | Rsa2048 | Rsa4096 | EcdsaP256 | EcdsaP384
  | Ed25519 | Chacha20Poly1305 | HmacSha256

(** Convert an object type to its ABI tag value. *)
let object_type_to_tag = function
  | SymmetricKey -> 0 | PublicKey -> 1 | PrivateKey -> 2
  | SecretData -> 3 | Certificate -> 4 | OpaqueData -> 5

(** Decode an object type from its ABI tag value. *)
let object_type_of_tag = function
  | 0 -> Some SymmetricKey | 1 -> Some PublicKey | 2 -> Some PrivateKey
  | 3 -> Some SecretData | 4 -> Some Certificate | 5 -> Some OpaqueData
  | _ -> None

(** Convert an operation to its ABI tag value. *)
let operation_to_tag = function
  | Create -> 0 | Get -> 1 | Activate -> 2 | Revoke -> 3 | Destroy -> 4
  | Locate -> 5 | Register -> 6 | Rekey -> 7 | Encrypt -> 8 | Decrypt -> 9
  | Sign -> 10 | Verify -> 11 | Wrap -> 12 | Unwrap -> 13 | Mac -> 14

(** Decode an operation from its ABI tag value. *)
let operation_of_tag = function
  | 0 -> Some Create | 1 -> Some Get | 2 -> Some Activate | 3 -> Some Revoke
  | 4 -> Some Destroy | 5 -> Some Locate | 6 -> Some Register
  | 7 -> Some Rekey | 8 -> Some Encrypt | 9 -> Some Decrypt
  | 10 -> Some Sign | 11 -> Some Verify | 12 -> Some Wrap
  | 13 -> Some Unwrap | 14 -> Some Mac | _ -> None

(** Convert a key state to its ABI tag value. *)
let key_state_to_tag = function
  | PreActive -> 0 | Active -> 1 | Deactivated -> 2 | Compromised -> 3
  | Destroyed -> 4 | DestroyedCompromised -> 5

(** Decode a key state from its ABI tag value. *)
let key_state_of_tag = function
  | 0 -> Some PreActive | 1 -> Some Active | 2 -> Some Deactivated
  | 3 -> Some Compromised | 4 -> Some Destroyed
  | 5 -> Some DestroyedCompromised | _ -> None

(** Convert a KMS algorithm to its ABI tag value. *)
let kms_algorithm_to_tag = function
  | Aes128 -> 0 | Aes256 -> 1 | Rsa2048 -> 2 | Rsa4096 -> 3
  | EcdsaP256 -> 4 | EcdsaP384 -> 5 | Ed25519 -> 6
  | Chacha20Poly1305 -> 7 | HmacSha256 -> 8

(** Decode a KMS algorithm from its ABI tag value. *)
let kms_algorithm_of_tag = function
  | 0 -> Some Aes128 | 1 -> Some Aes256 | 2 -> Some Rsa2048
  | 3 -> Some Rsa4096 | 4 -> Some EcdsaP256 | 5 -> Some EcdsaP384
  | 6 -> Some Ed25519 | 7 -> Some Chacha20Poly1305 | 8 -> Some HmacSha256
  | _ -> None

(* --- C FFI declarations --- *)

external c_kms_abi_version : unit -> int = "kms_abi_version"
external c_kms_create_context : unit -> int = "kms_create_context"
external c_kms_destroy_context : int -> unit = "kms_destroy_context"
external c_kms_can_transition : int -> int -> int = "kms_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_kms]. *)
let abi_version () = c_kms_abi_version ()

(** Create a new KMS context. *)
let create_context () =
  Proven_error.from_slot (c_kms_create_context ())

(** Destroy a KMS context, releasing its slot. *)
let destroy_context slot = c_kms_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_kms_can_transition (key_state_to_tag from) (key_state_to_tag to_) = 1
