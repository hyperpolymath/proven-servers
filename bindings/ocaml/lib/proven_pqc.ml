(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Post-Quantum Cryptography bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-pqc/ffi/zig/src/pqc.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for PQC algorithms, NIST levels,
    operations, hybrid modes, categories, and key states. *)

(** PQC algorithm types matching [PqcAlgorithm] in pqc.zig. *)
type pqc_algorithm =
  | Crystals_kyber | Crystals_dilithium | Falcon | Sphincs_plus
  | Classic_mceliece | Bike | Hqc | Frodokem

(** NIST security levels matching [NistLevel] in pqc.zig. *)
type nist_level = Nist1 | Nist2 | Nist3 | Nist4 | Nist5

(** PQC operations matching [Operation] in pqc.zig. *)
type operation = Keygen | Encapsulate | Decapsulate | Sign | Verify

(** Hybrid mode matching [HybridMode] in pqc.zig. *)
type hybrid_mode = Classical_only | Pqc_only | Hybrid

(** Algorithm category matching [AlgorithmCategory] in pqc.zig. *)
type algorithm_category = Kem | Signature

(** Key lifecycle states matching [KeyState] in pqc.zig. *)
type key_state = Empty | Generating | Generated | Active | Expired | Compromised

(** Convert an algorithm to its ABI tag value. *)
let pqc_algorithm_to_tag = function
  | Crystals_kyber -> 0 | Crystals_dilithium -> 1 | Falcon -> 2
  | Sphincs_plus -> 3 | Classic_mceliece -> 4 | Bike -> 5
  | Hqc -> 6 | Frodokem -> 7

(** Decode an algorithm from its ABI tag value. *)
let pqc_algorithm_of_tag = function
  | 0 -> Some Crystals_kyber | 1 -> Some Crystals_dilithium
  | 2 -> Some Falcon | 3 -> Some Sphincs_plus | 4 -> Some Classic_mceliece
  | 5 -> Some Bike | 6 -> Some Hqc | 7 -> Some Frodokem | _ -> None

(** Convert a NIST level to its ABI tag value. *)
let nist_level_to_tag = function
  | Nist1 -> 0 | Nist2 -> 1 | Nist3 -> 2 | Nist4 -> 3 | Nist5 -> 4

(** Decode a NIST level from its ABI tag value. *)
let nist_level_of_tag = function
  | 0 -> Some Nist1 | 1 -> Some Nist2 | 2 -> Some Nist3
  | 3 -> Some Nist4 | 4 -> Some Nist5 | _ -> None

(** Convert an operation to its ABI tag value. *)
let operation_to_tag = function
  | Keygen -> 0 | Encapsulate -> 1 | Decapsulate -> 2
  | Sign -> 3 | Verify -> 4

(** Decode an operation from its ABI tag value. *)
let operation_of_tag = function
  | 0 -> Some Keygen | 1 -> Some Encapsulate | 2 -> Some Decapsulate
  | 3 -> Some Sign | 4 -> Some Verify | _ -> None

(** Convert a hybrid mode to its ABI tag value. *)
let hybrid_mode_to_tag = function
  | Classical_only -> 0 | Pqc_only -> 1 | Hybrid -> 2

(** Decode a hybrid mode from its ABI tag value. *)
let hybrid_mode_of_tag = function
  | 0 -> Some Classical_only | 1 -> Some Pqc_only
  | 2 -> Some Hybrid | _ -> None

(** Convert an algorithm category to its ABI tag value. *)
let algorithm_category_to_tag = function
  | Kem -> 0 | Signature -> 1

(** Decode an algorithm category from its ABI tag value. *)
let algorithm_category_of_tag = function
  | 0 -> Some Kem | 1 -> Some Signature | _ -> None

(** Convert a key state to its ABI tag value. *)
let key_state_to_tag = function
  | Empty -> 0 | Generating -> 1 | Generated -> 2
  | Active -> 3 | Expired -> 4 | Compromised -> 5

(** Decode a key state from its ABI tag value. *)
let key_state_of_tag = function
  | 0 -> Some Empty | 1 -> Some Generating | 2 -> Some Generated
  | 3 -> Some Active | 4 -> Some Expired | 5 -> Some Compromised | _ -> None

(* --- C FFI declarations --- *)

external c_pqc_abi_version : unit -> int = "pqc_abi_version"
external c_pqc_create_context : unit -> int = "pqc_create_context"
external c_pqc_destroy_context : int -> unit = "pqc_destroy_context"
external c_pqc_can_transition : int -> int -> int = "pqc_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_pqc]. *)
let abi_version () = c_pqc_abi_version ()

(** Create a new PQC context. *)
let create_context () =
  Proven_error.from_slot (c_pqc_create_context ())

(** Destroy a PQC context, releasing its slot. *)
let destroy_context slot = c_pqc_destroy_context slot

(** Stateless query: check whether a key state transition is valid. *)
let can_transition ~from ~to_ =
  c_pqc_can_transition (key_state_to_tag from) (key_state_to_tag to_) = 1
