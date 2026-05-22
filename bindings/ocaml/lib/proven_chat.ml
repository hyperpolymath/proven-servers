(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Real-time chat server protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-chat/ffi/zig/src/chat.zig]. *)

(** MessageType matching [MessageType] in chat.zig. *)
type message_type =
  | Text  (** Text (tag 0). *)
  | Image  (** Image (tag 1). *)
  | File  (** File (tag 2). *)
  | System  (** System (tag 3). *)
  | Reaction  (** Reaction (tag 4). *)
  | Edit  (** Edit (tag 5). *)
  | Delete  (** Delete (tag 6). *)
  | Reply  (** Reply (tag 7). *)
  | Thread  (** Thread (tag 8). *)

let message_type_to_tag = function
  | Text -> 0 | Image -> 1 | File -> 2 | System -> 3 | Reaction -> 4
  | Edit -> 5 | Delete -> 6 | Reply -> 7 | Thread -> 8

let message_type_of_tag = function
  | 0 -> Some Text | 1 -> Some Image | 2 -> Some File | 3 -> Some System
  | 4 -> Some Reaction | 5 -> Some Edit | 6 -> Some Delete | 7 -> Some Reply
  | 8 -> Some Thread | _ -> None

(** PresenceStatus matching [PresenceStatus] in chat.zig. *)
type presence_status =
  | Online  (** Online (tag 0). *)
  | Away  (** Away (tag 1). *)
  | Dnd  (** Do Not Disturb (tag 2). *)
  | Invisible  (** Invisible (tag 3). *)
  | Offline  (** Offline (tag 4). *)

let presence_status_to_tag = function
  | Online -> 0 | Away -> 1 | Dnd -> 2 | Invisible -> 3 | Offline -> 4

let presence_status_of_tag = function
  | 0 -> Some Online | 1 -> Some Away | 2 -> Some Dnd | 3 -> Some Invisible
  | 4 -> Some Offline | _ -> None

(** RoomType matching [RoomType] in chat.zig. *)
type room_type =
  | Direct  (** Direct (tag 0). *)
  | Group  (** Group (tag 1). *)
  | Channel  (** Channel (tag 2). *)
  | Broadcast  (** Broadcast (tag 3). *)

let room_type_to_tag = function
  | Direct -> 0 | Group -> 1 | Channel -> 2 | Broadcast -> 3

let room_type_of_tag = function
  | 0 -> Some Direct | 1 -> Some Group | 2 -> Some Channel
  | 3 -> Some Broadcast | _ -> None

(** Permission matching [Permission] in chat.zig. *)
type permission =
  | Read  (** Read (tag 0). *)
  | Write  (** Write (tag 1). *)
  | Admin  (** Admin (tag 2). *)
  | Invite  (** Invite (tag 3). *)
  | Kick  (** Kick (tag 4). *)
  | Ban  (** Ban (tag 5). *)
  | Pin  (** Pin (tag 6). *)
  | DeleteOthers  (** DeleteOthers (tag 7). *)

let permission_to_tag = function
  | Read -> 0 | Write -> 1 | Admin -> 2 | Invite -> 3 | Kick -> 4
  | Ban -> 5 | Pin -> 6 | DeleteOthers -> 7

let permission_of_tag = function
  | 0 -> Some Read | 1 -> Some Write | 2 -> Some Admin | 3 -> Some Invite
  | 4 -> Some Kick | 5 -> Some Ban | 6 -> Some Pin
  | 7 -> Some DeleteOthers | _ -> None

(** Event matching [Event] in chat.zig. *)
type event =
  | MessageSent  (** MessageSent (tag 0). *)
  | MessageDelivered  (** MessageDelivered (tag 1). *)
  | MessageRead  (** MessageRead (tag 2). *)
  | UserJoined  (** UserJoined (tag 3). *)
  | UserLeft  (** UserLeft (tag 4). *)
  | Typing  (** Typing (tag 5). *)
  | RoomCreated  (** RoomCreated (tag 6). *)

let event_to_tag = function
  | MessageSent -> 0 | MessageDelivered -> 1 | MessageRead -> 2
  | UserJoined -> 3 | UserLeft -> 4 | Typing -> 5 | RoomCreated -> 6

let event_of_tag = function
  | 0 -> Some MessageSent | 1 -> Some MessageDelivered
  | 2 -> Some MessageRead | 3 -> Some UserJoined | 4 -> Some UserLeft
  | 5 -> Some Typing | 6 -> Some RoomCreated | _ -> None

(* --- C FFI declarations --- *)

external c_chat_abi_version : unit -> int = "chat_abi_version"
external c_chat_create_context : unit -> int = "chat_create_context"
external c_chat_destroy_context : int -> unit = "chat_destroy_context"
external c_chat_state : int -> int = "chat_state"
external c_chat_can_transition : int -> int -> int = "chat_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_chat_abi_version ()

let create_context () = Proven_error.from_slot (c_chat_create_context ())

let destroy_context slot = c_chat_destroy_context slot

let get_state slot = event_of_tag (c_chat_state slot)

let can_transition ~from ~to_ =
  c_chat_can_transition (event_to_tag from) (event_to_tag to_) = 1
