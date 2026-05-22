(* SPDX-License-Identifier: MPL-2.0 *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** PTP (Precision Time Protocol, IEEE 1588) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-ptp/ffi/zig/src/ptp.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for message types, clock classes,
    port states, and delay mechanisms. *)

(** PTP message types matching [PtpMessageType] in ptp.zig. *)
type ptp_message_type =
  | Sync | Delay_req | Pdelay_req | Pdelay_resp | Follow_up
  | Delay_resp | Pdelay_resp_follow_up | Announce | Signaling | Management

(** Clock class categories matching [ClockClass] in ptp.zig. *)
type clock_class = Primary_clock | Application_specific | Slave_only | Default_class

(** PTP port states matching [PtpPortState] in ptp.zig. *)
type ptp_port_state =
  | Initializing | Faulty | Disabled | Listening | Pre_master
  | Master | Passive | Uncalibrated | Slave

(** Delay measurement mechanisms matching [DelayMechanism] in ptp.zig. *)
type delay_mechanism = E2e | P2p | Dm_disabled

(** Convert a message type to its ABI tag value. *)
let ptp_message_type_to_tag = function
  | Sync -> 0 | Delay_req -> 1 | Pdelay_req -> 2 | Pdelay_resp -> 3
  | Follow_up -> 4 | Delay_resp -> 5 | Pdelay_resp_follow_up -> 6
  | Announce -> 7 | Signaling -> 8 | Management -> 9

(** Decode a message type from its ABI tag value. *)
let ptp_message_type_of_tag = function
  | 0 -> Some Sync | 1 -> Some Delay_req | 2 -> Some Pdelay_req
  | 3 -> Some Pdelay_resp | 4 -> Some Follow_up | 5 -> Some Delay_resp
  | 6 -> Some Pdelay_resp_follow_up | 7 -> Some Announce
  | 8 -> Some Signaling | 9 -> Some Management | _ -> None

(** Convert a clock class to its ABI tag value. *)
let clock_class_to_tag = function
  | Primary_clock -> 0 | Application_specific -> 1
  | Slave_only -> 2 | Default_class -> 3

(** Decode a clock class from its ABI tag value. *)
let clock_class_of_tag = function
  | 0 -> Some Primary_clock | 1 -> Some Application_specific
  | 2 -> Some Slave_only | 3 -> Some Default_class | _ -> None

(** Convert a port state to its ABI tag value. *)
let ptp_port_state_to_tag = function
  | Initializing -> 0 | Faulty -> 1 | Disabled -> 2 | Listening -> 3
  | Pre_master -> 4 | Master -> 5 | Passive -> 6 | Uncalibrated -> 7
  | Slave -> 8

(** Decode a port state from its ABI tag value. *)
let ptp_port_state_of_tag = function
  | 0 -> Some Initializing | 1 -> Some Faulty | 2 -> Some Disabled
  | 3 -> Some Listening | 4 -> Some Pre_master | 5 -> Some Master
  | 6 -> Some Passive | 7 -> Some Uncalibrated | 8 -> Some Slave | _ -> None

(** Convert a delay mechanism to its ABI tag value. *)
let delay_mechanism_to_tag = function
  | E2e -> 0 | P2p -> 1 | Dm_disabled -> 2

(** Decode a delay mechanism from its ABI tag value. *)
let delay_mechanism_of_tag = function
  | 0 -> Some E2e | 1 -> Some P2p | 2 -> Some Dm_disabled | _ -> None

(* --- C FFI declarations --- *)

external c_ptp_abi_version : unit -> int = "ptp_abi_version"
external c_ptp_create_context : unit -> int = "ptp_create_context"
external c_ptp_destroy_context : int -> unit = "ptp_destroy_context"
external c_ptp_can_transition : int -> int -> int = "ptp_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_ptp]. *)
let abi_version () = c_ptp_abi_version ()

(** Create a new PTP context. *)
let create_context () =
  Proven_error.from_slot (c_ptp_create_context ())

(** Destroy a PTP context, releasing its slot. *)
let destroy_context slot = c_ptp_destroy_context slot

(** Stateless query: check whether a port state transition is valid. *)
let can_transition ~from ~to_ =
  c_ptp_can_transition (ptp_port_state_to_tag from) (ptp_port_state_to_tag to_) = 1
