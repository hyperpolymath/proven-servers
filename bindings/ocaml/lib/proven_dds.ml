(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** DDStypes for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-dds/ffi/zig/src/dds.zig]. *)

(** ReliabilityKind matching [ReliabilityKind] in dds.zig. *)
type reliability_kind =
  | BestEffort  (** BestEffort (tag 0). *)
  | Reliable  (** Reliable (tag 1). *)

let reliability_kind_to_tag = function
  | BestEffort -> 0 | Reliable -> 1

let reliability_kind_of_tag = function
  | 0 -> Some BestEffort
  | 1 -> Some Reliable
  | _ -> None

(** DurabilityKind matching [DurabilityKind] in dds.zig. *)
type durability_kind =
  | TransientLocal  (** Transient-local durability (tag 1). *)
  | Transient  (** Transient durability (tag 2). *)
  | Persistent  (** Persistent durability (tag 3). *)

let durability_kind_to_tag = function
  | TransientLocal -> 1 | Transient -> 2 | Persistent -> 3

let durability_kind_of_tag = function
  | 1 -> Some TransientLocal
  | 2 -> Some Transient
  | 3 -> Some Persistent
  | _ -> None

(** HistoryKind matching [HistoryKind] in dds.zig. *)
type history_kind =
  | KeepLast  (** KeepLast (tag 0). *)
  | KeepAll  (** KeepAll (tag 1). *)

let history_kind_to_tag = function
  | KeepLast -> 0 | KeepAll -> 1

let history_kind_of_tag = function
  | 0 -> Some KeepLast
  | 1 -> Some KeepAll
  | _ -> None

(** OwnershipKind matching [OwnershipKind] in dds.zig. *)
type ownership_kind =
  | Shared  (** Shared (tag 0). *)
  | Exclusive  (** Exclusive (tag 1). *)

let ownership_kind_to_tag = function
  | Shared -> 0 | Exclusive -> 1

let ownership_kind_of_tag = function
  | 0 -> Some Shared
  | 1 -> Some Exclusive
  | _ -> None

(** EntityType matching [EntityType] in dds.zig. *)
type entity_type =
  | Participant  (** Participant (tag 0). *)
  | Publisher  (** Publisher (tag 1). *)
  | Subscriber  (** Subscriber (tag 2). *)
  | Topic  (** Topic (tag 3). *)
  | DataWriter  (** DataWriter (tag 4). *)
  | DataReader  (** DataReader (tag 5). *)

let entity_type_to_tag = function
  | Participant -> 0
  | Publisher -> 1
  | Subscriber -> 2
  | Topic -> 3
  | DataWriter -> 4
  | DataReader -> 5

let entity_type_of_tag = function
  | 0 -> Some Participant
  | 1 -> Some Publisher
  | 2 -> Some Subscriber
  | 3 -> Some Topic
  | 4 -> Some DataWriter
  | 5 -> Some DataReader
  | _ -> None

(** ParticipantState matching [ParticipantState] in dds.zig. *)
type participant_state =
  | Idle  (** Idle (tag 0). *)
  | Joined  (** Joined (tag 1). *)
  | Publishing  (** Publishing (tag 2). *)
  | Subscribing  (** Subscribing (tag 3). *)
  | Leaving  (** Leaving (tag 4). *)

let participant_state_to_tag = function
  | Idle -> 0
  | Joined -> 1
  | Publishing -> 2
  | Subscribing -> 3
  | Leaving -> 4

let participant_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Joined
  | 2 -> Some Publishing
  | 3 -> Some Subscribing
  | 4 -> Some Leaving
  | _ -> None

(* --- C FFI declarations --- *)

external c_dds_abi_version : unit -> int = "dds_abi_version"
external c_dds_create_context : unit -> int = "dds_create_context"
external c_dds_destroy_context : int -> unit = "dds_destroy_context"
external c_dds_state : int -> int = "dds_state"
external c_dds_can_transition : int -> int -> int = "dds_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_dds_abi_version ()

let create_context () = Proven_error.from_slot (c_dds_create_context ())

let destroy_context slot = c_dds_destroy_context slot

let get_state slot = participant_state_of_tag (c_dds_state slot)

let can_transition ~from ~to_ =
  c_dds_can_transition (participant_state_to_tag from) (participant_state_to_tag to_) = 1
