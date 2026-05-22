(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** RDF triple store bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-triplestore/ffi/zig/src/triplestore.zig]. Provides OCaml
    variant types matching the Idris2 ABI enums for statement types,
    index orders, storage backends, import formats, transaction isolation
    levels, and store states. *)

(** RDF statement types matching [Statement] in triplestore.zig. *)
type statement = Triple | Quad

(** Index orders matching [IndexOrder] in triplestore.zig. *)
type index_order = Spo | Pos | Osp | Gspo | Gpos | Gosp

(** Storage backends matching [StorageBackend] in triplestore.zig. *)
type storage_backend = In_memory | B_tree | Lsm | Persistent

(** Import formats matching [ImportFormat] in triplestore.zig. *)
type import_format = N_triples | Turtle | Rdf_xml | Json_ld | N_quads | Trig

(** Transaction isolation levels matching [TransactionIsolation] in triplestore.zig. *)
type transaction_isolation = Read_committed | Serializable | Snapshot

(** Store lifecycle states matching [StoreState] in triplestore.zig. *)
type store_state = Idle | Ready | In_transaction | Importing | Closing

(** Convert a statement type to its ABI tag value. *)
let statement_to_tag = function
  | Triple -> 0 | Quad -> 1

(** Decode a statement type from its ABI tag value. *)
let statement_of_tag = function
  | 0 -> Some Triple | 1 -> Some Quad | _ -> None

(** Convert an index order to its ABI tag value. *)
let index_order_to_tag = function
  | Spo -> 0 | Pos -> 1 | Osp -> 2 | Gspo -> 3 | Gpos -> 4 | Gosp -> 5

(** Decode an index order from its ABI tag value. *)
let index_order_of_tag = function
  | 0 -> Some Spo | 1 -> Some Pos | 2 -> Some Osp
  | 3 -> Some Gspo | 4 -> Some Gpos | 5 -> Some Gosp | _ -> None

(** Convert a storage backend to its ABI tag value. *)
let storage_backend_to_tag = function
  | In_memory -> 0 | B_tree -> 1 | Lsm -> 2 | Persistent -> 3

(** Decode a storage backend from its ABI tag value. *)
let storage_backend_of_tag = function
  | 0 -> Some In_memory | 1 -> Some B_tree | 2 -> Some Lsm
  | 3 -> Some Persistent | _ -> None

(** Convert an import format to its ABI tag value. *)
let import_format_to_tag = function
  | N_triples -> 0 | Turtle -> 1 | Rdf_xml -> 2
  | Json_ld -> 3 | N_quads -> 4 | Trig -> 5

(** Decode an import format from its ABI tag value. *)
let import_format_of_tag = function
  | 0 -> Some N_triples | 1 -> Some Turtle | 2 -> Some Rdf_xml
  | 3 -> Some Json_ld | 4 -> Some N_quads | 5 -> Some Trig | _ -> None

(** Convert a transaction isolation level to its ABI tag value. *)
let transaction_isolation_to_tag = function
  | Read_committed -> 0 | Serializable -> 1 | Snapshot -> 2

(** Decode a transaction isolation level from its ABI tag value. *)
let transaction_isolation_of_tag = function
  | 0 -> Some Read_committed | 1 -> Some Serializable
  | 2 -> Some Snapshot | _ -> None

(** Convert a store state to its ABI tag value. *)
let store_state_to_tag = function
  | Idle -> 0 | Ready -> 1 | In_transaction -> 2
  | Importing -> 3 | Closing -> 4

(** Decode a store state from its ABI tag value. *)
let store_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Ready | 2 -> Some In_transaction
  | 3 -> Some Importing | 4 -> Some Closing | _ -> None

(* --- C FFI declarations --- *)

external c_triplestore_abi_version : unit -> int = "triplestore_abi_version"
external c_triplestore_create_context : unit -> int = "triplestore_create_context"
external c_triplestore_destroy_context : int -> unit = "triplestore_destroy_context"
external c_triplestore_can_transition : int -> int -> int = "triplestore_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_triplestore]. *)
let abi_version () = c_triplestore_abi_version ()

(** Create a new triplestore context. *)
let create_context () =
  Proven_error.from_slot (c_triplestore_create_context ())

(** Destroy a triplestore context, releasing its slot. *)
let destroy_context slot = c_triplestore_destroy_context slot

(** Stateless query: check whether a store state transition is valid. *)
let can_transition ~from ~to_ =
  c_triplestore_can_transition (store_state_to_tag from) (store_state_to_tag to_) = 1
