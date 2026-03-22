(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** LDAP directory protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ldap/ffi/zig/src/ldap.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for session states, operations, search
    scopes, and result codes. *)

(** Session states matching [SessionState] in ldap.zig. *)
type session_state =
  | Anonymous | Bound | Closed | Binding

(** LDAP operations matching [Operation] in ldap.zig. *)
type operation =
  | Bind | Unbind | Search | Modify | Add | Delete | ModDn
  | Compare | Abandon | Extended

(** Search scopes matching [SearchScope] in ldap.zig. *)
type search_scope =
  | BaseObject | SingleLevel | WholeSubtree

(** Result codes matching [ResultCode] in ldap.zig. *)
type result_code =
  | Success | OperationsError | ProtocolError | TimeLimitExceeded
  | SizeLimitExceeded | AuthMethodNotSupported | NoSuchObject
  | InvalidCredentials | InsufficientAccessRights | Busy | Unavailable

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Anonymous -> 0 | Bound -> 1 | Closed -> 2 | Binding -> 3

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Anonymous | 1 -> Some Bound | 2 -> Some Closed
  | 3 -> Some Binding | _ -> None

(** Convert an operation to its ABI tag value. *)
let operation_to_tag = function
  | Bind -> 0 | Unbind -> 1 | Search -> 2 | Modify -> 3 | Add -> 4
  | Delete -> 5 | ModDn -> 6 | Compare -> 7 | Abandon -> 8 | Extended -> 9

(** Decode an operation from its ABI tag value. *)
let operation_of_tag = function
  | 0 -> Some Bind | 1 -> Some Unbind | 2 -> Some Search | 3 -> Some Modify
  | 4 -> Some Add | 5 -> Some Delete | 6 -> Some ModDn | 7 -> Some Compare
  | 8 -> Some Abandon | 9 -> Some Extended | _ -> None

(** Convert a search scope to its ABI tag value. *)
let search_scope_to_tag = function
  | BaseObject -> 0 | SingleLevel -> 1 | WholeSubtree -> 2

(** Decode a search scope from its ABI tag value. *)
let search_scope_of_tag = function
  | 0 -> Some BaseObject | 1 -> Some SingleLevel | 2 -> Some WholeSubtree
  | _ -> None

(** Convert a result code to its ABI tag value. *)
let result_code_to_tag = function
  | Success -> 0 | OperationsError -> 1 | ProtocolError -> 2
  | TimeLimitExceeded -> 3 | SizeLimitExceeded -> 4
  | AuthMethodNotSupported -> 5 | NoSuchObject -> 6
  | InvalidCredentials -> 7 | InsufficientAccessRights -> 8
  | Busy -> 9 | Unavailable -> 10

(** Decode a result code from its ABI tag value. *)
let result_code_of_tag = function
  | 0 -> Some Success | 1 -> Some OperationsError | 2 -> Some ProtocolError
  | 3 -> Some TimeLimitExceeded | 4 -> Some SizeLimitExceeded
  | 5 -> Some AuthMethodNotSupported | 6 -> Some NoSuchObject
  | 7 -> Some InvalidCredentials | 8 -> Some InsufficientAccessRights
  | 9 -> Some Busy | 10 -> Some Unavailable | _ -> None

(* --- C FFI declarations --- *)

external c_ldap_abi_version : unit -> int = "ldap_abi_version"
external c_ldap_create_context : unit -> int = "ldap_create_context"
external c_ldap_destroy_context : int -> unit = "ldap_destroy_context"
external c_ldap_can_transition : int -> int -> int = "ldap_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_ldap]. *)
let abi_version () = c_ldap_abi_version ()

(** Create a new LDAP context in the Anonymous state. *)
let create_context () =
  Proven_error.from_slot (c_ldap_create_context ())

(** Destroy an LDAP context, releasing its slot. *)
let destroy_context slot = c_ldap_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_ldap_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
