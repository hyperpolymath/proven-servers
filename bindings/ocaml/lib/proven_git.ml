(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Git Servertypes for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-git/ffi/zig/src/git.zig]. *)

(** Command matching [Command] in git.zig. *)
type command =
  | UploadPack  (** git-upload-pack (tag 0). *)
  | ReceivePack  (** git-receive-pack (tag 1). *)
  | UploadArchive  (** git-upload-archive (tag 2). *)

let command_to_tag = function
  | UploadPack -> 0 | ReceivePack -> 1 | UploadArchive -> 2

let command_of_tag = function
  | 0 -> Some UploadPack
  | 1 -> Some ReceivePack
  | 2 -> Some UploadArchive
  | _ -> None

(** PacketType matching [PacketType] in git.zig. *)
type packet_type =
  | Flush  (** Flush (tag 0). *)
  | Delimiter  (** Delimiter (tag 1). *)
  | ResponseEnd  (** ResponseEnd (tag 2). *)
  | Data  (** Data (tag 3). *)
  | PktError  (** Error packet (tag 4). *)
  | SidebandData  (** SidebandData (tag 5). *)
  | SidebandProgress  (** SidebandProgress (tag 6). *)
  | SidebandError  (** SidebandError (tag 7). *)

let packet_type_to_tag = function
  | Flush -> 0
  | Delimiter -> 1
  | ResponseEnd -> 2
  | Data -> 3
  | PktError -> 4
  | SidebandData -> 5
  | SidebandProgress -> 6
  | SidebandError -> 7

let packet_type_of_tag = function
  | 0 -> Some Flush
  | 1 -> Some Delimiter
  | 2 -> Some ResponseEnd
  | 3 -> Some Data
  | 4 -> Some PktError
  | 5 -> Some SidebandData
  | 6 -> Some SidebandProgress
  | 7 -> Some SidebandError
  | _ -> None

(** RefType matching [RefType] in git.zig. *)
type ref_type =
  | Branch  (** Branch (tag 0). *)
  | Tag  (** Tag (tag 1). *)
  | Head  (** Head (tag 2). *)
  | Remote  (** Remote (tag 3). *)
  | GitNote  (** Note (tag 4). *)

let ref_type_to_tag = function
  | Branch -> 0 | Tag -> 1 | Head -> 2 | Remote -> 3 | GitNote -> 4

let ref_type_of_tag = function
  | 0 -> Some Branch
  | 1 -> Some Tag
  | 2 -> Some Head
  | 3 -> Some Remote
  | 4 -> Some GitNote
  | _ -> None

(** Capability matching [Capability] in git.zig. *)
type capability =
  | MultiAck  (** MultiAck (tag 0). *)
  | ThinPack  (** ThinPack (tag 1). *)
  | SideBand64k  (** SideBand64k (tag 2). *)
  | OfsDelta  (** OFS-delta (tag 3). *)
  | Shallow  (** Shallow (tag 4). *)
  | DeepenSince  (** DeepenSince (tag 5). *)
  | DeepenNot  (** DeepenNot (tag 6). *)
  | FilterSpec  (** FilterSpec (tag 7). *)
  | ObjectFormat  (** ObjectFormat (tag 8). *)

let capability_to_tag = function
  | MultiAck -> 0
  | ThinPack -> 1
  | SideBand64k -> 2
  | OfsDelta -> 3
  | Shallow -> 4
  | DeepenSince -> 5
  | DeepenNot -> 6
  | FilterSpec -> 7
  | ObjectFormat -> 8

let capability_of_tag = function
  | 0 -> Some MultiAck
  | 1 -> Some ThinPack
  | 2 -> Some SideBand64k
  | 3 -> Some OfsDelta
  | 4 -> Some Shallow
  | 5 -> Some DeepenSince
  | 6 -> Some DeepenNot
  | 7 -> Some FilterSpec
  | 8 -> Some ObjectFormat
  | _ -> None

(** HookResult matching [HookResult] in git.zig. *)
type hook_result =
  | Accept  (** Accept (tag 0). *)
  | Reject  (** Reject (tag 1). *)

let hook_result_to_tag = function
  | Accept -> 0 | Reject -> 1

let hook_result_of_tag = function
  | 0 -> Some Accept
  | 1 -> Some Reject
  | _ -> None

(** ServerState matching [ServerState] in git.zig. *)
type server_state =
  | Idle  (** Idle (tag 0). *)
  | Discovery  (** Discovery (tag 1). *)
  | Negotiating  (** Negotiating (tag 2). *)
  | Transfer  (** Transfer (tag 3). *)
  | Shutdown  (** Shutdown (tag 4). *)

let server_state_to_tag = function
  | Idle -> 0
  | Discovery -> 1
  | Negotiating -> 2
  | Transfer -> 3
  | Shutdown -> 4

let server_state_of_tag = function
  | 0 -> Some Idle
  | 1 -> Some Discovery
  | 2 -> Some Negotiating
  | 3 -> Some Transfer
  | 4 -> Some Shutdown
  | _ -> None

(* --- C FFI declarations --- *)

external c_git_abi_version : unit -> int = "git_abi_version"
external c_git_create_context : unit -> int = "git_create_context"
external c_git_destroy_context : int -> unit = "git_destroy_context"
external c_git_state : int -> int = "git_state"
external c_git_can_transition : int -> int -> int = "git_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_git_abi_version ()

let create_context () = Proven_error.from_slot (c_git_create_context ())

let destroy_context slot = c_git_destroy_context slot

let get_state slot = server_state_of_tag (c_git_state slot)

let can_transition ~from ~to_ =
  c_git_can_transition (server_state_to_tag from) (server_state_to_tag to_) = 1
