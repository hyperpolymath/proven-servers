(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Federation types for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-federation/ffi/zig/src/federation.zig]. *)

(** ActivityType matching [ActivityType] in federation.zig. *)
type activity_type =
  | Create  (** Create (tag 0). *)
  | Update  (** Update (tag 1). *)
  | Delete  (** Delete (tag 2). *)
  | Follow  (** Follow (tag 3). *)
  | Accept  (** Accept (tag 4). *)
  | Reject  (** Reject (tag 5). *)
  | Announce  (** Announce (tag 6). *)
  | Like  (** Like (tag 7). *)
  | Undo  (** Undo (tag 8). *)
  | Block  (** Block (tag 9). *)
  | Flag  (** Flag (tag 10). *)

let activity_type_to_tag = function
  | Create -> 0
  | Update -> 1
  | Delete -> 2
  | Follow -> 3
  | Accept -> 4
  | Reject -> 5
  | Announce -> 6
  | Like -> 7
  | Undo -> 8
  | Block -> 9
  | Flag -> 10

let activity_type_of_tag = function
  | 0 -> Some Create
  | 1 -> Some Update
  | 2 -> Some Delete
  | 3 -> Some Follow
  | 4 -> Some Accept
  | 5 -> Some Reject
  | 6 -> Some Announce
  | 7 -> Some Like
  | 8 -> Some Undo
  | 9 -> Some Block
  | 10 -> Some Flag
  | _ -> None

(** ActorType matching [ActorType] in federation.zig. *)
type actor_type =
  | Person  (** Person (tag 0). *)
  | Service  (** Service (tag 1). *)
  | Application  (** Application (tag 2). *)
  | Group  (** Group (tag 3). *)
  | Organization  (** Organization (tag 4). *)

let actor_type_to_tag = function
  | Person -> 0
  | Service -> 1
  | Application -> 2
  | Group -> 3
  | Organization -> 4

let actor_type_of_tag = function
  | 0 -> Some Person
  | 1 -> Some Service
  | 2 -> Some Application
  | 3 -> Some Group
  | 4 -> Some Organization
  | _ -> None

(** DeliveryStatus matching [DeliveryStatus] in federation.zig. *)
type delivery_status =
  | Pending  (** Pending (tag 0). *)
  | Delivered  (** Delivered (tag 1). *)
  | Failed  (** Failed (tag 2). *)
  | Rejected  (** Rejected (tag 3). *)
  | Deferred  (** Deferred (tag 4). *)

let delivery_status_to_tag = function
  | Pending -> 0
  | Delivered -> 1
  | Failed -> 2
  | Rejected -> 3
  | Deferred -> 4

let delivery_status_of_tag = function
  | 0 -> Some Pending
  | 1 -> Some Delivered
  | 2 -> Some Failed
  | 3 -> Some Rejected
  | 4 -> Some Deferred
  | _ -> None

(** TrustLevel matching [TrustLevel] in federation.zig. *)
type trust_level =
  | SelfSigned  (** SelfSigned (tag 0). *)
  | PeerVerified  (** PeerVerified (tag 1). *)
  | FederationTrusted  (** FederationTrusted (tag 2). *)
  | Revoked  (** Revoked (tag 3). *)
  | Unknown  (** Unknown (tag 4). *)

let trust_level_to_tag = function
  | SelfSigned -> 0
  | PeerVerified -> 1
  | FederationTrusted -> 2
  | Revoked -> 3
  | Unknown -> 4

let trust_level_of_tag = function
  | 0 -> Some SelfSigned
  | 1 -> Some PeerVerified
  | 2 -> Some FederationTrusted
  | 3 -> Some Revoked
  | 4 -> Some Unknown
  | _ -> None

(** ObjectType matching [ObjectType] in federation.zig. *)
type object_type =
  | Note  (** Note (tag 0). *)
  | Article  (** Article (tag 1). *)
  | Image  (** Image (tag 2). *)
  | Video  (** Video (tag 3). *)
  | Audio  (** Audio (tag 4). *)
  | Document  (** Document (tag 5). *)
  | Event  (** Event (tag 6). *)
  | Collection  (** Collection (tag 7). *)
  | OrderedCollection  (** OrderedCollection (tag 8). *)

let object_type_to_tag = function
  | Note -> 0
  | Article -> 1
  | Image -> 2
  | Video -> 3
  | Audio -> 4
  | Document -> 5
  | Event -> 6
  | Collection -> 7
  | OrderedCollection -> 8

let object_type_of_tag = function
  | 0 -> Some Note
  | 1 -> Some Article
  | 2 -> Some Image
  | 3 -> Some Video
  | 4 -> Some Audio
  | 5 -> Some Document
  | 6 -> Some Event
  | 7 -> Some Collection
  | 8 -> Some OrderedCollection
  | _ -> None

(** ServerState matching [ServerState] in federation.zig. *)
type server_state =
  | Idle  (** Idle (tag 0). *)
  | Active  (** Active (tag 1). *)
  | Processing  (** Processing (tag 2). *)
  | Delivering  (** Delivering (tag 3). *)
  | Shutdown  (** Shutdown (tag 4). *)

let server_state_to_tag = function
  | Idle -> 0
  | Active -> 1
  | Processing -> 2
  | Delivering -> 3
  | Shutdown -> 4

let server_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Active
  | 2 -> Some Processing
  | 3 -> Some Delivering
  | 4 -> Some Shutdown
  | _ -> None

(* --- C FFI declarations --- *)

external c_federation_abi_version : unit -> int = "federation_abi_version"
external c_federation_create_context : unit -> int = "federation_create_context"
external c_federation_destroy_context : int -> unit = "federation_destroy_context"
external c_federation_state : int -> int = "federation_state"
external c_federation_can_transition : int -> int -> int = "federation_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_federation_abi_version ()

let create_context () = Proven_error.from_slot (c_federation_create_context ())

let destroy_context slot = c_federation_destroy_context slot

let get_state slot = server_state_of_tag (c_federation_state slot)

let can_transition ~from ~to_ =
  c_federation_can_transition (server_state_to_tag from) (server_state_to_tag to_) = 1
