(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Neurosymbolic AI (NeSy) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-nesy/ffi/zig/src/nesy.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for reasoning modes, proof statuses,
    constraint kinds, neural backends, confidence levels, drift kinds,
    and NeSy states. *)

(** Reasoning modes matching [ReasoningMode] in nesy.zig. *)
type reasoning_mode =
  | Symbolic | Neural | SymToNeural | NeuralToSym | Ensemble | Cascade

(** Proof statuses matching [ProofStatus] in nesy.zig. *)
type proof_status =
  | Pending | Attempting | Proved | Failed | Assumed | Vacuous

(** Constraint kinds matching [ConstraintKind] in nesy.zig. *)
type constraint_kind =
  | TypeEquality | Subtype | Linearity | Termination | Totality
  | Invariant | Refinement | DependentIndex

(** Neural backends matching [NeuralBackend] in nesy.zig. *)
type neural_backend =
  | LocalModel | Claude | Gemini | Mistral | Gpt | CustomNeural

(** Confidence levels matching [Confidence] in nesy.zig. *)
type confidence =
  | Verified | HighNeural | MediumNeural | LowNeural | Unknown | Contradicted

(** Drift kinds matching [DriftKind] in nesy.zig. *)
type drift_kind =
  | NoDrift | SemanticDrift | ConfidenceDrift | FactualDrift
  | TemporalDrift | CatastrophicDrift

(** NeSy states matching [NeSyState] in nesy.zig. *)
type nesy_state =
  | Idle | Ready | Reasoning | Verifying | Drift | Shutdown

(** Convert a reasoning mode to its ABI tag value. *)
let reasoning_mode_to_tag = function
  | Symbolic -> 0 | Neural -> 1 | SymToNeural -> 2 | NeuralToSym -> 3
  | Ensemble -> 4 | Cascade -> 5

(** Decode a reasoning mode from its ABI tag value. *)
let reasoning_mode_of_tag = function
  | 0 -> Some Symbolic | 1 -> Some Neural | 2 -> Some SymToNeural
  | 3 -> Some NeuralToSym | 4 -> Some Ensemble | 5 -> Some Cascade
  | _ -> None

(** Convert a proof status to its ABI tag value. *)
let proof_status_to_tag = function
  | Pending -> 0 | Attempting -> 1 | Proved -> 2 | Failed -> 3
  | Assumed -> 4 | Vacuous -> 5

(** Decode a proof status from its ABI tag value. *)
let proof_status_of_tag = function
  | 0 -> Some Pending | 1 -> Some Attempting | 2 -> Some Proved
  | 3 -> Some Failed | 4 -> Some Assumed | 5 -> Some Vacuous | _ -> None

(** Convert a constraint kind to its ABI tag value. *)
let constraint_kind_to_tag = function
  | TypeEquality -> 0 | Subtype -> 1 | Linearity -> 2 | Termination -> 3
  | Totality -> 4 | Invariant -> 5 | Refinement -> 6 | DependentIndex -> 7

(** Decode a constraint kind from its ABI tag value. *)
let constraint_kind_of_tag = function
  | 0 -> Some TypeEquality | 1 -> Some Subtype | 2 -> Some Linearity
  | 3 -> Some Termination | 4 -> Some Totality | 5 -> Some Invariant
  | 6 -> Some Refinement | 7 -> Some DependentIndex | _ -> None

(** Convert a neural backend to its ABI tag value. *)
let neural_backend_to_tag = function
  | LocalModel -> 0 | Claude -> 1 | Gemini -> 2 | Mistral -> 3
  | Gpt -> 4 | CustomNeural -> 5

(** Decode a neural backend from its ABI tag value. *)
let neural_backend_of_tag = function
  | 0 -> Some LocalModel | 1 -> Some Claude | 2 -> Some Gemini
  | 3 -> Some Mistral | 4 -> Some Gpt | 5 -> Some CustomNeural | _ -> None

(** Convert a confidence to its ABI tag value. *)
let confidence_to_tag = function
  | Verified -> 0 | HighNeural -> 1 | MediumNeural -> 2 | LowNeural -> 3
  | Unknown -> 4 | Contradicted -> 5

(** Decode a confidence from its ABI tag value. *)
let confidence_of_tag = function
  | 0 -> Some Verified | 1 -> Some HighNeural | 2 -> Some MediumNeural
  | 3 -> Some LowNeural | 4 -> Some Unknown | 5 -> Some Contradicted
  | _ -> None

(** Convert a drift kind to its ABI tag value. *)
let drift_kind_to_tag = function
  | NoDrift -> 0 | SemanticDrift -> 1 | ConfidenceDrift -> 2
  | FactualDrift -> 3 | TemporalDrift -> 4 | CatastrophicDrift -> 5

(** Decode a drift kind from its ABI tag value. *)
let drift_kind_of_tag = function
  | 0 -> Some NoDrift | 1 -> Some SemanticDrift | 2 -> Some ConfidenceDrift
  | 3 -> Some FactualDrift | 4 -> Some TemporalDrift
  | 5 -> Some CatastrophicDrift | _ -> None

(** Convert a NeSy state to its ABI tag value. *)
let nesy_state_to_tag = function
  | Idle -> 0 | Ready -> 1 | Reasoning -> 2 | Verifying -> 3
  | Drift -> 4 | Shutdown -> 5

(** Decode a NeSy state from its ABI tag value. *)
let nesy_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Ready | 2 -> Some Reasoning
  | 3 -> Some Verifying | 4 -> Some Drift | 5 -> Some Shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_nesy_abi_version : unit -> int = "nesy_abi_version"
external c_nesy_create_context : unit -> int = "nesy_create_context"
external c_nesy_destroy_context : int -> unit = "nesy_destroy_context"
external c_nesy_can_transition : int -> int -> int = "nesy_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_nesy]. *)
let abi_version () = c_nesy_abi_version ()

(** Create a new NeSy context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_nesy_create_context ())

(** Destroy a NeSy context, releasing its slot. *)
let destroy_context slot = c_nesy_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_nesy_can_transition (nesy_state_to_tag from) (nesy_state_to_tag to_) = 1
