(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Cache (Redis/Memcached) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-cache/ffi/zig/src/cache.zig]. *)

(** Command matching [Command] in cache.zig. *)
type command =
  | Get  (** Get (tag 0). *)
  | Set  (** Set (tag 1). *)
  | Delete  (** Delete (tag 2). *)
  | Exists  (** Exists (tag 3). *)
  | Expire  (** Expire (tag 4). *)
  | Ttl  (** Ttl (tag 5). *)
  | Keys  (** Keys (tag 6). *)
  | Flush  (** Flush (tag 7). *)
  | Incr  (** Incr (tag 8). *)
  | Decr  (** Decr (tag 9). *)
  | Append  (** Append (tag 10). *)
  | Prepend  (** Prepend (tag 11). *)
  | Cas  (** Cas (tag 12). *)

let command_to_tag = function
  | Get -> 0 | Set -> 1 | Delete -> 2 | Exists -> 3 | Expire -> 4
  | Ttl -> 5 | Keys -> 6 | Flush -> 7 | Incr -> 8 | Decr -> 9
  | Append -> 10 | Prepend -> 11 | Cas -> 12

let command_of_tag = function
  | 0 -> Some Get | 1 -> Some Set | 2 -> Some Delete | 3 -> Some Exists
  | 4 -> Some Expire | 5 -> Some Ttl | 6 -> Some Keys | 7 -> Some Flush
  | 8 -> Some Incr | 9 -> Some Decr | 10 -> Some Append
  | 11 -> Some Prepend | 12 -> Some Cas | _ -> None

(** EvictionPolicy matching [EvictionPolicy] in cache.zig. *)
type eviction_policy =
  | Lru  (** LRU (tag 0). *)
  | Lfu  (** LFU (tag 1). *)
  | Random  (** Random (tag 2). *)
  | EvictTtl  (** TTL-based eviction (tag 3). *)
  | NoEviction  (** NoEviction (tag 4). *)

let eviction_policy_to_tag = function
  | Lru -> 0 | Lfu -> 1 | Random -> 2 | EvictTtl -> 3 | NoEviction -> 4

let eviction_policy_of_tag = function
  | 0 -> Some Lru | 1 -> Some Lfu | 2 -> Some Random | 3 -> Some EvictTtl
  | 4 -> Some NoEviction | _ -> None

(** DataType matching [DataType] in cache.zig. *)
type data_type =
  | StringVal  (** StringVal (tag 0). *)
  | IntVal  (** IntVal (tag 1). *)
  | ListVal  (** ListVal (tag 2). *)
  | SetVal  (** SetVal (tag 3). *)
  | HashVal  (** HashVal (tag 4). *)

let data_type_to_tag = function
  | StringVal -> 0 | IntVal -> 1 | ListVal -> 2 | SetVal -> 3
  | HashVal -> 4

let data_type_of_tag = function
  | 0 -> Some StringVal | 1 -> Some IntVal | 2 -> Some ListVal
  | 3 -> Some SetVal | 4 -> Some HashVal | _ -> None

(** ErrorCode matching [ErrorCode] in cache.zig. *)
type error_code =
  | NotFound  (** NotFound (tag 0). *)
  | TypeMismatch  (** TypeMismatch (tag 1). *)
  | OutOfMemory  (** OutOfMemory (tag 2). *)
  | KeyTooLong  (** KeyTooLong (tag 3). *)
  | ValueTooLarge  (** ValueTooLarge (tag 4). *)
  | CasConflict  (** CasConflict (tag 5). *)

let error_code_to_tag = function
  | NotFound -> 0 | TypeMismatch -> 1 | OutOfMemory -> 2
  | KeyTooLong -> 3 | ValueTooLarge -> 4 | CasConflict -> 5

let error_code_of_tag = function
  | 0 -> Some NotFound | 1 -> Some TypeMismatch | 2 -> Some OutOfMemory
  | 3 -> Some KeyTooLong | 4 -> Some ValueTooLarge
  | 5 -> Some CasConflict | _ -> None

(** ReplicationMode matching [ReplicationMode] in cache.zig. *)
type replication_mode =
  | ReplNone  (** None (tag 0). *)
  | Primary  (** Primary (tag 1). *)
  | Replica  (** Replica (tag 2). *)
  | Sentinel  (** Sentinel (tag 3). *)

let replication_mode_to_tag = function
  | ReplNone -> 0 | Primary -> 1 | Replica -> 2 | Sentinel -> 3

let replication_mode_of_tag = function
  | 0 -> Some ReplNone | 1 -> Some Primary | 2 -> Some Replica
  | 3 -> Some Sentinel | _ -> None

(* --- C FFI declarations --- *)

external c_cache_abi_version : unit -> int = "cache_abi_version"
external c_cache_create_context : unit -> int = "cache_create_context"
external c_cache_destroy_context : int -> unit = "cache_destroy_context"
external c_cache_state : int -> int = "cache_state"
external c_cache_can_transition : int -> int -> int = "cache_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_cache_abi_version ()

let create_context () = Proven_error.from_slot (c_cache_create_context ())

let destroy_context slot = c_cache_destroy_context slot

let get_state slot = replication_mode_of_tag (c_cache_state slot)

let can_transition ~from ~to_ =
  c_cache_can_transition (replication_mode_to_tag from) (replication_mode_to_tag to_) = 1
