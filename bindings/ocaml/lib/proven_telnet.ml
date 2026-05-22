(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** Telnet protocol bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-telnet/ffi/zig/src/telnet.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for telnet commands, options,
    negotiation states, and session states. *)

(** Telnet commands matching [Command] in telnet.zig. *)
type command =
  | Se | Nop | Data_mark | Break | Interrupt_process | Abort_output
  | Are_you_there | Erase_char | Erase_line | Go_ahead | Sb
  | Will | Wont | Do | Dont | Iac

(** Telnet options matching [TelnetOption] in telnet.zig. *)
type telnet_option =
  | Echo | Suppress_go_ahead | Status | Timing_mark | Terminal_type
  | Window_size | Terminal_speed | Remote_flow_control
  | Linemode | Environment

(** Telnet negotiation states matching [NegotiationState] in telnet.zig. *)
type negotiation_state = Inactive | Will_sent | Do_sent | Neg_active

(** Telnet session states matching [SessionState] in telnet.zig. *)
type session_state = Idle | Negotiating | Session_active | Subneg | Closing

(** Convert a command to its ABI tag value. *)
let command_to_tag = function
  | Se -> 0 | Nop -> 1 | Data_mark -> 2 | Break -> 3
  | Interrupt_process -> 4 | Abort_output -> 5 | Are_you_there -> 6
  | Erase_char -> 7 | Erase_line -> 8 | Go_ahead -> 9 | Sb -> 10
  | Will -> 11 | Wont -> 12 | Do -> 13 | Dont -> 14 | Iac -> 15

(** Decode a command from its ABI tag value. *)
let command_of_tag = function
  | 0 -> Some Se | 1 -> Some Nop | 2 -> Some Data_mark | 3 -> Some Break
  | 4 -> Some Interrupt_process | 5 -> Some Abort_output
  | 6 -> Some Are_you_there | 7 -> Some Erase_char | 8 -> Some Erase_line
  | 9 -> Some Go_ahead | 10 -> Some Sb | 11 -> Some Will | 12 -> Some Wont
  | 13 -> Some Do | 14 -> Some Dont | 15 -> Some Iac | _ -> None

(** Convert a telnet option to its ABI tag value. *)
let telnet_option_to_tag = function
  | Echo -> 0 | Suppress_go_ahead -> 1 | Status -> 2 | Timing_mark -> 3
  | Terminal_type -> 4 | Window_size -> 5 | Terminal_speed -> 6
  | Remote_flow_control -> 7 | Linemode -> 8 | Environment -> 9

(** Decode a telnet option from its ABI tag value. *)
let telnet_option_of_tag = function
  | 0 -> Some Echo | 1 -> Some Suppress_go_ahead | 2 -> Some Status
  | 3 -> Some Timing_mark | 4 -> Some Terminal_type | 5 -> Some Window_size
  | 6 -> Some Terminal_speed | 7 -> Some Remote_flow_control
  | 8 -> Some Linemode | 9 -> Some Environment | _ -> None

(** Convert a negotiation state to its ABI tag value. *)
let negotiation_state_to_tag = function
  | Inactive -> 0 | Will_sent -> 1 | Do_sent -> 2 | Neg_active -> 3

(** Decode a negotiation state from its ABI tag value. *)
let negotiation_state_of_tag = function
  | 0 -> Some Inactive | 1 -> Some Will_sent | 2 -> Some Do_sent
  | 3 -> Some Neg_active | _ -> None

(** Convert a session state to its ABI tag value. *)
let session_state_to_tag = function
  | Idle -> 0 | Negotiating -> 1 | Session_active -> 2
  | Subneg -> 3 | Closing -> 4

(** Decode a session state from its ABI tag value. *)
let session_state_of_tag = function
  | 0 -> Some Idle | 1 -> Some Negotiating | 2 -> Some Session_active
  | 3 -> Some Subneg | 4 -> Some Closing | _ -> None

(* --- C FFI declarations --- *)

external c_telnet_abi_version : unit -> int = "telnet_abi_version"
external c_telnet_create_context : unit -> int = "telnet_create_context"
external c_telnet_destroy_context : int -> unit = "telnet_destroy_context"
external c_telnet_can_transition : int -> int -> int = "telnet_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_telnet]. *)
let abi_version () = c_telnet_abi_version ()

(** Create a new telnet context. *)
let create_context () =
  Proven_error.from_slot (c_telnet_create_context ())

(** Destroy a telnet context, releasing its slot. *)
let destroy_context slot = c_telnet_destroy_context slot

(** Stateless query: check whether a session state transition is valid. *)
let can_transition ~from ~to_ =
  c_telnet_can_transition (session_state_to_tag from) (session_state_to_tag to_) = 1
