(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** IRC protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-irc/ffi/zig/src/irc.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for IRC commands, numeric replies, channel
    modes, connection states, and errors. *)

(** IRC commands matching [Command] in irc.zig. *)
type command =
  | Nick | User | Join | Part | Privmsg | Notice | Quit | Ping | Pong
  | Mode | Kick | Topic | Invite | Names | List | Who | Whois

(** IRC numeric replies matching [NumericReply] in irc.zig. *)
type numeric_reply =
  | Welcome | YourHost | Created | MyInfo | Bounce | NickInUse
  | NoSuchNick | NoSuchChannel | ChannelIsFull | InviteOnlyChan
  | BannedFromChan

(** Channel modes matching [ChannelMode] in irc.zig. *)
type channel_mode =
  | Op | Voice | Ban | Limit | InviteOnly | Moderated | NoExternalMsgs
  | TopicLock | Secret | Private

(** Connection states matching [State] in irc.zig. *)
type state =
  | Disconnected | Connecting | Registered | InChannel | Quitting

(** IRC errors matching [IrcError] in irc.zig. *)
type irc_error =
  | None | IrcError_NickInUse | ChannelFull | IrcError_InviteOnly
  | Banned | NotRegistered

(** Convert a command to its ABI tag value. *)
let command_to_tag = function
  | Nick -> 0 | User -> 1 | Join -> 2 | Part -> 3 | Privmsg -> 4
  | Notice -> 5 | Quit -> 6 | Ping -> 7 | Pong -> 8 | Mode -> 9
  | Kick -> 10 | Topic -> 11 | Invite -> 12 | Names -> 13 | List -> 14
  | Who -> 15 | Whois -> 16

(** Decode a command from its ABI tag value. *)
let command_of_tag = function
  | 0 -> Some Nick | 1 -> Some User | 2 -> Some Join | 3 -> Some Part
  | 4 -> Some Privmsg | 5 -> Some Notice | 6 -> Some Quit | 7 -> Some Ping
  | 8 -> Some Pong | 9 -> Some Mode | 10 -> Some Kick | 11 -> Some Topic
  | 12 -> Some Invite | 13 -> Some Names | 14 -> Some List | 15 -> Some Who
  | 16 -> Some Whois | _ -> None

(** Convert a numeric reply to its ABI tag value. *)
let numeric_reply_to_tag = function
  | Welcome -> 0 | YourHost -> 1 | Created -> 2 | MyInfo -> 3
  | Bounce -> 4 | NickInUse -> 5 | NoSuchNick -> 6 | NoSuchChannel -> 7
  | ChannelIsFull -> 8 | InviteOnlyChan -> 9 | BannedFromChan -> 10

(** Decode a numeric reply from its ABI tag value. *)
let numeric_reply_of_tag = function
  | 0 -> Some Welcome | 1 -> Some YourHost | 2 -> Some Created
  | 3 -> Some MyInfo | 4 -> Some Bounce | 5 -> Some NickInUse
  | 6 -> Some NoSuchNick | 7 -> Some NoSuchChannel
  | 8 -> Some ChannelIsFull | 9 -> Some InviteOnlyChan
  | 10 -> Some BannedFromChan | _ -> None

(** Convert a channel mode to its ABI tag value. *)
let channel_mode_to_tag = function
  | Op -> 0 | Voice -> 1 | Ban -> 2 | Limit -> 3 | InviteOnly -> 4
  | Moderated -> 5 | NoExternalMsgs -> 6 | TopicLock -> 7 | Secret -> 8
  | Private -> 9

(** Decode a channel mode from its ABI tag value. *)
let channel_mode_of_tag = function
  | 0 -> Some Op | 1 -> Some Voice | 2 -> Some Ban | 3 -> Some Limit
  | 4 -> Some InviteOnly | 5 -> Some Moderated | 6 -> Some NoExternalMsgs
  | 7 -> Some TopicLock | 8 -> Some Secret | 9 -> Some Private | _ -> None

(** Convert a state to its ABI tag value. *)
let state_to_tag = function
  | Disconnected -> 0 | Connecting -> 1 | Registered -> 2
  | InChannel -> 3 | Quitting -> 4

(** Decode a state from its ABI tag value. *)
let state_of_tag = function
  | 0 -> Some Disconnected | 1 -> Some Connecting | 2 -> Some Registered
  | 3 -> Some InChannel | 4 -> Some Quitting | _ -> None

(** Convert an IRC error to its ABI tag value. *)
let irc_error_to_tag = function
  | None -> 0 | IrcError_NickInUse -> 1 | ChannelFull -> 2
  | IrcError_InviteOnly -> 3 | Banned -> 4 | NotRegistered -> 5

(** Decode an IRC error from its ABI tag value. *)
let irc_error_of_tag = function
  | 0 -> Some None | 1 -> Some IrcError_NickInUse | 2 -> Some ChannelFull
  | 3 -> Some IrcError_InviteOnly | 4 -> Some Banned
  | 5 -> Some NotRegistered | _ -> Option.None

(* --- C FFI declarations --- *)

external c_irc_abi_version : unit -> int = "irc_abi_version"
external c_irc_create_context : unit -> int = "irc_create_context"
external c_irc_destroy_context : int -> unit = "irc_destroy_context"
external c_irc_can_transition : int -> int -> int = "irc_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_irc]. *)
let abi_version () = c_irc_abi_version ()

(** Create a new IRC context in the Disconnected state. *)
let create_context () =
  Proven_error.from_slot (c_irc_create_context ())

(** Destroy an IRC context, releasing its slot. *)
let destroy_context slot = c_irc_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_irc_can_transition (state_to_tag from) (state_to_tag to_) = 1
