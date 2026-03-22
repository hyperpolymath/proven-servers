(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** WebSocket protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-websocket/ffi/zig/src/websocket.zig]. Provides OCaml
    variant types matching the Idris2 ABI enums for WebSocket opcodes and
    close codes. *)

(** WebSocket frame opcodes matching [Opcode] in websocket.zig. *)
type opcode = Continuation | Text | Binary | Close | Ping | Pong

(** WebSocket close status codes matching [CloseCode] in websocket.zig. *)
type close_code =
  | Normal | Going_away | Protocol_error | Unsupported_data
  | No_status | Abnormal | Invalid_payload | Policy_violation
  | Message_too_big | Mandatory_extension | Internal_error

(** Convert an opcode to its ABI tag value. *)
let opcode_to_tag = function
  | Continuation -> 0 | Text -> 1 | Binary -> 2
  | Close -> 3 | Ping -> 4 | Pong -> 5

(** Decode an opcode from its ABI tag value. *)
let opcode_of_tag = function
  | 0 -> Some Continuation | 1 -> Some Text | 2 -> Some Binary
  | 3 -> Some Close | 4 -> Some Ping | 5 -> Some Pong | _ -> None

(** Convert a close code to its ABI tag value. *)
let close_code_to_tag = function
  | Normal -> 0 | Going_away -> 1 | Protocol_error -> 2
  | Unsupported_data -> 3 | No_status -> 4 | Abnormal -> 5
  | Invalid_payload -> 6 | Policy_violation -> 7 | Message_too_big -> 8
  | Mandatory_extension -> 9 | Internal_error -> 10

(** Decode a close code from its ABI tag value. *)
let close_code_of_tag = function
  | 0 -> Some Normal | 1 -> Some Going_away | 2 -> Some Protocol_error
  | 3 -> Some Unsupported_data | 4 -> Some No_status | 5 -> Some Abnormal
  | 6 -> Some Invalid_payload | 7 -> Some Policy_violation
  | 8 -> Some Message_too_big | 9 -> Some Mandatory_extension
  | 10 -> Some Internal_error | _ -> None

(* --- C FFI declarations --- *)

external c_websocket_abi_version : unit -> int = "websocket_abi_version"
external c_websocket_create_context : unit -> int = "websocket_create_context"
external c_websocket_destroy_context : int -> unit = "websocket_destroy_context"
external c_websocket_can_transition : int -> int -> int = "websocket_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_websocket]. *)
let abi_version () = c_websocket_abi_version ()

(** Create a new WebSocket context. *)
let create_context () =
  Proven_error.from_slot (c_websocket_create_context ())

(** Destroy a WebSocket context, releasing its slot. *)
let destroy_context slot = c_websocket_destroy_context slot

(** Stateless query: check whether an opcode transition is valid. *)
let can_transition ~from ~to_ =
  c_websocket_can_transition (opcode_to_tag from) (opcode_to_tag to_) = 1
