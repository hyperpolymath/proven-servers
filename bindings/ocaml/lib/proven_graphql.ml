(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** GraphQL protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-graphql/ffi/zig/src/graphql.zig]. *)

(** GraphQL request lifecycle phases. *)
type graphql_phase =
  | Received  (** Request received, not yet parsed. *)
  | Parsed    (** Query parsed and validated. *)
  | Executing (** Execution in progress. *)
  | Complete  (** Execution complete, response ready. *)
  | Error     (** Error occurred. *)

(** GraphQL operation types. *)
type operation_type = Query | Mutation | Subscription

let phase_to_tag = function
  | Received -> 0 | Parsed -> 1 | Executing -> 2
  | Complete -> 3 | Error -> 4

let phase_of_tag = function
  | 0 -> Some Received | 1 -> Some Parsed | 2 -> Some Executing
  | 3 -> Some Complete | 4 -> Some Error | _ -> None

let op_type_to_tag = function
  | Query -> 0 | Mutation -> 1 | Subscription -> 2

(* --- Disabled native FFI declarations --- *)
(* Raw Zig C symbols are not OCaml primitives. All operations
   raise a clear exception until OCaml-compatible stubs exist. *)

let c_graphql_abi_version : unit -> int = fun () ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_create : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_destroy : int -> unit = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_phase : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_operation_type : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_error_category : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_advance : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_abort : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_set_query_depth : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_query_depth : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_set_complexity : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_complexity : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_resolve_field : int -> int -> int -> int = fun _arg0 _arg1 _arg2 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_fields_resolved : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_can_transition : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_sub_create : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_sub_phase : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_sub_advance : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_sub_emit_event : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_sub_abort : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_sub_event_count : int -> int = fun _arg0 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_introspection_query : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_check_depth : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()
let c_graphql_check_complexity : int -> int -> int = fun _arg0 _arg1 ->
  Proven_unavailable.raise_unavailable ()

(* --- Safe wrappers --- *)

let abi_version () = c_graphql_abi_version ()

let create op_type =
  Proven_error.from_slot (c_graphql_create (op_type_to_tag op_type))

let destroy slot = c_graphql_destroy slot
let get_phase slot = phase_of_tag (c_graphql_phase slot)
let operation_type slot = c_graphql_operation_type slot
let error_category slot = c_graphql_error_category slot
let advance slot = Proven_error.from_status (c_graphql_advance slot)
let abort slot ~err_category = Proven_error.from_status (c_graphql_abort slot err_category)

let set_query_depth slot ~depth =
  Proven_error.from_status (c_graphql_set_query_depth slot depth)

let query_depth slot = c_graphql_query_depth slot

let set_complexity slot ~score =
  Proven_error.from_status (c_graphql_set_complexity slot score)

let complexity slot = c_graphql_complexity slot

let resolve_field slot ~type_kind ~scalar_kind =
  Proven_error.from_status (c_graphql_resolve_field slot type_kind scalar_kind)

let fields_resolved slot = c_graphql_fields_resolved slot

let can_transition ~from ~to_ =
  c_graphql_can_transition (phase_to_tag from) (phase_to_tag to_) = 1

let sub_create slot = Proven_error.from_slot (c_graphql_sub_create slot)
let sub_phase slot = c_graphql_sub_phase slot
let sub_advance slot = Proven_error.from_status (c_graphql_sub_advance slot)
let sub_emit_event slot = Proven_error.from_status (c_graphql_sub_emit_event slot)
let sub_abort slot = Proven_error.from_status (c_graphql_sub_abort slot)
let sub_event_count slot = c_graphql_sub_event_count slot

let introspection_query slot ~intro_field =
  Proven_error.from_status (c_graphql_introspection_query slot intro_field)

let check_depth ~depth ~max_depth =
  c_graphql_check_depth depth max_depth = 1

let check_complexity ~score ~max_complexity =
  c_graphql_check_complexity score max_complexity = 1
