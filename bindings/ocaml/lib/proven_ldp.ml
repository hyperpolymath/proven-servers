(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Linked Data Platform (W3C LDP) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ldp/ffi/zig/src/ldp.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for container types, resource types,
    preferences, interaction models, and constraint violations. *)

(** Container types matching [ContainerType] in ldp.zig. *)
type container_type =
  | Basic | Direct | Indirect

(** LDP resource types matching [LdpResourceType] in ldp.zig. *)
type ldp_resource_type =
  | RdfSource | NonRdfSource | Container

(** Client preferences matching [Preference] in ldp.zig. *)
type preference =
  | MinimalContainer | IncludeContainment | IncludeMembership
  | OmitContainment | OmitMembership

(** Interaction models matching [InteractionModel] in ldp.zig. *)
type interaction_model =
  | Ldpr | Ldpc | LdpBasicContainer | LdpDirectContainer
  | LdpIndirectContainer

(** Constraint violations matching [ConstraintViolation] in ldp.zig. *)
type constraint_violation =
  | MembershipConstant | ContainsTriplesModified | ServerManaged
  | TypeConflict

(** Convert a container type to its ABI tag value. *)
let container_type_to_tag = function
  | Basic -> 0 | Direct -> 1 | Indirect -> 2

(** Decode a container type from its ABI tag value. *)
let container_type_of_tag = function
  | 0 -> Some Basic | 1 -> Some Direct | 2 -> Some Indirect | _ -> None

(** Convert a resource type to its ABI tag value. *)
let ldp_resource_type_to_tag = function
  | RdfSource -> 0 | NonRdfSource -> 1 | Container -> 2

(** Decode a resource type from its ABI tag value. *)
let ldp_resource_type_of_tag = function
  | 0 -> Some RdfSource | 1 -> Some NonRdfSource | 2 -> Some Container
  | _ -> None

(** Convert a preference to its ABI tag value. *)
let preference_to_tag = function
  | MinimalContainer -> 0 | IncludeContainment -> 1
  | IncludeMembership -> 2 | OmitContainment -> 3 | OmitMembership -> 4

(** Decode a preference from its ABI tag value. *)
let preference_of_tag = function
  | 0 -> Some MinimalContainer | 1 -> Some IncludeContainment
  | 2 -> Some IncludeMembership | 3 -> Some OmitContainment
  | 4 -> Some OmitMembership | _ -> None

(** Convert an interaction model to its ABI tag value. *)
let interaction_model_to_tag = function
  | Ldpr -> 0 | Ldpc -> 1 | LdpBasicContainer -> 2
  | LdpDirectContainer -> 3 | LdpIndirectContainer -> 4

(** Decode an interaction model from its ABI tag value. *)
let interaction_model_of_tag = function
  | 0 -> Some Ldpr | 1 -> Some Ldpc | 2 -> Some LdpBasicContainer
  | 3 -> Some LdpDirectContainer | 4 -> Some LdpIndirectContainer
  | _ -> None

(** Convert a constraint violation to its ABI tag value. *)
let constraint_violation_to_tag = function
  | MembershipConstant -> 0 | ContainsTriplesModified -> 1
  | ServerManaged -> 2 | TypeConflict -> 3

(** Decode a constraint violation from its ABI tag value. *)
let constraint_violation_of_tag = function
  | 0 -> Some MembershipConstant | 1 -> Some ContainsTriplesModified
  | 2 -> Some ServerManaged | 3 -> Some TypeConflict | _ -> None

(* --- C FFI declarations --- *)

external c_ldp_abi_version : unit -> int = "ldp_abi_version"
external c_ldp_create_context : unit -> int = "ldp_create_context"
external c_ldp_destroy_context : int -> unit = "ldp_destroy_context"
external c_ldp_can_transition : int -> int -> int = "ldp_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_ldp]. *)
let abi_version () = c_ldp_abi_version ()

(** Create a new LDP context. *)
let create_context () =
  Proven_error.from_slot (c_ldp_create_context ())

(** Destroy an LDP context, releasing its slot. *)
let destroy_context slot = c_ldp_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_ldp_can_transition (container_type_to_tag from) (container_type_to_tag to_) = 1
