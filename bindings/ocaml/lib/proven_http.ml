(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** HTTP protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-http/ffi/zig/src/http.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for HTTP methods, versions, status codes,
    content types, header types, and request phases. *)

(** HTTP methods matching [Method] in http.zig. *)
type method_ =
  | Get | Post | Put | Delete | Patch | Head | Options | Trace | Connect

(** HTTP version matching [Version] in http.zig. *)
type version = Http10 | Http11 | Http20 | Http30

(** Status code categories matching [StatusCategory] in http.zig. *)
type status_category =
  | Informational | Success | Redirect | ClientError | ServerError

(** HTTP status codes matching [StatusCode] in http.zig. *)
type status_code =
  | Continue | SwitchingProtocols | Ok | Created | Accepted | NoContent
  | MovedPermanently | Found | NotModified | TemporaryRedirect
  | PermanentRedirect | BadRequest | Unauthorized | Forbidden | NotFound
  | MethodNotAllowed | RequestTimeout | Conflict | Gone | LengthRequired
  | PayloadTooLarge | UriTooLong | UnsupportedMedia | TooManyRequests
  | InternalError | NotImplemented | BadGateway | ServiceUnavailable
  | GatewayTimeout

(** Content types matching [ContentType] in http.zig. *)
type content_type =
  | TextPlain | TextHtml | ApplicationJson | ApplicationXml
  | ApplicationForm | MultipartForm | OctetStream | TextCss

(** Header types matching [HeaderType] in http.zig. *)
type header_type =
  | HContentType | ContentLength | Host | Connection | Accept
  | UserAgent | Server | Location | CacheControl | Custom

(** Request lifecycle phases matching [RequestPhase] in http.zig. *)
type request_phase =
  | Idle | Receiving | HeadersParsed | BodyReceiving
  | Complete | Responding | Sent

(** Convert a method to its ABI tag value. *)
let method_to_tag = function
  | Get -> 0 | Post -> 1 | Put -> 2 | Delete -> 3 | Patch -> 4
  | Head -> 5 | Options -> 6 | Trace -> 7 | Connect -> 8

(** Decode a method from its ABI tag value. *)
let method_of_tag = function
  | 0 -> Some Get | 1 -> Some Post | 2 -> Some Put | 3 -> Some Delete
  | 4 -> Some Patch | 5 -> Some Head | 6 -> Some Options | 7 -> Some Trace
  | 8 -> Some Connect | _ -> None

(** Convert a version to its ABI tag value. *)
let version_to_tag = function
  | Http10 -> 0 | Http11 -> 1 | Http20 -> 2 | Http30 -> 3

(** Decode a version from its ABI tag value. *)
let version_of_tag = function
  | 0 -> Some Http10 | 1 -> Some Http11 | 2 -> Some Http20
  | 3 -> Some Http30 | _ -> None

(** Convert a status category to its ABI tag value. *)
let status_category_to_tag = function
  | Informational -> 0 | Success -> 1 | Redirect -> 2
  | ClientError -> 3 | ServerError -> 4

(** Decode a status category from its ABI tag value. *)
let status_category_of_tag = function
  | 0 -> Some Informational | 1 -> Some Success | 2 -> Some Redirect
  | 3 -> Some ClientError | 4 -> Some ServerError | _ -> None

(** Convert a status code to its ABI tag value. *)
let status_code_to_tag = function
  | Continue -> 0 | SwitchingProtocols -> 1 | Ok -> 2 | Created -> 3
  | Accepted -> 4 | NoContent -> 5 | MovedPermanently -> 6 | Found -> 7
  | NotModified -> 8 | TemporaryRedirect -> 9 | PermanentRedirect -> 10
  | BadRequest -> 11 | Unauthorized -> 12 | Forbidden -> 13 | NotFound -> 14
  | MethodNotAllowed -> 15 | RequestTimeout -> 16 | Conflict -> 17
  | Gone -> 18 | LengthRequired -> 19 | PayloadTooLarge -> 20
  | UriTooLong -> 21 | UnsupportedMedia -> 22 | TooManyRequests -> 23
  | InternalError -> 24 | NotImplemented -> 25 | BadGateway -> 26
  | ServiceUnavailable -> 27 | GatewayTimeout -> 28

(** Decode a status code from its ABI tag value. *)
let status_code_of_tag = function
  | 0 -> Some Continue | 1 -> Some SwitchingProtocols | 2 -> Some Ok
  | 3 -> Some Created | 4 -> Some Accepted | 5 -> Some NoContent
  | 6 -> Some MovedPermanently | 7 -> Some Found | 8 -> Some NotModified
  | 9 -> Some TemporaryRedirect | 10 -> Some PermanentRedirect
  | 11 -> Some BadRequest | 12 -> Some Unauthorized | 13 -> Some Forbidden
  | 14 -> Some NotFound | 15 -> Some MethodNotAllowed
  | 16 -> Some RequestTimeout | 17 -> Some Conflict | 18 -> Some Gone
  | 19 -> Some LengthRequired | 20 -> Some PayloadTooLarge
  | 21 -> Some UriTooLong | 22 -> Some UnsupportedMedia
  | 23 -> Some TooManyRequests | 24 -> Some InternalError
  | 25 -> Some NotImplemented | 26 -> Some BadGateway
  | 27 -> Some ServiceUnavailable | 28 -> Some GatewayTimeout | _ -> None

(** Convert a content type to its ABI tag value. *)
let content_type_to_tag = function
  | TextPlain -> 0 | TextHtml -> 1 | ApplicationJson -> 2
  | ApplicationXml -> 3 | ApplicationForm -> 4 | MultipartForm -> 5
  | OctetStream -> 6 | TextCss -> 7

(** Decode a content type from its ABI tag value. *)
let content_type_of_tag = function
  | 0 -> Some TextPlain | 1 -> Some TextHtml | 2 -> Some ApplicationJson
  | 3 -> Some ApplicationXml | 4 -> Some ApplicationForm
  | 5 -> Some MultipartForm | 6 -> Some OctetStream | 7 -> Some TextCss
  | _ -> None

(** Convert a header type to its ABI tag value. *)
let header_type_to_tag = function
  | HContentType -> 0 | ContentLength -> 1 | Host -> 2 | Connection -> 3
  | Accept -> 4 | UserAgent -> 5 | Server -> 6 | Location -> 7
  | CacheControl -> 8 | Custom -> 9

(** Decode a header type from its ABI tag value. *)
let header_type_of_tag = function
  | 0 -> Some HContentType | 1 -> Some ContentLength | 2 -> Some Host
  | 3 -> Some Connection | 4 -> Some Accept | 5 -> Some UserAgent
  | 6 -> Some Server | 7 -> Some Location | 8 -> Some CacheControl
  | 9 -> Some Custom | _ -> None

(** Convert a request phase to its ABI tag value. *)
let request_phase_to_tag = function
  | Idle -> 0 | Receiving -> 1 | HeadersParsed -> 2 | BodyReceiving -> 3
  | Complete -> 4 | Responding -> 5 | Sent -> 6

(** Decode a request phase from its ABI tag value. *)
let request_phase_of_tag = function
  | 0 -> Some Idle | 1 -> Some Receiving | 2 -> Some HeadersParsed
  | 3 -> Some BodyReceiving | 4 -> Some Complete | 5 -> Some Responding
  | 6 -> Some Sent | _ -> None

(* --- C FFI declarations --- *)

external c_http_abi_version : unit -> int = "http_abi_version"
external c_http_create_context : unit -> int = "http_create_context"
external c_http_destroy_context : int -> unit = "http_destroy_context"
external c_http_can_transition : int -> int -> int = "http_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_http]. *)
let abi_version () = c_http_abi_version ()

(** Create a new HTTP context in the Idle phase. *)
let create_context () =
  Proven_error.from_slot (c_http_create_context ())

(** Destroy an HTTP context, releasing its slot. *)
let destroy_context slot = c_http_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_http_can_transition (request_phase_to_tag from) (request_phase_to_tag to_) = 1
