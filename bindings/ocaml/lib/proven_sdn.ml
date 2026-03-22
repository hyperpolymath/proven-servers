(* SPDX-License-Identifier: PMPL-1.0-or-later *)
(* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> *)

(** SDN (Software-Defined Networking) bindings for proven-servers.

    Wraps the C-ABI functions from
    [protocols/proven-sdn/ffi/zig/src/sdn.zig]. Provides OCaml variant
    types matching the Idris2 ABI enums for message types, flow actions,
    match fields, and port states. *)

(** SDN message types matching [SdnMessageType] in sdn.zig. *)
type sdn_message_type =
  | Hello | Error | Echo_request | Echo_reply
  | Features_request | Features_reply | Flow_mod | Packet_in
  | Packet_out | Port_status | Barrier_request | Barrier_reply

(** Flow actions matching [FlowAction] in sdn.zig. *)
type flow_action =
  | Output | Set_field | Drop | Push_vlan
  | Pop_vlan | Set_queue | Group

(** Match fields matching [MatchField] in sdn.zig. *)
type match_field =
  | In_port | Eth_dst | Eth_src | Eth_type | Vlan_id
  | Ip_src | Ip_dst | Tcp_src | Tcp_dst | Udp_src | Udp_dst

(** Port states matching [PortState] in sdn.zig. *)
type port_state = Up | Down | Blocked

(** Convert a message type to its ABI tag value. *)
let sdn_message_type_to_tag = function
  | Hello -> 0 | Error -> 1 | Echo_request -> 2 | Echo_reply -> 3
  | Features_request -> 4 | Features_reply -> 5 | Flow_mod -> 6
  | Packet_in -> 7 | Packet_out -> 8 | Port_status -> 9
  | Barrier_request -> 10 | Barrier_reply -> 11

(** Decode a message type from its ABI tag value. *)
let sdn_message_type_of_tag = function
  | 0 -> Some Hello | 1 -> Some Error | 2 -> Some Echo_request
  | 3 -> Some Echo_reply | 4 -> Some Features_request
  | 5 -> Some Features_reply | 6 -> Some Flow_mod | 7 -> Some Packet_in
  | 8 -> Some Packet_out | 9 -> Some Port_status
  | 10 -> Some Barrier_request | 11 -> Some Barrier_reply | _ -> None

(** Convert a flow action to its ABI tag value. *)
let flow_action_to_tag = function
  | Output -> 0 | Set_field -> 1 | Drop -> 2 | Push_vlan -> 3
  | Pop_vlan -> 4 | Set_queue -> 5 | Group -> 6

(** Decode a flow action from its ABI tag value. *)
let flow_action_of_tag = function
  | 0 -> Some Output | 1 -> Some Set_field | 2 -> Some Drop
  | 3 -> Some Push_vlan | 4 -> Some Pop_vlan | 5 -> Some Set_queue
  | 6 -> Some Group | _ -> None

(** Convert a match field to its ABI tag value. *)
let match_field_to_tag = function
  | In_port -> 0 | Eth_dst -> 1 | Eth_src -> 2 | Eth_type -> 3
  | Vlan_id -> 4 | Ip_src -> 5 | Ip_dst -> 6 | Tcp_src -> 7
  | Tcp_dst -> 8 | Udp_src -> 9 | Udp_dst -> 10

(** Decode a match field from its ABI tag value. *)
let match_field_of_tag = function
  | 0 -> Some In_port | 1 -> Some Eth_dst | 2 -> Some Eth_src
  | 3 -> Some Eth_type | 4 -> Some Vlan_id | 5 -> Some Ip_src
  | 6 -> Some Ip_dst | 7 -> Some Tcp_src | 8 -> Some Tcp_dst
  | 9 -> Some Udp_src | 10 -> Some Udp_dst | _ -> None

(** Convert a port state to its ABI tag value. *)
let port_state_to_tag = function
  | Up -> 0 | Down -> 1 | Blocked -> 2

(** Decode a port state from its ABI tag value. *)
let port_state_of_tag = function
  | 0 -> Some Up | 1 -> Some Down | 2 -> Some Blocked | _ -> None

(* --- C FFI declarations --- *)

external c_sdn_abi_version : unit -> int = "sdn_abi_version"
external c_sdn_create_context : unit -> int = "sdn_create_context"
external c_sdn_destroy_context : int -> unit = "sdn_destroy_context"
external c_sdn_can_transition : int -> int -> int = "sdn_can_transition"

(* --- Safe wrappers --- *)

(** Return the ABI version of the linked [libproven_sdn]. *)
let abi_version () = c_sdn_abi_version ()

(** Create a new SDN context. *)
let create_context () =
  Proven_error.from_slot (c_sdn_create_context ())

(** Destroy an SDN context, releasing its slot. *)
let destroy_context slot = c_sdn_destroy_context slot

(** Stateless query: check whether a port state transition is valid. *)
let can_transition ~from ~to_ =
  c_sdn_can_transition (port_state_to_tag from) (port_state_to_tag to_) = 1
