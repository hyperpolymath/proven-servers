(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** HTTP/1.1+ protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-httpd/ffi/zig/src/httpd.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for HTTP methods, status codes,
    request phases, and versions. *)

(** HTTP request methods matching [Method] in httpd.zig. *)
type method_ =
  | GET | HEAD | POST | PUT | DELETE | CONNECT | OPTIONS | TRACE | PATCH

(** HTTP status code categories matching [StatusCode] in httpd.zig. *)
type status_code =
  | Ok_200 | Created_201 | No_content_204 | Moved_permanently_301
  | Found_302 | Not_modified_304 | Bad_request_400 | Unauthorized_401
  | Forbidden_403 | Not_found_404 | Method_not_allowed_405
  | Internal_server_error_500 | Bad_gateway_502 | Service_unavailable_503

(** HTTP request lifecycle phases matching [RequestPhase] in httpd.zig. *)
type request_phase =
  | Idle | Receiving | Headers_parsed | Body_receiving
  | Complete | Responding | Sent

(** HTTP protocol versions. *)
type version = Http10 | Http11

(** Result of feeding raw HTTP data into a context. *)
type parse_result = Parse_complete | Parse_rejected | Parse_need_more

(** Convert a method to its ABI tag value. *)
let method_to_tag = function
  | GET -> 0 | HEAD -> 1 | POST -> 2 | PUT -> 3 | DELETE -> 4
  | CONNECT -> 5 | OPTIONS -> 6 | TRACE -> 7 | PATCH -> 8

(** Decode a method from its ABI tag value. *)
let method_of_tag = function
  | 0 -> Some GET | 1 -> Some HEAD | 2 -> Some POST | 3 -> Some PUT
  | 4 -> Some DELETE | 5 -> Some CONNECT | 6 -> Some OPTIONS
  | 7 -> Some TRACE | 8 -> Some PATCH | _ -> None

(** Convert a status code to its ABI tag value. *)
let status_code_to_tag = function
  | Ok_200 -> 0 | Created_201 -> 1 | No_content_204 -> 2
  | Moved_permanently_301 -> 3 | Found_302 -> 4 | Not_modified_304 -> 5
  | Bad_request_400 -> 6 | Unauthorized_401 -> 7 | Forbidden_403 -> 8
  | Not_found_404 -> 9 | Method_not_allowed_405 -> 10
  | Internal_server_error_500 -> 11 | Bad_gateway_502 -> 12
  | Service_unavailable_503 -> 13

(** Convert a phase to its ABI tag value. *)
let phase_to_tag = function
  | Idle -> 0 | Receiving -> 1 | Headers_parsed -> 2 | Body_receiving -> 3
  | Complete -> 4 | Responding -> 5 | Sent -> 6

(** Decode a phase from its ABI tag value. *)
let phase_of_tag = function
  | 0 -> Some Idle | 1 -> Some Receiving | 2 -> Some Headers_parsed
  | 3 -> Some Body_receiving | 4 -> Some Complete | 5 -> Some Responding
  | 6 -> Some Sent | _ -> None

(** Decode a version from its ABI tag value. *)
let version_of_tag = function
  | 0 -> Some Http10 | 1 -> Some Http11 | _ -> None

(* --- C FFI declarations --- *)

external c_http_abi_version : unit -> int = "http_abi_version"
external c_http_create_context : unit -> int = "http_create_context"
external c_http_destroy_context : int -> unit = "http_destroy_context"
external c_http_parse_request : int -> int = "http_parse_request"
external c_http_get_method : int -> int = "http_get_method"
external c_http_set_status : int -> int -> int = "http_set_status"
external c_http_send_response : int -> int = "http_send_response"
external c_http_keep_alive_check : int -> int = "http_keep_alive_check"
external c_http_get_phase : int -> int = "http_get_phase"
external c_http_get_version : int -> int = "http_get_version"
external c_http_reset_context : int -> int = "http_reset_context"
external c_http_can_transition : int -> int -> int = "http_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_httpd]. *)
let abi_version () = c_http_abi_version ()

(** Create a new HTTP context in the Idle phase. *)
let create_context () =
  Proven_error.from_slot (c_http_create_context ())

(** Destroy an HTTP context, releasing its slot. *)
let destroy_context slot = c_http_destroy_context slot

(** Feed raw HTTP data into a context for parsing. *)
let parse_request slot =
  match c_http_parse_request slot with
  | 0 -> Ok Parse_complete
  | 1 -> Ok Parse_rejected
  | 2 -> Ok Parse_need_more
  | n -> Error (Proven_error.Unknown_error n)

(** Get the HTTP method of the parsed request. *)
let get_method slot = method_of_tag (c_http_get_method slot)

(** Set the response status code. *)
let set_status slot status =
  Proven_error.from_status (c_http_set_status slot (status_code_to_tag status))

(** Send the response, transitioning Responding -> Sent. *)
let send_response slot =
  Proven_error.from_status (c_http_send_response slot)

(** Check if the connection uses keep-alive. *)
let keep_alive_check slot = c_http_keep_alive_check slot = 1

(** Get the current request processing phase. *)
let get_phase slot = phase_of_tag (c_http_get_phase slot)

(** Get the HTTP version of the parsed request. *)
let get_version slot = version_of_tag (c_http_get_version slot)

(** Reset the context for keep-alive reuse (Sent -> Idle). *)
let reset_context slot =
  Proven_error.from_status (c_http_reset_context slot)

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_http_can_transition (phase_to_tag from) (phase_to_tag to_) = 1
