(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** CardDAV (RFC 6352) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-carddav/ffi/zig/src/carddav.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for property types, card methods,
    vCard versions, card errors, and server states. *)

(** vCard property types matching [PropertyType] in carddav.zig. *)
type property_type =
  | Fn_name | N | Email | Tel | Adr | Org | Photo | Url | Note

(** CardDAV methods matching [CardMethod] in carddav.zig. *)
type card_method = Get | Put | Delete | Propfind | Proppatch | Report | Mkcol

(** vCard versions matching [VCardVersion] in carddav.zig. *)
type vcard_version = Vcard3 | Vcard4

(** CardDAV error conditions matching [CardError] in carddav.zig. *)
type card_error =
  | Valid_address_data | No_resource_type | Max_resource_size | Uid_conflict
  | Supported_address_data | Precondition_failed

(** Server lifecycle states matching [ServerState] in carddav.zig. *)
type server_state = Idle | Bound | Serving | Shutdown

(** Convert a [property_type] to its ABI tag value. *)
let property_type_to_tag = function
  | Fn_name -> 0 | N -> 1 | Email -> 2 | Tel -> 3 | Adr -> 4
  | Org -> 5 | Photo -> 6 | Url -> 7 | Note -> 8

(** Decode a [property_type] from its ABI tag value. *)
let property_type_of_tag = function
  | 0 -> Some Fn_name | 1 -> Some N | 2 -> Some Email | 3 -> Some Tel
  | 4 -> Some Adr | 5 -> Some Org | 6 -> Some Photo | 7 -> Some Url
  | 8 -> Some Note | _ -> None

(** Convert a [card_method] to its ABI tag value. *)
let card_method_to_tag = function
  | Get -> 0 | Put -> 1 | Delete -> 2 | Propfind -> 3 | Proppatch -> 4
  | Report -> 5 | Mkcol -> 6

(** Decode a [card_method] from its ABI tag value. *)
let card_method_of_tag = function
  | 0 -> Some Get | 1 -> Some Put | 2 -> Some Delete | 3 -> Some Propfind
  | 4 -> Some Proppatch | 5 -> Some Report | 6 -> Some Mkcol | _ -> None

(** Convert a [vcard_version] to its ABI tag value. *)
let vcard_version_to_tag = function Vcard3 -> 0 | Vcard4 -> 1

(** Decode a [vcard_version] from its ABI tag value. *)
let vcard_version_of_tag = function
  | 0 -> Some Vcard3 | 1 -> Some Vcard4 | _ -> None

(** Convert a [card_error] to its ABI tag value. *)
let card_error_to_tag = function
  | Valid_address_data -> 0 | No_resource_type -> 1 | Max_resource_size -> 2
  | Uid_conflict -> 3 | Supported_address_data -> 4
  | Precondition_failed -> 5

(** Decode a [card_error] from its ABI tag value. *)
let card_error_of_tag = function
  | 0 -> Some Valid_address_data | 1 -> Some No_resource_type
  | 2 -> Some Max_resource_size | 3 -> Some Uid_conflict
  | 4 -> Some Supported_address_data | 5 -> Some Precondition_failed
  | _ -> None

(** Convert a [server_state] to its ABI tag value. *)
let server_state_to_tag = function
  | Idle -> 0 | Bound -> 1 | Serving -> 2 | Shutdown -> 3

(** Decode a [server_state] from its ABI tag value. *)
let server_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Bound | 2 -> Some Serving
  | 3 -> Some Shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_carddav_abi_version : unit -> int = "carddav_abi_version"
external c_carddav_create_context : unit -> int = "carddav_create_context"
external c_carddav_destroy_context : int -> unit = "carddav_destroy_context"
external c_carddav_can_transition : int -> int -> int = "carddav_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_carddav]. *)
let abi_version () = c_carddav_abi_version ()

(** Create a new CardDAV context. *)
let create_context () =
  Proven_error.from_slot (c_carddav_create_context ())

(** Destroy a CardDAV context, releasing its slot. *)
let destroy_context slot = c_carddav_destroy_context slot

(** Stateless query: check whether a server state transition is valid. *)
let can_transition ~from ~to_ =
  c_carddav_can_transition (server_state_to_tag from) (server_state_to_tag to_) = 1
