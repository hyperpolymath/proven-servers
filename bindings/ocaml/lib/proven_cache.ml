(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Cache (Redis/Memcached) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-cache/ffi/zig/src/cache.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for cache commands, eviction policies,
    data types, error codes, and replication modes. *)

(** Cache commands matching [Command] in cache.zig. *)
type command =
  | Get | Set | Delete | Exists | Expire | Ttl | Keys | Flush
  | Incr | Decr | Append | Prepend | Cas

(** Eviction policies matching [EvictionPolicy] in cache.zig. *)
type eviction_policy = Lru | Lfu | Random | Evict_ttl | No_eviction

(** Value data types matching [DataType] in cache.zig. *)
type data_type = String_val | Int_val | List_val | Set_val | Hash_val

(** Error codes matching [ErrorCode] in cache.zig. *)
type error_code =
  | Not_found | Type_mismatch | Out_of_memory | Key_too_long
  | Value_too_large | Cas_conflict

(** Replication modes matching [ReplicationMode] in cache.zig. *)
type replication_mode = Repl_none | Primary | Replica | Sentinel

(** Convert a [command] to its ABI tag value. *)
let command_to_tag = function
  | Get -> 0 | Set -> 1 | Delete -> 2 | Exists -> 3 | Expire -> 4
  | Ttl -> 5 | Keys -> 6 | Flush -> 7 | Incr -> 8 | Decr -> 9
  | Append -> 10 | Prepend -> 11 | Cas -> 12

(** Decode a [command] from its ABI tag value. *)
let command_of_tag = function
  | 0 -> Some Get | 1 -> Some Set | 2 -> Some Delete | 3 -> Some Exists
  | 4 -> Some Expire | 5 -> Some Ttl | 6 -> Some Keys | 7 -> Some Flush
  | 8 -> Some Incr | 9 -> Some Decr | 10 -> Some Append
  | 11 -> Some Prepend | 12 -> Some Cas | _ -> None

(** Convert an [eviction_policy] to its ABI tag value. *)
let eviction_policy_to_tag = function
  | Lru -> 0 | Lfu -> 1 | Random -> 2 | Evict_ttl -> 3 | No_eviction -> 4

(** Decode an [eviction_policy] from its ABI tag value. *)
let eviction_policy_of_tag = function
  | 0 -> Some Lru | 1 -> Some Lfu | 2 -> Some Random | 3 -> Some Evict_ttl
  | 4 -> Some No_eviction | _ -> None

(** Convert a [data_type] to its ABI tag value. *)
let data_type_to_tag = function
  | String_val -> 0 | Int_val -> 1 | List_val -> 2 | Set_val -> 3
  | Hash_val -> 4

(** Decode a [data_type] from its ABI tag value. *)
let data_type_of_tag = function
  | 0 -> Some String_val | 1 -> Some Int_val | 2 -> Some List_val
  | 3 -> Some Set_val | 4 -> Some Hash_val | _ -> None

(** Convert an [error_code] to its ABI tag value. *)
let error_code_to_tag = function
  | Not_found -> 0 | Type_mismatch -> 1 | Out_of_memory -> 2
  | Key_too_long -> 3 | Value_too_large -> 4 | Cas_conflict -> 5

(** Decode an [error_code] from its ABI tag value. *)
let error_code_of_tag = function
  | 0 -> Some Not_found | 1 -> Some Type_mismatch | 2 -> Some Out_of_memory
  | 3 -> Some Key_too_long | 4 -> Some Value_too_large
  | 5 -> Some Cas_conflict | _ -> None

(** Convert a [replication_mode] to its ABI tag value. *)
let replication_mode_to_tag = function
  | Repl_none -> 0 | Primary -> 1 | Replica -> 2 | Sentinel -> 3

(** Decode a [replication_mode] from its ABI tag value. *)
let replication_mode_of_tag = function
  | 0 -> Some Repl_none | 1 -> Some Primary | 2 -> Some Replica
  | 3 -> Some Sentinel | _ -> None

(* --- C FFI declarations --- *)

external c_cache_abi_version : unit -> int = "cache_abi_version"
external c_cache_create_context : unit -> int = "cache_create_context"
external c_cache_destroy_context : int -> unit = "cache_destroy_context"
external c_cache_can_transition : int -> int -> int = "cache_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_cache]. *)
let abi_version () = c_cache_abi_version ()

(** Create a new cache context. *)
let create_context () =
  Proven_error.from_slot (c_cache_create_context ())

(** Destroy a cache context, releasing its slot. *)
let destroy_context slot = c_cache_destroy_context slot

(** Stateless query: check whether a replication mode transition is valid. *)
let can_transition ~from ~to_ =
  c_cache_can_transition (replication_mode_to_tag from) (replication_mode_to_tag to_) = 1
