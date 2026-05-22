(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Graph database protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-graphdb/ffi/zig/src/graphdb.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for graph element types, query
    languages, traversal strategies, and session states. *)

(** Graph element types matching [ElementType] in graphdb.zig. *)
type element_type =
  | Node | Edge | Property | Label | Index

(** Query language variants matching [QueryLanguage] in graphdb.zig. *)
type query_language =
  | Cypher | Gremlin | Sparql | GraphQl

(** Traversal strategies matching [TraversalStrategy] in graphdb.zig. *)
type traversal_strategy =
  | Bfs | Dfs | Dijkstra | AStar | Random

(** Consistency levels matching [Consistency] in graphdb.zig. *)
type consistency =
  | Strong | Eventual | Session | Causal

(** Error codes matching [ErrorCode] in graphdb.zig. *)
type error_code =
  | SyntaxError | NodeNotFound | EdgeNotFound | ConstraintViolation
  | IndexExists | TransactionConflict | OutOfMemory

(** Session lifecycle states matching [SessionState] in graphdb.zig. *)
type session_state =
  | Idle | Connected | Querying | Traversing | Disconnecting

(** Convert an element type to its ABI tag value. *)
let element_type_to_tag = function
  | Node -> 0 | Edge -> 1 | Property -> 2 | Label -> 3 | Index -> 4

(** Decode an element type from its ABI tag value. *)
let element_type_of_tag = function
  | 0 -> Some Node | 1 -> Some Edge | 2 -> Some Property
  | 3 -> Some Label | 4 -> Some Index | _ -> None

(** Convert a query language to its ABI tag value. *)
let query_language_to_tag = function
  | Cypher -> 0 | Gremlin -> 1 | Sparql -> 2 | GraphQl -> 3

(** Decode a query language from its ABI tag value. *)
let query_language_of_tag = function
  | 0 -> Some Cypher | 1 -> Some Gremlin | 2 -> Some Sparql
  | 3 -> Some GraphQl | _ -> None

(** Convert a traversal strategy to its ABI tag value. *)
let traversal_strategy_to_tag = function
  | Bfs -> 0 | Dfs -> 1 | Dijkstra -> 2 | AStar -> 3 | Random -> 4

(** Decode a traversal strategy from its ABI tag value. *)
let traversal_strategy_of_tag = function
  | 0 -> Some Bfs | 1 -> Some Dfs | 2 -> Some Dijkstra
  | 3 -> Some AStar | 4 -> Some Random | _ -> None

(** Convert a consistency level to its ABI tag value. *)
let consistency_to_tag = function
  | Strong -> 0 | Eventual -> 1 | Session -> 2 | Causal -> 3

(** Decode a consistency level from its ABI tag value. *)
let consistency_of_tag = function
  | 0 -> Some Strong | 1 -> Some Eventual | 2 -> Some Session
  | 3 -> Some Causal | _ -> None

(** Convert an error code to its ABI tag value. *)
let error_code_to_tag = function
  | SyntaxError -> 0 | NodeNotFound -> 1 | EdgeNotFound -> 2
  | ConstraintViolation -> 3 | IndexExists -> 4 | TransactionConflict -> 5
  | OutOfMemory -> 6

(** Decode an error code from its ABI tag value. *)
let error_code_of_tag = function
  | 0 -> Some SyntaxError | 1 -> Some NodeNotFound | 2 -> Some EdgeNotFound
  | 3 -> Some ConstraintViolation | 4 -> Some IndexExists
  | 5 -> Some TransactionConflict | 6 -> Some OutOfMemory | _ -> None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | Connected -> 1 | Querying -> 2 | Traversing -> 3
  | Disconnecting -> 4

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Connected | 2 -> Some Querying
  | 3 -> Some Traversing | 4 -> Some Disconnecting | _ -> None

(* --- C FFI declarations --- *)

external c_graphdb_abi_version : unit -> int = "graphdb_abi_version"
external c_graphdb_create_context : unit -> int = "graphdb_create_context"
external c_graphdb_destroy_context : int -> unit = "graphdb_destroy_context"
external c_graphdb_can_transition : int -> int -> int = "graphdb_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_graphdb]. *)
let abi_version () = c_graphdb_abi_version ()

(** Create a new graph DB context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_graphdb_create_context ())

(** Destroy a graph DB context, releasing its slot. *)
let destroy_context slot = c_graphdb_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_graphdb_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
