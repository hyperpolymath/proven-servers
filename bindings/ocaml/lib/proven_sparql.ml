(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** SPARQL endpoint bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-sparql/ffi/zig/src/sparql.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for query types, update types,
    result formats, and error types. *)

(** SPARQL query types matching [SparqlQueryType] in sparql.zig. *)
type sparql_query_type = Select | Construct | Ask | Describe

(** SPARQL update operations matching [UpdateType] in sparql.zig. *)
type update_type = Insert | Delete | Load | Clear | Create | Drop

(** SPARQL result formats matching [ResultFormat] in sparql.zig. *)
type result_format = Xml | Json | Csv | Tsv

(** SPARQL error types matching [SparqlErrorType] in sparql.zig. *)
type sparql_error_type =
  | Parse_error | Query_timeout | Results_too_large
  | Unknown_graph | Access_denied

(** Convert a query type to its ABI tag value. *)
let sparql_query_type_to_tag = function
  | Select -> 0 | Construct -> 1 | Ask -> 2 | Describe -> 3

(** Decode a query type from its ABI tag value. *)
let sparql_query_type_of_tag = function
  | 0 -> Some Select | 1 -> Some Construct | 2 -> Some Ask
  | 3 -> Some Describe | _ -> None

(** Convert an update type to its ABI tag value. *)
let update_type_to_tag = function
  | Insert -> 0 | Delete -> 1 | Load -> 2 | Clear -> 3
  | Create -> 4 | Drop -> 5

(** Decode an update type from its ABI tag value. *)
let update_type_of_tag = function
  | 0 -> Some Insert | 1 -> Some Delete | 2 -> Some Load
  | 3 -> Some Clear | 4 -> Some Create | 5 -> Some Drop | _ -> None

(** Convert a result format to its ABI tag value. *)
let result_format_to_tag = function
  | Xml -> 0 | Json -> 1 | Csv -> 2 | Tsv -> 3

(** Decode a result format from its ABI tag value. *)
let result_format_of_tag = function
  | 0 -> Some Xml | 1 -> Some Json | 2 -> Some Csv
  | 3 -> Some Tsv | _ -> None

(** Convert an error type to its ABI tag value. *)
let sparql_error_type_to_tag = function
  | Parse_error -> 0 | Query_timeout -> 1 | Results_too_large -> 2
  | Unknown_graph -> 3 | Access_denied -> 4

(** Decode an error type from its ABI tag value. *)
let sparql_error_type_of_tag = function
  | 0 -> Some Parse_error | 1 -> Some Query_timeout
  | 2 -> Some Results_too_large | 3 -> Some Unknown_graph
  | 4 -> Some Access_denied | _ -> None

(* --- C FFI declarations --- *)

external c_sparql_abi_version : unit -> int = "sparql_abi_version"
external c_sparql_create_context : unit -> int = "sparql_create_context"
external c_sparql_destroy_context : int -> unit = "sparql_destroy_context"
external c_sparql_can_transition : int -> int -> int = "sparql_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_sparql]. *)
let abi_version () = c_sparql_abi_version ()

(** Create a new SPARQL context. *)
let create_context () =
  Proven_error.from_slot (c_sparql_create_context ())

(** Destroy a SPARQL context, releasing its slot. *)
let destroy_context slot = c_sparql_destroy_context slot

(** Stateless query: check whether a query type transition is valid. *)
let can_transition ~from ~to_ =
  c_sparql_can_transition (sparql_query_type_to_tag from) (sparql_query_type_to_tag to_) = 1
