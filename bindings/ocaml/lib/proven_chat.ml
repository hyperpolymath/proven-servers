(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Real-time chat server protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-chat/ffi/zig/src/chat.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for message types, presence statuses,
    room types, permissions, and events. *)

(** Message types matching [MessageType] in chat.zig. *)
type message_type =
  | Text | Image | File | System | Reaction | Edit | Delete | Reply | Thread

(** Presence statuses matching [PresenceStatus] in chat.zig. *)
type presence_status = Online | Away | Dnd | Invisible | Offline

(** Room types matching [RoomType] in chat.zig. *)
type room_type = Direct | Group | Channel | Broadcast

(** Permissions matching [Permission] in chat.zig. *)
type permission =
  | Read | Write | Admin | Invite | Kick | Ban | Pin | Delete_others

(** Chat events matching [Event] in chat.zig. *)
type event =
  | Message_sent | Message_delivered | Message_read | User_joined
  | User_left | Typing | Room_created

(** Convert a [message_type] to its ABI tag value. *)
let message_type_to_tag = function
  | Text -> 0 | Image -> 1 | File -> 2 | System -> 3 | Reaction -> 4
  | Edit -> 5 | Delete -> 6 | Reply -> 7 | Thread -> 8

(** Decode a [message_type] from its ABI tag value. *)
let message_type_of_tag = function
  | 0 -> Some Text | 1 -> Some Image | 2 -> Some File | 3 -> Some System
  | 4 -> Some Reaction | 5 -> Some Edit | 6 -> Some Delete | 7 -> Some Reply
  | 8 -> Some Thread | _ -> None

(** Convert a [presence_status] to its ABI tag value. *)
let presence_status_to_tag = function
  | Online -> 0 | Away -> 1 | Dnd -> 2 | Invisible -> 3 | Offline -> 4

(** Decode a [presence_status] from its ABI tag value. *)
let presence_status_of_tag = function
  | 0 -> Some Online | 1 -> Some Away | 2 -> Some Dnd | 3 -> Some Invisible
  | 4 -> Some Offline | _ -> None

(** Convert a [room_type] to its ABI tag value. *)
let room_type_to_tag = function
  | Direct -> 0 | Group -> 1 | Channel -> 2 | Broadcast -> 3

(** Decode a [room_type] from its ABI tag value. *)
let room_type_of_tag = function
  | 0 -> Some Direct | 1 -> Some Group | 2 -> Some Channel
  | 3 -> Some Broadcast | _ -> None

(** Convert a [permission] to its ABI tag value. *)
let permission_to_tag = function
  | Read -> 0 | Write -> 1 | Admin -> 2 | Invite -> 3 | Kick -> 4
  | Ban -> 5 | Pin -> 6 | Delete_others -> 7

(** Decode a [permission] from its ABI tag value. *)
let permission_of_tag = function
  | 0 -> Some Read | 1 -> Some Write | 2 -> Some Admin | 3 -> Some Invite
  | 4 -> Some Kick | 5 -> Some Ban | 6 -> Some Pin
  | 7 -> Some Delete_others | _ -> None

(** Convert an [event] to its ABI tag value. *)
let event_to_tag = function
  | Message_sent -> 0 | Message_delivered -> 1 | Message_read -> 2
  | User_joined -> 3 | User_left -> 4 | Typing -> 5 | Room_created -> 6

(** Decode an [event] from its ABI tag value. *)
let event_of_tag = function
  | 0 -> Some Message_sent | 1 -> Some Message_delivered
  | 2 -> Some Message_read | 3 -> Some User_joined | 4 -> Some User_left
  | 5 -> Some Typing | 6 -> Some Room_created | _ -> None

(* --- C FFI declarations --- *)

external c_chat_abi_version : unit -> int = "chat_abi_version"
external c_chat_create_context : unit -> int = "chat_create_context"
external c_chat_destroy_context : int -> unit = "chat_destroy_context"
external c_chat_can_transition : int -> int -> int = "chat_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_chat]. *)
let abi_version () = c_chat_abi_version ()

(** Create a new chat context. *)
let create_context () =
  Proven_error.from_slot (c_chat_create_context ())

(** Destroy a chat context, releasing its slot. *)
let destroy_context slot = c_chat_destroy_context slot

(** Stateless query: check whether an event transition is valid. *)
let can_transition ~from ~to_ =
  c_chat_can_transition (event_to_tag from) (event_to_tag to_) = 1
