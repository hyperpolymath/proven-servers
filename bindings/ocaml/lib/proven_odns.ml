(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Oblivious DNS protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-odns/ffi/zig/src/odns.zig]. Provides OCaml variant types
    matching the Idris2 ABI enums for roles, message types, error reasons,
    encapsulation formats, and session states. *)

(** ODNS roles matching [Role] in odns.zig. *)
type role =
  | Client | Proxy | Target

(** ODNS message types matching [OdnsMessageType] in odns.zig. *)
type odns_message_type =
  | Query | Response

(** ODNS error reasons matching [OdnsErrorReason] in odns.zig. *)
type odns_error_reason =
  | ProxyError | TargetError | DecryptionFailed | InvalidConfig
  | PayloadTooLarge

(** Encapsulation formats matching [EncapsulationFormat] in odns.zig. *)
type encapsulation_format =
  | Hpke

(** Session states matching [SessionState] in odns.zig. *)
type session_state =
  | Idle | KeyExchange | Ready | Processing | Closing

(** Convert a role to its ABI tag value. *)
let role_to_tag = function
  | Client -> 0 | Proxy -> 1 | Target -> 2

(** Decode a role from its ABI tag value. *)
let role_of_tag = function
  | 0 -> Some Client | 1 -> Some Proxy | 2 -> Some Target | _ -> None

(** Convert a message type to its ABI tag value. *)
let odns_message_type_to_tag = function
  | Query -> 0 | Response -> 1

(** Decode a message type from its ABI tag value. *)
let odns_message_type_of_tag = function
  | 0 -> Some Query | 1 -> Some Response | _ -> None

(** Convert an error reason to its ABI tag value. *)
let odns_error_reason_to_tag = function
  | ProxyError -> 0 | TargetError -> 1 | DecryptionFailed -> 2
  | InvalidConfig -> 3 | PayloadTooLarge -> 4

(** Decode an error reason from its ABI tag value. *)
let odns_error_reason_of_tag = function
  | 0 -> Some ProxyError | 1 -> Some TargetError
  | 2 -> Some DecryptionFailed | 3 -> Some InvalidConfig
  | 4 -> Some PayloadTooLarge | _ -> None

(** Convert an encapsulation format to its ABI tag value. *)
let encapsulation_format_to_tag = function
  | Hpke -> 0

(** Decode an encapsulation format from its ABI tag value. *)
let encapsulation_format_of_tag = function
  | 0 -> Some Hpke | _ -> None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | KeyExchange -> 1 | Ready -> 2 | Processing -> 3
  | Closing -> 4

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some KeyExchange | 2 -> Some Ready
  | 3 -> Some Processing | 4 -> Some Closing | _ -> None

(* --- C FFI declarations --- *)

external c_odns_abi_version : unit -> int = "odns_abi_version"
external c_odns_create_context : unit -> int = "odns_create_context"
external c_odns_destroy_context : int -> unit = "odns_destroy_context"
external c_odns_can_transition : int -> int -> int = "odns_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_odns]. *)
let abi_version () = c_odns_abi_version ()

(** Create a new ODNS context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_odns_create_context ())

(** Destroy an ODNS context, releasing its slot. *)
let destroy_context slot = c_odns_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_odns_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
