(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Neurosymbolic engine protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-neurosym/ffi/zig/src/neurosym.zig]. Provides OCaml
    variant types matching the Idris2 ABI enums for inference modes, symbolic
    operations, neural operations, fusion strategies, confidence levels,
    knowledge types, and engine states. *)

(** Inference modes matching [InferenceMode] in neurosym.zig. *)
type inference_mode =
  | Neural | Symbolic | Hybrid | Cascade

(** Symbolic operations matching [SymbolicOp] in neurosym.zig. *)
type symbolic_op =
  | Unify | Resolve | Rewrite | Prove | Search | Constrain

(** Neural operations matching [NeuralOp] in neurosym.zig. *)
type neural_op =
  | Embed | Classify | Generate | Attend | Retrieve | Finetune

(** Fusion strategies matching [FusionStrategy] in neurosym.zig. *)
type fusion_strategy =
  | NeuralThenSymbolic | SymbolicThenNeural | Parallel | Iterative | Gated

(** Confidence levels matching [ConfidenceLevel] in neurosym.zig. *)
type confidence_level =
  | Proven | HighConfidence | Moderate | LowConfidence
  | Uncertain | Contradicted

(** Knowledge types matching [KnowledgeType] in neurosym.zig. *)
type knowledge_type =
  | Axiom | Learned | Inferred | Grounded | Hypothetical | Retracted

(** Engine states matching [NeurosymState] in neurosym.zig. *)
type neurosym_state =
  | Idle | Ready | Inferring | Reasoning | Fusing | Shutdown

(** Convert an inference mode to its ABI tag value. *)
let inference_mode_to_tag = function
  | Neural -> 0 | Symbolic -> 1 | Hybrid -> 2 | Cascade -> 3

(** Decode an inference mode from its ABI tag value. *)
let inference_mode_of_tag = function
  | 0 -> Some Neural | 1 -> Some Symbolic | 2 -> Some Hybrid
  | 3 -> Some Cascade | _ -> None

(** Convert a symbolic operation to its ABI tag value. *)
let symbolic_op_to_tag = function
  | Unify -> 0 | Resolve -> 1 | Rewrite -> 2 | Prove -> 3
  | Search -> 4 | Constrain -> 5

(** Decode a symbolic operation from its ABI tag value. *)
let symbolic_op_of_tag = function
  | 0 -> Some Unify | 1 -> Some Resolve | 2 -> Some Rewrite
  | 3 -> Some Prove | 4 -> Some Search | 5 -> Some Constrain | _ -> None

(** Convert a neural operation to its ABI tag value. *)
let neural_op_to_tag = function
  | Embed -> 0 | Classify -> 1 | Generate -> 2 | Attend -> 3
  | Retrieve -> 4 | Finetune -> 5

(** Decode a neural operation from its ABI tag value. *)
let neural_op_of_tag = function
  | 0 -> Some Embed | 1 -> Some Classify | 2 -> Some Generate
  | 3 -> Some Attend | 4 -> Some Retrieve | 5 -> Some Finetune | _ -> None

(** Convert a fusion strategy to its ABI tag value. *)
let fusion_strategy_to_tag = function
  | NeuralThenSymbolic -> 0 | SymbolicThenNeural -> 1 | Parallel -> 2
  | Iterative -> 3 | Gated -> 4

(** Decode a fusion strategy from its ABI tag value. *)
let fusion_strategy_of_tag = function
  | 0 -> Some NeuralThenSymbolic | 1 -> Some SymbolicThenNeural
  | 2 -> Some Parallel | 3 -> Some Iterative | 4 -> Some Gated | _ -> None

(** Convert a confidence level to its ABI tag value. *)
let confidence_level_to_tag = function
  | Proven -> 0 | HighConfidence -> 1 | Moderate -> 2 | LowConfidence -> 3
  | Uncertain -> 4 | Contradicted -> 5

(** Decode a confidence level from its ABI tag value. *)
let confidence_level_of_tag = function
  | 0 -> Some Proven | 1 -> Some HighConfidence | 2 -> Some Moderate
  | 3 -> Some LowConfidence | 4 -> Some Uncertain
  | 5 -> Some Contradicted | _ -> None

(** Convert a knowledge type to its ABI tag value. *)
let knowledge_type_to_tag = function
  | Axiom -> 0 | Learned -> 1 | Inferred -> 2 | Grounded -> 3
  | Hypothetical -> 4 | Retracted -> 5

(** Decode a knowledge type from its ABI tag value. *)
let knowledge_type_of_tag = function
  | 0 -> Some Axiom | 1 -> Some Learned | 2 -> Some Inferred
  | 3 -> Some Grounded | 4 -> Some Hypothetical | 5 -> Some Retracted
  | _ -> None

(** Convert a neurosym state to its ABI tag value. *)
let neurosym_state_to_tag = function
  | Idle -> 0 | Ready -> 1 | Inferring -> 2 | Reasoning -> 3
  | Fusing -> 4 | Shutdown -> 5

(** Decode a neurosym state from its ABI tag value. *)
let neurosym_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Ready | 2 -> Some Inferring
  | 3 -> Some Reasoning | 4 -> Some Fusing | 5 -> Some Shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_neurosym_abi_version : unit -> int = "neurosym_abi_version"
external c_neurosym_create_context : unit -> int = "neurosym_create_context"
external c_neurosym_destroy_context : int -> unit = "neurosym_destroy_context"
external c_neurosym_can_transition : int -> int -> int = "neurosym_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_neurosym]. *)
let abi_version () = c_neurosym_abi_version ()

(** Create a new neurosymbolic engine context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_neurosym_create_context ())

(** Destroy a neurosymbolic engine context, releasing its slot. *)
let destroy_context slot = c_neurosym_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_neurosym_can_transition (neurosym_state_to_tag from) (neurosym_state_to_tag to_) = 1
