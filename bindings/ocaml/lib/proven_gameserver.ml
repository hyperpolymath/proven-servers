(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Game Servertypes for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-gameserver/ffi/zig/src/gameserver.zig]. *)

(** SessionType matching [SessionType] in gameserver.zig. *)
type session_type =
  | Lobby  (** Lobby (tag 0). *)
  | Match  (** Match (tag 1). *)
  | Practice  (** Practice (tag 2). *)
  | Spectator  (** Spectator (tag 3). *)
  | Tournament  (** Tournament (tag 4). *)

let session_type_to_tag = function
  | Lobby -> 0
  | Match -> 1
  | Practice -> 2
  | Spectator -> 3
  | Tournament -> 4

let session_type_of_tag = function
  | 0 -> Some Lobby
  | 1 -> Some Match
  | 2 -> Some Practice
  | 3 -> Some Spectator
  | 4 -> Some Tournament
  | _ -> None

(** PlayerState matching [PlayerState] in gameserver.zig. *)
type player_state =
  | Idle  (** Idle (tag 0). *)
  | Queuing  (** Queuing (tag 1). *)
  | Loading  (** Loading (tag 2). *)
  | Playing  (** Playing (tag 3). *)
  | Spectating  (** Spectating (tag 4). *)
  | Disconnected  (** Disconnected (tag 5). *)

let player_state_to_tag = function
  | Idle -> 0
  | Queuing -> 1
  | Loading -> 2
  | Playing -> 3
  | Spectating -> 4
  | Disconnected -> 5

let player_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Queuing
  | 2 -> Some Loading
  | 3 -> Some Playing
  | 4 -> Some Spectating
  | 5 -> Some Disconnected
  | _ -> None

(** MatchState matching [MatchState] in gameserver.zig. *)
type match_state =
  | Waiting  (** Waiting (tag 0). *)
  | Starting  (** Starting (tag 1). *)
  | InProgress  (** InProgress (tag 2). *)
  | Paused  (** Paused (tag 3). *)
  | Ending  (** Ending (tag 4). *)
  | Complete  (** Complete (tag 5). *)

let match_state_to_tag = function
  | Waiting -> 0
  | Starting -> 1
  | InProgress -> 2
  | Paused -> 3
  | Ending -> 4
  | Complete -> 5

let match_state_of_tag = function
  | 0 -> Some Waiting
  | 1 -> Some Starting
  | 2 -> Some InProgress
  | 3 -> Some Paused
  | 4 -> Some Ending
  | 5 -> Some Complete
  | _ -> None

(* --- C FFI declarations --- *)

external c_gameserver_abi_version : unit -> int = "gameserver_abi_version"
external c_gameserver_create_context : unit -> int = "gameserver_create_context"
external c_gameserver_destroy_context : int -> unit = "gameserver_destroy_context"
external c_gameserver_state : int -> int = "gameserver_state"
external c_gameserver_match_state : int -> int = "gameserver_match_state"
external c_gameserver_can_transition : int -> int -> int = "gameserver_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_gameserver_abi_version ()

let create_context () = Proven_error.from_slot (c_gameserver_create_context ())

let destroy_context slot = c_gameserver_destroy_context slot

let get_state slot = player_state_of_tag (c_gameserver_state slot)

let can_transition ~from ~to_ =
  c_gameserver_can_transition (player_state_to_tag from) (player_state_to_tag to_) = 1
