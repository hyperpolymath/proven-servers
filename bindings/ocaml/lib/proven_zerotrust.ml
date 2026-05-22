(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Zero Trust architecture bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-zerotrust/ffi/zig/src/zerotrust.zig]. Provides OCaml
    variant types matching the Idris2 ABI enums for policy types, identity
    confidence levels, device trust scores, access decisions, context
    signal kinds, and authentication factors. *)

(** Zero Trust policy types matching [PolicyType] in zerotrust.zig. *)
type policy_type = Always_verify | Never_trust | Least_privilege | Micro_segmentation

(** Identity confidence levels matching [IdentityConfidence] in zerotrust.zig. *)
type identity_confidence =
  | Unverified | Basic_auth | Mfa_verified | Strong_auth | Continuous_auth

(** Device trust scores matching [DeviceTrustScore] in zerotrust.zig. *)
type device_trust_score =
  | Device_unknown | Device_partial | Device_compliant
  | Device_managed | Device_hardened

(** Access decisions matching [AccessDecision] in zerotrust.zig. *)
type access_decision = Allow | Deny | Challenge | Step_up

(** Context signal kinds matching [ContextSignalKind] in zerotrust.zig. *)
type context_signal_kind = Location | Time | Device | Behavior | Network

(** Authentication factors matching [AuthFactor] in zerotrust.zig. *)
type auth_factor = Certificate | Token | Biometric | Fido2 | Totp | Push

(** Convert a policy type to its ABI tag value. *)
let policy_type_to_tag = function
  | Always_verify -> 0 | Never_trust -> 1 | Least_privilege -> 2
  | Micro_segmentation -> 3

(** Decode a policy type from its ABI tag value. *)
let policy_type_of_tag = function
  | 0 -> Some Always_verify | 1 -> Some Never_trust
  | 2 -> Some Least_privilege | 3 -> Some Micro_segmentation | _ -> None

(** Convert an identity confidence to its ABI tag value. *)
let identity_confidence_to_tag = function
  | Unverified -> 0 | Basic_auth -> 1 | Mfa_verified -> 2
  | Strong_auth -> 3 | Continuous_auth -> 4

(** Decode an identity confidence from its ABI tag value. *)
let identity_confidence_of_tag = function
  | 0 -> Some Unverified | 1 -> Some Basic_auth | 2 -> Some Mfa_verified
  | 3 -> Some Strong_auth | 4 -> Some Continuous_auth | _ -> None

(** Convert a device trust score to its ABI tag value. *)
let device_trust_score_to_tag = function
  | Device_unknown -> 0 | Device_partial -> 1 | Device_compliant -> 2
  | Device_managed -> 3 | Device_hardened -> 4

(** Decode a device trust score from its ABI tag value. *)
let device_trust_score_of_tag = function
  | 0 -> Some Device_unknown | 1 -> Some Device_partial
  | 2 -> Some Device_compliant | 3 -> Some Device_managed
  | 4 -> Some Device_hardened | _ -> None

(** Convert an access decision to its ABI tag value. *)
let access_decision_to_tag = function
  | Allow -> 0 | Deny -> 1 | Challenge -> 2 | Step_up -> 3

(** Decode an access decision from its ABI tag value. *)
let access_decision_of_tag = function
  | 0 -> Some Allow | 1 -> Some Deny | 2 -> Some Challenge
  | 3 -> Some Step_up | _ -> None

(** Convert a context signal kind to its ABI tag value. *)
let context_signal_kind_to_tag = function
  | Location -> 0 | Time -> 1 | Device -> 2 | Behavior -> 3 | Network -> 4

(** Decode a context signal kind from its ABI tag value. *)
let context_signal_kind_of_tag = function
  | 0 -> Some Location | 1 -> Some Time | 2 -> Some Device
  | 3 -> Some Behavior | 4 -> Some Network | _ -> None

(** Convert an auth factor to its ABI tag value. *)
let auth_factor_to_tag = function
  | Certificate -> 0 | Token -> 1 | Biometric -> 2
  | Fido2 -> 3 | Totp -> 4 | Push -> 5

(** Decode an auth factor from its ABI tag value. *)
let auth_factor_of_tag = function
  | 0 -> Some Certificate | 1 -> Some Token | 2 -> Some Biometric
  | 3 -> Some Fido2 | 4 -> Some Totp | 5 -> Some Push | _ -> None

(* --- C FFI declarations --- *)

external c_zerotrust_abi_version : unit -> int = "zerotrust_abi_version"
external c_zerotrust_create_context : unit -> int = "zerotrust_create_context"
external c_zerotrust_destroy_context : int -> unit = "zerotrust_destroy_context"
external c_zerotrust_can_transition : int -> int -> int = "zerotrust_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_zerotrust]. *)
let abi_version () = c_zerotrust_abi_version ()

(** Create a new Zero Trust context. *)
let create_context () =
  Proven_error.from_slot (c_zerotrust_create_context ())

(** Destroy a Zero Trust context, releasing its slot. *)
let destroy_context slot = c_zerotrust_destroy_context slot

(** Stateless query: check whether an access decision transition is valid. *)
let can_transition ~from ~to_ =
  c_zerotrust_can_transition (access_decision_to_tag from) (access_decision_to_tag to_) = 1
