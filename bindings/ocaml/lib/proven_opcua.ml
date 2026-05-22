(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** OPC UA (Unified Architecture) protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-opcua/ffi/zig/src/opcua.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for service types, node classes,
    status codes, security modes, and session states. *)

(** OPC UA service types matching [ServiceType] in opcua.zig. *)
type service_type =
  | Read | Write | Browse | Subscribe | Publish | Call
  | CreateSession | ActivateSession | CloseSession
  | CreateSubscription | DeleteSubscription

(** Node classes matching [NodeClass] in opcua.zig. *)
type node_class =
  | Object | Variable | Method | ObjectType | VariableType
  | ReferenceType | DataType | View

(** Status codes matching [StatusCode] in opcua.zig. *)
type status_code =
  | Good | Uncertain | Bad | BadNodeIdUnknown | BadAttributeIdInvalid
  | BadNotReadable | BadNotWritable | BadOutOfRange | BadTypeMismatch
  | BadSessionIdInvalid | BadSubscriptionIdInvalid | BadTimeout

(** Security modes matching [SecurityMode] in opcua.zig. *)
type security_mode =
  | None | Sign | SignAndEncrypt

(** Session states matching [SessionState] in opcua.zig. *)
type session_state =
  | Idle | Connected | Created | Activated | Monitoring | Closing

(** Convert a service type to its ABI tag value. *)
let service_type_to_tag = function
  | Read -> 0 | Write -> 1 | Browse -> 2 | Subscribe -> 3 | Publish -> 4
  | Call -> 5 | CreateSession -> 6 | ActivateSession -> 7
  | CloseSession -> 8 | CreateSubscription -> 9 | DeleteSubscription -> 10

(** Decode a service type from its ABI tag value. *)
let service_type_of_tag = function
  | 0 -> Some Read | 1 -> Some Write | 2 -> Some Browse
  | 3 -> Some Subscribe | 4 -> Some Publish | 5 -> Some Call
  | 6 -> Some CreateSession | 7 -> Some ActivateSession
  | 8 -> Some CloseSession | 9 -> Some CreateSubscription
  | 10 -> Some DeleteSubscription | _ -> None

(** Convert a node class to its ABI tag value. *)
let node_class_to_tag = function
  | Object -> 0 | Variable -> 1 | Method -> 2 | ObjectType -> 3
  | VariableType -> 4 | ReferenceType -> 5 | DataType -> 6 | View -> 7

(** Decode a node class from its ABI tag value. *)
let node_class_of_tag = function
  | 0 -> Some Object | 1 -> Some Variable | 2 -> Some Method
  | 3 -> Some ObjectType | 4 -> Some VariableType
  | 5 -> Some ReferenceType | 6 -> Some DataType | 7 -> Some View
  | _ -> None

(** Convert a status code to its ABI tag value. *)
let status_code_to_tag = function
  | Good -> 0 | Uncertain -> 1 | Bad -> 2 | BadNodeIdUnknown -> 3
  | BadAttributeIdInvalid -> 4 | BadNotReadable -> 5 | BadNotWritable -> 6
  | BadOutOfRange -> 7 | BadTypeMismatch -> 8 | BadSessionIdInvalid -> 9
  | BadSubscriptionIdInvalid -> 10 | BadTimeout -> 11

(** Decode a status code from its ABI tag value. *)
let status_code_of_tag = function
  | 0 -> Some Good | 1 -> Some Uncertain | 2 -> Some Bad
  | 3 -> Some BadNodeIdUnknown | 4 -> Some BadAttributeIdInvalid
  | 5 -> Some BadNotReadable | 6 -> Some BadNotWritable
  | 7 -> Some BadOutOfRange | 8 -> Some BadTypeMismatch
  | 9 -> Some BadSessionIdInvalid | 10 -> Some BadSubscriptionIdInvalid
  | 11 -> Some BadTimeout | _ -> None

(** Convert a security mode to its ABI tag value. *)
let security_mode_to_tag = function
  | None -> 0 | Sign -> 1 | SignAndEncrypt -> 2

(** Decode a security mode from its ABI tag value. *)
let security_mode_of_tag = function
  | 0 -> Some None | 1 -> Some Sign | 2 -> Some SignAndEncrypt
  | _ -> Option.None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | Connected -> 1 | Created -> 2 | Activated -> 3
  | Monitoring -> 4 | Closing -> 5

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Connected | 2 -> Some Created
  | 3 -> Some Activated | 4 -> Some Monitoring | 5 -> Some Closing
  | _ -> None

(* --- C FFI declarations --- *)

external c_opcua_abi_version : unit -> int = "opcua_abi_version"
external c_opcua_create_context : unit -> int = "opcua_create_context"
external c_opcua_destroy_context : int -> unit = "opcua_destroy_context"
external c_opcua_can_transition : int -> int -> int = "opcua_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_opcua]. *)
let abi_version () = c_opcua_abi_version ()

(** Create a new OPC UA context in the Idle state. *)
let create_context () =
  Proven_error.from_slot (c_opcua_create_context ())

(** Destroy an OPC UA context, releasing its slot. *)
let destroy_context slot = c_opcua_destroy_context slot

(** Stateless query: check whether a lifecycle transition is valid. *)
let can_transition ~from ~to_ =
  c_opcua_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
