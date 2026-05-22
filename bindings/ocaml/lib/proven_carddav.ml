(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** CardDAV (RFC 6352) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-carddav/ffi/zig/src/carddav.zig]. *)

(** PropertyType matching [PropertyType] in carddav.zig. *)
type property_type =
  | FnName  (** FN (tag 0). *)
  | N  (** N (tag 1). *)
  | Email  (** EMAIL (tag 2). *)
  | Tel  (** TEL (tag 3). *)
  | Adr  (** ADR (tag 4). *)
  | Org  (** ORG (tag 5). *)
  | Photo  (** PHOTO (tag 6). *)
  | Url  (** URL (tag 7). *)
  | Note  (** NOTE (tag 8). *)

let property_type_to_tag = function
  | FnName -> 0 | N -> 1 | Email -> 2 | Tel -> 3 | Adr -> 4
  | Org -> 5 | Photo -> 6 | Url -> 7 | Note -> 8

let property_type_of_tag = function
  | 0 -> Some FnName | 1 -> Some N | 2 -> Some Email | 3 -> Some Tel
  | 4 -> Some Adr | 5 -> Some Org | 6 -> Some Photo | 7 -> Some Url
  | 8 -> Some Note | _ -> None

(** CardMethod matching [CardMethod] in carddav.zig. *)
type card_method =
  | Get  (** GET (tag 0). *)
  | Put  (** PUT (tag 1). *)
  | Delete  (** DELETE (tag 2). *)
  | Propfind  (** PROPFIND (tag 3). *)
  | Proppatch  (** PROPPATCH (tag 4). *)
  | Report  (** REPORT (tag 5). *)
  | Mkcol  (** MKCOL (tag 6). *)

let card_method_to_tag = function
  | Get -> 0 | Put -> 1 | Delete -> 2 | Propfind -> 3 | Proppatch -> 4
  | Report -> 5 | Mkcol -> 6

let card_method_of_tag = function
  | 0 -> Some Get | 1 -> Some Put | 2 -> Some Delete | 3 -> Some Propfind
  | 4 -> Some Proppatch | 5 -> Some Report | 6 -> Some Mkcol | _ -> None

(** VCardVersion matching [VCardVersion] in carddav.zig. *)
type vcard_version =
  | Vcard3  (** vCard 3.0 (tag 0). *)
  | Vcard4  (** vCard 4.0 (tag 1). *)

let vcard_version_to_tag = function Vcard3 -> 0 | Vcard4 -> 1

let vcard_version_of_tag = function
  | 0 -> Some Vcard3 | 1 -> Some Vcard4 | _ -> None

(** CardError matching [CardError] in carddav.zig. *)
type card_error =
  | ValidAddressData  (** ValidAddressData (tag 0). *)
  | NoResourceType  (** NoResourceType (tag 1). *)
  | MaxResourceSize  (** MaxResourceSize (tag 2). *)
  | UidConflict  (** UidConflict (tag 3). *)
  | SupportedAddressData  (** SupportedAddressData (tag 4). *)
  | PreconditionFailed  (** PreconditionFailed (tag 5). *)

let card_error_to_tag = function
  | ValidAddressData -> 0 | NoResourceType -> 1 | MaxResourceSize -> 2
  | UidConflict -> 3 | SupportedAddressData -> 4
  | PreconditionFailed -> 5

let card_error_of_tag = function
  | 0 -> Some ValidAddressData | 1 -> Some NoResourceType
  | 2 -> Some MaxResourceSize | 3 -> Some UidConflict
  | 4 -> Some SupportedAddressData | 5 -> Some PreconditionFailed
  | _ -> None

(** ServerState matching [ServerState] in carddav.zig. *)
type server_state =
  | Idle  (** Idle (tag 0). *)
  | Bound  (** Bound (tag 1). *)
  | Serving  (** Serving (tag 2). *)
  | Shutdown  (** Shutdown (tag 3). *)

let server_state_to_tag = function
  | Idle -> 0 | Bound -> 1 | Serving -> 2 | Shutdown -> 3

let server_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Bound | 2 -> Some Serving
  | 3 -> Some Shutdown | _ -> None

(* --- C FFI declarations --- *)

external c_carddav_abi_version : unit -> int = "carddav_abi_version"
external c_carddav_create_context : unit -> int = "carddav_create_context"
external c_carddav_destroy_context : int -> unit = "carddav_destroy_context"
external c_carddav_state : int -> int = "carddav_state"
external c_carddav_can_transition : int -> int -> int = "carddav_can_transition"

(* --- Safe wrappers --- *)

let abi_version () = c_carddav_abi_version ()

let create_context () = Proven_error.from_slot (c_carddav_create_context ())

let destroy_context slot = c_carddav_destroy_context slot

let get_state slot = server_state_of_tag (c_carddav_state slot)

let can_transition ~from ~to_ =
  c_carddav_can_transition (server_state_to_tag from) (server_state_to_tag to_) = 1
