(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Semantic Web bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-semweb/ffi/zig/src/semweb.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for RDF formats, resource types,
    HTTP methods, content negotiation, and error codes. *)

(** RDF serialisation formats matching [RdfFormat] in semweb.zig. *)
type rdf_format = Rdf_xml | Turtle | N_triples | N_quads | Json_ld | Trig

(** Semantic web resource types matching [SemwebResourceType] in semweb.zig. *)
type semweb_resource_type =
  | Class | Property | Individual | Ontology | Named_graph

(** HTTP methods for Linked Data matching [HttpMethod] in semweb.zig. *)
type http_method = Get | Post | Put | Patch | Delete

(** Content negotiation preferences matching [ContentNegotiation] in semweb.zig. *)
type content_negotiation = Neg_rdf_xml | Neg_turtle | Neg_json_ld | Neg_html

(** Semantic web error codes matching [SemwebErrorCode] in semweb.zig. *)
type semweb_error_code =
  | Not_found | Invalid_uri | Malformed_rdf | Unsupported_format
  | Conflicting_triples

(** Convert an RDF format to its ABI tag value. *)
let rdf_format_to_tag = function
  | Rdf_xml -> 0 | Turtle -> 1 | N_triples -> 2
  | N_quads -> 3 | Json_ld -> 4 | Trig -> 5

(** Decode an RDF format from its ABI tag value. *)
let rdf_format_of_tag = function
  | 0 -> Some Rdf_xml | 1 -> Some Turtle | 2 -> Some N_triples
  | 3 -> Some N_quads | 4 -> Some Json_ld | 5 -> Some Trig | _ -> None

(** Convert a resource type to its ABI tag value. *)
let semweb_resource_type_to_tag = function
  | Class -> 0 | Property -> 1 | Individual -> 2
  | Ontology -> 3 | Named_graph -> 4

(** Decode a resource type from its ABI tag value. *)
let semweb_resource_type_of_tag = function
  | 0 -> Some Class | 1 -> Some Property | 2 -> Some Individual
  | 3 -> Some Ontology | 4 -> Some Named_graph | _ -> None

(** Convert an HTTP method to its ABI tag value. *)
let http_method_to_tag = function
  | Get -> 0 | Post -> 1 | Put -> 2 | Patch -> 3 | Delete -> 4

(** Decode an HTTP method from its ABI tag value. *)
let http_method_of_tag = function
  | 0 -> Some Get | 1 -> Some Post | 2 -> Some Put
  | 3 -> Some Patch | 4 -> Some Delete | _ -> None

(** Convert a content negotiation preference to its ABI tag value. *)
let content_negotiation_to_tag = function
  | Neg_rdf_xml -> 0 | Neg_turtle -> 1 | Neg_json_ld -> 2 | Neg_html -> 3

(** Decode a content negotiation preference from its ABI tag value. *)
let content_negotiation_of_tag = function
  | 0 -> Some Neg_rdf_xml | 1 -> Some Neg_turtle
  | 2 -> Some Neg_json_ld | 3 -> Some Neg_html | _ -> None

(** Convert an error code to its ABI tag value. *)
let semweb_error_code_to_tag = function
  | Not_found -> 0 | Invalid_uri -> 1 | Malformed_rdf -> 2
  | Unsupported_format -> 3 | Conflicting_triples -> 4

(** Decode an error code from its ABI tag value. *)
let semweb_error_code_of_tag = function
  | 0 -> Some Not_found | 1 -> Some Invalid_uri | 2 -> Some Malformed_rdf
  | 3 -> Some Unsupported_format | 4 -> Some Conflicting_triples | _ -> None

(* --- C FFI declarations --- *)

external c_semweb_abi_version : unit -> int = "semweb_abi_version"
external c_semweb_create_context : unit -> int = "semweb_create_context"
external c_semweb_destroy_context : int -> unit = "semweb_destroy_context"
external c_semweb_can_transition : int -> int -> int = "semweb_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_semweb]. *)
let abi_version () = c_semweb_abi_version ()

(** Create a new Semantic Web context. *)
let create_context () =
  Proven_error.from_slot (c_semweb_create_context ())

(** Destroy a Semantic Web context, releasing its slot. *)
let destroy_context slot = c_semweb_destroy_context slot

(** Stateless query: check whether a resource type transition is valid. *)
let can_transition ~from ~to_ =
  c_semweb_can_transition (semweb_resource_type_to_tag from) (semweb_resource_type_to_tag to_) = 1
